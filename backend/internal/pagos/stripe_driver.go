package pagos

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"strings"
	"time"

	stripe "github.com/stripe/stripe-go/v76"
	"github.com/stripe/stripe-go/v76/paymentintent"
	"github.com/stripe/stripe-go/v76/refund"
	"github.com/stripe/stripe-go/v76/webhook"
)

// StripeDriver implementa PaymentProvider contra Stripe México.
//
// Esta implementación NO maneja datos sensibles de tarjeta directamente:
// el frontend usa flutter_stripe / PaymentSheet para tokenizar y nos
// llega un payment_method_id (pm_xxx). El PCI scope queda en SAQ-A.
//
// SDK: stripe-go/v76 (https://github.com/stripe/stripe-go)
type StripeDriver struct {
	secretKey      string
	webhookSecret  string
	isLive         bool // true si sk_live_*, false si sk_test_*
	statementDesc  string // ej. "FERRETERIA DDT"
}

// NewStripeDriver crea el driver y configura la API key global de Stripe.
// Devuelve error si la key es inválida o si el webhook secret está vacío.
func NewStripeDriver(secretKey, webhookSecret string) (*StripeDriver, error) {
	secretKey = strings.TrimSpace(secretKey)
	webhookSecret = strings.TrimSpace(webhookSecret)
	if secretKey == "" {
		return nil, NewConfigError("STRIPE_SECRET_KEY vacío", nil)
	}
	if webhookSecret == "" {
		return nil, NewConfigError("STRIPE_WEBHOOK_SECRET vacío", nil)
	}
	if !strings.HasPrefix(secretKey, "sk_") {
		return nil, NewConfigError("STRIPE_SECRET_KEY no empieza con sk_", nil)
	}

	stripe.Key = secretKey

	return &StripeDriver{
		secretKey:     secretKey,
		webhookSecret: webhookSecret,
		isLive:        strings.HasPrefix(secretKey, "sk_live_"),
		statementDesc: "FERRETERIA",
	}, nil
}

// Name devuelve "stripe" — coincide con el ENUM de la columna pagos.proveedor.
func (d *StripeDriver) Name() string { return "stripe" }

// IsLive devuelve true si la API key es de producción (sk_live_*).
// Útil para validar antes de hacer cobros reales.
func (d *StripeDriver) IsLive() bool { return d.isLive }

// =============================================================================
// CreateCharge — crea un PaymentIntent y lo confirma con el payment_method.
// =============================================================================

func (d *StripeDriver) CreateCharge(ctx context.Context, req ChargeRequest) (*ChargeResponse, error) {
	if req.AmountCentavos <= 0 {
		return nil, NewConfigError("AmountCentavos debe ser > 0", nil)
	}
	if req.Currency == "" {
		req.Currency = "MXN"
	}
	if req.PaymentMethodID == "" {
		return nil, NewConfigError("PaymentMethodID es requerido (el frontend debe tokenizar primero)", nil)
	}

	params := &stripe.PaymentIntentParams{
		Amount:        stripe.Int64(req.AmountCentavos),
		Currency:      stripe.String(strings.ToLower(req.Currency)),
		Description:   stripe.String(req.Description),
		PaymentMethod: stripe.String(req.PaymentMethodID),
		Confirm:       stripe.Bool(true),
		OffSession:    stripe.Bool(false),
		// Stripe confirma inmediatamente; si requiere 3DS devolvemos
		// Status = "requires_action" con ClientSecret para que el frontend
		// complete el flujo via PaymentSheet.
		UseStripeSDK: stripe.Bool(true),
	}

	// Metadata: útil para reconciliar pagos con ventas en el dashboard de Stripe.
	if len(req.Metadata) > 0 {
		params.Metadata = make(map[string]string, len(req.Metadata))
		for k, v := range req.Metadata {
			params.Metadata[k] = v
		}
	}

	// Statement descriptor: aparece en el estado de cuenta del cliente.
	// Stripe permite hasta 22 caracteres.
	if req.StatementDescriptor != "" {
		params.StatementDescriptor = stripe.String(truncate(req.StatementDescriptor, 22))
	} else if d.statementDesc != "" {
		params.StatementDescriptor = stripe.String(d.statementDesc)
	}

	// MSIs: solo aplicar si el cliente eligió meses sin intereses.
	// Stripe México requiere que el merchant tenga MSIs habilitados en dashboard.
	if req.Installments > 1 {
		params.PaymentMethodOptions = &stripe.PaymentIntentPaymentMethodOptionsParams{
			Card: &stripe.PaymentIntentPaymentMethodOptionsCardParams{
				Installments: &stripe.PaymentIntentPaymentMethodOptionsCardInstallmentsParams{
					Enabled: stripe.Bool(true),
					Plan: &stripe.PaymentIntentPaymentMethodOptionsCardInstallmentsPlanParams{
						Count: stripe.Int64(int64(req.Installments)),
					},
				},
			},
		}
	}

	pi, err := paymentintent.New(params)
	if err != nil {
		return nil, d.translateError(err, "create_charge")
	}

	return d.paymentIntentToResponse(pi), nil
}

// =============================================================================
// GetCharge — consulta el estado actual de un PaymentIntent.
// =============================================================================

func (d *StripeDriver) GetCharge(ctx context.Context, providerRef string) (*ChargeStatus, error) {
	if providerRef == "" {
		return nil, NewConfigError("providerRef vacío", nil)
	}

	pi, err := paymentintent.Get(providerRef, nil)
	if err != nil {
		var sErr *stripe.Error
		if errors.As(err, &sErr) && sErr.Code == stripe.ErrorCodeResourceMissing {
			return nil, NewNotFoundError(providerRef, err)
		}
		return nil, d.translateError(err, "get_charge")
	}

	status := &ChargeStatus{
		ProviderRef:    pi.ID,
		Status:         mapStripeStatus(string(pi.Status)),
		AmountCentavos: pi.Amount,
		Currency:       strings.ToUpper(string(pi.Currency)),
	}
	if pi.Status == stripe.PaymentIntentStatusSucceeded && pi.LatestCharge != nil {
		paidAt := time.Unix(pi.LatestCharge.Created, 0)
		status.PaidAt = &paidAt
	}
	return status, nil
}

// =============================================================================
// Refund — reembolso total o parcial.
// =============================================================================

func (d *StripeDriver) Refund(ctx context.Context, providerRef string, amountCentavos int64) (*RefundResponse, error) {
	if providerRef == "" {
		return nil, NewConfigError("providerRef vacío", nil)
	}

	// Buscar el último charge del PaymentIntent.
	pi, err := paymentintent.Get(providerRef, nil)
	if err != nil {
		var sErr *stripe.Error
		if errors.As(err, &sErr) && sErr.Code == stripe.ErrorCodeResourceMissing {
			return nil, NewNotFoundError(providerRef, err)
		}
		return nil, d.translateError(err, "get_intent_for_refund")
	}
	if pi.LatestCharge == nil || pi.LatestCharge.ID == "" {
		return nil, NewConfigError("el PaymentIntent no tiene un charge asociado", nil)
	}

	params := &stripe.RefundParams{
		Charge: stripe.String(pi.LatestCharge.ID),
	}
	if amountCentavos > 0 {
		params.Amount = stripe.Int64(amountCentavos)
	}

	re, err := refund.New(params)
	if err != nil {
		return nil, d.translateError(err, "create_refund")
	}

	return &RefundResponse{
		RefundRef:      re.ID,
		Status:         string(re.Status),
		AmountCentavos: re.Amount,
	}, nil
}

// =============================================================================
// ParseWebhook — valida firma y convierte a WebhookEvent.
// =============================================================================

func (d *StripeDriver) ParseWebhook(payload []byte, signature string) (*WebhookEvent, error) {
	if d.webhookSecret == "" {
		return nil, NewSignatureError("STRIPE_WEBHOOK_SECRET no configurado", nil)
	}
	if signature == "" {
		return nil, NewSignatureError("header Stripe-Signature ausente", nil)
	}

	event, err := webhook.ConstructEvent(payload, signature, d.webhookSecret)
	if err != nil {
		return nil, NewSignatureError("firma inválida o payload corrupto", err)
	}

	out := &WebhookEvent{
		ReceivedAt: time.Now().UTC(),
		Raw:        payload,
	}

	switch event.Type {
	case "payment_intent.succeeded":
		out.Type = "charge.succeeded"
		out.Status = "succeeded"
		extractPaymentIntentData(event, out)

	case "payment_intent.payment_failed":
		out.Type = "charge.failed"
		out.Status = "failed"
		extractPaymentIntentData(event, out)

	case "charge.refunded":
		out.Type = "charge.refunded"
		out.Status = "refunded"
		extractChargeData(event, out)

	case "charge.failed":
		out.Type = "charge.failed"
		out.Status = "failed"
		extractChargeData(event, out)

	default:
		// Otros eventos no nos interesan; devolvemos type vacío para que el
		// handler los descarte silenciosamente (Stripe envía muchos tipos).
		slog.Info("stripe_webhook_ignored", slog.String("event_type", string(event.Type)))
		out.Type = ""
		out.Status = ""
	}

	return out, nil
}

// =============================================================================
// Helpers privados
// =============================================================================

// paymentIntentToResponse mapea un PI de Stripe a nuestro ChargeResponse.
func (d *StripeDriver) paymentIntentToResponse(pi *stripe.PaymentIntent) *ChargeResponse {
	resp := &ChargeResponse{
		ProviderRef:  pi.ID,
		Status:       mapStripeStatus(string(pi.Status)),
		ClientSecret: pi.ClientSecret,
	}

	if pi.NextAction != nil {
		resp.NextAction = &NextAction{
			Type:           string(pi.NextAction.Type),
			RedirectURL:    pi.NextAction.RedirectToURL.URL,
			SDKInstruction: "",
		}
	}

	if pi.LastPaymentError != nil {
		resp.Message = pi.LastPaymentError.Msg
	}
	return resp
}

// translateError convierte un error de stripe-go en PagoError tipado.
func (d *StripeDriver) translateError(err error, op string) error {
	var sErr *stripe.Error
	if !errors.As(err, &sErr) {
		return NewNetworkError(fmt.Sprintf("%s: error no clasificado", op), err)
	}

	// Stripe marca las tarjetas rechazadas con Type=ErrorTypeCard.
	switch sErr.Type {
	case stripe.ErrorTypeCard:
		return NewCardError(string(sErr.Code), sErr.Msg, err)
	default:
		return NewNetworkError(fmt.Sprintf("%s: %s", op, sErr.Msg), err)
	}
}

// mapStripeStatus convierte el status del PI a uno de nuestros status normalizados.
func mapStripeStatus(s string) string {
	switch stripe.PaymentIntentStatus(s) {
	case stripe.PaymentIntentStatusSucceeded:
		return "succeeded"
	case stripe.PaymentIntentStatusRequiresAction:
		return "requires_action"
	case stripe.PaymentIntentStatusProcessing:
		return "pending"
	case stripe.PaymentIntentStatusRequiresPaymentMethod:
		return "failed"
	case stripe.PaymentIntentStatusCanceled:
		return "failed"
	default:
		return "pending"
	}
}

// extractPaymentIntentData lee el ID y monto del payload de un evento
// de tipo payment_intent.* usando Data.Raw (json.RawMessage) y unmarshal
// a un PaymentIntent. La API de v76.25.0 cambió: Data.Object es un
// map[string]interface{} (no función); unmarshal directo es lo correcto.
func extractPaymentIntentData(event stripe.Event, out *WebhookEvent) {
	if len(event.Data.Raw) == 0 {
		return
	}
	var pi stripe.PaymentIntent
	if err := json.Unmarshal(event.Data.Raw, &pi); err != nil {
		slog.Warn("webhook_unmarshal_pi_failed", slog.Any("error", err))
		return
	}
	out.ProviderRef = pi.ID
	out.AmountCentavos = pi.Amount
	// Código de error si viene de un payment_failed.
	if pi.LastPaymentError != nil {
		out.FailureCode = string(pi.LastPaymentError.Code)
		out.FailureMsg = pi.LastPaymentError.Msg
	}
}

// extractChargeData equivalente para eventos charge.*.
func extractChargeData(event stripe.Event, out *WebhookEvent) {
	if len(event.Data.Raw) == 0 {
		return
	}
	var ch stripe.Charge
	if err := json.Unmarshal(event.Data.Raw, &ch); err != nil {
		slog.Warn("webhook_unmarshal_charge_failed", slog.Any("error", err))
		return
	}
	if ch.PaymentIntent != nil {
		out.ProviderRef = ch.PaymentIntent.ID
	} else {
		out.ProviderRef = ch.ID
	}
	out.AmountCentavos = ch.Amount
	if ch.FailureCode != "" {
		out.FailureCode = string(ch.FailureCode)
		out.FailureMsg = ch.FailureMessage
	}
}

func truncate(s string, max int) string {
	if len(s) <= max {
		return s
	}
	return s[:max]
}

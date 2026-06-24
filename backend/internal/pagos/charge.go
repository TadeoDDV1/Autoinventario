package pagos

import (
	"context"
	"encoding/json"
	"time"
)

// ChargeRequest es lo que el handler de caja le pasa al provider para cobrar.
//
// AmountCentavos SIEMPRE va en centavos (entero) para evitar problemas de
// precisión con float64 en dinero. Stripe México usa centavos también
// (1 peso = 100 centavos). 12.34 pesos = 1234 centavos.
type ChargeRequest struct {
	AmountCentavos      int64             // 1234 = $12.34 MXN
	Currency            string            // "MXN"
	Description         string            // "Venta V-260622-123456"
	CustomerEmail       string            // opcional, para recibo
	Metadata            map[string]string // venta_id, folio, etc
	PaymentMethodID     string            // opaco al provider (pm_xxx para Stripe)
	Installments        int               // MSIs (1 si no aplica)
	StatementDescriptor string            // 22 chars max, aparece en estado de cuenta
	IdempotencyKey      string            // para reintentos seguros (UUID)
}

// ChargeResponse es lo que el provider devuelve al backend tras crear el cargo.
//
// Status mapea a uno de:
//   - "succeeded"   → cargo aprobado, listo para persistir
//   - "requires_action" → 3DS / SCA, devolver ClientSecret al frontend
//   - "failed"      → rechazo, mostrar mensaje de error
//   - "pending"     → asíncrono (ej. SPEI esperando pago), esperar webhook
type ChargeResponse struct {
	ProviderRef  string      // ID del cargo en el provider (ch_xxx para Stripe)
	Status       string      // succeeded | requires_action | failed | pending
	ClientSecret string      // para PaymentSheet / 3DS
	NextAction   *NextAction // URL o instrucciones para el siguiente paso
	Message      string      // mensaje legible para mostrar al usuario en errores
}

// NextAction indica qué hacer si Status == "requires_action".
type NextAction struct {
	Type           string // "use_stripe_sdk" | "redirect_to_url" | "display_invoice"
	RedirectURL    string // si requiere redirección (ej. OXXO voucher)
	SDKInstruction string // instrucción opaca para el SDK del frontend
}

// ChargeStatus representa el estado actual de un cargo consultado al provider.
type ChargeStatus struct {
	ProviderRef  string
	Status       string
	AmountCentavos int64
	Currency     string
	PaidAt       *time.Time // nil si no pagado
	FailureCode  string     // código de error del provider
	FailureMsg   string
}

// RefundResponse es lo que el provider devuelve al reembolsar.
type RefundResponse struct {
	RefundRef   string // re_xxx para Stripe
	Status      string // succeeded | pending | failed
	AmountCentavos int64
}

// WebhookEvent es el evento normalizado que recibe el backend desde el provider.
// Cada provider tiene su propio formato de webhook; este es el contrato interno.
type WebhookEvent struct {
	Type          string // "charge.succeeded" | "charge.failed" | "charge.refunded"
	ProviderRef   string // ID del cargo
	Status        string // succeeded | failed | refunded
	AmountCentavos int64
	FailureCode   string
	FailureMsg    string
	ReceivedAt    time.Time
	Raw           json.RawMessage // payload original para auditoría en metadata_json
}

// =============================================================================
// Interface PaymentProvider — el contrato que todos los drivers implementan.
// =============================================================================

// PaymentProvider es el contrato que cumple Stripe, Conekta, MercadoPago, etc.
// El manager (manager.go) selecciona el driver correcto según config.
//
// Diseño:
//   - Cada driver es autónomo: registra su propia config en init() si aplica.
//   - El handler solo conoce la interface, no al provider concreto.
//   - Es seguro para uso concurrente: el manager es de solo lectura.
type PaymentProvider interface {
	// Name devuelve el identificador del provider ("stripe", "conekta", ...).
	// Debe coincidir con el ENUM de la columna pagos.proveedor.
	Name() string

	// CreateCharge crea un cargo contra el provider.
	// Devuelve un ChargeResponse con status "succeeded", "requires_action", "pending" o "failed".
	// Errores de provider se devuelven wrapped en un PagoError (ver errors.go).
	CreateCharge(ctx context.Context, req ChargeRequest) (*ChargeResponse, error)

	// GetCharge consulta el estado actual de un cargo por su referencia en el provider.
	// Útil para reconciliación o cuando el webhook se demora.
	GetCharge(ctx context.Context, providerRef string) (*ChargeStatus, error)

	// Refund reembolsa (total o parcial) un cargo aprobado.
	// amountCentavos: si es 0, reembolso total; si > 0, reembolso parcial hasta ese monto.
	Refund(ctx context.Context, providerRef string, amountCentavos int64) (*RefundResponse, error)

	// ParseWebhook valida la firma del webhook y lo convierte en un WebhookEvent normalizado.
	// La firma llega en el header del request (ej. "Stripe-Signature") y se pasa
	// como parámetro junto con el cuerpo crudo.
	ParseWebhook(payload []byte, signature string) (*WebhookEvent, error)
}

package pagos

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"strconv"

	"github.com/ferreteria/backend/internal/apperrors"
	"github.com/ferreteria/backend/internal/models"
	"github.com/ferreteria/backend/internal/repository"
	"github.com/gin-gonic/gin"
)

// Handler agrupa los endpoints REST del módulo de pagos.
type Handler struct {
	mgr   *Manager
	repo  *repository.PagoRepository
	ventas *repository.VentaRepository // para hidratar pagos con info de la venta
}

// NewHandler construye el handler. ventas puede ser nil si no se quieren listar
// pagos por venta; los endpoints de listado devolverán entonces error 501.
func NewHandler(mgr *Manager, pagos *repository.PagoRepository, ventas *repository.VentaRepository) *Handler {
	return &Handler{mgr: mgr, repo: pagos, ventas: ventas}
}

// =============================================================================
// DTOs (request/response que viaján por JSON)
// =============================================================================

// CreateChargeRequest es lo que el frontend envía para iniciar un cobro.
//
// IMPORTANTE: el frontend debe haber tokenizado la tarjeta con Stripe SDK antes,
// y nos pasa el payment_method_id resultante.
type CreateChargeRequest struct {
	Proveedor           string            `json:"proveedor"`            // "stripe" (default si vacío)
	VentaID             int64             `json:"venta_id" validate:"required"`
	AmountCentavos      int64             `json:"amount_centavos" validate:"required,gt=0"`
	Currency            string            `json:"currency"`             // "MXN" default
	Description         string            `json:"description"`
	CustomerEmail       string            `json:"customer_email"`
	PaymentMethodID     string            `json:"payment_method_id" validate:"required"`
	Installments        int               `json:"installments"`         // 1 si no aplica
	StatementDescriptor string            `json:"statement_descriptor"`
	Metadata            map[string]string `json:"metadata"`
}

// CreateChargeResponse es lo que devolvemos al frontend.
type CreateChargeResponse struct {
	PagoID       int64                  `json:"pago_id"`
	ProviderRef  string                 `json:"provider_ref"`
	Status       string                 `json:"status"`
	ClientSecret string                 `json:"client_secret,omitempty"`
	NextAction   *NextAction            `json:"next_action,omitempty"`
	Message      string                 `json:"message,omitempty"`
}

// RefundRequest: amount_centavos=0 → reembolso total.
type RefundRequest struct {
	AmountCentavos int64 `json:"amount_centavos"`
	Reason         string `json:"reason"` // "requested_by_customer" | "duplicate" | "fraudulent"
}

// =============================================================================
// POST /api/v1/pagos/charges — crea un cargo contra el provider
// =============================================================================

func (h *Handler) CreateCharge(c *gin.Context) {
	var req CreateChargeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: err.Error()})
		return
	}

	if req.Currency == "" {
		req.Currency = "MXN"
	}
	if req.Installments == 0 {
		req.Installments = 1
	}

	provider, err := h.mgr.Get(req.Proveedor)
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, models.APIError{
			Error: "PROVIDER_UNAVAILABLE", Message: err.Error(),
		})
		return
	}

	idempotencyKey := newIdempotencyKey()

	chargeReq := ChargeRequest{
		AmountCentavos:      req.AmountCentavos,
		Currency:            req.Currency,
		Description:         req.Description,
		CustomerEmail:       req.CustomerEmail,
		Metadata:            req.Metadata,
		PaymentMethodID:     req.PaymentMethodID,
		Installments:        req.Installments,
		StatementDescriptor: req.StatementDescriptor,
		IdempotencyKey:      idempotencyKey,
	}

	resp, err := provider.CreateCharge(c.Request.Context(), chargeReq)
	if err != nil {
		h.respondProviderError(c, err, "create_charge")
		return
	}

	// Determinar estado interno a partir del status del provider.
	estadoInterno := "pendiente"
	switch resp.Status {
	case "succeeded":
		estadoInterno = "aprobado"
	case "failed":
		estadoInterno = "rechazado"
	case "requires_action":
		estadoInterno = "pendiente"
	}

	pago := &repository.PagoCreate{
		VentaID:       req.VentaID,
		Proveedor:     provider.Name(),
		Referencia:    resp.ProviderRef,
		MontoCentavos: req.AmountCentavos,
		Moneda:        req.Currency,
		Estado:        estadoInterno,
		MetodoPago:    "card",
		Installments:  req.Installments,
		Ult4:          "", // se completa cuando llegue el webhook (succeeded)
		MetadataJSON:  resp.MessageAsJSON(req.Metadata),
	}
	pagoID, err := h.repo.Create(pago)
	if err != nil {
		slog.Error("pago_create_db_failed",
			slog.String("provider_ref", resp.ProviderRef),
			slog.Any("error", err))
		// El cargo en Stripe ya pasó; cobrar de nuevo sería doble cobro.
		// Devolvemos el resultado del provider igual para que el frontend sepa.
		c.JSON(http.StatusOK, CreateChargeResponse{
			ProviderRef:  resp.ProviderRef,
			Status:       resp.Status,
			ClientSecret: resp.ClientSecret,
			NextAction:   resp.NextAction,
			Message:      "Pago creado en provider pero falló registro local: " + err.Error(),
		})
		return
	}

	// Si ya fue aprobado en el primer intento, actualizar referencia_pago en ventas.
	if estadoInterno == "aprobado" && h.ventas != nil {
		_ = h.repo.UpdateVentaReferencia(req.VentaID, resp.ProviderRef)
	}

	c.JSON(http.StatusCreated, CreateChargeResponse{
		PagoID:       pagoID,
		ProviderRef:  resp.ProviderRef,
		Status:       resp.Status,
		ClientSecret: resp.ClientSecret,
		NextAction:   resp.NextAction,
		Message:      resp.Message,
	})
}

// =============================================================================
// GET /api/v1/pagos/:referencia — estado actual de un pago
// =============================================================================

func (h *Handler) GetCharge(c *gin.Context) {
	referencia := c.Param("referencia")
	if referencia == "" {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "referencia requerida"})
		return
	}

	provider, err := h.mgr.Get("")
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, models.APIError{Error: "PROVIDER_UNAVAILABLE", Message: err.Error()})
		return
	}

	status, err := provider.GetCharge(c.Request.Context(), referencia)
	if err != nil {
		h.respondProviderError(c, err, "get_charge")
		return
	}

	c.JSON(http.StatusOK, status)
}

// =============================================================================
// POST /api/v1/pagos/:referencia/refund — reembolso total o parcial
// =============================================================================

func (h *Handler) Refund(c *gin.Context) {
	referencia := c.Param("referencia")
	if referencia == "" {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "referencia requerida"})
		return
	}

	var req RefundRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: err.Error()})
		return
	}

	provider, err := h.mgr.Get("")
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, models.APIError{Error: "PROVIDER_UNAVAILABLE", Message: err.Error()})
		return
	}

	res, err := provider.Refund(c.Request.Context(), referencia, req.AmountCentavos)
	if err != nil {
		h.respondProviderError(c, err, "refund")
		return
	}

	// Marcar como reembolsado en BD (asíncrono respecto al webhook).
	if err := h.repo.UpdateEstado(referencia, "reembolsado"); err != nil {
		slog.Warn("pago_update_estado_failed",
			slog.String("referencia", referencia),
			slog.Any("error", err))
	}

	c.JSON(http.StatusOK, res)
}

// =============================================================================
// POST /api/v1/pagos/webhook — entrada ÚNICA para webhooks de cualquier provider.
// El manager rutea al driver correspondiente según el header de firma.
// =============================================================================

func (h *Handler) Webhook(c *gin.Context) {
	// Leemos el body crudo: el driver necesita el payload intacto para validar firma.
	body, err := c.GetRawData()
	if err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "no se pudo leer el body"})
		return
	}

	// Detectar provider por header de firma.
	// Stripe usa "Stripe-Signature"; Conekta usa "X-Digest"; MercadoPago usa "X-Signature".
	var providerName, signature string
	if sig := c.GetHeader("Stripe-Signature"); sig != "" {
		providerName = "stripe"
		signature = sig
	} else if sig := c.GetHeader("X-Digest"); sig != "" {
		providerName = "conekta"
		signature = sig
	} else if sig := c.GetHeader("X-Signature"); sig != "" {
		providerName = "mercadopago"
		signature = sig
	} else {
		slog.Warn("webhook_no_provider_detected",
			slog.String("path", c.Request.URL.Path),
			slog.String("remote", c.ClientIP()),
		)
		c.JSON(http.StatusBadRequest, models.APIError{Error: "NO_PROVIDER", Message: "no se detectó provider en headers"})
		return
	}

	provider, err := h.mgr.Get(providerName)
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, models.APIError{Error: "PROVIDER_UNAVAILABLE", Message: err.Error()})
		return
	}

	event, err := provider.ParseWebhook(body, signature)
	if err != nil {
		slog.Warn("webhook_parse_failed",
			slog.String("provider", providerName),
			slog.Any("error", err),
		)
		c.JSON(http.StatusBadRequest, models.APIError{Error: "WEBHOOK_INVALID", Message: err.Error()})
		return
	}

	if event.Type == "" {
		// Evento ignorado por el provider (ej. account.updated). Respondemos 200 OK
		// para que no reintenten.
		c.JSON(http.StatusOK, gin.H{"status": "ignored"})
		return
	}

	// Actualizar estado del pago en BD.
	estadoInterno := mapEstadoWebhook(event.Status)
	if estadoInterno != "" {
		if err := h.repo.UpdateEstado(event.ProviderRef, estadoInterno); err != nil {
			// Si no existe el pago todavía (webhook llegó antes que confirmemos),
			// no es error fatal: el siguiente GetCharge lo reconciliará.
			if !errors.Is(err, apperrors.ErrNotFound) {
				slog.Warn("webhook_update_estado_failed",
					slog.String("referencia", event.ProviderRef),
					slog.Any("error", err))
			}
		}
	}

	// Si el cargo se aprobó, actualizar referencia_pago en la venta.
	if event.Status == "succeeded" && h.ventas != nil {
		pago, err := h.repo.GetByReferencia(event.ProviderRef)
		if err == nil {
			_ = h.repo.UpdateVentaReferencia(pago.VentaID, event.ProviderRef)
		}
	}

	slog.Info("webhook_processed",
		slog.String("provider", providerName),
		slog.String("event_type", event.Type),
		slog.String("referencia", event.ProviderRef),
		slog.String("estado", event.Status),
	)

	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

// =============================================================================
// GET /api/v1/pagos/venta/:venta_id — lista los intentos de pago de una venta
// =============================================================================

func (h *Handler) ListByVenta(c *gin.Context) {
	ventaIDStr := c.Param("venta_id")
	ventaID, err := strconv.ParseInt(ventaIDStr, 10, 64)
	if err != nil || ventaID <= 0 {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "venta_id inválido"})
		return
	}

	pagos, err := h.repo.ListByVenta(ventaID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIError{Error: "INTERNAL_ERROR", Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"venta_id": ventaID,
		"pagos":    pagos,
	})
}

// =============================================================================
// GET /api/v1/pagos/providers — lista providers disponibles (debug + selector UI)
// =============================================================================

func (h *Handler) ListProviders(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"principal": h.mgr.Principal(),
		"disponibles": h.mgr.Available(),
	})
}

// =============================================================================
// Helpers privados
// =============================================================================

// respondProviderError mapea PagoError a HTTP status code correcto.
func (h *Handler) respondProviderError(c *gin.Context, err error, op string) {
	var pe *PagoError
	if errors.As(err, &pe) {
		switch pe.Kind {
		case ErrCard:
			c.JSON(http.StatusPaymentRequired, models.APIError{
				Error: "CARD_DECLINED", Message: pe.Message,
			})
		case ErrNetwork:
			c.JSON(http.StatusBadGateway, models.APIError{
				Error: "PROVIDER_NETWORK_ERROR", Message: pe.Message,
			})
		case ErrSignature:
			c.JSON(http.StatusUnauthorized, models.APIError{
				Error: "INVALID_SIGNATURE", Message: pe.Message,
			})
		case ErrConfig:
			c.JSON(http.StatusInternalServerError, models.APIError{
				Error: "PROVIDER_CONFIG_ERROR", Message: pe.Message,
			})
		case ErrNotFound:
			c.JSON(http.StatusNotFound, models.APIError{
				Error: "NOT_FOUND", Message: pe.Message,
			})
		default:
			c.JSON(http.StatusInternalServerError, models.APIError{
				Error: "PAYMENT_ERROR", Message: pe.Message,
			})
		}
		return
	}
	c.JSON(http.StatusInternalServerError, models.APIError{
		Error: "PAYMENT_ERROR", Message: op + ": " + err.Error(),
	})
}

func mapEstadoWebhook(providerStatus string) string {
	switch providerStatus {
	case "succeeded":
		return "aprobado"
	case "failed":
		return "rechazado"
	case "refunded":
		return "reembolsado"
	default:
		return ""
	}
}

func newIdempotencyKey() string {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "fallback-key"
	}
	return hex.EncodeToString(b)
}

// MessageAsJSON guarda el mensaje del provider como JSON crudo para metadata_json.
// Helper para no repetir el encoding en cada handler.
func (r *ChargeResponse) MessageAsJSON(meta map[string]string) json.RawMessage {
	obj := map[string]any{
		"client_secret": r.ClientSecret,
		"message":       r.Message,
	}
	if r.NextAction != nil {
		obj["next_action_type"] = r.NextAction.Type
		obj["redirect_url"] = r.NextAction.RedirectURL
	}
	if len(meta) > 0 {
		obj["metadata"] = meta
	}
	b, _ := json.Marshal(obj)
	return b
}

package ia

import (
	"errors"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/ferreteria/backend/internal/apperrors"
	"github.com/ferreteria/backend/internal/models"
	"github.com/ferreteria/backend/internal/service"
)

// SyncHandler gestiona el batch sync de ventas offline.
type SyncHandler struct {
	ventaService *service.VentaService
}

func NewSyncHandler(ventaService *service.VentaService) *SyncHandler {
	return &SyncHandler{ventaService: ventaService}
}

// VentaOfflineItem es una venta generada en modo offline, marcada con un
// client_id único para que el cliente pueda reconciliar.
type VentaOfflineItem struct {
	ClientID  string                 `json:"client_id"`  // UUID generado en el cliente
	CreatedAt time.Time              `json:"created_at"` // timestamp del cliente
	Venta     models.VentaCreate     `json:"venta"`
}

// SyncBatchRequest es el body del endpoint batch.
type SyncBatchRequest struct {
	Ventas []VentaOfflineItem `json:"ventas"`
}

// SyncBatchResponseItem es el resultado de una venta procesada.
type SyncBatchResponseItem struct {
	ClientID string `json:"client_id"`
	OK       bool   `json:"ok"`
	ID       int64  `json:"id,omitempty"`
	Folio    string `json:"folio,omitempty"`
	Error    string `json:"error,omitempty"`
}

// SyncBatchResponse es la respuesta del batch.
type SyncBatchResponse struct {
	Procesadas  int                   `json:"procesadas"`
	Fallidas    int                   `json:"fallidas"`
	Resultados  []SyncBatchResponseItem `json:"resultados"`
	ServerTime  time.Time             `json:"server_time"`
}

// SyncVentas procesa un batch de ventas pendientes del cliente offline.
// POST /api/v1/sync/ventas
//
// Estrategia: procesar una por una. Si una falla, marcarla como fallida
// pero continuar con las demás. Devolver al cliente la lista de client_id
// que se procesaron bien para que las marque como synced localmente.
func (h *SyncHandler) SyncVentas(c *gin.Context) {
	var req SyncBatchRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: err.Error()})
		return
	}

	resp := SyncBatchResponse{
		Resultados: make([]SyncBatchResponseItem, 0, len(req.Ventas)),
		ServerTime: time.Now(),
	}

	for _, item := range req.Ventas {
		result := SyncBatchResponseItem{ClientID: item.ClientID}

		// Validar que tenga client_id (es lo que usaremos para reconciliar)
		if item.ClientID == "" {
			result.OK = false
			result.Error = "client_id vacío"
			resp.Resultados = append(resp.Resultados, result)
			resp.Fallidas++
			continue
		}

		// Validar que la venta tenga items
		if len(item.Venta.Detalles) == 0 {
			result.OK = false
			result.Error = "venta sin detalles"
			resp.Resultados = append(resp.Resultados, result)
			resp.Fallidas++
			continue
		}

		// Intentar crear la venta
		id, folio, err := h.ventaService.Create(&item.Venta)
		if err != nil {
			result.OK = false
			result.Error = err.Error()
			// Si es error de stock, el detalle se preserva
			if errors.Is(err, apperrors.ErrStockInsuficiente) {
				result.Error = "STOCK_INSUFICIENTE: " + err.Error()
			}
			resp.Resultados = append(resp.Resultados, result)
			resp.Fallidas++
			continue
		}

		result.OK = true
		result.ID = id
		result.Folio = folio
		resp.Resultados = append(resp.Resultados, result)
		resp.Procesadas++
	}

	c.JSON(http.StatusOK, resp)
}

package ia

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
)

// Handler expone los endpoints HTTP del módulo IA.
type Handler struct {
	copilot       *CopilotService
	dashboard     *DashboardService
	predicciones  *PrediccionesService
	db            *sqlx.DB // referencia opcional para queries directas
}

func NewHandler(db *sqlx.DB) *Handler {
	// Cargar catálogo inicial en background-safe way
	catalogo := loadCatalogo(db)
	coOccurre := loadCoOccurrencias(db)
	copilot := NewCopilotService(catalogo, coOccurre)
	_ = coOccurre // ya quedan en el catálogo vía RefrescarCatalogo
	return &Handler{
		copilot:      copilot,
		dashboard:    NewDashboardService(db),
		predicciones: NewPrediccionesService(db),
		db:           db,
	}
}

// Copilot retorna el CopilotService para que el ChatHandler reuse su LLMClient.
func (h *Handler) Copilot() *CopilotService {
	return h.copilot
}

// RefrescarCatalogo recarga el catálogo (llamar cada N horas o por endpoint admin).
func (h *Handler) RefrescarCatalogo(db *sqlx.DB) {
	catalogo := loadCatalogo(db)
	coOccurre := loadCoOccurrencias(db)
	h.copilot.RefrescarCatalogo(catalogo)
	_ = coOccurre
}

// GetDashboardVentasHoy devuelve las ventas agregadas por hora para hoy.
// GET /api/v1/dashboard/ventas-hoy
func (h *Handler) GetDashboardVentasHoy(c *gin.Context) {
	horas, err := h.dashboard.ResumenHorasHoy(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "INTERNAL_ERROR", "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, horas)
}

// GetDashboardRecientes devuelve las últimas N ventas de hoy.
// GET /api/v1/dashboard/recientes?limit=5
func (h *Handler) GetDashboardRecientes(c *gin.Context) {
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "5"))
	if limit < 1 || limit > 50 {
		limit = 5
	}
	recientes, err := h.dashboard.ListRecientesHoy(c.Request.Context(), limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "INTERNAL_ERROR", "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, recientes)
}

// GetSugerencias devuelve sugerencias para el carrito actual.
// GET /api/v1/ia/sugerencias?carrito=1,2,3&limite=3
func (h *Handler) GetSugerencias(c *gin.Context) {
	carritoStr := c.Query("carrito")
	limite, _ := strconv.Atoi(c.DefaultQuery("limite", "3"))

	ids := make([]int, 0, 4)
	if carritoStr != "" {
		for _, part := range strings.Split(carritoStr, ",") {
			part = strings.TrimSpace(part)
			if n, err := strconv.Atoi(part); err == nil && n > 0 {
				ids = append(ids, n)
			}
		}
	}

	out := h.copilot.Sugerir(c.Request.Context(), SugerenciasInput{
		CarritoProductoIDs: ids,
		Limite:             limite,
	})
	c.JSON(http.StatusOK, out)
}

// GetDashboard devuelve el resumen ejecutivo del día.
// GET /api/v1/dashboard/resumen
func (h *Handler) GetDashboard(c *gin.Context) {
	resumen, err := h.dashboard.ResumenHoy(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "INTERNAL_ERROR", "message": err.Error()})
		return
	}

	// Adjuntar predicción de copilot para el top producto del día (insight rápido)
	if len(resumen.TopProductos) > 0 {
		sugs := h.copilot.Sugerir(c.Request.Context(), SugerenciasInput{
			CarritoProductoIDs: []int{resumen.TopProductos[0].ProductoID},
			Limite:             2,
		})
		resumen.PrediccionesCopilot = &sugs
	}

	c.JSON(http.StatusOK, resumen)
}

// GetPredicciones devuelve el análisis predictivo de inventario.
// GET /api/v1/ia/inventario/predicciones
func (h *Handler) GetPredicciones(c *gin.Context) {
	resumen, err := h.predicciones.Analizar(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "INTERNAL_ERROR", "message": err.Error()})
		return
	}

	// Si hay LLM, refinar las recomendaciones con un toque humano
	if h.copilot.llmClient != nil && h.copilot.llmClient.Disponible() {
		if refined, err := h.refinarRecomendaciones(c.Request.Context(), resumen); err == nil {
			resumen.Recomendaciones = refined
		}
	}

	c.JSON(http.StatusOK, resumen)
}

// refinarRecomendaciones pide al LLM que reescriba las recomendaciones
// en tono ejecutivo, en español, máximo 3 líneas.
func (h *Handler) refinarRecomendaciones(ctx context.Context, r *PrediccionesResumen) ([]string, error) {
	if h.copilot.llmClient == nil || !h.copilot.llmClient.Disponible() {
		return r.Recomendaciones, nil
	}

	prompt := fmt.Sprintf(
		"Genera 3-5 recomendaciones ejecutivas en español para el dueño de una ferretería, "+
			"basadas en este análisis de inventario (cada bullet debe ser conciso, una línea):\n\n"+
			"- %d productos críticos (agotarse en ≤3 días)\n"+
			"- %d productos urgentes (≤7 días)\n"+
			"- %d productos sin ventas en 30 días\n"+
			"- %d productos dormidos (60+ días sin ventas)\n"+
			"- Valor total inventario: $%.2f\n"+
			"- Valor en riesgo: $%.2f\n\n"+
			"Usa un tono profesional pero directo. Empieza cada línea con un emoji apropiado.",
		r.ProductosCriticos, r.ProductosUrgentes, r.ProductosSinVentas, r.ProductosDormidos,
		r.ValorInventario, r.ValorCritico,
	)

	body := map[string]interface{}{
		"model": h.copilot.llmClient.model,
		"messages": []map[string]string{
			{"role": "system", "content": "Eres un consultor de negocios para ferreterías. Respondes en español, conciso y directo."},
			{"role": "user", "content": prompt},
		},
		"max_tokens":  250,
		"temperature": 0.4,
	}
	jsonBody, _ := json.Marshal(body)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, h.copilot.llmClient.baseURL+"/chat/completions", bytes.NewReader(jsonBody))
	if err != nil {
		return r.Recomendaciones, err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+h.copilot.llmClient.apiKey)

	resp, err := h.copilot.llmClient.http.Do(req)
	if err != nil {
		return r.Recomendaciones, err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return r.Recomendaciones, fmt.Errorf("status %d", resp.StatusCode)
	}

	var parsed struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&parsed); err != nil {
		return r.Recomendaciones, err
	}
	if len(parsed.Choices) == 0 {
		return r.Recomendaciones, fmt.Errorf("sin choices")
	}

	raw := strings.TrimSpace(parsed.Choices[0].Message.Content)
	// Split por líneas que empiecen con "-", "•", o número seguido de punto
	lines := splitRecomendaciones(raw)
	if len(lines) == 0 {
		return r.Recomendaciones, nil
	}
	return lines, nil
}

func splitRecomendaciones(raw string) []string {
	out := make([]string, 0, 5)
	for _, line := range strings.Split(raw, "\n") {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		// Quitar bullets comunes
		for _, prefix := range []string{"- ", "• ", "* "} {
			if strings.HasPrefix(line, prefix) {
				line = strings.TrimPrefix(line, prefix)
				break
			}
		}
		// Quitar numeración "1. ", "1) "
		for i := 1; i <= 9; i++ {
			prefixes := []string{itoa(i) + ". ", itoa(i) + ") "}
			for _, p := range prefixes {
				if strings.HasPrefix(line, p) {
					line = strings.TrimPrefix(line, p)
					break
				}
			}
		}
		if line != "" {
			out = append(out, line)
		}
	}
	return out
}

// loadCatalogo trae los productos activos con sus ventas de los últimos 30 días.
func loadCatalogo(db *sqlx.DB) []ProductoCatalogo {
	if db == nil {
		return nil
	}
	rows, err := db.Query(`
		SELECT
			p.id, p.nombre, COALESCE(c.nombre, 'Sin categoría') as categoria,
			p.precio_venta, p.stock_actual, p.stock_minimo, p.activo,
			COALESCE(SUM(d.cantidad), 0) as vendidos_30d
		FROM productos p
		LEFT JOIN categorias c ON c.id = p.categoria_id
		LEFT JOIN detalle_ventas d ON d.producto_id = p.id
		LEFT JOIN ventas v ON v.id = d.venta_id
			AND v.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
		WHERE p.activo = TRUE
		GROUP BY p.id, p.nombre, c.nombre, p.precio_venta, p.stock_actual, p.stock_minimo, p.activo
	`)
	if err != nil {
		return nil
	}
	defer rows.Close()

	out := make([]ProductoCatalogo, 0, 64)
	for rows.Next() {
		var p ProductoCatalogo
		if err := rows.Scan(&p.ID, &p.Nombre, &p.Categoria, &p.Precio, &p.Stock, &p.StockMin, &p.Activo, &p.Vendidos30); err == nil {
			out = append(out, p)
		}
	}
	return out
}

// loadCoOccurrencias calcula pares de productos que se venden juntos.
// Retorna los 20 pares más frecuentes con score = co-ocurrencias / total ventas A.
func loadCoOccurrencias(db *sqlx.DB) []CoOccurrencia {
	if db == nil {
		return nil
	}
	rows, err := db.Query(`
		SELECT t1.producto_id as a, t2.producto_id as b, COUNT(*) as co_count
		FROM detalle_ventas t1
		JOIN detalle_ventas t2 ON t1.venta_id = t2.venta_id AND t1.producto_id != t2.producto_id AND t1.id < t2.id
		JOIN ventas v ON v.id = t1.venta_id
			AND v.created_at >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
		GROUP BY t1.producto_id, t2.producto_id
		HAVING co_count >= 2
		ORDER BY co_count DESC
		LIMIT 50
	`)
	if err != nil {
		return nil
	}
	defer rows.Close()

	type pairCount struct {
		a, b   int
		count  int
	}
	pairs := make([]pairCount, 0, 50)
	totalA := make(map[int]int)
	for rows.Next() {
		var p pairCount
		if err := rows.Scan(&p.a, &p.b, &p.count); err == nil {
			pairs = append(pairs, p)
			totalA[p.a]++
		}
	}

	out := make([]CoOccurrencia, 0, len(pairs))
	for _, p := range pairs {
		denom := totalA[p.a]
		if denom == 0 {
			continue
		}
		score := float64(p.count) / float64(denom)
		if score > 1.0 {
			score = 1.0
		}
		out = append(out, CoOccurrencia{ProductoA: p.a, ProductoB: p.b, Score: score})
	}
	return out
}

// Asegurar que el contexto se use (silencia warning de compilación si no se referencia)
var _ = context.Background

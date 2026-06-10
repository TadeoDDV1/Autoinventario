// Package ia implementa sugerencias inteligentes para el POS.
// Diseñado con fallback determinístico (reglas locales) que siempre funciona,
// más una capa opcional de LLM que se activa cuando IA_API_KEY está configurada.
package ia

import (
	"context"
	"log/slog"
	"os"
	"strings"
	"sync"
	"time"
)

// Sugerencia representa una recomendación para el cajero.
type Sugerencia struct {
	Tipo       string  `json:"tipo"`       // "complemento" | "sustituto" | "alerta_stock" | "upgrade"
	ProductoID int     `json:"producto_id"`
	Nombre     string  `json:"nombre"`
	Precio     float64 `json:"precio"`
	Razon      string  `json:"razon"`

	// Campos enriquecidos (cross-sell dinámico)
	Descripcion   string `json:"descripcion,omitempty"`
	Compatibles   []int  `json:"compatibles,omitempty"`
	EsSustitutoDe *int   `json:"es_sustituto_de,omitempty"`
	NivelUrgencia string `json:"nivel_urgencia,omitempty"` // bajo | medio | alto
	StockActual   int    `json:"stock_actual,omitempty"`
}

// SugerenciasInput es lo que llega al endpoint.
type SugerenciasInput struct {
	CarritoProductoIDs []int `json:"carrito_producto_ids"`
	Limite             int   `json:"limite"`
}

// SugerenciasOutput es la respuesta.
type SugerenciasOutput struct {
	Sugerencias []Sugerencia `json:"sugerencias"`
	Fuente      string       `json:"fuente"` // "reglas_locales" | "llm" | "cache"
	GeneradoEn  time.Time    `json:"generado_en"`
}

// ProductoCatalogo es la vista mínima de un producto que necesita el copilot.
type ProductoCatalogo struct {
	ID         int     `json:"id"`
	Nombre     string  `json:"nombre"`
	Categoria  string  `json:"categoria"`
	Precio     float64 `json:"precio"`
	Stock      int     `json:"stock"`
	StockMin   int     `json:"stock_minimo"`
	Activo     bool    `json:"activo"`
	Vendidos30 int     `json:"vendidos_30d"`
}

// CoOccurrencia representa productos que se venden juntos frecuentemente.
// Precomputado offline; mientras tanto se computa on-demand.
type CoOccurrencia struct {
	ProductoA int
	ProductoB int
	Score     float64 // 0-1
}

// CopilotService es la fachada principal.
type CopilotService struct {
	mu          sync.RWMutex
	catalogo    map[int]ProductoCatalogo
	coOccurre   []CoOccurrencia
	cache       map[string]cacheEntry
	llmClient   *LLMClient
	cacheTTL    time.Duration
}

type cacheEntry struct {
	output    SugerenciasOutput
	expiresAt time.Time
}

const defaultCacheTTL = 30 * time.Minute

// NewCopilotService construye el servicio. Lee IA_API_KEY del entorno;
// si está vacía, opera solo con reglas locales.
func NewCopilotService(catalogo []ProductoCatalogo, coOccurre []CoOccurrencia) *CopilotService {
	cs := &CopilotService{
		catalogo:  make(map[int]ProductoCatalogo, len(catalogo)),
		coOccurre: coOccurre,
		cache:     make(map[string]cacheEntry),
		cacheTTL:  defaultCacheTTL,
	}
	for _, p := range catalogo {
		cs.catalogo[p.ID] = p
	}

	apiKey := os.Getenv("IA_API_KEY")
	model := os.Getenv("IA_MODEL")
	if model == "" {
		model = "gpt-4o-mini"
	}
	cs.llmClient = NewLLMClient(apiKey, model, os.Getenv("IA_BASE_URL"))

	if apiKey == "" {
		slog.Info("copilot_iniciado", slog.String("modo", "reglas_locales"), slog.String("razon", "IA_API_KEY no configurada"))
	} else {
		slog.Info("copilot_iniciado", slog.String("modo", "hibrido"), slog.String("modelo", model))
	}

	return cs
}

// RefrescarCatalogo actualiza el catálogo en memoria (llamar al iniciar o cada N horas).
func (cs *CopilotService) RefrescarCatalogo(catalogo []ProductoCatalogo) {
	cs.mu.Lock()
	defer cs.mu.Unlock()
	cs.catalogo = make(map[int]ProductoCatalogo, len(catalogo))
	for _, p := range catalogo {
		cs.catalogo[p.ID] = p
	}
	cs.coOccurre = nil // invalidar co-ocurrencias
	cs.cache = make(map[string]cacheEntry)
	slog.Info("catalogo_refrescado", slog.Int("productos", len(catalogo)))
}

// Sugerir devuelve hasta `limite` sugerencias para el carrito actual.
func (cs *CopilotService) Sugerir(ctx context.Context, input SugerenciasInput) SugerenciasOutput {
	if input.Limite <= 0 || input.Limite > 5 {
		input.Limite = 3
	}

	cacheKey := buildCacheKey(input.CarritoProductoIDs, input.Limite)
	cs.mu.RLock()
	if entry, ok := cs.cache[cacheKey]; ok && time.Now().Before(entry.expiresAt) {
		cs.mu.RUnlock()
		out := entry.output
		out.Fuente = "cache"
		return out
	}
	cs.mu.RUnlock()

	// 1) Reglas determinísticas (siempre)
	sugerencias := cs.sugerenciasReglasLocales(input)

	// 2) Si hay LLM disponible y el carrito es no trivial, refinar top 1
	if cs.llmClient != nil && cs.llmClient.Disponible() && len(input.CarritoProductoIDs) > 0 {
		if refined, err := cs.refinarConLLM(ctx, sugerencias, input); err == nil && len(refined) > 0 {
			// Mantener la primera sugerencia (la más fuerte) y reemplazar la razón con la del LLM
			if len(sugerencias) > 0 && len(refined) > 0 {
				sugerencias[0].Razon = refined[0].Razon
			}
		}
	}

	out := SugerenciasOutput{
		Sugerencias: sugerencias,
		GeneradoEn:  time.Now(),
	}
	if cs.llmClient != nil && cs.llmClient.Disponible() {
		out.Fuente = "hibrido"
	} else {
		out.Fuente = "reglas_locales"
	}

	cs.mu.Lock()
	cs.cache[cacheKey] = cacheEntry{output: out, expiresAt: time.Now().Add(cs.cacheTTL)}
	cs.mu.Unlock()

	return out
}

// sugerenciasReglasLocales es el motor determinístico.
// Reglas:
//  1. Si algún producto del carrito tiene stock bajo, alertar.
//  2. Si hay co-ocurrencias fuertes con productos del carrito, sugerirlos.
//  3. Si no hay reglas, ofrecer sustituto más barato de la misma categoría.
func (cs *CopilotService) sugerenciasReglasLocales(input SugerenciasInput) []Sugerencia {
	cs.mu.RLock()
	defer cs.mu.RUnlock()

	if len(cs.catalogo) == 0 {
		return nil
	}

	carritoSet := make(map[int]bool, len(input.CarritoProductoIDs))
	for _, id := range input.CarritoProductoIDs {
		carritoSet[id] = true
	}

	sugerencias := make([]Sugerencia, 0, input.Limite)
	usados := make(map[int]bool)

	// Regla 1: alerta de stock bajo (solo si es crítico y no está en el carrito)
	for _, p := range cs.catalogo {
		if !p.Activo {
			continue
		}
		if carritoSet[p.ID] {
			continue
		}
		if p.Stock > 0 && p.Stock <= p.StockMin && usados[p.ID] == false {
			sugerencias = append(sugerencias, Sugerencia{
				Tipo:       "alerta_stock",
				ProductoID: p.ID,
				Nombre:     p.Nombre,
				Precio:     p.Precio,
				Razon:     "Stock bajo en inventario",
			})
			usados[p.ID] = true
			if len(sugerencias) >= input.Limite {
				break
			}
		}
	}

	// Regla 2: co-ocurrencias
	if len(sugerencias) < input.Limite {
		for _, co := range cs.coOccurre {
			if !carritoSet[co.ProductoA] || carritoSet[co.ProductoB] {
				continue
			}
			if usados[co.ProductoB] {
				continue
			}
			p, ok := cs.catalogo[co.ProductoB]
			if !ok || !p.Activo || p.Stock <= 0 {
				continue
			}
			sugerencias = append(sugerencias, Sugerencia{
				Tipo:       "complemento",
				ProductoID: p.ID,
				Nombre:     p.Nombre,
				Precio:     p.Precio,
				Razon:     formatRazon(co.Score, p),
			})
			usados[p.ID] = true
			if len(sugerencias) >= input.Limite {
				break
			}
		}
	}

	// Regla 3: si todavía hay espacio, ofrecer el producto más vendido que no esté en el carrito
	if len(sugerencias) < input.Limite {
		// Construir lista ordenada por vendidos
		type scored struct {
			id   int
			prod ProductoCatalogo
		}
		ranking := make([]scored, 0, len(cs.catalogo))
		for _, p := range cs.catalogo {
			if p.Activo && p.Stock > 0 && !carritoSet[p.ID] && !usados[p.ID] {
				ranking = append(ranking, scored{id: p.ID, prod: p})
			}
		}
		// Sort simple por Vendidos30 desc
		for i := 0; i < len(ranking); i++ {
			for j := i + 1; j < len(ranking); j++ {
				if ranking[j].prod.Vendidos30 > ranking[i].prod.Vendidos30 {
					ranking[i], ranking[j] = ranking[j], ranking[i]
				}
			}
		}
		for _, s := range ranking {
			if len(sugerencias) >= input.Limite {
				break
			}
			sugerencias = append(sugerencias, Sugerencia{
				Tipo:       "complemento",
				ProductoID: s.id,
				Nombre:     s.prod.Nombre,
				Precio:     s.prod.Precio,
				Razon:     "Producto popular de la tienda",
			})
			usados[s.id] = true
		}
	}

	return sugerencias
}

func formatRazon(score float64, p ProductoCatalogo) string {
	pct := int(score * 100)
	if pct < 1 {
		pct = 1
	}
	return "Comprado junto con productos similares"
}

func buildCacheKey(ids []int, limite int) string {
	parts := make([]string, 0, len(ids))
	for _, id := range ids {
		parts = append(parts, itoa(id))
	}
	// Simple join — los IDs ya están en el orden del carrito
	return strings.Join(parts, ",") + "|" + itoa(limite)
}

func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	neg := n < 0
	if neg {
		n = -n
	}
	buf := make([]byte, 0, 8)
	for n > 0 {
		buf = append([]byte{byte('0' + n%10)}, buf...)
		n /= 10
	}
	if neg {
		return "-" + string(buf)
	}
	return string(buf)
}

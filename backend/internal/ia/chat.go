package ia

import (
	"log/slog"
	"net/http"
	"regexp"
	"sort"
	"strings"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
)

// ChatRequest es lo que llega al endpoint /ia/chat.
type ChatRequest struct {
	Mensaje    string    `json:"mensaje"`
	Contexto   string    `json:"contexto,omitempty"` // "caja" | "inventario" | "general"
	Historial  []ChatMsg `json:"historial,omitempty"`
	CarritoIDs []int     `json:"carrito_ids,omitempty"`
}

// ChatMsg es un mensaje en el historial.
type ChatMsg struct {
	Rol   string `json:"rol"`   // "user" | "assistant"
	Texto string `json:"texto"`
}

// ChatResponse es lo que devuelve el endpoint.
type ChatResponse struct {
	Texto       string       `json:"texto"`
	Sugerencias []Sugerencia `json:"sugerencias,omitempty"`
	Fuente      string       `json:"fuente"`  // "reglas" | "llm" | "hibrido"
	Confianza   float64      `json:"confianza"`
	Intencion   string       `json:"intencion,omitempty"`
}

// ChatHandler gestiona el chat IA conversacional.
type ChatHandler struct {
	mu           sync.RWMutex
	iaActivo     bool
	ultimoCambio time.Time
	db           *sqlx.DB
	productos    []ProductoCatalogo
}

// NewChatHandler construye el handler. iaActivo empieza en false (reglas locales).
// Se activa via POST /ia/toggle.
func NewChatHandler(db *sqlx.DB) *ChatHandler {
	return &ChatHandler{
		iaActivo:     false,
		ultimoCambio: time.Now(),
		db:           db,
		productos:    loadCatalogo(db),
	}
}

// SetIAActivo activa o desactiva el uso de LLM.
func (h *ChatHandler) SetIAActivo(activo bool) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.iaActivo = activo
	h.ultimoCambio = time.Now()
	slog.Info("ia_toggle_changed", slog.Bool("activo", activo))
}

// GetIAActivo consulta el estado actual del toggle.
func (h *ChatHandler) GetIAActivo() bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return h.iaActivo
}

// RefrescarProductos recarga el catálogo (llamar al crear/actualizar producto).
func (h *ChatHandler) RefrescarProductos() {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.productos = loadCatalogo(h.db)
	slog.Info("chat_catalogo_refrescado", slog.Int("count", len(h.productos)))
}

// Chat procesa el mensaje y devuelve una respuesta inteligente.
//
// GET/POST /api/v1/ia/chat
// Body: { mensaje, contexto?, historial?, carrito_ids? }
func (h *ChatHandler) Chat(c *gin.Context) {
	var req ChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "BAD_REQUEST", "message": err.Error()})
		return
	}

	mensaje := strings.TrimSpace(req.Mensaje)
	if mensaje == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "BAD_REQUEST", "message": "mensaje vacío"})
		return
	}

	intencion := detectarIntencion(mensaje)
	keyword := extraerKeyword(mensaje)

	h.mu.RLock()
	productos := h.productos
	h.mu.RUnlock()

	resp := h.generarRespuesta(mensaje, intencion, keyword, productos, req.CarritoIDs)

	// Si el LLM está activo, refinar la respuesta
	h.mu.RLock()
	iaActivo := h.iaActivo
	h.mu.RUnlock()

	if iaActivo {
		// Buscar el LLMClient del copilot (que ya maneja su disponibilidad)
		if cs := GetCopilotGlobal(); cs != nil && cs.llmClient != nil && cs.llmClient.Disponible() {
			if refined, err := cs.refinarChatConLLM(c.Request.Context(), mensaje, resp.Texto); err == nil && refined != "" {
				resp.Texto = refined
				resp.Fuente = "llm"
			}
		}
	}

	c.JSON(http.StatusOK, resp)
}

// ToggleIA activa/desactiva el uso de LLM en el chat.
//
// POST /api/v1/ia/toggle
// Body: { "activo": true|false }
func (h *ChatHandler) ToggleIA(c *gin.Context) {
	var req struct {
		Activo bool `json:"activo"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "BAD_REQUEST", "message": err.Error()})
		return
	}
	h.SetIAActivo(req.Activo)
	c.JSON(http.StatusOK, gin.H{
		"activo":       req.Activo,
		"cambiado_en":  time.Now().UTC().Format(time.RFC3339),
		"mensaje":      "Estado de IA actualizado",
		"fuente_actual": fuenteActual(req.Activo),
	})
}

// GetEstado devuelve el estado actual del toggle.
//
// GET /api/v1/ia/estado
func (h *ChatHandler) GetEstado(c *gin.Context) {
	h.mu.RLock()
	activo := h.iaActivo
	cambio := h.ultimoCambio
	h.mu.RUnlock()
	c.JSON(http.StatusOK, gin.H{
		"activo":        activo,
		"cambiado_en":   cambio.UTC().Format(time.RFC3339),
		"fuente_actual": fuenteActual(activo),
		"descripcion":   "Cuando está activo y hay API key configurada, el chat usa LLM para refinar respuestas.",
	})
}

func fuenteActual(activo bool) string {
	if activo {
		return "llm (si API key configurada)"
	}
	return "reglas_locales"
}

// ── Generación de respuesta ─────────────────────────────────

func (h *ChatHandler) generarRespuesta(
	mensaje, intencion, keyword string,
	productos []ProductoCatalogo,
	carritoIDs []int,
) ChatResponse {
	resp := ChatResponse{Fuente: "reglas", Confianza: 0.7}

	switch intencion {
	case "recomendar":
		resp.Texto, resp.Sugerencias = h.responderRecomendacion(keyword, productos)
		resp.Intencion = "recomendar"
		resp.Confianza = 0.8
	case "para_que_sirve":
		resp.Texto = h.responderUsoProducto(keyword)
		resp.Intencion = "para_que_sirve"
		resp.Confianza = 0.85
	case "comparar":
		resp.Texto = h.responderComparacion(keyword, mensaje)
		resp.Intencion = "comparar"
		resp.Confianza = 0.7
	case "sustituto":
		resp.Texto, resp.Sugerencias = h.responderSustituto(keyword, productos)
		resp.Intencion = "sustituto"
		resp.Confianza = 0.75
	case "complemento":
		resp.Texto, resp.Sugerencias = h.responderComplemento(keyword, productos)
		resp.Intencion = "complemento"
		resp.Confianza = 0.8
	case "stock":
		resp.Texto, resp.Sugerencias = h.responderStock(mensaje, productos)
		resp.Intencion = "stock"
		resp.Confianza = 0.8
	case "ayuda":
		resp.Texto = responderAyuda()
		resp.Intencion = "ayuda"
		resp.Confianza = 1.0
	default:
		// Saludo o pregunta no entendida
		if esSaludo(mensaje) {
			resp.Texto = "¡Hola! 👋 Soy tu asistente de ferretería. Puedo ayudarte con:\n\n" +
				"• Recomendar productos complementarios\n" +
				"• Explicar para qué sirve un producto\n" +
				"• Sugerir sustitutos más baratos\n" +
				"• Avisarte sobre stock bajo\n\n" +
				"Pregúntame algo como: *\"¿qué le ofrezco a alguien que compra un taladro?\"*"
			resp.Confianza = 1.0
			resp.Intencion = "saludo"
		} else {
			resp.Texto = "No estoy seguro de entender. Pregúntame cosas como:\n\n" +
				"• *\"¿qué vendo junto con un taladro?\"*\n" +
				"• *\"¿para qué sirve el teflón?\"*\n" +
				"• *\"¿qué alternativas hay al PVC?\"*\n" +
				"• *\"¿qué está por agotarse?\"*\n\n" +
				"O escribe **ayuda** para ver todo lo que puedo hacer."
			resp.Confianza = 0.5
			resp.Intencion = "desconocida"
		}
	}

	return resp
}

// ── Respuestas por intención ─────────────────────────────────

func (h *ChatHandler) responderRecomendacion(keyword string, productos []ProductoCatalogo) (string, []Sugerencia) {
	prod := GetProductoConocimiento(keyword)
	if prod == nil {
		// Intentar por categoría
		cat := GetCategoriaPorKeyword(keyword)
		if cat != "" {
			cc := GetCategoriaConocimiento(cat)
			if cc != nil {
				compatibles := cc.Necesita
				texto := "💡 Para alguien que lleva productos de **" + cat + "** típicamente se ofrece:\n\n"
				for i, c := range compatibles {
					if i >= 5 {
						break
					}
					texto += "• " + c + "\n"
				}
				texto += "\n¿Quieres que te busque alguno en el inventario?"
				return texto, buscarProductosPorNombre(compatibles, productos, 3)
			}
		}
		return "🤔 No reconocí ese producto. ¿Me lo describes de otra forma? " +
			"Por ejemplo: *taladro*, *cemento*, *cinta aislante*...", nil
	}

	texto := "🎯 Para alguien que compra un **" + prod.Nombre + "** te recomiendo ofrecerle:\n\n"
	for _, c := range prod.Compatibles {
		texto += "• " + c + "\n"
	}
	if len(prod.Usos) > 0 {
		texto += "\n**Usos comunes:**\n"
		for _, u := range prod.Usos {
			texto += "• " + u + "\n"
		}
	}
	texto += "\n¿Quieres agregar alguno al carrito? Toca los productos de abajo 👇"

	sugs := buscarProductosPorNombre(prod.Compatibles, productos, 3)
	return texto, sugs
}

func (h *ChatHandler) responderUsoProducto(keyword string) string {
	prod := GetProductoConocimiento(keyword)
	if prod == nil {
		cat := GetCategoriaPorKeyword(keyword)
		if cat != "" {
			cc := GetCategoriaConocimiento(cat)
			return "📚 **" + cat + "**\n\n" + cc.Descripcion
		}
		return "🤔 No sé qué es '" + keyword + "'. Prueba con: *taladro*, *cemento*, *PVC*, *teflón*..."
	}

	texto := "🔍 **" + prod.Nombre + "**\n\n"
	texto += prod.Descripcion + "\n"
	if len(prod.Usos) > 0 {
		texto += "\n**Usos principales:**\n"
		for _, u := range prod.Usos {
			texto += "• " + u + "\n"
		}
	}
	if len(prod.Compatibles) > 0 {
		texto += "\n**Se usa con:** " + strings.Join(prod.Compatibles, ", ")
	}
	if len(prod.Sustitutos) > 0 {
		texto += "\n\n**Alternativas:** " + strings.Join(prod.Sustitutos, ", ")
	}
	return texto
}

func (h *ChatHandler) responderComparacion(keyword, mensaje string) string {
	// Buscar dos productos en el mensaje
	productos := []string{}
	for key := range RelacionesProducto {
		if contains(normalizeKeyword(mensaje), key) {
			productos = append(productos, key)
		}
	}
	if len(productos) < 2 {
		return "🤔 Para comparar necesito que menciones dos productos. " +
			"Por ejemplo: *\"¿qué diferencia hay entre PVC y CPVC?\"*"
	}
	p1 := GetProductoConocimiento(productos[0])
	p2 := GetProductoConocimiento(productos[1])
	if p1 == nil || p2 == nil {
		return "🤔 No conozco ambos productos lo suficiente para compararlos."
	}
	texto := "⚖️ **" + p1.Nombre + " vs " + p2.Nombre + "**\n\n"
	texto += "**" + p1.Nombre + ":**\n" + p1.Descripcion + "\n\n"
	texto += "**" + p2.Nombre + ":**\n" + p2.Descripcion + "\n"
	if len(p1.Usos) > 0 && len(p2.Usos) > 0 {
		texto += "\n**" + p1.Nombre + "** se usa para: " + strings.Join(p1.Usos, ", ") + "\n"
		texto += "**" + p2.Nombre + "** se usa para: " + strings.Join(p2.Usos, ", ")
	}
	return texto
}

func (h *ChatHandler) responderSustituto(keyword string, productos []ProductoCatalogo) (string, []Sugerencia) {
	prod := GetProductoConocimiento(keyword)
	if prod == nil {
		return "🤔 No conozco '" + keyword + "' para buscar alternativas. " +
			"Prueba con: *taladro*, *PVC*, *cemento*...", nil
	}
	if len(prod.Sustitutos) == 0 {
		return "ℹ️ **" + prod.Nombre + "** no tiene sustitutos registrados en mi base.", nil
	}
	texto := "🔄 **Alternativas a " + prod.Nombre + "**\n\n"
	for _, s := range prod.Sustitutos {
		texto += "• " + s + "\n"
	}
	texto += "\nToca abajo para agregarlos al carrito 👇"
	sugs := buscarProductosPorNombre(prod.Sustitutos, productos, 3)
	return texto, sugs
}

func (h *ChatHandler) responderComplemento(keyword string, productos []ProductoCatalogo) (string, []Sugerencia) {
	// "complemento" o "junto con" → reusar logica de recomendación
	return h.responderRecomendacion(keyword, productos)
}

func (h *ChatHandler) responderStock(mensaje string, productos []ProductoCatalogo) (string, []Sugerencia) {
	// Detectar si pregunta por "stock bajo" o por un producto específico
	if contains(normalizeKeyword(mensaje), "bajo") || contains(normalizeKeyword(mensaje), "agotar") {
		bajos := make([]ProductoCatalogo, 0)
		for _, p := range productos {
			if p.Activo && p.Stock > 0 && p.Stock <= p.StockMin {
				bajos = append(bajos, p)
			}
		}
		sort.Slice(bajos, func(i, j int) bool {
			return bajos[i].Stock < bajos[j].Stock
		})
		if len(bajos) == 0 {
			return "✅ No hay productos con stock bajo en este momento.", nil
		}
		texto := "⚠️ **Productos con stock bajo** (" + itoa(len(bajos)) + ")\n\n"
		max := 10
		if len(bajos) < max {
			max = len(bajos)
		}
		sugs := make([]Sugerencia, 0, max)
		for i := 0; i < max; i++ {
			p := bajos[i]
			texto += "• " + p.Nombre + " — stock: " + itoa(p.Stock) + " / mín: " + itoa(p.StockMin) + "\n"
			sugs = append(sugs, Sugerencia{
				Tipo:          "alerta_stock",
				ProductoID:    p.ID,
				Nombre:        p.Nombre,
				Precio:        p.Precio,
				Razon:         "Stock bajo: " + itoa(p.Stock) + " unidades",
				StockActual:   p.Stock,
				NivelUrgencia: "alto",
			})
		}
		return texto, sugs
	}
	// Búsqueda por nombre: usar keyword extraído del mensaje
	kw := extraerKeyword(mensaje)
	if kw == "" {
		return "🤔 No encontré productos para tu búsqueda.", nil
	}
	encontrados := buscarProductosPorNombre([]string{kw}, productos, 5)
	if len(encontrados) == 0 {
		return "🤔 No encontré '" + kw + "' en el inventario.", nil
	}
	texto := "🔎 **" + kw + "** en inventario:\n\n"
	for _, s := range encontrados {
		texto += "• " + s.Nombre + " — $" + floatToStr(s.Precio) + "\n"
	}
	return texto, encontrados
}

func responderAyuda() string {
	return "🛠️ **Lo que puedo hacer**\n\n" +
		"**Recomendaciones**\n" +
		"• *\"¿qué le ofrezco a alguien que compra un taladro?\"*\n" +
		"• *\"¿qué vendo junto con pintura?\"*\n\n" +
		"**Información de productos**\n" +
		"• *\"¿para qué sirve el teflón?\"*\n" +
		"• *\"¿qué diferencia hay entre PVC y CPVC?\"*\n" +
		"• *\"¿qué alternativas hay al cemento?\"*\n\n" +
		"**Inventario**\n" +
		"• *\"¿qué está por agotarse?\"*\n" +
		"• *\"¿cuánto stock tengo de brocas?\"*\n\n" +
		"Las respuestas se generan con datos de tu inventario y una base de conocimiento de ferretería."
}

// ── Detección de intención ─────────────────────────────────

var (
	intencionRecomendar = regexp.MustCompile(`(?i)(recomendar|ofrecer|vender|vendo|vende|sugerir|cliente|compr[óa]|lleva|quiere)`)
	intencionUso        = regexp.MustCompile(`(?i)(para qu[eé]|qu[eé] es|usos?|sirve|funciona|informaci[oó]n|explica)`)
	intencionComparar   = regexp.MustCompile(`(?i)(comparar|comparaci[oó]n|diferencia|vs\.?|versus|cual es mejor)`)
	intencionSustituto  = regexp.MustCompile(`(?i)(alternativa|sustituto|reemplazo|m[aá]s barato|equivalente|similar a)`)
	intencionComplemento = regexp.MustCompile(`(?i)(complemento|junto con|se usa con|acompa[ñn]a|necesita|requiere)`)
	intencionStock      = regexp.MustCompile(`(?i)(stock|inventario|disponib|agotar|bajo|queda|hay|cu[aá]nto)`)
	intencionAyuda      = regexp.MustCompile(`(?i)^(ayuda|help|qu[eé] puedes|opciones|comandos)\b`)
	saludoRegex         = regexp.MustCompile(`(?i)^(hola|buen[oa]s|hey|qu[eé] tal|hi|hello)\b`)
	stopwords = map[string]bool{
		"qué": true, "que": true, "es": true, "el": true, "la": true, "los": true, "las": true,
		"un": true, "una": true, "de": true, "del": true, "al": true, "y": true, "o": true,
		"a": true, "para": true, "con": true, "en": true, "se": true, "lo": true,
		"me": true, "te": true, "si": true, "no": true, "ya": true,
		"cómo": true, "como": true, "cuál": true, "cual": true, "cuáles": true, "cuales": true,
		"este": true, "esta": true, "ese": true, "esa": true, "eso": true,
		"tiene": true, "tengo": true, "hay": true, "puedo": true, "puedes": true,
	}
)

func detectarIntencion(mensaje string) string {
	m := strings.ToLower(mensaje)
	switch {
	case intencionAyuda.MatchString(m):
		return "ayuda"
	case intencionComparar.MatchString(m):
		return "comparar"
	case intencionSustituto.MatchString(m):
		return "sustituto"
	case intencionComplemento.MatchString(m):
		return "complemento"
	case intencionUso.MatchString(m):
		return "para_que_sirve"
	case intencionRecomendar.MatchString(m):
		return "recomendar"
	case intencionStock.MatchString(m):
		return "stock"
	}
	return "desconocida"
}

func esSaludo(mensaje string) bool {
	return saludoRegex.MatchString(strings.ToLower(mensaje))
}

// extraerKeyword saca la palabra más relevante del mensaje.
// Busca primero en la base de conocimiento, luego en palabras sueltas.
func extraerKeyword(mensaje string) string {
	m := normalizeKeyword(mensaje)

	// Primero buscar match exacto en productos
	for key := range RelacionesProducto {
		if contains(m, key) {
			return key
		}
	}
	// Luego en categorías
	for _, cat := range ConocimientoFerreteria {
		for _, k := range cat.Keywords {
			if contains(m, k) {
				return k
			}
		}
	}
	// Buscar palabras relevantes (filtrar stopwords)
	palabras := strings.FieldsFunc(m, func(r rune) bool {
		return !(r >= 'a' && r <= 'z') && !(r >= '0' && r <= '9')
	})
	for _, p := range palabras {
		if len(p) >= 3 && !stopwords[p] {
			return p
		}
	}
	return ""
}

// buscarProductosPorNombre busca en el catálogo los productos cuyo nombre
// matchea alguno de los keywords dados.
func buscarProductosPorNombre(keywords []string, productos []ProductoCatalogo, limite int) []Sugerencia {
	if limite <= 0 || limite > 5 {
		limite = 3
	}
	out := make([]Sugerencia, 0, limite)
	for _, kw := range keywords {
		kwNorm := normalizeKeyword(kw)
		for _, p := range productos {
			if !p.Activo || p.Stock <= 0 {
				continue
			}
			if contains(normalizeKeyword(p.Nombre), kwNorm) || contains(kwNorm, normalizeKeyword(p.Nombre)) {
				out = append(out, Sugerencia{
					Tipo:         "complemento",
					ProductoID:   p.ID,
					Nombre:       p.Nombre,
					Precio:       p.Precio,
					Razon:        "Compatible con " + kw,
					StockActual:  p.Stock,
					NivelUrgencia: "medio",
				})
				if len(out) >= limite {
					return out
				}
			}
		}
	}
	return out
}

// ── Copilot global (para reusar el LLMClient) ─────────────

var (
	copilotGlobal *CopilotService
	copilotMu     sync.RWMutex
)

// SetCopilotGlobal guarda el copilot para que ChatHandler reuse su LLMClient.
func SetCopilotGlobal(cs *CopilotService) {
	copilotMu.Lock()
	defer copilotMu.Unlock()
	copilotGlobal = cs
}

// GetCopilotGlobal retorna el copilot global, o nil.
func GetCopilotGlobal() *CopilotService {
	copilotMu.RLock()
	defer copilotMu.RUnlock()
	return copilotGlobal
}

package ia

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// SugerenciaProducto es la respuesta del endpoint /ia/sugerir-producto.
type SugerenciaProducto struct {
	Nombre            string  `json:"nombre"`
	CategoriaSugerida string  `json:"categoria_sugerida"`
	CategoriaID       *int    `json:"categoria_id,omitempty"`
	PrecioMin         float64 `json:"precio_min"`
	PrecioMax         float64 `json:"precio_max"`
	PrecioPromedio    float64 `json:"precio_promedio"`
	Descripcion       string  `json:"descripcion"`
	Necesita          []int   `json:"necesita,omitempty"`
	Coincidencias     int     `json:"coincidencias"`
	Fuente            string  `json:"fuente"` // "bd" | "conocimiento" | "mixto"
}

// SugerirProducto analiza el nombre de un producto y devuelve sugerencias
// de categoría, rango de precios y descripción.
//
// GET /api/v1/ia/sugerir-producto?nombre=Taladro Bosch
func (h *Handler) SugerirProducto(c *gin.Context) {
	nombre := strings.TrimSpace(c.Query("nombre"))
	if nombre == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "BAD_REQUEST", "message": "nombre requerido"})
		return
	}

	resultado := SugerenciaProducto{
		Nombre:  nombre,
		Fuente:  "mixto",
	}

	// 1) Buscar en BD productos con nombre similar
	keyword := strings.ToLower(nombre)
	keywordNorm := normalizeKeyword(nombre)
	productosSimilares, categoriaFrecuente, categoriaID := buscarProductosSimilares(h, keyword)

	if len(productosSimilares) > 0 {
		resultado.Coincidencias = len(productosSimilares)
		resultado.CategoriaSugerida = categoriaFrecuente
		resultado.CategoriaID = categoriaID
		resultado.PrecioMin = productosSimilares[0].Precio
		resultado.PrecioMax = productosSimilares[0].Precio
		sum := 0.0
		for _, p := range productosSimilares {
			if p.Precio < resultado.PrecioMin {
				resultado.PrecioMin = p.Precio
			}
			if p.Precio > resultado.PrecioMax {
				resultado.PrecioMax = p.Precio
			}
			sum += p.Precio
		}
		resultado.PrecioPromedio = sum / float64(len(productosSimilares))
	}

	// 2) Buscar en la base de conocimiento
	prodConoc := GetProductoConocimiento(keywordNorm)
	catConoc := GetCategoriaConocimiento(resultado.CategoriaSugerida)
	if catConoc == nil {
		catConoc = GetCategoriaConocimiento(categoriaFrecuente)
	}

	if prodConoc != nil {
		if resultado.CategoriaSugerida == "" {
			resultado.CategoriaSugerida = prodConoc.Categoria
			resultado.CategoriaID = buscarCategoriaIDPorNombre(h, prodConoc.Categoria)
		}
		if resultado.Descripcion == "" {
			resultado.Descripcion = prodConoc.Descripcion
		}
		// Agregar productos compatibles como sugerencia
		resultado.Necesita = buscarIDsPorNombres(h, prodConoc.Compatibles)
		resultado.Fuente = "conocimiento"
		if len(productosSimilares) > 0 {
			resultado.Fuente = "mixto"
		}
	} else if catConoc != nil {
		if resultado.Descripcion == "" {
			resultado.Descripcion = catConoc.Descripcion
		}
		resultado.Necesita = buscarIDsPorNombres(h, catConoc.Necesita)
		if resultado.CategoriaSugerida == "" {
			resultado.CategoriaSugerida = catConoc.Nombre
			resultado.CategoriaID = buscarCategoriaIDPorNombre(h, catConoc.Nombre)
		}
		resultado.Fuente = "conocimiento"
		if len(productosSimilares) > 0 {
			resultado.Fuente = "mixto"
		}
	}

	// 3) Si no hay descripción, autogenerar una
	if resultado.Descripcion == "" {
		resultado.Descripcion = "Producto de ferretería: " + nombre + "."
	}

	c.JSON(http.StatusOK, resultado)
}

// ── Helpers ──

type productoSimilar struct {
	Nombre string
	Precio float64
	ID     int
	CategoriaNombre string
	CategoriaID     int
}

func buscarProductosSimilares(h *Handler, keyword string) ([]productoSimilar, string, *int) {
	if h.db == nil {
		return nil, "", nil
	}
	// Buscar productos que contengan la keyword en el nombre
	rows, err := h.db.Query(`
		SELECT p.id, p.nombre, p.precio_venta, COALESCE(c.nombre, '') as cat_nombre, COALESCE(p.categoria_id, 0) as cat_id
		FROM productos p
		LEFT JOIN categorias c ON c.id = p.categoria_id
		WHERE p.activo = TRUE AND LOWER(p.nombre) LIKE ?
		LIMIT 20
	`, "%"+keyword+"%")
	if err != nil {
		return nil, "", nil
	}
	defer rows.Close()

	out := make([]productoSimilar, 0, 10)
	catCount := make(map[string]int)
	catIDs := make(map[string]int)
	for rows.Next() {
		var p productoSimilar
		if err := rows.Scan(&p.ID, &p.Nombre, &p.Precio, &p.CategoriaNombre, &p.CategoriaID); err == nil {
			out = append(out, p)
			if p.CategoriaNombre != "" {
				catCount[p.CategoriaNombre]++
				catIDs[p.CategoriaNombre] = p.CategoriaID
			}
		}
	}

	if len(out) == 0 {
		return nil, "", nil
	}

	// Categoría más frecuente
	bestCat := ""
	bestCount := 0
	for cat, count := range catCount {
		if count > bestCount {
			bestCat = cat
			bestCount = count
		}
	}
	var catID *int
	if bestCat != "" {
		id := catIDs[bestCat]
		catID = &id
	}
	return out, bestCat, catID
}

func buscarCategoriaIDPorNombre(h *Handler, nombre string) *int {
	if h.db == nil || nombre == "" {
		return nil
	}
	var id int
	if err := h.db.QueryRow("SELECT id FROM categorias WHERE LOWER(nombre) = ? LIMIT 1", strings.ToLower(nombre)).Scan(&id); err != nil {
		return nil
	}
	return &id
}

func buscarIDsPorNombres(h *Handler, nombres []string) []int {
	if h.db == nil || len(nombres) == 0 {
		return nil
	}
	out := make([]int, 0, len(nombres))
	for _, n := range nombres {
		var id int
		if err := h.db.QueryRow("SELECT id FROM productos WHERE activo = TRUE AND LOWER(nombre) LIKE ? LIMIT 1", "%"+strings.ToLower(n)+"%").Scan(&id); err == nil {
			out = append(out, id)
		}
	}
	if len(out) == 0 {
		return nil
	}
	return out
}

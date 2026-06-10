package ia

// conocimiento_ferreteria.go
//
// Base de conocimiento estática sobre ferretería mexicana. Contiene:
//   - Categorías con sus productos típicos y productos complementarios
//   - Productos específicos con su descripción, usos y productos compatibles
//   - Sustitutos comunes (alternativas más baratas o equivalentes)
//
// Esta base se usa para:
//   - El chat IA conversacional: "¿qué le ofrezco a alguien que compra un taladro?"
//   - El autocompletado de productos nuevos: sugiere categoría, precio y descripción
//   - Los tooltips educativos en el carrito: explica para qué sirve cada producto
//   - El copilot de recomendaciones: encuentra productos compatibles
//
// La versión Flutter (assets/conocimiento_ferreteria.json) espeja este contenido
// para uso offline.

// CategoriaConocimiento describe una categoría de la ferretería.
type CategoriaConocimiento struct {
	Nombre           string
	Icono            string   // nombre de Material Icon (sin prefijo "Icons.")
	ProductosTipicos []string // sustantivos clave para detectar productos
	Necesita         []string // productos que típicamente se llevan junto
	Descripcion      string
	Keywords         []string // palabras que activan esta categoría
}

// ProductoConocimiento describe un producto individual.
type ProductoConocimiento struct {
	Nombre      string
	Categoria   string
	Compatibles []string // productos que se usan junto (cross-sell)
	Descripcion string
	Usos        []string
	Sustitutos  []string // alternativas (más baratas o equivalentes)
}

// ConocimientoFerreteria: mapa de las 8 categorías que ya están en la BD.
// El key es el nombre exacto de la categoría en la tabla `categorias`.
var ConocimientoFerreteria = map[string]CategoriaConocimiento{
	"Herramientas Manuales": {
		Nombre:           "Herramientas Manuales",
		Icono:            "handyman",
		ProductosTipicos: []string{"martillo", "destornillador", "llave", "pinzas", "alicate", "cinta métrica", "flexómetro"},
		Necesita:         []string{"cinta métrica", "lápiz", "guantes"},
		Descripcion:      "Herramientas que funcionan con fuerza humana. Ideales para trabajos de precisión y ensamblaje.",
		Keywords:         []string{"martillo", "destornillador", "llave", "pinzas", "alicate", "cinta", "flexómetro"},
	},
	"Herramientas Eléctricas": {
		Nombre:           "Herramientas Eléctricas",
		Icono:            "power",
		ProductosTipicos: []string{"taladro", "rotomartillo", "sierra circular", "lijadora", "esmeril", "caladora", "router"},
		Necesita:         []string{"broca", "disco de corte", "disco de lija", "cinta métrica", "gafas de protección", "guantes", "extensión eléctrica"},
		Descripcion:      "Herramientas que funcionan con electricidad o batería. Para perforar, cortar, lijar y más.",
		Keywords:         []string{"taladro", "rotomartillo", "sierra", "lijadora", "esmeril", "caladora", "router", "eléctrica"},
	},
	"Electricidad": {
		Nombre:           "Electricidad",
		Icono:            "electrical_services",
		ProductosTipicos: []string{"cable", "interruptor", "contacto", "apagador", "foco", "bombilla", "cinta aislante", "cinta de aislar", "breaker"},
		Necesita:         []string{"cinta aislante", "destornillador", "pelacables", "multímetro", "cinta de aislar"},
		Descripcion:      "Materiales y herramientas para instalaciones eléctricas residenciales y comerciales.",
		Keywords:         []string{"cable", "interruptor", "contacto", "apagador", "foco", "bombilla", "eléctrico", "breaker"},
	},
	"Plomería": {
		Nombre:           "Plomería",
		Icono:            "plumbing",
		ProductosTipicos: []string{"tubo pvc", "codo", "tee", "válvula", "llave stillson", "teflón", "pegamento pvc", "cinta selladora", "empaque"},
		Necesita:         []string{"teflón", "pegamento pvc", "cinta selladora", "codo", "llave stillson"},
		Descripcion:      "Materiales y herramientas para instalación y reparación de tuberías de agua y drenaje.",
		Keywords:         []string{"pvc", "codo", "tee", "válvula", "tubo", "plomería", "teflón", "sellar"},
	},
	"Tornillería y Fijaciones": {
		Nombre:           "Tornillería y Fijaciones",
		Icono:            "screwdriver",
		ProductosTipicos: []string{"tornillo", "taquete", "ancla", "clavo", "birlos", "tuerca", "rondana", "arandela", "broca"},
		Necesita:         []string{"destornillador", "taladro", "broca", "llave"},
		Descripcion:      "Sujetadores y elementos de fijación. Tornillos, taquetes, anclas y más.",
		Keywords:         []string{"tornillo", "taquete", "ancla", "clavo", "birlos", "tuerca", "rondana", "arandela"},
	},
	"Pintura y Acabados": {
		Nombre:           "Pintura y Acabados",
		Icono:            "format_paint",
		ProductosTipicos: []string{"pintura", "brocha", "rodillo", "cinta de enmascarar", "lija", "thinner", "barniz", "sellador"},
		Necesita:         []string{"brocha", "rodillo", "cinta de enmascarar", "lija", "cubrepintura", "charola"},
		Descripcion:      "Pinturas, herramientas y accesorios para acabados de superficies.",
		Keywords:         []string{"pintura", "brocha", "rodillo", "cinta", "lija", "thinner", "barniz", "sellador"},
	},
	"Construcción": {
		Nombre:           "Construcción",
		Icono:            "foundation",
		ProductosTipicos: []string{"cemento", "arena", "grava", "block", "tabique", "yeso", "mortero", "varilla", "alambrón"},
		Necesita:         []string{"cuchara de albañil", "nivel", "cinta métrica", "carretilla", "bieldo"},
		Descripcion:      "Materiales de construcción para obra negra y acabados.",
		Keywords:         []string{"cemento", "arena", "grava", "block", "tabique", "yeso", "mortero", "varilla", "construcción"},
	},
	"Seguridad Industrial": {
		Nombre:           "Seguridad Industrial",
		Icono:            "health_and_safety",
		ProductosTipicos: []string{"casco", "guantes", "gafas", "lentes de seguridad", "mascarilla", "tapones auditivos", "chaleco", "botas industriales"},
		Necesita:         []string{"casco", "guantes", "gafas", "chaleco"},
		Descripcion:      "Equipo de protección personal para trabajo en obra, taller o industria.",
		Keywords:         []string{"casco", "guantes", "gafas", "lentes", "mascarilla", "tapones", "chaleco", "botas", "seguridad", "epp"},
	},
}

// RelacionesProducto: mapa de productos clave con su conocimiento profundo.
// El key es la palabra clave en minúsculas que el chat/sugeridor detecta.
// Solo incluimos los 30-40 productos más importantes; el resto cae en la
// categoría general.
var RelacionesProducto = map[string]ProductoConocimiento{
	"taladro": {
		Nombre:      "Taladro",
		Categoria:   "Herramientas Eléctricas",
		Compatibles: []string{"broca", "cinta métrica", "gafas", "guantes"},
		Descripcion: "Herramienta eléctrica para perforar superficies o atornillar/desatornillar.",
		Usos:        []string{"perforar concreto", "perforar madera", "perforar metal", "atornillar", "mezclar pintura"},
		Sustitutos:  []string{"rotomartillo", "taladro inalámbrico", "atornillador eléctrico"},
	},
	"rotomartillo": {
		Nombre:      "Rotomartillo",
		Categoria:   "Herramientas Eléctricas",
		Compatibles: []string{"broca para concreto", "cincel", "gafas", "guantes", "cinta métrica"},
		Descripcion: "Taladro de alta potencia con percusión. Ideal para concreto y mampostería.",
		Usos:        []string{"perforar concreto", "demoler", "cincelar"},
		Sustitutos:  []string{"taladro con percusión"},
	},
	"martillo": {
		Nombre:      "Martillo",
		Categoria:   "Herramientas Manuales",
		Compatibles: []string{"clavos", "gafas", "guantes", "cinta métrica"},
		Descripcion: "Herramienta manual para clavar, desclavar y golpear.",
		Usos:        []string{"clavar clavos", "desclavar", "golpear", "demoler ligero"},
		Sustitutos:  []string{"maza", "marro"},
	},
	"destornillador": {
		Nombre:      "Destornillador",
		Categoria:   "Herramientas Manuales",
		Compatibles: []string{"tornillo", "gafas"},
		Descripcion: "Herramienta manual para atornillar y desatornillar.",
		Usos:        []string{"atornillar", "desatornillar", "apretar", "aflojar"},
		Sustitutos:  []string{"atornillador eléctrico", "llave Allen"},
	},
	"cinta métrica": {
		Nombre:      "Cinta métrica / Flexómetro",
		Categoria:   "Herramientas Manuales",
		Compatibles: []string{"lápiz", "nivel"},
		Descripcion: "Instrumento de medición flexible. Indispensable en cualquier trabajo.",
		Usos:        []string{"medir distancias", "marcar", "nivelar"},
	},
	"broca": {
		Nombre:      "Broca",
		Categoria:   "Tornillería y Fijaciones",
		Compatibles: []string{"taladro", "rotomartillo", "gafas"},
		Descripcion: "Accesorio de corte que se monta en un taladro para perforar.",
		Usos:        []string{"perforar concreto", "perforar madera", "perforar metal"},
		Sustitutos:  []string{"broca con percusión", "sierra copa"},
	},
	"disco de corte": {
		Nombre:      "Disco de corte",
		Categoria:   "Herramientas Eléctricas",
		Compatibles: []string{"esmeril", "sierra circular", "gafas", "guantes", "mascarilla"},
		Descripcion: "Disco abrasivo para cortar metal, concreto o madera con esmeril o sierra.",
		Usos:        []string{"cortar metal", "cortar concreto", "cortar azulejo"},
		Sustitutos:  []string{"sierra de mano"},
	},
	"cinta aislante": {
		Nombre:      "Cinta aislante / Cinta de aislar",
		Categoria:   "Electricidad",
		Compatibles: []string{"cable", "destornillador"},
		Descripcion: "Cinta adhesiva para aislar conexiones eléctricas.",
		Usos:        []string{"aislar cables", "sujetar", "marcar"},
	},
	"pvc": {
		Nombre:      "Tubo PVC",
		Categoria:   "Plomería",
		Compatibles: []string{"codo", "tee", "pegamento pvc", "teflón", "cinta selladora"},
		Descripcion: "Tubo de policloruro de vinilo para conducción de agua fría o drenaje.",
		Usos:        []string{"agua potable", "drenaje", "riego", "instalaciones sanitarias"},
		Sustitutos:  []string{"tubo CPVC", "tubo PPR", "tubo galvanizado"},
	},
	"codo": {
		Nombre:      "Codo",
		Categoria:   "Plomería",
		Compatibles: []string{"tubo pvc", "pegamento pvc", "teflón"},
		Descripcion: "Conexión en ángulo (90° o 45°) para cambiar dirección en tuberías.",
	},
	"teflón": {
		Nombre:      "Teflón / Cinta de teflón",
		Categoria:   "Plomería",
		Compatibles: []string{"llave stillson", "codo", "válvula", "tubo pvc"},
		Descripcion: "Cinta selladora para roscas en conexiones de plomería.",
		Usos:        []string{"sellar roscas", "evitar fugas"},
		Sustitutos:  []string{"cinta selladora", "pegamento para roscas"},
	},
	"tornillo": {
		Nombre:      "Tornillo",
		Categoria:   "Tornillería y Fijaciones",
		Compatibles: []string{"taquete", "destornillador", "taladro", "broca"},
		Descripcion: "Sujetador roscado para unir piezas. Se usa con taquete en muros.",
		Usos:        []string{"fijar", "ensamblar", "colgar"},
		Sustitutos:  []string{"clavo", "birlos", "ancla"},
	},
	"taquete": {
		Nombre:      "Taquete",
		Categoria:   "Tornillería y Fijaciones",
		Compatibles: []string{"tornillo", "taladro", "broca"},
		Descripcion: "Ancla plástica que se inserta en muro para recibir un tornillo.",
		Usos:        []string{"colgar en muro", "fijar en concreto", "fijar en tabique"},
		Sustitutos:  []string{"ancla metálica", "taquete de expansión"},
	},
	"pintura": {
		Nombre:      "Pintura",
		Categoria:   "Pintura y Acabados",
		Compatibles: []string{"brocha", "rodillo", "cinta de enmascarar", "lija", "thinner", "cubrepintura"},
		Descripcion: "Recubrimiento líquido para proteger y decorar superficies.",
		Usos:        []string{"pintar muros", "pintar madera", "pintar metal", "pintar exteriores"},
	},
	"brocha": {
		Nombre:      "Brocha",
		Categoria:   "Pintura y Acabados",
		Compatibles: []string{"pintura", "thinner", "cinta de enmascarar"},
		Descripcion: "Herramienta con cerdas para aplicar pintura en superficies.",
		Usos:        []string{"aplicar pintura", "retocar", "barnizar"},
	},
	"rodillo": {
		Nombre:      "Rodillo",
		Categoria:   "Pintura y Acabados",
		Compatibles: []string{"pintura", "charola", "cinta de enmascarar"},
		Descripcion: "Herramienta cilíndrica con felpa para pintar grandes superficies rápido.",
	},
	"cinta de enmascarar": {
		Nombre:      "Cinta de enmascarar / masking tape",
		Categoria:   "Pintura y Acabados",
		Compatibles: []string{"pintura", "brocha", "rodillo"},
		Descripcion: "Cinta adhesiva para proteger superficies al pintar o delimitar áreas.",
	},
	"casco": {
		Nombre:      "Casco",
		Categoria:   "Seguridad Industrial",
		Compatibles: []string{"gafas", "guantes", "chaleco", "botas"},
		Descripcion: "Equipo de protección para la cabeza en obras y construcción.",
	},
	"guantes": {
		Nombre:      "Guantes",
		Categoria:   "Seguridad Industrial",
		Compatibles: []string{"casco", "gafas", "mascarilla"},
		Descripcion: "Protección para las manos. Hay de varios tipos: carnaza, nitrilo, látex, anticorte.",
	},
	"gafas": {
		Nombre:      "Gafas / Lentes de seguridad",
		Categoria:   "Seguridad Industrial",
		Compatibles: []string{"casco", "guantes", "mascarilla"},
		Descripcion: "Protección ocular contra partículas, polvo o salpicaduras.",
	},
	"cemento": {
		Nombre:      "Cemento",
		Categoria:   "Construcción",
		Compatibles: []string{"arena", "grava", "agua", "cuchara de albañil", "carretilla"},
		Descripcion: "Material aglomerante para hacer concreto o mortero.",
		Usos:        []string{"hacer concreto", "pegar block", "resanes", "acabados"},
	},
	"block": {
		Nombre:      "Block / Tabique",
		Categoria:   "Construcción",
		Compatibles: []string{"cemento", "arena", "mortero"},
		Descripcion: "Pieza de concreto o arcilla para construcción de muros.",
	},
}

// GetCategoriaPorKeyword busca la categoría de un producto por palabra clave.
// Retorna el nombre de la categoría o string vacío si no encuentra.
func GetCategoriaPorKeyword(keyword string) string {
	kw := normalizeKeyword(keyword)
	for _, cat := range ConocimientoFerreteria {
		for _, ptipico := range cat.ProductosTipicos {
			if normalizeKeyword(ptipico) == kw {
				return cat.Nombre
			}
		}
		for _, k := range cat.Keywords {
			if normalizeKeyword(k) == kw {
				return cat.Nombre
			}
		}
	}
	return ""
}

// GetProductoConocimiento retorna el conocimiento de un producto específico.
func GetProductoConocimiento(nombreProducto string) *ProductoConocimiento {
	kw := normalizeKeyword(nombreProducto)
	// Búsqueda exacta primero
	if p, ok := RelacionesProducto[kw]; ok {
		return &p
	}
	// Búsqueda parcial: si el nombre contiene la keyword
	for key, p := range RelacionesProducto {
		if contains(normalizeKeyword(nombreProducto), key) || contains(key, kw) {
			return &p
		}
	}
	return nil
}

// GetCategoriaConocimiento retorna el conocimiento de una categoría.
func GetCategoriaConocimiento(nombreCategoria string) *CategoriaConocimiento {
	if c, ok := ConocimientoFerreteria[nombreCategoria]; ok {
		return &c
	}
	return nil
}

// GetCompatiblesPorCategoria retorna los productos típicos que complementan
// una categoría completa.
func GetCompatiblesPorCategoria(nombreCategoria string) []string {
	c, ok := ConocimientoFerreteria[nombreCategoria]
	if !ok {
		return nil
	}
	return c.Necesita
}

// BuscarProductosPorKeyword busca en la base de conocimiento productos
// que coincidan (parcial o totalmente) con la keyword.
// Retorna hasta `limite` productos con su conocimiento.
func BuscarProductosPorKeyword(keyword string, limite int) []ProductoConocimiento {
	kw := normalizeKeyword(keyword)
	if limite <= 0 || limite > 10 {
		limite = 5
	}
	resultados := make([]ProductoConocimiento, 0, limite)
	for key, p := range RelacionesProducto {
		if contains(key, kw) || contains(kw, key) {
			resultados = append(resultados, p)
			if len(resultados) >= limite {
				break
			}
		}
	}
	return resultados
}

// GetSustitutos retorna las alternativas de un producto.
// Si el producto está en la base de conocimiento, retorna sus sustitutos.
// Si no, busca alternativas de la misma categoría.
func GetSustitutos(nombreProducto string) []string {
	p := GetProductoConocimiento(nombreProducto)
	if p == nil {
		return nil
	}
	return p.Sustitutos
}

// ── Helpers internos ──

func normalizeKeyword(s string) string {
	out := make([]byte, 0, len(s))
	for i := 0; i < len(s); i++ {
		c := s[i]
		if c >= 'A' && c <= 'Z' {
			c += 32 // to lower
		}
		if c == 'á' {
			c = 'a'
		} else if c == 'é' {
			c = 'e'
		} else if c == 'í' {
			c = 'i'
		} else if c == 'ó' {
			c = 'o'
		} else if c == 'ú' {
			c = 'u'
		} else if c == 'ñ' {
			c = 'n'
		}
		out = append(out, c)
	}
	return string(out)
}

func contains(haystack, needle string) bool {
	if needle == "" {
		return true
	}
	return indexOf(haystack, needle) >= 0
}

func indexOf(s, substr string) int {
	if len(substr) > len(s) {
		return -1
	}
	for i := 0; i+len(substr) <= len(s); i++ {
		match := true
		for j := 0; j < len(substr); j++ {
			if s[i+j] != substr[j] {
				match = false
				break
			}
		}
		if match {
			return i
		}
	}
	return -1
}

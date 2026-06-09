package ia

import (
	"context"
	"math"
	"sort"
	"time"

	"github.com/jmoiron/sqlx"
)

// PrediccionInventario es una proyección para un producto.
type PrediccionInventario struct {
	ProductoID           int     `json:"producto_id"`
	Nombre               string  `json:"nombre"`
	Categoria            string  `json:"categoria"`
	StockActual          int     `json:"stock_actual"`
	StockMinimo          int     `json:"stock_minimo"`
	PrecioVenta          float64 `json:"precio_venta"`
	VendidosUltimos30D   int     `json:"vendidos_ultimos_30d"`
	PromedioDiario       float64 `json:"promedio_diario"`
	DiasRestantes        float64 `json:"dias_restantes"`        // 0 si no hay ventas
	FechaAgotamiento     string  `json:"fecha_agotamiento"`     // ISO date o ""
	CantidadSugerida     int     `json:"cantidad_sugerida"`     // sugerencia de pedido
	NivelUrgencia        string  `json:"nivel_urgencia"`        // critico | urgente | normal | sin_ventas | muerto
	Razon                string  `json:"razon"`                 // razón principal
}

// PrediccionesResumen contiene las métricas globales del análisis.
type PrediccionesResumen struct {
	FechaAnalisis        string                 `json:"fecha_analisis"`
	TotalProductos       int                    `json:"total_productos"`
	ProductosCriticos    int                    `json:"productos_criticos"`
	ProductosUrgentes    int                    `json:"productos_urgentes"`
	ProductosSinVentas   int                    `json:"productos_sin_ventas"`
	ProductosDormidos    int                    `json:"productos_dormidos"`
	ValorInventario      float64                `json:"valor_inventario"`
	ValorCritico         float64                `json:"valor_critico"`         // valor de productos en riesgo
	TopCriticos          []PrediccionInventario `json:"top_criticos"`          // los 10 más urgentes
	Recomendaciones      []string               `json:"recomendaciones"`       // bullets priorizados
}

// PrediccionesService analiza el inventario y genera proyecciones.
type PrediccionesService struct {
	db *sqlx.DB
}

func NewPrediccionesService(db *sqlx.DB) *PrediccionesService {
	return &PrediccionesService{db: db}
}

// Analizar ejecuta la query que une productos con su historial de ventas
// y devuelve las predicciones ordenadas por urgencia.
func (s *PrediccionesService) Analizar(ctx context.Context) (*PrediccionesResumen, error) {
	// Una sola query que trae TODO lo necesario:
	//   - datos del producto
	//   - ventas agregadas últimos 30 días
	//   - ventas agregadas últimos 7 días (para detectar tendencias)
	rows, err := s.db.QueryContext(ctx, `
		SELECT
			p.id,
			p.nombre,
			COALESCE(c.nombre, 'Sin categoría') as categoria,
			p.stock_actual,
			p.stock_minimo,
			p.precio_venta,
			COALESCE(SUM(CASE WHEN v.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN d.cantidad ELSE 0 END), 0) as vendidos_30d,
			COALESCE(SUM(CASE WHEN v.created_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) THEN d.cantidad ELSE 0 END), 0) as vendidos_7d,
			p.created_at as producto_creado
		FROM productos p
		LEFT JOIN categorias c ON c.id = p.categoria_id
		LEFT JOIN detalle_ventas d ON d.producto_id = p.id
		LEFT JOIN ventas v ON v.id = d.venta_id
		WHERE p.activo = TRUE
		GROUP BY p.id, p.nombre, c.nombre, p.stock_actual, p.stock_minimo, p.precio_venta, p.created_at
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	type rawRow struct {
		id            int
		nombre        string
		categoria     string
		stockActual   int
		stockMin      int
		precioVenta   float64
		vendidos30d   int
		vendidos7d    int
		creado        time.Time
	}

	raws := make([]rawRow, 0, 64)
	for rows.Next() {
		var r rawRow
		if err := rows.Scan(&r.id, &r.nombre, &r.categoria, &r.stockActual, &r.stockMin, &r.precioVenta, &r.vendidos30d, &r.vendidos7d, &r.creado); err == nil {
			raws = append(raws, r)
		}
	}

	resumen := &PrediccionesResumen{
		FechaAnalisis: time.Now().Format("2006-01-02"),
	}

	predicciones := make([]PrediccionInventario, 0, len(raws))

	for _, r := range raws {
		// Promedio diario (base 30 días). Si no hay ventas, 0.
		promedioDiario := float64(r.vendidos30d) / 30.0

		// Días restantes: infinito si no hay ventas, sino stock / promedio
		var diasRestantes float64
		var fechaAgotamiento string
		if promedioDiario <= 0.001 {
			diasRestantes = 0
		} else {
			diasRestantes = float64(r.stockActual) / promedioDiario
			if diasRestantes > 999 {
				diasRestantes = 999
			}
			fecha := time.Now().AddDate(0, 0, int(math.Ceil(diasRestantes)))
			fechaAgotamiento = fecha.Format("2006-01-02")
		}

		// Tendencia: comparar últimos 7 días vs los 7 días previos
		// (aproximación: si vendidos_7d / 7 > promedioDiario * 1.2 → acelerando)
		ratioReciente := float64(r.vendidos7d) / 7.0
		acelerando := ratioReciente > promedioDiario*1.2 && promedioDiario > 0

		// Sugerencia de pedido: 30 días de cobertura - stock actual
		cantidadSugerida := 0
		if promedioDiario > 0.01 {
			cobDeseada := int(math.Ceil(promedioDiario * 30))
			cantidadSugerida = cobDeseada - r.stockActual
			if cantidadSugerida < 0 {
				cantidadSugerida = 0
			}
		}

		// Clasificación de urgencia
		nivel, razon := clasificarUrgencia(r.stockActual, r.stockMin, diasRestantes, promedioDiario, r.creado, r.vendidos30d, acelerando)

		pred := PrediccionInventario{
			ProductoID:         r.id,
			Nombre:             r.nombre,
			Categoria:          r.categoria,
			StockActual:        r.stockActual,
			StockMinimo:        r.stockMin,
			PrecioVenta:        r.precioVenta,
			VendidosUltimos30D: r.vendidos30d,
			PromedioDiario:     round2(promedioDiario),
			DiasRestantes:      round2(diasRestantes),
			FechaAgotamiento:   fechaAgotamiento,
			CantidadSugerida:   cantidadSugerida,
			NivelUrgencia:      nivel,
			Razon:              razon,
		}
		predicciones = append(predicciones, pred)

		// Acumular métricas
		resumen.TotalProductos++
		resumen.ValorInventario += float64(r.stockActual) * r.precioVenta
		switch nivel {
		case "critico":
			resumen.ProductosCriticos++
			resumen.ValorCritico += float64(r.stockActual) * r.precioVenta
		case "urgente":
			resumen.ProductosUrgentes++
			resumen.ValorCritico += float64(r.stockActual) * r.precioVenta
		case "sin_ventas":
			resumen.ProductosSinVentas++
		case "muerto":
			resumen.ProductosDormidos++
		}
	}

	// Ordenar por urgencia: críticos primero, luego urgentes, luego por días restantes ascendente
	sort.Slice(predicciones, func(i, j int) bool {
		prio := map[string]int{
			"critico":    0,
			"urgente":    1,
			"normal":     2,
			"sin_ventas": 3,
			"muerto":     4,
		}
		pi, pj := prio[predicciones[i].NivelUrgencia], prio[predicciones[j].NivelUrgencia]
		if pi != pj {
			return pi < pj
		}
		// Mismo nivel: ordenar por días restantes (los más urgentes primero)
		// sin_ventas y muerto tienen 0 días, van al final
		if predicciones[i].DiasRestantes == 0 && predicciones[j].DiasRestantes == 0 {
			return predicciones[i].VendidosUltimos30D < predicciones[j].VendidosUltimos30D
		}
		return predicciones[i].DiasRestantes < predicciones[j].DiasRestantes
	})

	// Top 10 críticos
	if len(predicciones) > 10 {
		resumen.TopCriticos = predicciones[:10]
	} else {
		resumen.TopCriticos = predicciones
	}

	// Generar recomendaciones
	resumen.Recomendaciones = generarRecomendaciones(resumen)

	resumen.ValorInventario = round2(resumen.ValorInventario)
	resumen.ValorCritico = round2(resumen.ValorCritico)

	return resumen, nil
}

func clasificarUrgencia(stockActual, stockMin int, diasRestantes, promedioDiario float64, creado time.Time, vendidos30d int, acelerando bool) (string, string) {
	diasEnCatalogo := int(time.Since(creado).Hours() / 24)

	// Sin ventas: producto que lleva >30 días en catálogo y no ha vendido nada
	if vendidos30d == 0 {
		if diasEnCatalogo > 60 {
			return "muerto", "Sin ventas en " + itoa(diasEnCatalogo) + " días en catálogo"
		}
		return "sin_ventas", "Sin ventas en los últimos 30 días"
	}

	// Stock en 0
	if stockActual <= 0 {
		return "critico", "Sin stock y vende " + floatToStr(promedioDiario) + " unidades/día"
	}

	// Días restantes <= 3 → crítico
	if diasRestantes <= 3 {
		razon := "Se agotará en " + floatToStr(diasRestantes) + " días"
		if acelerando {
			razon += " (ventas acelerándose)"
		}
		return "critico", razon
	}

	// Stock por debajo del mínimo
	if stockActual <= stockMin {
		razon := "Stock (" + itoa(stockActual) + ") por debajo del mínimo (" + itoa(stockMin) + ")"
		if diasRestantes > 0 {
			razon += " — durará ~" + floatToStr(diasRestantes) + " días"
		}
		return "urgente", razon
	}

	// Días restantes <= 7
	if diasRestantes > 0 && diasRestantes <= 7 {
		return "urgente", "Se agotará en ~" + floatToStr(diasRestantes) + " días"
	}

	// Días restantes <= 14
	if diasRestantes > 0 && diasRestantes <= 14 {
		return "normal", "Stock para " + floatToStr(diasRestantes) + " días — planear reorden"
	}

	// Stock saludable
	if diasRestantes == 0 {
		return "sin_ventas", "Sin ventas en los últimos 30 días"
	}
	return "normal", "Stock saludable — " + floatToStr(diasRestantes) + " días de cobertura"
}

func generarRecomendaciones(r *PrediccionesResumen) []string {
	recs := make([]string, 0, 5)

	if r.ProductosCriticos > 0 {
		recs = append(recs, "⚠️ "+itoa(r.ProductosCriticos)+" producto(s) en estado CRÍTICO — reordenar HOY")
	}
	if r.ProductosUrgentes > 0 {
		recs = append(recs, "🟠 "+itoa(r.ProductosUrgentes)+" producto(s) urgentes — reordenar esta semana")
	}
	if r.ProductosDormidos > 0 {
		recs = append(recs, "💤 "+itoa(r.ProductosDormidos)+" producto(s) sin ventas en 60+ días — considerar promoción o retiro")
	}
	if r.ProductosSinVentas > 0 && r.ProductosSinVentas <= 5 {
		recs = append(recs, "📉 "+itoa(r.ProductosSinVentas)+" producto(s) sin ventas en 30 días — revisar demanda")
	}
	if r.ValorCritico > 0 {
		recs = append(recs, "💰 Valor en riesgo: $"+floatToStr(r.ValorCritico)+" — representa el inventario que necesita reorden urgente")
	}
	if len(recs) == 0 {
		recs = append(recs, "✅ Todo en orden — sin acciones urgentes")
	}
	return recs
}

func round2(v float64) float64 {
	return math.Round(v*100) / 100
}

func floatToStr(v float64) string {
	if v == 0 {
		return "0"
	}
	if v < 0 {
		return "-" + floatToStr(-v)
	}
	entero := int(v)
	dec := v - float64(entero)
	if dec < 0.05 {
		return itoa(entero)
	}
	return itoa(entero) + "." + itoa(int(dec*10+0.5))
}

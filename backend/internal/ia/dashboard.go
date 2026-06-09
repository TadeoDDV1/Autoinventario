package ia

import (
	"context"
	"time"

	"github.com/jmoiron/sqlx"
)

// DashboardResumen es el payload del nuevo endpoint /api/v1/dashboard/resumen.
type DashboardResumen struct {
	Fecha                string             `json:"fecha"`
	VentasHoy            float64            `json:"ventas_hoy"`
	TransaccionesHoy     int                `json:"transacciones_hoy"`
	TicketPromedio       float64            `json:"ticket_promedio"`
	VentasAyer           float64            `json:"ventas_ayer"`
	VariacionPct         float64            `json:"variacion_pct"`
	VentasEfectivo       float64            `json:"ventas_efectivo"`
	VentasTarjeta        float64            `json:"ventas_tarjeta"`
	TopProductos         []TopProducto      `json:"top_productos"`
	StockBajo            []StockBajoItem    `json:"stock_bajo"`
	VentasUltimos7Dias   []VentasDia        `json:"ventas_ultimos_7_dias"`
	PrediccionesCopilot  *SugerenciasOutput `json:"predicciones_copilot,omitempty"`
}

type TopProducto struct {
	ProductoID  int     `json:"producto_id"`
	Nombre      string  `json:"nombre"`
	Cantidad    int     `json:"cantidad"`
	TotalVenta  float64 `json:"total_venta"`
}

type StockBajoItem struct {
	ProductoID  int     `json:"producto_id"`
	Nombre      string  `json:"nombre"`
	StockActual int     `json:"stock_actual"`
	StockMin    int     `json:"stock_minimo"`
}

type VentasDia struct {
	Fecha        string  `json:"fecha"`
	TotalVentas  float64 `json:"total_ventas"`
	Transacciones int    `json:"transacciones"`
}

// DashboardService genera el resumen del día desde queries SQL agregadas.
type DashboardService struct {
	db *sqlx.DB
}

func NewDashboardService(db *sqlx.DB) *DashboardService {
	return &DashboardService{db: db}
}

// ResumenHoy genera el dashboard para la fecha actual.
func (s *DashboardService) ResumenHoy(ctx context.Context) (*DashboardResumen, error) {
	out := &DashboardResumen{Fecha: time.Now().Format("2006-01-02")}

	// Ventas de hoy + ticket promedio
	var totalVentas float64
	var transacciones int
	if err := s.db.QueryRowContext(ctx, `
		SELECT COALESCE(SUM(total), 0), COUNT(*)
		FROM ventas
		WHERE DATE(created_at) = CURDATE()
	`).Scan(&totalVentas, &transacciones); err != nil {
		return nil, err
	}
	out.VentasHoy = totalVentas
	out.TransaccionesHoy = transacciones
	if transacciones > 0 {
		out.TicketPromedio = totalVentas / float64(transacciones)
	}

	// Ventas de ayer
	if err := s.db.QueryRowContext(ctx, `
		SELECT COALESCE(SUM(total), 0)
		FROM ventas
		WHERE DATE(created_at) = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
	`).Scan(&out.VentasAyer); err != nil {
		return nil, err
	}
	if out.VentasAyer > 0 {
		out.VariacionPct = ((out.VentasHoy - out.VentasAyer) / out.VentasAyer) * 100
	} else if out.VentasHoy > 0 {
		out.VariacionPct = 100
	}

	// Desglose por método de pago
	if err := s.db.QueryRowContext(ctx, `
		SELECT
			COALESCE(SUM(CASE WHEN metodo_pago = 'efectivo' THEN total ELSE 0 END), 0),
			COALESCE(SUM(CASE WHEN metodo_pago = 'tarjeta' THEN total ELSE 0 END), 0)
		FROM ventas
		WHERE DATE(created_at) = CURDATE()
	`).Scan(&out.VentasEfectivo, &out.VentasTarjeta); err != nil {
		return nil, err
	}

	// Top 5 productos vendidos hoy
	rows, err := s.db.QueryContext(ctx, `
		SELECT d.producto_id, p.nombre, SUM(d.cantidad) as cantidad, SUM(d.subtotal) as total
		FROM detalle_ventas d
		JOIN productos p ON p.id = d.producto_id
		JOIN ventas v ON v.id = d.venta_id
		WHERE DATE(v.created_at) = CURDATE()
		GROUP BY d.producto_id, p.nombre
		ORDER BY cantidad DESC
		LIMIT 5
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var tp TopProducto
		if err := rows.Scan(&tp.ProductoID, &tp.Nombre, &tp.Cantidad, &tp.TotalVenta); err != nil {
			return nil, err
		}
		out.TopProductos = append(out.TopProductos, tp)
	}

	// Stock bajo (los 10 más críticos)
	rows, err = s.db.QueryContext(ctx, `
		SELECT id, nombre, stock_actual, stock_minimo
		FROM productos
		WHERE activo = TRUE AND stock_actual <= stock_minimo
		ORDER BY (stock_actual - stock_minimo) ASC
		LIMIT 10
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var sb StockBajoItem
		if err := rows.Scan(&sb.ProductoID, &sb.Nombre, &sb.StockActual, &sb.StockMin); err != nil {
			return nil, err
		}
		out.StockBajo = append(out.StockBajo, sb)
	}

	// Ventas últimos 7 días
	rows, err = s.db.QueryContext(ctx, `
		SELECT DATE(created_at) as fecha, COALESCE(SUM(total), 0), COUNT(*)
		FROM ventas
		WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
		GROUP BY DATE(created_at)
		ORDER BY fecha ASC
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var vd VentasDia
		if err := rows.Scan(&vd.Fecha, &vd.TotalVentas, &vd.Transacciones); err != nil {
			return nil, err
		}
		out.VentasUltimos7Dias = append(out.VentasUltimos7Dias, vd)
	}

	return out, nil
}

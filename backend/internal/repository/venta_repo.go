package repository

import (
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
	"github.com/ferreteria/backend/internal/models"
)

type VentaRepository struct {
	db *sqlx.DB
}

func NewVentaRepository(db *sqlx.DB) *VentaRepository {
	return &VentaRepository{db: db}
}

func (r *VentaRepository) Create(venta *models.VentaCreate) (int64, string, error) {
	folio := fmt.Sprintf("V-%d", time.Now().UnixMilli())

	tx, err := r.db.Beginx()
	if err != nil {
		return 0, "", err
	}
	defer tx.Rollback()

	query := `INSERT INTO ventas (folio, subtotal, iva, total, metodo_pago, monto_recibido, cambio)
		VALUES (?, ?, ?, ?, ?, ?, ?)`

	result, err := tx.Exec(query,
		folio, venta.Subtotal, venta.Iva, venta.Total,
		venta.MetodoPago, venta.MontoRecibido, venta.Cambio)
	if err != nil {
		return 0, "", err
	}

	ventaID, err := result.LastInsertId()
	if err != nil {
		return 0, "", err
	}

	for _, detalle := range venta.Detalles {
		query = `INSERT INTO detalle_ventas (venta_id, producto_id, cantidad, precio_unitario, subtotal)
			VALUES (?, ?, ?, ?, ?)`
		_, err := tx.Exec(query, ventaID, detalle.ProductoID, detalle.Cantidad, detalle.PrecioUnitario, detalle.Subtotal)
		if err != nil {
			return 0, "", err
		}

		query = `UPDATE productos SET stock_actual = stock_actual - ? WHERE id = ?`
		_, err = tx.Exec(query, detalle.Cantidad, detalle.ProductoID)
		if err != nil {
			return 0, "", err
		}
	}

	if err := tx.Commit(); err != nil {
		return 0, "", err
	}

	return ventaID, folio, nil
}

func (r *VentaRepository) GetAll(page, pageSize int) ([]models.Venta, int64, error) {
	var total int64
	countQuery := "SELECT COUNT(*) FROM ventas"
	if err := r.db.Get(&total, countQuery); err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	query := `SELECT v.*, GROUP_CONCAT(CONCAT(d.producto_id, ':', d.cantidad, ':', d.precio_unitario, ':', d.subtotal) ORDER BY d.id SEPARATOR ',') as detalles_raw
		FROM ventas v
		LEFT JOIN detalle_ventas d ON v.id = d.venta_id
		GROUP BY v.id
		ORDER BY v.created_at DESC
		LIMIT ? OFFSET ?`

	rows, err := r.db.Queryx(query, pageSize, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	ventas := make([]models.Venta, 0)
	for rows.Next() {
		var v models.Venta
		var detallesRaw *string
		if err := rows.Scan(&v.ID, &v.Folio, &v.Subtotal, &v.Iva, &v.Total, &v.MetodoPago, &v.MontoRecibido, &v.Cambio, &v.CreatedAt, &detallesRaw); err != nil {
			return nil, 0, err
		}
		ventas = append(ventas, v)
	}

	return ventas, total, nil
}

func (r *VentaRepository) GetByID(id int) (*models.Venta, error) {
	var venta models.Venta
	query := `SELECT v.* FROM ventas v WHERE v.id = ?`
	if err := r.db.Get(&venta, query, id); err != nil {
		return nil, err
	}

	detalleQuery := `SELECT d.*, p.nombre as nombre_producto
		FROM detalle_ventas d
		JOIN productos p ON d.producto_id = p.id
		WHERE d.venta_id = ?`
	detalles := make([]models.DetalleVenta, 0)
	if err := r.db.Select(&detalles, detalleQuery, id); err != nil {
		return nil, err
	}
	venta.Detalles = detalles

	return &venta, nil
}

func (r *VentaRepository) GetByFecha(fecha time.Time) ([]models.Venta, error) {
	query := `SELECT v.* FROM ventas v WHERE DATE(v.created_at) = DATE(?) ORDER BY v.created_at DESC`
	ventas := make([]models.Venta, 0)
	if err := r.db.Select(&ventas, query, fecha); err != nil {
		return nil, err
	}

	for i := range ventas {
		detalleQuery := `SELECT d.*, p.nombre as nombre_producto
			FROM detalle_ventas d
			JOIN productos p ON d.producto_id = p.id
			WHERE d.venta_id = ?`
		detalles := make([]models.DetalleVenta, 0)
		r.db.Select(&detalles, detalleQuery, ventas[i].ID)
		ventas[i].Detalles = detalles
	}

	return ventas, nil
}

func (r *VentaRepository) GetTotalesFecha(fecha time.Time) (float64, float64, float64, error) {
	query := `SELECT
		COALESCE(SUM(total), 0) as total_ventas,
		COALESCE(SUM(CASE WHEN metodo_pago = 'efectivo' THEN total ELSE 0 END), 0) as total_efectivo,
		COALESCE(SUM(CASE WHEN metodo_pago = 'tarjeta' THEN total ELSE 0 END), 0) as total_tarjeta
		FROM ventas WHERE DATE(created_at) = DATE(?)`

	var result struct {
		TotalVentas   float64 `db:"total_ventas"`
		TotalEfectivo float64 `db:"total_efectivo"`
		TotalTarjeta  float64 `db:"total_tarjeta"`
	}

	if err := r.db.Get(&result, query, fecha); err != nil {
		return 0, 0, 0, err
	}

	return result.TotalVentas, result.TotalEfectivo, result.TotalTarjeta, nil
}
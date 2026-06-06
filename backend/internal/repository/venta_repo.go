package repository

import (
	"fmt"
	"time"

	"github.com/ferreteria/backend/internal/apperrors"
	"github.com/ferreteria/backend/internal/models"
	"github.com/jmoiron/sqlx"
)

type VentaRepository struct {
	db *sqlx.DB
}

func NewVentaRepository(db *sqlx.DB) *VentaRepository {
	return &VentaRepository{db: db}
}

func (r *VentaRepository) Create(venta *models.VentaCreate) (int64, string, error) {
	folio := fmt.Sprintf("V-%d", time.Now().UnixNano())

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
		var stockActual int
		var nombre string
		err = tx.QueryRowx(
			"SELECT stock_actual, nombre FROM productos WHERE id = ? FOR UPDATE",
			detalle.ProductoID,
		).Scan(&stockActual, &nombre)
		if err != nil {
			return 0, "", apperrors.NewNotFound("producto", detalle.ProductoID)
		}
		if stockActual < detalle.Cantidad {
			return 0, "", apperrors.NewStockError(
				detalle.ProductoID, stockActual, detalle.Cantidad, nombre,
			)
		}

		query = `INSERT INTO detalle_ventas (venta_id, producto_id, cantidad, precio_unitario, subtotal)
			VALUES (?, ?, ?, ?, ?)`
		if _, err := tx.Exec(query, ventaID, detalle.ProductoID, detalle.Cantidad, detalle.PrecioUnitario, detalle.Subtotal); err != nil {
			return 0, "", err
		}

		query = `UPDATE productos SET stock_actual = stock_actual - ? WHERE id = ?`
		if _, err = tx.Exec(query, detalle.Cantidad, detalle.ProductoID); err != nil {
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
	if err := r.db.Get(&total, "SELECT COUNT(*) FROM ventas"); err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	query := `SELECT id, folio, subtotal, iva, total, metodo_pago, monto_recibido, cambio, created_at
		FROM ventas
		ORDER BY created_at DESC
		LIMIT ? OFFSET ?`

	ventas := make([]models.Venta, 0)
	if err := r.db.Select(&ventas, query, pageSize, offset); err != nil {
		return nil, 0, err
	}

	if err := r.hydrateDetalles(ventas); err != nil {
		return nil, 0, err
	}

	return ventas, total, nil
}

func (r *VentaRepository) GetByID(id int) (*models.Venta, error) {
	var venta models.Venta
	if err := r.db.Get(&venta, "SELECT v.* FROM ventas v WHERE v.id = ?", id); err != nil {
		return nil, apperrors.NewNotFound("venta", id)
	}

	detalles := make([]models.DetalleVenta, 0)
	detalleQuery := `SELECT d.*, p.nombre as nombre_producto
		FROM detalle_ventas d
		JOIN productos p ON d.producto_id = p.id
		WHERE d.venta_id = ?`
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

	if err := r.hydrateDetalles(ventas); err != nil {
		return nil, err
	}

	return ventas, nil
}

func (r *VentaRepository) hydrateDetalles(ventas []models.Venta) error {
	if len(ventas) == 0 {
		return nil
	}
	ids := make([]int, len(ventas))
	for i, v := range ventas {
		ids[i] = v.ID
	}
	detalleQuery := `SELECT d.id, d.venta_id, d.producto_id, d.cantidad, d.precio_unitario, d.subtotal, p.nombre as nombre_producto
		FROM detalle_ventas d
		JOIN productos p ON d.producto_id = p.id
		WHERE d.venta_id IN (?)`
	q, args, err := sqlx.In(detalleQuery, ids)
	if err != nil {
		return err
	}
	q = r.db.Rebind(q)
	var allDetalles []models.DetalleVenta
	if err := r.db.Select(&allDetalles, q, args...); err != nil {
		return err
	}
	byVenta := make(map[int][]models.DetalleVenta, len(ventas))
	for _, d := range allDetalles {
		byVenta[d.VentaID] = append(byVenta[d.VentaID], d)
	}
	for i := range ventas {
		detalles := byVenta[ventas[i].ID]
		if detalles == nil {
			detalles = []models.DetalleVenta{}
		}
		ventas[i].Detalles = detalles
	}
	return nil
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

package repository

import (
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
	"github.com/ferreteria/backend/internal/models"
)

type EntradaRepository struct {
	db *sqlx.DB
}

func NewEntradaRepository(db *sqlx.DB) *EntradaRepository {
	return &EntradaRepository{db: db}
}

func (r *EntradaRepository) Create(entrada *models.EntradaCreate) (int64, string, error) {
	folio := fmt.Sprintf("E-%d", time.Now().UnixMilli())

	tx, err := r.db.Beginx()
	if err != nil {
		return 0, "", err
	}
	defer tx.Rollback()

	var total float64
	for _, d := range entrada.Detalles {
		total += d.CostoUnitario * float64(d.Cantidad)
	}

	query := `INSERT INTO entradas_inventario (folio, proveedor, total, observaciones) VALUES (?, ?, ?, ?)`
	result, err := tx.Exec(query, folio, entrada.Proveedor, total, entrada.Observaciones)
	if err != nil {
		return 0, "", err
	}

	entradaID, err := result.LastInsertId()
	if err != nil {
		return 0, "", err
	}

	for _, detalle := range entrada.Detalles {
		query = `INSERT INTO detalle_entradas (entrada_id, producto_id, cantidad, costo_unitario) VALUES (?, ?, ?, ?)`
		_, err := tx.Exec(query, entradaID, detalle.ProductoID, detalle.Cantidad, detalle.CostoUnitario)
		if err != nil {
			return 0, "", err
		}

		query = `UPDATE productos SET stock_actual = stock_actual + ? WHERE id = ?`
		_, err = tx.Exec(query, detalle.Cantidad, detalle.ProductoID)
		if err != nil {
			return 0, "", err
		}
	}

	if err := tx.Commit(); err != nil {
		return 0, "", err
	}

	return entradaID, folio, nil
}

func (r *EntradaRepository) GetAll(page, pageSize int) ([]models.EntradaInventario, int64, error) {
	var total int64
	countQuery := "SELECT COUNT(*) FROM entradas_inventario"
	if err := r.db.Get(&total, countQuery); err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	query := `SELECT * FROM entradas_inventario ORDER BY fecha DESC LIMIT ? OFFSET ?`

	entradas := make([]models.EntradaInventario, 0)
	if err := r.db.Select(&entradas, query, pageSize, offset); err != nil {
		return nil, 0, err
	}

	return entradas, total, nil
}

func (r *EntradaRepository) GetByID(id int) (*models.EntradaInventario, error) {
	var entrada models.EntradaInventario
	query := `SELECT * FROM entradas_inventario WHERE id = ?`
	if err := r.db.Get(&entrada, query, id); err != nil {
		return nil, err
	}

	detalleQuery := `SELECT de.*, p.nombre as nombre_producto
		FROM detalle_entradas de
		JOIN productos p ON de.producto_id = p.id
		WHERE de.entrada_id = ?`
	detalles := make([]models.DetalleEntrada, 0)
	if err := r.db.Select(&detalles, detalleQuery, id); err != nil {
		return nil, err
	}
	entrada.Detalles = detalles

	return &entrada, nil
}
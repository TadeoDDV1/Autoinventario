package repository

import (
	"fmt"
	"strings"
	"time"

	"github.com/ferreteria/backend/internal/apperrors"
	"github.com/ferreteria/backend/internal/models"
	"github.com/jmoiron/sqlx"
)

type EntradaRepository struct {
	db *sqlx.DB
}

func NewEntradaRepository(db *sqlx.DB) *EntradaRepository {
	return &EntradaRepository{db: db}
}

func (r *EntradaRepository) Create(entrada *models.EntradaCreate) (int64, string, error) {
	folio := fmt.Sprintf("E-%d", time.Now().UnixNano())

	tx, err := r.db.Beginx()
	if err != nil {
		return 0, "", err
	}
	defer tx.Rollback()

	var total float64
	for _, d := range entrada.Detalles {
		total += d.CostoUnitario * float64(d.Cantidad)
	}

	result, err := tx.Exec(
		`INSERT INTO entradas_inventario (folio, proveedor, total, observaciones) VALUES (?, ?, ?, ?)`,
		folio, entrada.Proveedor, total, entrada.Observaciones,
	)
	if err != nil {
		return 0, "", err
	}

	entradaID, err := result.LastInsertId()
	if err != nil {
		return 0, "", err
	}

	for _, detalle := range entrada.Detalles {
		if _, err := tx.Exec(
			`INSERT INTO detalle_entradas (entrada_id, producto_id, cantidad, costo_unitario) VALUES (?, ?, ?, ?)`,
			entradaID, detalle.ProductoID, detalle.Cantidad, detalle.CostoUnitario,
		); err != nil {
			return 0, "", err
		}

		if _, err := tx.Exec(
			`UPDATE productos SET stock_actual = stock_actual + ? WHERE id = ?`,
			detalle.Cantidad, detalle.ProductoID,
		); err != nil {
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
	if err := r.db.Get(&total, "SELECT COUNT(*) FROM entradas_inventario"); err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	entradas := make([]models.EntradaInventario, 0)
	query := `SELECT * FROM entradas_inventario ORDER BY fecha DESC LIMIT ? OFFSET ?`
	if err := r.db.Select(&entradas, query, pageSize, offset); err != nil {
		return nil, 0, err
	}

	return entradas, total, nil
}

// GetByDateRange devuelve entradas dentro de [desde, hasta] (inclusive en el día hasta).
// Si desde o hasta son zero, se omite ese límite.
func (r *EntradaRepository) GetByDateRange(desde, hasta time.Time, page, pageSize int) ([]models.EntradaInventario, int64, error) {
	var conditions []string
	var args []interface{}

	if !desde.IsZero() {
		conditions = append(conditions, "fecha >= ?")
		args = append(args, desde)
	}
	if !hasta.IsZero() {
		// fin del día
		endOfDay := time.Date(hasta.Year(), hasta.Month(), hasta.Day(), 23, 59, 59, 0, hasta.Location())
		conditions = append(conditions, "fecha <= ?")
		args = append(args, endOfDay)
	}

	whereClause := ""
	if len(conditions) > 0 {
		whereClause = "WHERE " + strings.Join(conditions, " AND ")
	}

	var total int64
	countQuery := "SELECT COUNT(*) FROM entradas_inventario " + whereClause
	if err := r.db.Get(&total, countQuery, args...); err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	entradas := make([]models.EntradaInventario, 0)
	query := `SELECT * FROM entradas_inventario ` + whereClause + ` ORDER BY fecha DESC LIMIT ? OFFSET ?`
	args = append(args, pageSize, offset)
	if err := r.db.Select(&entradas, query, args...); err != nil {
		return nil, 0, err
	}

	return entradas, total, nil
}

func (r *EntradaRepository) GetByID(id int) (*models.EntradaInventario, error) {
	var entrada models.EntradaInventario
	if err := r.db.Get(&entrada, "SELECT * FROM entradas_inventario WHERE id = ?", id); err != nil {
		return nil, apperrors.NewNotFound("entrada", id)
	}

	detalles := make([]models.DetalleEntrada, 0)
	detalleQuery := `SELECT de.*, p.nombre as nombre_producto
		FROM detalle_entradas de
		JOIN productos p ON de.producto_id = p.id
		WHERE de.entrada_id = ?`
	if err := r.db.Select(&detalles, detalleQuery, id); err != nil {
		return nil, err
	}
	entrada.Detalles = detalles

	return &entrada, nil
}

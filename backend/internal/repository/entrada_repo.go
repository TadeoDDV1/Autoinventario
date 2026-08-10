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

// FiltrosEntradas agrupa filtros aplicables a GetAll y GetByDateRange.
// Proveedor y Q usan LIKE y se aplican directamente sobre las columnas
// `proveedor`, `folio` y `observaciones`. El escape de caracteres
// especiales se realiza en [`escapeLike`].
type FiltrosEntradas struct {
	Desde     time.Time
	Hasta     time.Time
	Proveedor string
	Q         string
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
	return r.listPaginadas(
		"SELECT * FROM entradas_inventario",
		[]interface{}{},
		"",
		page, pageSize,
	)
}

// GetByDateRange devuelve entradas dentro de [desde, hasta] (inclusive en el día hasta).
// Si desde o hasta son zero, se omite ese límite. Proveedor y Q son filtros opcionales
// aplicados a las columnas `proveedor`, `folio` y `observaciones`.
func (r *EntradaRepository) GetByDateRange(
	filtros FiltrosEntradas,
	page, pageSize int,
) ([]models.EntradaInventario, int64, error) {
	var conditions []string
	var args []interface{}

	if !filtros.Desde.IsZero() {
		conditions = append(conditions, "fecha >= ?")
		args = append(args, filtros.Desde)
	}
	if !filtros.Hasta.IsZero() {
		// fin del día
		endOfDay := time.Date(
			filtros.Hasta.Year(), filtros.Hasta.Month(), filtros.Hasta.Day(),
			23, 59, 59, 0, filtros.Hasta.Location(),
		)
		conditions = append(conditions, "fecha <= ?")
		args = append(args, endOfDay)
	}
	if filtros.Proveedor != "" {
		conditions = append(conditions, "proveedor LIKE ?")
		args = append(args, "%"+escapeLike(filtros.Proveedor)+"%")
	}
	if filtros.Q != "" {
		conditions = append(conditions, "(folio LIKE ? OR observaciones LIKE ?)")
		pat := "%" + escapeLike(filtros.Q) + "%"
		args = append(args, pat, pat)
	}

	whereClause := ""
	if len(conditions) > 0 {
		whereClause = "WHERE " + strings.Join(conditions, " AND ")
	}

	return r.listPaginadas(
		"SELECT * FROM entradas_inventario",
		args,
		whereClause,
		page, pageSize,
	)
}

// listPaginadas ejecuta COUNT + SELECT con OFFSET, luego carga los detalles
// de las páginas resultantes en una sola query batch (sin N+1).
func (r *EntradaRepository) listPaginadas(
	baseQuery string,
	args []interface{},
	whereClause string,
	page, pageSize int,
) ([]models.EntradaInventario, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 20
	}
	offset := (page - 1) * pageSize

	countQuery := "SELECT COUNT(*) FROM entradas_inventario " + whereClause
	var total int64
	if err := r.db.Get(&total, countQuery, args...); err != nil {
		return nil, 0, err
	}

	dataQuery := baseQuery + " " + whereClause +
		" ORDER BY fecha DESC, id DESC LIMIT ? OFFSET ?"
	dataArgs := append(append([]interface{}{}, args...), pageSize, offset)
	entradas := make([]models.EntradaInventario, 0)
	if err := r.db.Select(&entradas, dataQuery, dataArgs...); err != nil {
		return nil, 0, err
	}

	if len(entradas) == 0 {
		return entradas, total, nil
	}

	if err := r.loadDetalles(&entradas); err != nil {
		return nil, 0, err
	}

	return entradas, total, nil
}

// loadDetalles carga los detalles de todas las entradas en una sola query
// batch (sin N+1), incluyendo el `nombre_producto` desde `productos`.
func (r *EntradaRepository) loadDetalles(
	entradas *[]models.EntradaInventario,
) error {
	if len(*entradas) == 0 {
		return nil
	}
	ids := make([]interface{}, 0, len(*entradas))
	for _, e := range *entradas {
		ids = append(ids, e.ID)
	}
	placeholders := strings.Repeat("?,", len(ids))
	placeholders = strings.TrimSuffix(placeholders, ",")

	type detConEntrada struct {
		EntradaID      int     `db:"entrada_id"`
		ID             int     `db:"id"`
		ProductoID     int     `db:"producto_id"`
		Cantidad       int     `db:"cantidad"`
		CostoUnitario  float64 `db:"costo_unitario"`
		NombreProducto string  `db:"nombre_producto"`
	}

	q := `SELECT de.entrada_id, de.id, de.producto_id, de.cantidad, de.costo_unitario,
	             p.nombre AS nombre_producto
	      FROM detalle_entradas de
	      JOIN productos p ON de.producto_id = p.id
	      WHERE de.entrada_id IN (` + placeholders + `)
	      ORDER BY de.entrada_id, de.id ASC`

	filas := make([]detConEntrada, 0)
	if err := r.db.Select(&filas, q, ids...); err != nil {
		return err
	}

	byEntrada := make(map[int][]models.DetalleEntrada, len(*entradas))
	for _, f := range filas {
		d := models.DetalleEntrada{
			ID:             f.ID,
			EntradaID:      f.EntradaID,
			ProductoID:     f.ProductoID,
			Cantidad:       f.Cantidad,
			CostoUnitario:  f.CostoUnitario,
			NombreProducto: f.NombreProducto,
		}
		byEntrada[f.EntradaID] = append(byEntrada[f.EntradaID], d)
	}

	for i := range *entradas {
		if d, ok := byEntrada[(*entradas)[i].ID]; ok {
			(*entradas)[i].Detalles = d
		} else {
			(*entradas)[i].Detalles = []models.DetalleEntrada{}
		}
	}
	return nil
}

// escapeLike escapa los caracteres especiales de MySQL/MariaDB
// (`%`, `_` y `\`) para que un usuario pueda buscar un valor que
// los contenga sin que se interpreten como comodines.
func escapeLike(s string) string {
	r := strings.NewReplacer(
		`\`, `\\`,
		`%`, `\%`,
		`_`, `\_`,
	)
	return r.Replace(s)
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

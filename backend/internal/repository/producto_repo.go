package repository

import (
	"fmt"
	"strings"

	"github.com/ferreteria/backend/internal/apperrors"
	"github.com/ferreteria/backend/internal/models"
	"github.com/jmoiron/sqlx"
)

type ProductoRepository struct {
	db *sqlx.DB
}

func NewProductoRepository(db *sqlx.DB) *ProductoRepository {
	return &ProductoRepository{db: db}
}

func (r *ProductoRepository) GetAll(page, pageSize int, search string, categoriaID *int) ([]models.Producto, int64, error) {
	var conditions []string
	var args []interface{}

	conditions = append(conditions, "p.activo = TRUE")

	if search != "" {
		conditions = append(conditions, "(p.nombre LIKE ? OR p.codigo_barras LIKE ? OR p.descripcion LIKE ? OR p.sku LIKE ? OR p.marca LIKE ?)")
		args = append(args, "%"+search+"%", "%"+search+"%", "%"+search+"%", "%"+search+"%", "%"+search+"%")
	}

	if categoriaID != nil {
		conditions = append(conditions, "p.categoria_id = ?")
		args = append(args, *categoriaID)
	}

	whereClause := "WHERE " + strings.Join(conditions, " AND ")

	countQuery := "SELECT COUNT(*) FROM productos p " + whereClause
	var total int64
	if err := r.db.Get(&total, countQuery, args...); err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	query := `SELECT p.id, p.codigo_barras, p.sku, p.nombre, p.marca, p.descripcion, p.uso,
		p.precio_compra, p.precio_venta, p.precio_mayoreo, p.unidad_medida,
		p.stock_actual, p.stock_minimo, p.categoria_id, p.ubicacion,
		p.activo, p.created_at, p.updated_at,
		c.nombre as categoria_nombre
		FROM productos p
		LEFT JOIN categorias c ON p.categoria_id = c.id
		` + whereClause + `
		ORDER BY p.nombre ASC
		LIMIT ? OFFSET ?`

	args = append(args, pageSize, offset)

	productos := make([]models.Producto, 0)
	if err := r.db.Select(&productos, query, args...); err != nil {
		return nil, 0, err
	}

	return productos, total, nil
}

func (r *ProductoRepository) GetByID(id int) (*models.Producto, error) {
	var producto models.Producto
	query := `SELECT p.id, p.codigo_barras, p.sku, p.nombre, p.marca, p.descripcion, p.uso,
		p.precio_compra, p.precio_venta, p.precio_mayoreo, p.unidad_medida,
		p.stock_actual, p.stock_minimo, p.categoria_id, p.ubicacion,
		p.activo, p.created_at, p.updated_at,
		c.nombre as categoria_nombre
		FROM productos p
		LEFT JOIN categorias c ON p.categoria_id = c.id
		WHERE p.id = ? AND p.activo = TRUE`

	if err := r.db.Get(&producto, query, id); err != nil {
		return nil, apperrors.NewNotFound("producto", id)
	}
	return &producto, nil
}

func (r *ProductoRepository) Create(p *models.ProductoCreate) (int64, error) {
	unidad := p.UnidadMedida
	if unidad == "" {
		unidad = "pieza"
	}
	query := `INSERT INTO productos (
		codigo_barras, sku, nombre, marca, descripcion, uso,
		precio_compra, precio_venta, precio_mayoreo, unidad_medida,
		stock_actual, stock_minimo, categoria_id, ubicacion
	) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`

	result, err := r.db.Exec(query,
		p.CodigoBarras, p.SKU, p.Nombre, p.Marca, p.Descripcion, p.Uso,
		p.PrecioCompra, p.PrecioVenta, p.PrecioMayoreo, unidad,
		p.StockActual, p.StockMinimo, p.CategoriaID, p.Ubicacion)
	if err != nil {
		return 0, err
	}

	return result.LastInsertId()
}

func (r *ProductoRepository) Update(id int, p *models.ProductoUpdate) error {
	var setClauses []string
	var args []interface{}

	if p.CodigoBarras != nil {
		setClauses = append(setClauses, "codigo_barras = ?")
		args = append(args, *p.CodigoBarras)
	}
	if p.SKU != nil {
		setClauses = append(setClauses, "sku = ?")
		args = append(args, *p.SKU)
	}
	if p.Nombre != nil {
		setClauses = append(setClauses, "nombre = ?")
		args = append(args, *p.Nombre)
	}
	if p.Marca != nil {
		setClauses = append(setClauses, "marca = ?")
		args = append(args, *p.Marca)
	}
	if p.Descripcion != nil {
		setClauses = append(setClauses, "descripcion = ?")
		args = append(args, *p.Descripcion)
	}
	if p.Uso != nil {
		setClauses = append(setClauses, "uso = ?")
		args = append(args, *p.Uso)
	}
	if p.PrecioCompra != nil {
		setClauses = append(setClauses, "precio_compra = ?")
		args = append(args, *p.PrecioCompra)
	}
	if p.PrecioVenta != nil {
		setClauses = append(setClauses, "precio_venta = ?")
		args = append(args, *p.PrecioVenta)
	}
	if p.PrecioMayoreo != nil {
		setClauses = append(setClauses, "precio_mayoreo = ?")
		args = append(args, *p.PrecioMayoreo)
	}
	if p.UnidadMedida != nil {
		setClauses = append(setClauses, "unidad_medida = ?")
		args = append(args, *p.UnidadMedida)
	}
	if p.StockActual != nil {
		setClauses = append(setClauses, "stock_actual = ?")
		args = append(args, *p.StockActual)
	}
	if p.StockMinimo != nil {
		setClauses = append(setClauses, "stock_minimo = ?")
		args = append(args, *p.StockMinimo)
	}
	if p.CategoriaID != nil {
		setClauses = append(setClauses, "categoria_id = ?")
		args = append(args, *p.CategoriaID)
	}
	if p.Ubicacion != nil {
		setClauses = append(setClauses, "ubicacion = ?")
		args = append(args, *p.Ubicacion)
	}

	if len(setClauses) == 0 {
		return apperrors.ErrNoHayCampos
	}

	query := "UPDATE productos SET " + strings.Join(setClauses, ", ") + " WHERE id = ? AND activo = TRUE"
	args = append(args, id)

	result, err := r.db.Exec(query, args...)
	if err != nil {
		return err
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return apperrors.NewNotFound("producto", id)
	}

	return nil
}

func (r *ProductoRepository) Delete(id int) error {
	result, err := r.db.Exec("UPDATE productos SET activo = FALSE WHERE id = ?", id)
	if err != nil {
		return err
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return apperrors.NewNotFound("producto", id)
	}

	return nil
}

func (r *ProductoRepository) GetCategorias() ([]models.Categoria, error) {
	categorias := make([]models.Categoria, 0)
	if err := r.db.Select(&categorias, "SELECT * FROM categorias WHERE activo = TRUE ORDER BY nombre ASC"); err != nil {
		return nil, err
	}
	return categorias, nil
}

func (r *ProductoRepository) CreateCategoria(c *models.CategoriaCreate) (int64, error) {
	result, err := r.db.Exec("INSERT INTO categorias (nombre, descripcion) VALUES (?, ?)", c.Nombre, c.Descripcion)
	if err != nil {
		return 0, err
	}
	return result.LastInsertId()
}

func (r *ProductoRepository) BuscarPorCodigo(codigo string) (*models.Producto, error) {
	var producto models.Producto
	query := `SELECT p.id, p.codigo_barras, p.sku, p.nombre, p.marca, p.descripcion, p.uso,
		p.precio_compra, p.precio_venta, p.precio_mayoreo, p.unidad_medida,
		p.stock_actual, p.stock_minimo, p.categoria_id, p.ubicacion,
		p.activo, p.created_at, p.updated_at,
		c.nombre as categoria_nombre
		FROM productos p
		LEFT JOIN categorias c ON p.categoria_id = c.id
		WHERE p.codigo_barras = ? AND p.activo = TRUE`

	if err := r.db.Get(&producto, query, codigo); err != nil {
		return nil, apperrors.NewNotFound("producto con código "+codigo, 0)
	}
	return &producto, nil
}

func (r *ProductoRepository) AjustarStock(id int, cantidad int) error {
	if cantidad < 0 {
		return fmt.Errorf("cantidad no puede ser negativa")
	}
	result, err := r.db.Exec("UPDATE productos SET stock_actual = ? WHERE id = ? AND activo = TRUE", cantidad, id)
	if err != nil {
		return err
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return apperrors.NewNotFound("producto", id)
	}

	return nil
}

// SKUExists devuelve true si ya existe un producto con ese SKU (ignorando
// el propio id). Usado por el service para validar unicidad antes de insertar.
func (r *ProductoRepository) SKUExists(sku string, excludeID int) (bool, error) {
	if sku == "" {
		return false, nil
	}
	var count int
	query := "SELECT COUNT(*) FROM productos WHERE sku = ? AND activo = TRUE AND id <> ?"
	if err := r.db.Get(&count, query, sku, excludeID); err != nil {
		return false, err
	}
	return count > 0, nil
}
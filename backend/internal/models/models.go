package models

import "time"

type Producto struct {
	ID             int       `json:"id" db:"id"`
	CodigoBarras   *string   `json:"codigo_barras" db:"codigo_barras"`
	SKU            *string   `json:"sku,omitempty" db:"sku"`
	Nombre         string    `json:"nombre" db:"nombre" validate:"required"`
	Marca          *string   `json:"marca,omitempty" db:"marca"`
	Descripcion    *string   `json:"descripcion" db:"descripcion"`
	Uso            *string   `json:"uso,omitempty" db:"uso"`
	PrecioCompra   float64   `json:"precio_compra" db:"precio_compra" validate:"gte=0"`
	PrecioVenta    float64   `json:"precio_venta" db:"precio_venta" validate:"required,gt=0"`
	PrecioMayoreo  *float64  `json:"precio_mayoreo,omitempty" db:"precio_mayoreo"`
	UnidadMedida   string    `json:"unidad_medida" db:"unidad_medida"`
	StockActual    int       `json:"stock_actual" db:"stock_actual" validate:"gte=0"`
	StockMinimo    int       `json:"stock_minimo" db:"stock_minimo" validate:"gte=0"`
	CategoriaID    *int      `json:"categoria_id" db:"categoria_id"`
	Ubicacion      *string   `json:"ubicacion,omitempty" db:"ubicacion"`
	Activo         bool      `json:"activo" db:"activo"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time `json:"updated_at" db:"updated_at"`
	CategoriaNombre *string  `json:"categoria_nombre,omitempty" db:"categoria_nombre"`
}

type ProductoCreate struct {
	CodigoBarras  *string  `json:"codigo_barras" validate:"omitempty"`
	SKU           *string  `json:"sku,omitempty" validate:"omitempty,max=50"`
	Nombre        string   `json:"nombre" validate:"required"`
	Marca         *string  `json:"marca,omitempty" validate:"omitempty,max=100"`
	Descripcion   *string  `json:"descripcion"`
	Uso           *string  `json:"uso,omitempty"`
	PrecioCompra  float64  `json:"precio_compra" validate:"gte=0"`
	PrecioVenta   float64  `json:"precio_venta" validate:"required,gt=0"`
	PrecioMayoreo *float64 `json:"precio_mayoreo,omitempty" validate:"omitempty,gte=0"`
	UnidadMedida  string   `json:"unidad_medida" validate:"omitempty,oneof=pieza metro kg litro caja rollo par otro"`
	StockActual   int      `json:"stock_actual" validate:"gte=0"`
	StockMinimo   int      `json:"stock_minimo" validate:"gte=0"`
	CategoriaID   *int     `json:"categoria_id"`
	Ubicacion     *string  `json:"ubicacion,omitempty" validate:"omitempty,max=100"`
}

type ProductoUpdate struct {
	CodigoBarras  *string  `json:"codigo_barras"`
	SKU           *string  `json:"sku,omitempty" validate:"omitempty,max=50"`
	Nombre        *string  `json:"nombre" validate:"omitempty,min=1"`
	Marca         *string  `json:"marca,omitempty" validate:"omitempty,max=100"`
	Descripcion   *string  `json:"descripcion"`
	Uso           *string  `json:"uso,omitempty"`
	PrecioCompra  *float64 `json:"precio_compra" validate:"omitempty,gte=0"`
	PrecioVenta   *float64 `json:"precio_venta" validate:"omitempty,gt=0"`
	PrecioMayoreo *float64 `json:"precio_mayoreo,omitempty" validate:"omitempty,gte=0"`
	UnidadMedida  *string  `json:"unidad_medida,omitempty" validate:"omitempty,oneof=pieza metro kg litro caja rollo par otro"`
	StockActual   *int     `json:"stock_actual" validate:"omitempty,gte=0"`
	StockMinimo   *int     `json:"stock_minimo" validate:"omitempty,gte=0"`
	CategoriaID   *int     `json:"categoria_id"`
	Ubicacion     *string  `json:"ubicacion,omitempty" validate:"omitempty,max=100"`
}

type Categoria struct {
	ID          int       `json:"id" db:"id"`
	Nombre      string    `json:"nombre" db:"nombre" validate:"required"`
	Descripcion *string   `json:"descripcion" db:"descripcion"`
	Activo      bool      `json:"activo" db:"activo"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

type CategoriaCreate struct {
	Nombre      string  `json:"nombre" validate:"required"`
	Descripcion *string `json:"descripcion"`
}

type PaginatedResponse struct {
	Data       interface{} `json:"data"`
	Total      int64       `json:"total"`
	Page       int         `json:"page"`
	PageSize   int         `json:"page_size"`
	TotalPages int         `json:"total_pages"`
}

type APIError struct {
	Error   string `json:"error"`
	Message string `json:"message"`
}
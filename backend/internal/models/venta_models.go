package models

import "time"

type Venta struct {
	ID            int            `json:"id" db:"id"`
	Folio         string         `json:"folio" db:"folio"`
	Subtotal      float64        `json:"subtotal" db:"subtotal"`
	Iva           float64        `json:"iva" db:"iva"`
	Total         float64        `json:"total" db:"total"`
	MetodoPago    string         `json:"metodo_pago" db:"metodo_pago"`
	MontoRecibido *float64       `json:"monto_recibido" db:"monto_recibido"`
	Cambio        *float64       `json:"cambio" db:"cambio"`
	ReferenciaPago *string       `json:"referencia_pago,omitempty" db:"referencia_pago"`
	CreatedAt     time.Time      `json:"created_at" db:"created_at"`
	Detalles      []DetalleVenta `json:"detalles,omitempty"`
}

type DetalleVenta struct {
	ID            int     `json:"id" db:"id"`
	VentaID       int     `json:"venta_id" db:"venta_id"`
	ProductoID    int     `json:"producto_id" db:"producto_id"`
	Cantidad      int     `json:"cantidad" db:"cantidad"`
	PrecioUnitario float64 `json:"precio_unitario" db:"precio_unitario"`
	Subtotal      float64 `json:"subtotal" db:"subtotal"`
	NombreProducto string  `json:"nombre_producto,omitempty" db:"nombre_producto"`
}

type VentaCreate struct {
	Detalles       []DetalleVentaCreate `json:"detalles" validate:"required,min=1"`
	Subtotal       float64             `json:"subtotal" validate:"required,gte=0"`
	Iva            float64             `json:"iva" validate:"required,gte=0"`
	Total          float64             `json:"total" validate:"required,gt=0"`
	MetodoPago     string              `json:"metodo_pago" validate:"required,oneof=efectivo tarjeta transferencia mixto"`
	MontoRecibido  *float64            `json:"monto_recibido"`
	Cambio         *float64            `json:"cambio"`
	ReferenciaPago *string             `json:"referencia_pago,omitempty"`
}

type DetalleVentaCreate struct {
	ProductoID    int     `json:"producto_id" validate:"required"`
	Cantidad      int     `json:"cantidad" validate:"required,gt=0"`
	PrecioUnitario float64 `json:"precio_unitario" validate:"required,gt=0"`
	Subtotal      float64 `json:"subtotal" validate:"required"`
}

type EntradaInventario struct {
	ID           int              `json:"id" db:"id"`
	Folio        string           `json:"folio" db:"folio"`
	Proveedor    *string          `json:"proveedor" db:"proveedor"`
	Fecha        time.Time        `json:"fecha" db:"fecha"`
	Total        float64          `json:"total" db:"total"`
	Observaciones *string          `json:"observaciones" db:"observaciones"`
	Detalles      []DetalleEntrada `json:"detalles,omitempty"`
}

type DetalleEntrada struct {
	ID            int     `json:"id" db:"id"`
	EntradaID     int     `json:"entrada_id" db:"entrada_id"`
	ProductoID    int     `json:"producto_id" db:"producto_id"`
	Cantidad      int     `json:"cantidad" db:"cantidad"`
	CostoUnitario float64 `json:"costo_unitario" db:"costo_unitario"`
	NombreProducto string  `json:"nombre_producto,omitempty" db:"nombre_producto"`
}

type EntradaCreate struct {
	Proveedor     *string               `json:"proveedor"`
	Observaciones *string               `json:"observaciones"`
	Detalles      []DetalleEntradaCreate `json:"detalles" validate:"required,min=1"`
}

type DetalleEntradaCreate struct {
	ProductoID    int     `json:"producto_id" validate:"required"`
	Cantidad      int     `json:"cantidad" validate:"required,gt=0"`
	CostoUnitario float64 `json:"costo_unitario" validate:"required,gt=0"`
}
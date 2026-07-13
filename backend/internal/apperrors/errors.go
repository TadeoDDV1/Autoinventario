package apperrors

import (
	"errors"
	"fmt"
)

var (
	ErrNotFound          = errors.New("recurso no encontrado")
	ErrProductoNoFound   = errors.New("producto no encontrado")
	ErrCategoriaNoFound  = errors.New("categoría no encontrada")
	ErrVentaNoFound      = errors.New("venta no encontrada")
	ErrEntradaNoFound    = errors.New("entrada no encontrada")
	ErrStockInsuficiente = errors.New("stock insuficiente")
	ErrNoHayCampos       = errors.New("no hay campos para actualizar")
	ErrIDInvalido        = errors.New("id inválido")
	ErrSKUExiste         = errors.New("ya existe un producto con ese SKU")
)

type StockError struct {
	ProductoID     int
	Disponible     int
	Solicitado     int
	ProductoNombre string
}

func (e *StockError) Error() string {
	return fmt.Sprintf("stock insuficiente para producto %d (disponible: %d, solicitado: %d)",
		e.ProductoID, e.Disponible, e.Solicitado)
}

func (e *StockError) Unwrap() error { return ErrStockInsuficiente }

func NewStockError(productoID, disponible, solicitado int, nombre string) error {
	return &StockError{
		ProductoID:     productoID,
		Disponible:     disponible,
		Solicitado:     solicitado,
		ProductoNombre: nombre,
	}
}

type NotFoundError struct {
	Recurso string
	ID      int
}

func (e *NotFoundError) Error() string {
	return fmt.Sprintf("%s con id %d no encontrado", e.Recurso, e.ID)
}

func (e *NotFoundError) Unwrap() error { return ErrNotFound }

func NewNotFound(recurso string, id int) error {
	return &NotFoundError{Recurso: recurso, ID: id}
}

package apperrors

import (
	"errors"
	"testing"
)

func TestStockError(t *testing.T) {
	err := NewStockError(10, 2, 5, "Martillo")
	if err == nil {
		t.Fatal("expected error, got nil")
	}

	if !errors.Is(err, ErrStockInsuficiente) {
		t.Errorf("expected errors.Is(err, ErrStockInsuficiente) to be true")
	}

	stockErr, ok := err.(*StockError)
	if !ok {
		t.Fatalf("expected *StockError type, got %T", err)
	}

	if stockErr.ProductoID != 10 || stockErr.Disponible != 2 || stockErr.Solicitado != 5 || stockErr.ProductoNombre != "Martillo" {
		t.Errorf("unexpected StockError fields: %+v", stockErr)
	}

	expectedMsg := "stock insuficiente para producto 10 (disponible: 2, solicitado: 5)"
	if err.Error() != expectedMsg {
		t.Errorf("expected message %q, got %q", expectedMsg, err.Error())
	}
}

func TestNotFoundError(t *testing.T) {
	err := NewNotFound("producto", 42)
	if err == nil {
		t.Fatal("expected error, got nil")
	}

	if !errors.Is(err, ErrNotFound) {
		t.Errorf("expected errors.Is(err, ErrNotFound) to be true")
	}

	expectedMsg := "producto con id 42 no encontrado"
	if err.Error() != expectedMsg {
		t.Errorf("expected message %q, got %q", expectedMsg, err.Error())
	}
}

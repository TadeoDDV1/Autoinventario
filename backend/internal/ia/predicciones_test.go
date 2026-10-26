package ia

import (
	"testing"
	"time"
)

func TestClasificarUrgencia(t *testing.T) {
	// Stock en 0 con ventas
	nivel, razon := clasificarUrgencia(0, 5, 0, 2.5, time.Now().AddDate(0, -2, 0), 75, false)
	if nivel != "critico" {
		t.Errorf("expected 'critico', got %q (%s)", nivel, razon)
	}

	// Días restantes <= 3
	nivel, _ = clasificarUrgencia(5, 2, 2.0, 2.5, time.Now().AddDate(0, -2, 0), 75, false)
	if nivel != "critico" {
		t.Errorf("expected 'critico' for 2 days left, got %q", nivel)
	}

	// Stock por debajo del mínimo
	nivel, _ = clasificarUrgencia(3, 5, 6.0, 0.5, time.Now().AddDate(0, -2, 0), 15, false)
	if nivel != "urgente" {
		t.Errorf("expected 'urgente', got %q", nivel)
	}

	// Stock saludable
	nivel, _ = clasificarUrgencia(100, 10, 50.0, 2.0, time.Now().AddDate(0, -2, 0), 60, false)
	if nivel != "normal" {
		t.Errorf("expected 'normal', got %q", nivel)
	}

	// Sin ventas
	nivel, _ = clasificarUrgencia(10, 2, 0, 0, time.Now().AddDate(0, -1, 0), 0, false)
	if nivel != "sin_ventas" {
		t.Errorf("expected 'sin_ventas', got %q", nivel)
	}

	// Producto muerto (>60 días sin ventas)
	nivel, _ = clasificarUrgencia(10, 2, 0, 0, time.Now().AddDate(0, -3, 0), 0, false)
	if nivel != "muerto" {
		t.Errorf("expected 'muerto', got %q", nivel)
	}
}

func TestRound2(t *testing.T) {
	if got := round2(12.3456); got != 12.35 {
		t.Errorf("round2(12.3456) = %f, expected 12.35", got)
	}
	if got := round2(12.3411); got != 12.34 {
		t.Errorf("round2(12.3411) = %f, expected 12.34", got)
	}
}

func TestGenerarRecomendaciones(t *testing.T) {
	resumen := &PrediccionesResumen{
		ProductosCriticos: 2,
		ProductosUrgentes: 1,
		ValorCritico:      450.50,
	}
	recs := generarRecomendaciones(resumen)
	if len(recs) == 0 {
		t.Fatal("expected recommendations, got none")
	}
}

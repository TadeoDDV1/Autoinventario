package ia

import (
	"testing"
)

func TestDetectarIntencion(t *testing.T) {
	tests := []struct {
		mensaje  string
		expected string
	}{
		{"¿Qué le ofrezco a alguien que compra un taladro?", "recomendar"},
		{"¿Para qué sirve el teflón?", "para_que_sirve"},
		{"Diferencia entre PVC y CPVC", "comparar"},
		{"¿Qué alternativa hay al cemento?", "sustituto"},
		{"¿Qué se usa junto con la pintura?", "complemento"},
		{"¿Cuánto stock tengo de brocas?", "stock"},
		{"ayuda", "ayuda"},
		{"algo sin sentido xyz123", "desconocida"},
	}

	for _, tt := range tests {
		got := detectarIntencion(tt.mensaje)
		if got != tt.expected {
			t.Errorf("detectarIntencion(%q) = %q, expected %q", tt.mensaje, got, tt.expected)
		}
	}
}

func TestEsSaludo(t *testing.T) {
	if !esSaludo("hola buenas tardes") {
		t.Error("expected 'hola buenas tardes' to be recognized as greeting")
	}
	if !esSaludo("hey que tal") {
		t.Error("expected 'hey que tal' to be recognized as greeting")
	}
	if esSaludo("precio del tubo pvc") {
		t.Error("expected 'precio del tubo pvc' to NOT be recognized as greeting")
	}
}

func TestExtraerKeyword(t *testing.T) {
	kw := extraerKeyword("necesito brocas para concreto")
	if kw == "" {
		t.Error("expected keyword to be extracted from 'necesito brocas para concreto'")
	}
}

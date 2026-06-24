package pagos

import (
	"context"
	"encoding/json"
	"testing"
)

// fakeProvider es un PaymentProvider mockeado para tests de Handler.
// NO toca la red ni requiere claves de Stripe.
type fakeProvider struct {
	parseWebhook func(payload []byte, signature string) (*WebhookEvent, error)
	parseCalled  bool
}

func (f *fakeProvider) Name() string { return "fake" }
func (f *fakeProvider) CreateCharge(_ context.Context, _ ChargeRequest) (*ChargeResponse, error) {
	return &ChargeResponse{ProviderRef: "ch_fake", Status: "succeeded"}, nil
}
func (f *fakeProvider) GetCharge(_ context.Context, _ string) (*ChargeStatus, error) {
	return &ChargeStatus{ProviderRef: "ch_fake", Status: "succeeded"}, nil
}
func (f *fakeProvider) Refund(_ context.Context, _ string, _ int64) (*RefundResponse, error) {
	return &RefundResponse{RefundRef: "re_fake", Status: "succeeded"}, nil
}
func (f *fakeProvider) ParseWebhook(p []byte, s string) (*WebhookEvent, error) {
	f.parseCalled = true
	if f.parseWebhook != nil {
		return f.parseWebhook(p, s)
	}
	return nil, nil
}

func TestMapStripeStatus(t *testing.T) {
	tests := []struct {
		in   string
		want string
	}{
		{"succeeded", "succeeded"},
		{"requires_action", "requires_action"},
		{"processing", "pending"},
		{"requires_payment_method", "failed"},
		{"canceled", "failed"},
		{"unknown_status", "pending"},
	}
	for _, tt := range tests {
		got := mapStripeStatus(tt.in)
		if got != tt.want {
			t.Errorf("mapStripeStatus(%q) = %q, want %q", tt.in, got, tt.want)
		}
	}
}

func TestMapEstadoWebhook(t *testing.T) {
	tests := []struct {
		in   string
		want string
	}{
		{"succeeded", "aprobado"},
		{"failed", "rechazado"},
		{"refunded", "reembolsado"},
		{"unknown", ""}, // vacío: handler no actualiza BD
	}
	for _, tt := range tests {
		got := mapEstadoWebhook(tt.in)
		if got != tt.want {
			t.Errorf("mapEstadoWebhook(%q) = %q, want %q", tt.in, got, tt.want)
		}
	}
}

func TestPagoErrorKind(t *testing.T) {
	err := NewCardError("card_declined", "tu tarjeta fue rechazada", nil)
	if !IsCardDeclined(err) {
		t.Errorf("IsCardDeclined(NewCardError(...)) = false, want true")
	}
	if IsNetwork(err) {
		t.Errorf("IsNetwork(NewCardError(...)) = true, want false")
	}

	netErr := NewNetworkError("timeout", nil)
	if IsCardDeclined(netErr) {
		t.Errorf("IsCardDeclined(NewNetworkError(...)) = true, want false")
	}
	if !IsNetwork(netErr) {
		t.Errorf("IsNetwork(NewNetworkError(...)) = false, want true")
	}
}

func TestChargeResponseMessageAsJSON(t *testing.T) {
	resp := &ChargeResponse{
		ProviderRef:  "ch_123",
		Status:       "requires_action",
		ClientSecret: "cs_abc",
		Message:      "needs 3DS",
		NextAction: &NextAction{
			Type:        "use_stripe_sdk",
			RedirectURL: "https://example.com/3ds",
		},
	}
	meta := map[string]string{"venta_id": "42"}
	got := resp.MessageAsJSON(meta)

	var parsed map[string]any
	if err := json.Unmarshal(got, &parsed); err != nil {
		t.Fatalf("MessageAsJSON returned invalid JSON: %v", err)
	}
	if parsed["client_secret"] != "cs_abc" {
		t.Errorf("client_secret = %v, want cs_abc", parsed["client_secret"])
	}
	if parsed["next_action_type"] != "use_stripe_sdk" {
		t.Errorf("next_action_type = %v", parsed["next_action_type"])
	}
	if parsed["metadata"].(map[string]any)["venta_id"] != "42" {
		t.Errorf("metadata.venta_id = %v", parsed["metadata"])
	}
}

func TestNewIdempotencyKey(t *testing.T) {
	k1 := newIdempotencyKey()
	k2 := newIdempotencyKey()
	if k1 == "" || k2 == "" {
		t.Fatalf("idempotency keys vacías")
	}
	if k1 == k2 {
		t.Errorf("dos keys consecutivas son iguales (deberían ser únicas): %s", k1)
	}
	if len(k1) != 32 { // 16 bytes en hex
		t.Errorf("len(key) = %d, want 32", len(k1))
	}
}

func TestManagerGetSinPrincipalCarga(t *testing.T) {
	// Sin claves no debe crashear; el manager queda sin drivers pero responde.
	mgr, err := NewManager(ManagerConfig{
		Principal:           "stripe",
		StripeSecretKey:     "",
		StripeWebhookSecret: "",
	})
	if err != nil {
		t.Fatalf("NewManager: %v", err)
	}
	if mgr.Principal() != "stripe" {
		t.Errorf("Principal() = %q, want stripe", mgr.Principal())
	}
	if len(mgr.Available()) != 0 {
		t.Errorf("Available() = %v, want []", mgr.Available())
	}
	_, err = mgr.Get("stripe")
	if err == nil {
		t.Errorf("Get(\"stripe\") sin driver: err = nil, want error")
	}
}

func TestManagerGetProviderDesconocido(t *testing.T) {
	mgr := &Manager{
		providers: map[string]PaymentProvider{
			"fake": &fakeProvider{},
		},
		principal: "fake",
	}
	_, err := mgr.Get("mercadopago")
	if err == nil {
		t.Errorf("Get(\"mercadopago\") con sólo fake cargado: err = nil, want error")
	}
}

func TestNewStripeDriverRechazaConfigInvalida(t *testing.T) {
	// Sin secret key
	_, err := NewStripeDriver("", "whsec_x")
	if err == nil {
		t.Errorf("NewStripeDriver(\"\", \"whsec\"): err = nil, want error")
	}

	// Sin webhook secret
	_, err = NewStripeDriver("sk_test_abc", "")
	if err == nil {
		t.Errorf("NewStripeDriver(sk, \"\"): err = nil, want error")
	}

	// Secret key mal formada
	_, err = NewStripeDriver("pk_test_abc", "whsec_x")
	if err == nil {
		t.Errorf("NewStripeDriver(pk_*, ...): err = nil, want error (debe empezar con sk_)")
	}

	// Válido
	d, err := NewStripeDriver("sk_test_abcdef", "whsec_xyz")
	if err != nil {
		t.Fatalf("NewStripeDriver válido: %v", err)
	}
	if d.Name() != "stripe" {
		t.Errorf("Name() = %q, want stripe", d.Name())
	}
	if d.IsLive() {
		t.Errorf("IsLive() con sk_test_*: true, want false")
	}
	if d.IsLive() {
		// ya cubierto arriba
	}
	live, _ := NewStripeDriver("sk_live_abcdef", "whsec_xyz")
	if !live.IsLive() {
		t.Errorf("IsLive() con sk_live_*: false, want true")
	}
}

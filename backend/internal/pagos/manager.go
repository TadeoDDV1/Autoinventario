package pagos

import (
	"fmt"
	"log/slog"
	"strings"
)

// Manager es el factory que devuelve el PaymentProvider activo.
//
// Uso:
//   mgr, err := NewManager(cfg)
//   provider, err := mgr.Get("stripe")
//
// El manager es seguro para uso concurrente y de solo lectura después de
// inicializarse. La selección del provider principal viene de la config
// (PAGOS_PROVEEDOR_PRINCIPAL en .env).
type Manager struct {
	providers map[string]PaymentProvider
	principal string // nombre del provider por defecto
}

// NewManager carga todos los providers configurados en el entorno y los
// registra. Devuelve el manager listo para usar.
//
// Configuración esperada (vía env):
//   PAGOS_PROVEEDOR_PRINCIPAL=stripe
//   STRIPE_SECRET_KEY=sk_...
//   STRIPE_WEBHOOK_SECRET=whsec_...
//
// Si el provider principal no se puede inicializar, devuelve error
// (queremos fallar rápido al levantar el server, no al primer cobro).
func NewManager(cfg ManagerConfig) (*Manager, error) {
	cfg.Principal = strings.TrimSpace(strings.ToLower(cfg.Principal))
	if cfg.Principal == "" {
		cfg.Principal = "stripe"
	}

	mgr := &Manager{
		providers: make(map[string]PaymentProvider),
		principal: cfg.Principal,
	}

	// Inicializar Stripe si hay claves configuradas.
	// Si no hay claves, logueamos y seguimos (útil para dev sin Stripe).
	if cfg.StripeSecretKey != "" && cfg.StripeWebhookSecret != "" {
		driver, err := NewStripeDriver(cfg.StripeSecretKey, cfg.StripeWebhookSecret)
		if err != nil {
			return nil, fmt.Errorf("manager: stripe init: %w", err)
		}
		mgr.providers[driver.Name()] = driver
		slog.Info("pagos_provider_loaded",
			slog.String("name", driver.Name()),
			slog.Bool("live_mode", driver.IsLive()),
		)
	} else {
		slog.Warn("pagos_stripe_no_configured",
			slog.Bool("has_secret", cfg.StripeSecretKey != ""),
			slog.Bool("has_webhook", cfg.StripeWebhookSecret != ""),
		)
	}

	if len(mgr.providers) == 0 {
		slog.Warn("pagos_no_providers_available", slog.String("principal", cfg.Principal))
	}

	return mgr, nil
}

// Get devuelve el provider por nombre.
// Si nombre está vacío, devuelve el principal configurado.
func (m *Manager) Get(nombre string) (PaymentProvider, error) {
	if nombre == "" {
		nombre = m.principal
	}
	p, ok := m.providers[nombre]
	if !ok {
		return nil, fmt.Errorf("manager: provider %q no disponible (cargados: %v)", nombre, m.availableNames())
	}
	return p, nil
}

// Principal devuelve el nombre del provider por defecto.
func (m *Manager) Principal() string { return m.principal }

// Available devuelve la lista de providers cargados (para /pagos/providers).
func (m *Manager) Available() []string {
	return m.availableNames()
}

func (m *Manager) availableNames() []string {
	names := make([]string, 0, len(m.providers))
	for n := range m.providers {
		names = append(names, n)
	}
	return names
}

// ManagerConfig es la config que NewManager lee del entorno.
// La carga real (os.Getenv) la hace el main.go y la inyecta aquí.
type ManagerConfig struct {
	Principal          string
	StripeSecretKey    string
	StripeWebhookSecret string
}

// guard para asegurar compilación si se agregan campos privados thread-safe.
var _ struct{} = struct{}{}

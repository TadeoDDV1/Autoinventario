# Plan Maestro: Pagos múltiples + Mejoras pendientes

**Fecha:** 2026-06-22
**Estado:** Pendiente aprobación
**Stack:** Go 1.21+ / Gin / sqlx / MySQL · Flutter 3.x / Riverpod 2.x
**Contexto:** Cierre de pendientes del plan 10-jun + nueva funcionalidad de pagos con múltiples proveedores.

---

## 🎯 Objetivo

Cuatro frentes que se trabajarán en paralelo, priorizados por impacto/coste:

1. **Pagos con tarjeta** (nuevo): integrar Stripe como primer proveedor, arquitectura preparada para sumar más.
2. **Cierre de pendientes baratos** del plan 10-jun: atajos de teclado y widget de uso.
3. **UX del modo caja**: drag & drop + totales grandes + cobro rápido.
4. **Toggle de IA en Dashboard** (1 archivo).

---

## 💳 Bloque 1 — Pagos: Stripe + arquitectura multi-proveedor

### 1.1 Panorama de proveedores México (junio 2026)

| Proveedor | Tipo | Comisión tarjeta | MSI (meses sin intereses) | Métodos locales | SDK Go oficial | Webhook | Notas |
|---|---|---|---|---|---|---|---|
| **Stripe** | Internacional | ~3.6% + $3 MXN | Sí (3, 6, 12, 18) | Tarjeta, Apple/Google Pay | ✅ `stripe-go` | ✅ | Mejor DX, docs, sandbox. No tiene SPEI/efectivo nativo. |
| **Conekta** | 🇲🇽 México | ~3.6% + IVA | Sí | Tarjeta, **SPEI, BBVA, OXXO, Aplazo, Coppel Pay** | ✅ `conekta-go` | ✅ | Mejor para pagos en efectivo (OXXO Pay). 90%+ mexicanos bancarizados. |
| **MercadoPago** | 🇲🇽 LATAM | ~4.99% online / 3.99% QR | Sí | Tarjeta, **efectivo, transferencia, MSIs** | ✅ `mercadopago-sdk-go` (comunidad) | ✅ | Mayor reconocimiento de marca. SDK Go comunitario, no oficial. |
| **OpenPay** | 🇲🇽 México (BBVA) | ~3.5% + $2.5 | Sí | Tarjeta, **SPEI, tiendas** | ✅ `openpay-go` (oficial) | ✅ | Backed por BBVA, sólido. Menos popular. |
| **Clip** | 🇲🇽 México | **3.6% + IVA** flat | Sí (12 MSI) | Terminal física + app | ❌ Solo API REST | ⚠️ Limitado | Mejor para **terminal física** que ya compre el comercio. |
| **STP / Banco directo** | 🇲🇽 México | Negociable (1.5-2.5%) | A acuerdo | SPEI | ❌ Custom | ❌ Custom | Requiere integración directa con banco. Más complejo. |

**Decisión recomendada:** **Stripe como proveedor principal** (el usuario ya lo pidió) + arquitectura `PaymentProvider` interface para que mañana puedas agregar **Conekta** (OXXO/SPEI) o **MercadoPago** (efectivo) con un cambio de config, sin reescribir el módulo de caja.

### 1.2 Arquitectura propuesta

```
┌──────────────────────────────────────────────────────┐
│  Frontend (Flutter)                                  │
│                                                      │
│  ┌──────────────┐    ┌──────────────────────────┐   │
│  │ caja_screen  │ →  │ PaymentProviderSelector  │   │
│  └──────────────┘    │ (UI: elegir método)      │   │
│                      └──────────┬───────────────┘   │
│                                 │                    │
│                      ┌──────────▼───────────────┐   │
│                      │ PaymentService           │   │
│                      │ (orquesta contra backend)│   │
│                      └──────────┬───────────────┘   │
│                                 │ HTTP              │
└─────────────────────────────────┼──────────────────┘
                                  │
┌─────────────────────────────────▼──────────────────┐
│  Backend (Go)                                       │
│                                                    │
│  ┌──────────────────────────────────────────────┐ │
│  │ /api/v1/pagos (nuevo router)                 │ │
│  └────────┬─────────────────────────────────────┘ │
│           │                                        │
│  ┌────────▼────────────┐                           │
│  │ PaymentManager      │ ← factory pattern        │
│  │ (selecciona driver) │                           │
│  └──┬─────┬─────┬──────┘                           │
│     │     │     │                                  │
│  ┌──▼──┐┌─▼──┐┌─▼─────┐                            │
│  │Stri ││Cnk ││MP stub│  ← cada driver implementa │
│  │peDrv││Drv ││       │     PaymentProvider        │
│  └─────┘└────┘└───────┘                            │
│                                                    │
│  ┌──────────────────────────┐                      │
│  │ /api/v1/pagos/webhook    │ ← endpoint único     │
│  │ (recibe TODOS los provee)│   que rutea al driver│
│  └──────────────────────────┘                      │
│                                                    │
│  ┌──────────────────────────┐                      │
│  │ Tabla MySQL nueva:       │                      │
│  │ pagos (transacciones)    │                      │
│  │ ventas.metodo_pago       │ ← enum              │
│  │ ventas.referencia_pago   │ ← ID del proveedor  │
│  └──────────────────────────┘                      │
└────────────────────────────────────────────────────┘
```

### 1.3 Schema de BD nuevo

```sql
-- Tabla de pagos (auditoría de TODAS las transacciones con proveedor externo)
CREATE TABLE pagos (
  id              BIGINT AUTO_INCREMENT PRIMARY KEY,
  venta_id        BIGINT NOT NULL,
  proveedor       ENUM('stripe','conekta','mercadopago','efectivo','transferencia') NOT NULL,
  referencia      VARCHAR(128) NOT NULL,         -- ID del charge en el proveedor
  monto_centavos  BIGINT NOT NULL,               -- evitar floats
  moneda          CHAR(3) DEFAULT 'MXN',
  estado          ENUM('pendiente','aprobado','rechazado','reembolsado') NOT NULL,
  metodo_pago     VARCHAR(64),                   -- 'card','oxxo','spei','cash'
  installments    INT DEFAULT 1,                 -- MSIs
  ult_4           CHAR(4),                       -- últimos 4 dígitos (si tarjeta)
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  metadata_json   JSON,                          -- payload completo del proveedor
  INDEX idx_venta (venta_id),
  INDEX idx_proveedor_ref (proveedor, referencia),
  CONSTRAINT fk_pago_venta FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Modificar tabla ventas
ALTER TABLE ventas
  ADD COLUMN metodo_pago        ENUM('efectivo','tarjeta','transferencia','mixto') DEFAULT 'efectivo' AFTER total,
  ADD COLUMN monto_recibido     DECIMAL(12,2) DEFAULT 0 AFTER metodo_pago,   -- para calcular cambio
  ADD COLUMN cambio             DECIMAL(12,2) DEFAULT 0 AFTER monto_recibido,
  ADD COLUMN referencia_pago    VARCHAR(128) DEFAULT NULL AFTER cambio;     -- ID del pago aprobado
```

### 1.4 Interface Go (`backend/internal/pagos/`)

```go
// pago_provider.go — interface que implementan todos los drivers
type PaymentProvider interface {
    Name() string
    CreateCharge(ctx context.Context, req ChargeRequest) (*ChargeResponse, error)
    GetCharge(ctx context.Context, providerRef string) (*ChargeStatus, error)
    Refund(ctx context.Context, providerRef string, amountCentavos int64) (*RefundResponse, error)
    ParseWebhook(payload []byte, signature string) (*WebhookEvent, error)
    // El provider concreto se auto-registra en init()
}

type ChargeRequest struct {
    AmountCentavos    int64
    Currency          string
    Description       string
    CustomerEmail     string
    Metadata          map[string]string
    PaymentMethodID   string  // opaco, depende del provider
    Installments      int
    StatementDescriptor string // aparecer en el estado de cuenta
}

type ChargeResponse struct {
    ProviderRef  string
    Status       string  // 'succeeded','requires_action','failed'
    ClientSecret string  // para 3DS / SCA
    NextAction   *NextAction
}
```

### 1.5 Tareas de implementación

**Fase 1A — Stripe (1 sesión)**
- [ ] `backend/go.mod`: agregar `github.com/stripe/stripe-go/v76`
- [ ] `backend/.env.example`: agregar `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`, `STRIPE_WEBHOOK_SECRET`
- [ ] `backend/internal/pagos/provider.go` (interface)
- [ ] `backend/internal/pagos/stripe_driver.go` (~200 líneas)
- [ ] `backend/internal/pagos/manager.go` (factory)
- [ ] `backend/internal/pagos/handler.go` (endpoints: create-charge, get-status, refund, webhook)
- [ ] `backend/internal/router/router.go`: agregar `/api/v1/pagos/*` y `/api/v1/pagos/webhook`
- [ ] `backend/migrations/2026-06-22_pagos.sql` (schema nuevo)
- [ ] `frontend/pubspec.yaml`: agregar `flutter_stripe: ^11.0.0`
- [ ] `frontend/lib/services/payment_service.dart` (orquesta contra backend)
- [ ] `frontend/lib/models/pago.dart` (Pago, EstadoPago, MetodoPago)
- [ ] `frontend/lib/screens/pagos/pago_screen.dart` (PaymentSheet de Stripe)
- [ ] `frontend/lib/screens/caja/caja_screen.dart`: integrar botón "Cobrar con tarjeta"
- [ ] `frontend/lib/screens/caja/quick_cart_summary.dart`: agregar sección "Método de pago" + cambio
- [ ] `frontend/lib/widgets/pagos/payment_method_selector.dart` (dropdown con métodos disponibles)
- [ ] `frontend/lib/widgets/pagos/efectivo_dialog.dart` (calculadora de cambio)

**Fase 1B — Conekta (opcional, siguiente sesión)**
- [ ] Solo si el usuario lo pide. Aprovecha la interface; ~150 líneas.

**Fase 1C — Sandbox / testing**
- [ ] Backend: tests con `httptest` simulando el webhook de Stripe
- [ ] Frontend: usar claves TEST de Stripe (pk_test_*, sk_test_*)
- [ ] Tarjeta de prueba: `4242 4242 4242 4242` (visa ok), `4000 0000 0000 0002` (rechazo)

### 1.6 Variables de entorno a agregar

```bash
# backend/.env.example — líneas nuevas
STRIPE_SECRET_KEY=sk_test_***           # sandbox
STRIPE_PUBLISHABLE_KEY=pk_test_***      # expuesta al frontend
STRIPE_WEBHOOK_SECRET=whsec_***         # del dashboard de Stripe

# Proveedor activo (futuro)
PAGOS_PROVEEDOR_PRINCIPAL=stripe        # stripe|conekta|mercadopago

# Cuando agreguemos:
CONEKTA_PUBLIC_KEY=***
CONEKTA_PRIVATE_KEY=***
```

### 1.7 Riesgos a tener en cuenta

- **PCI DSS scope**: usando `PaymentSheet` de Stripe en Flutter + `stripe-go` en backend, **NO manejamos tarjetas directamente** → scope SAQ-A, no se requiere certificación. ✅
- **MSIs (Meses Sin Intereses)**: Stripe México los soporta pero requiere cuenta habilitada. Configurar en dashboard.
- **3D Secure / SCA**: Stripe lo activa automáticamente cuando el banco lo requiere. El `next_action` que devuelve el backend lo maneja el `PaymentSheet`.
- **Webhooks en localhost**: usar `stripe listen --forward-to http://localhost:8080/api/v1/pagos/webhook` (Stripe CLI). Documentar en README.
- **Dinero real vs sandbox**: distinguir `sk_live_*` vs `sk_test_*` con un check de prefijo en el `manager`.

---

## 🔧 Bloque 2 — Cierre de pendientes baratos (plan 10-jun)

### 2.1 Ctrl+K en Caja abre chat
- **Archivo:** `frontend/lib/screens/caja/caja_screen.dart`
- **Cambio:** agregar `Shortcuts`/`Actions` widget para `LogicalKeySet(control, LogicalKey.keyK)` → `Navigator.pushNamed(context, '/chat')`
- **Esfuerzo:** 15 min

### 2.2 Widget `uso_tooltip.dart` (mostrar "para qué sirve" al hover/long-press)
- **Archivo nuevo:** `frontend/lib/widgets/inventario/uso_tooltip.dart`
- **Función:** leer `frontend/assets/conocimiento_ferreteria.json` y mostrar descripción/uso al hacer long-press en un producto de la lista
- **Esfuerzo:** 1-2 horas

### 2.3 Refrescar `CopilotPanel` para usar `TarjetaSugerencia` (recuadro inset)
- **Archivos:**
  - `frontend/lib/widgets/ia/copilot_panel.dart` (refactor: reemplazar chips planos por tarjetas)
  - Reutilizar `tarjeta_sugerencia.dart` (ya existe del commit `c811c81`)
- **Esfuerzo:** 1 hora

---

## 🛒 Bloque 3 — UX del modo caja

### 3.1 Drag & drop en el carrito
- **Archivo:** `frontend/lib/screens/caja/caja_screen.dart` + `quick_cart_summary.dart`
- **Librería:** `flutter_reorderable_list` (ya viene en Flutter SDK) o `drag_and_drop_lists`
- **Esfuerzo:** 2-3 horas

### 3.2 Totales más grandes
- **Archivo:** `frontend/lib/widgets/caja/quick_cart_summary.dart`
- **Cambio:** `Text(total, style: TextStyle(fontSize: 36, fontWeight: bold))` en lugar de 18
- **Esfuerzo:** 15 min

### 3.3 Atajo `Ctrl+P` para cobro rápido
- **Archivo:** `frontend/lib/screens/caja/caja_screen.dart`
- **Comportamiento:** abre el diálogo de pago con el método por defecto (efectivo)
- **Esfuerzo:** 30 min

---

## 🏠 Bloque 4 — Toggle IA en Dashboard (1 archivo)

- **Archivo:** `frontend/lib/screens/dashboard/dashboard_screen.dart`
- **Cambio:** agregar `IconButton` en el `AppBar` que llame al `iaProvider.toggle()`. Reutilizar `fuente_ia_badge.dart` que ya existe.
- **Esfuerzo:** 30 min

---

## 📅 Roadmap propuesto

| # | Bloque | Sesiones | Bloqueante |
|---|---|---|---|
| 1 | **Pagos Fase 1A (Stripe)** | 1 sesión larga (4-5h) | Necesita claves de Stripe |
| 2 | Pendientes baratos (Ctrl+K, uso_tooltip, CopilotPanel) | 1 sesión corta (1.5h) | No |
| 3 | UX caja (drag&drop, totales, Ctrl+P) | 1 sesión (3h) | No |
| 4 | Toggle IA Dashboard | 15 min | No |
| 5 | Pagos Fase 1B (Conekta, si lo decides) | 1 sesión (3h) | Necesita claves |
| 6 | Tests del módulo pagos | 1 sesión (2h) | Bloque 1 listo |

**Total estimado sin bloque 5/6:** ~1 sesión larga + 2 cortas = **~9 horas de trabajo**.

---

## ✅ Criterios de éxito

### Pagos
- [ ] Compra con tarjeta de prueba `4242...` aprueba y se persiste en `pagos`
- [ ] Webhook de Stripe actualiza el estado de la venta
- [ ] `PaymentSheet` se cierra, vuelve a la app, y se ve el ticket con `metodo_pago='tarjeta'`
- [ ] Reembolso desde el dashboard de Stripe se refleja en `pagos.estado='reembolsado'`
- [ ] Frontend puede leer claves públicas desde build args (no hardcoded)
- [ ] `flutter build linux --release` y `go build ./...` sin errores
- [ ] Verificado end-to-end con `curl` + screenshot del `PaymentSheet`

### Pendientes baratos
- [ ] `Ctrl+K` desde Caja abre chat (verificado manualmente con screenshot)
- [ ] Long-press en producto del inventario muestra tooltip con "para qué sirve"
- [ ] `CopilotPanel` usa `TarjetaSugerencia` con recuadro inset (verificado visualmente)

### UX caja
- [ ] Drag & drop reordena items del carrito
- [ ] Total se ve a 36pt en negrita
- [ ] `Ctrl+P` abre el diálogo de pago con método por defecto

### Dashboard
- [ ] Botón en AppBar togglea IA on/off, el badge se actualiza inmediatamente

---

## 🔗 Archivos a tocar (resumen)

**Backend nuevos (10):**
- `backend/internal/pagos/provider.go`
- `backend/internal/pagos/manager.go`
- `backend/internal/pagos/handler.go`
- `backend/internal/pagos/stripe_driver.go`
- `backend/internal/pagos/webhook_router.go`
- `backend/internal/pagos/errors.go`
- `backend/internal/pagos/charge.go` (modelos)
- `backend/internal/repository/pago_repo.go`
- `backend/migrations/2026-06-22_pagos.sql`
- `backend/internal/pagos/stripe_driver_test.go`

**Backend modificados (3):**
- `backend/go.mod`, `backend/go.sum`
- `backend/.env.example`
- `backend/internal/router/router.go`
- `backend/internal/handler/venta_handler.go` (relacionar venta con pago)

**Frontend nuevos (8):**
- `frontend/lib/models/pago.dart`
- `frontend/lib/services/payment_service.dart`
- `frontend/lib/screens/pagos/pago_screen.dart`
- `frontend/lib/widgets/pagos/payment_method_selector.dart`
- `frontend/lib/widgets/pagos/efectivo_dialog.dart`
- `frontend/lib/widgets/pagos/tarjeta_dialog.dart`
- `frontend/lib/widgets/inventario/uso_tooltip.dart`

**Frontend modificados (5):**
- `frontend/lib/screens/caja/caja_screen.dart` (Ctrl+K + Ctrl+P + drag&drop + pago)
- `frontend/lib/screens/caja/quick_cart_summary.dart` (totales grandes + método de pago)
- `frontend/lib/widgets/ia/copilot_panel.dart` (refactor a TarjetaSugerencia)
- `frontend/lib/screens/dashboard/dashboard_screen.dart` (toggle IA)
- `frontend/pubspec.yaml` (flutter_stripe)

---

## 🚦 Decisiones pendientes con Tadeo (22-jun)

1. **¿Arrancamos con pagos (Stripe) primero, o con los pendientes baratos (1.5h)?** Sugerencia: pendientes baratos primero (calentamos + limpian la base), después pagos (más grande).
2. **¿Te interesa agregar Conekta desde el inicio, o lo dejamos solo con Stripe por ahora?**
3. **¿Tienes cuenta de Stripe ya creada, o necesitas ayuda con el setup (cuenta sandbox)?**
4. **¿El método de pago por defecto al cobrar va a ser `efectivo` (como ahora) y "tarjeta" como segunda opción?**
5. **¿Quieres que el ticket PDF (que ya existe) incluya el método de pago y últimos 4 dígitos de la tarjeta?**

---

## 📚 Referencias

- Stripe México: https://stripe.com/mx
- Conekta: https://www.conekta.com (3.6% + IVA, OXXO/SPEI)
- MercadoPago: https://www.mercadopago.com.mx (~4.99%, OXXO/transferencia)
- OpenPay (BBVA): https://www.openpay.mx
- Clip: https://www.clip.mx (3.6% + IVA flat, terminal física)
- flutter_stripe SDK: https://pub.dev/packages/flutter_stripe
- stripe-go SDK: https://github.com/stripe/stripe-go

> **Nota:** Las comisiones listadas son las estándar reportadas a mediados de 2026. Antes de contratar, **verifica los precios actuales directamente con cada proveedor** — pueden tener descuentos por volumen o promociones para nuevoscomercios.

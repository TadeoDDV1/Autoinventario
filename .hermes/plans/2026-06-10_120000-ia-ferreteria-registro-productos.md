# Plan: IA Copilot para Vendedor + Registro Rápido de Productos

**Fecha:** 2026-06-10
**Status:** ✅ Aprobado, en ejecución
**Stack:** Go/Gin backend + Flutter frontend
**Autor:** Hermes Agent

---

## 🎯 Visión

La app de ferretería pasa de ser una **caja registradora** a un **asistente de ventas inteligente** que:
1. **Ayuda al vendedor inexperto** — sugiere productos complementarios, comparaciones, usos y cross-selling.
2. **Acelera el registro de productos** — escaneando códigos con cámara o pistola HID, autocompletando datos desde una base de conocimiento de ferretería.
3. **Es proactivo y dinámico** — la app guía al cajero, no necesita saber de ferretería.

## ✅ Decisiones del usuario (Tadeo)

| Pregunta | Respuesta |
|---|---|
| LLM obligatorio u opcional | **Opcional**, activable desde la pantalla de inicio |
| Onboarding inicial | **NO** (sin tutorial forzado) |
| Escaneo de productos | **AMBAS**: cámara móvil + pistola HID desktop |
| Historial de chat | **Sí**, guardable y consultable después |
| Quién llena el JSON de conocimiento | **Yo (Hermes) lo lleno** |

---

## 🐛 Bugs reales encontrados durante el análisis

### Bug #1: Mismatch `created_at` ↔ `fecha` en Venta (en historial)

**Archivo:** `frontend/lib/models/venta.dart` línea 82-84
**Síntoma:** El historial de ventas muestra la fecha como `null` o crashea al parsear.

**Causa:** El backend devuelve `created_at` (de la query SQL), pero `Venta.fromJson` busca `json['fecha']`.

**Fix:**
```dart
// ANTES
fecha: json['fecha'] != null ? DateTime.parse(json['fecha'] as String) : null,
// DESPUÉS
fecha: json['created_at'] != null
    ? DateTime.parse(json['created_at'] as String)
    : (json['fecha'] != null ? DateTime.parse(json['fecha'] as String) : null),
```

### Bug #2: `DetalleVenta.fromJson` no maneja `null` en `precio_unitario`

**Archivo:** `frontend/lib/models/venta.dart` línea 21
**Síntoma:** Si un detalle tiene `precio_unitario` null, crashea.

**Fix:**
```dart
precioUnitario: (json['precio_unitario'] as num?)?.toDouble() ?? 0.0,
```

### Bug #3 (preventivo): `TicketScreen` requiere `Venta` con folio

**Verificar:** `routes.dart` línea 53: `final venta = state.extra as Venta;` — debe ser seguro porque el quick_cart_summary pasa la venta con folio asignado del backend.

**Acción:** Validar que el flujo no crashea si `folio` es null.

---

## 📦 FASE 0 — Fixes críticos (bugs reales)

### 0.1 Fix `Venta.fromJson` — manejar `created_at` y nulls

**Archivo:** `frontend/lib/models/venta.dart`

- Cambiar `fecha: json['fecha']` → `fecha: json['created_at'] ?? json['fecha']`
- Hacer todos los campos numéricos null-safe con `?? 0.0`
- Hacer `nombreProducto` null-safe (puede ser `null` en el JOIN si producto fue borrado)

### 0.2 Verificar `getVentaById` y `historial_ventas_screen`

- Verificar que el detalle se muestre correctamente
- Si el backend devuelve el detalle como `null` o vacío, mostrar mensaje "Sin productos"

---

## 📦 FASE 1 — Base de conocimiento de ferretería

**Objetivo:** Tener un mapa de categorías y productos típicos que sirva para:
- Recomendar productos en el chat IA
- Autocompletar formularios de registro
- Mostrar "para qué sirve" en tooltips

### 1.1 Backend: `internal/ia/conocimiento_ferreteria.go`

**Archivo nuevo:** `backend/internal/ia/conocimiento_ferreteria.go`

Mapa estático de las 8 categorías que ya tienes en la BD:
- Herramientas Manuales
- Herramientas Eléctricas
- Electricidad
- Plomería
- Tornillería y Fijaciones
- Pintura y Acabados
- Construcción
- Seguridad Industrial

Estructura:
```go
type CategoriaConocimiento struct {
    Icono            string
    ProductosTipicos []string
    Necesita         []string
    Descripcion      string
    Keywords         []string
    Sustitutos       map[string][]string  // producto → alternativas
}

var ConocimientoFerreteria = map[string]CategoriaConocimiento{
    "Herramientas Eléctricas": {
        Icono:            "power",
        ProductosTipicos: []string{"taladro", "rotomartillo", "sierra circular", "lijadora", "esmeril"},
        Necesita:         []string{"broca", "disco de corte", "lija", "cinta métrica", "gafas protección"},
        Descripcion:      "Herramientas que funcionan con electricidad o batería para perforar, cortar, lijar",
        Keywords:         []string{"taladro", "rotomartillo", "sierra", "lijadora", "esmeril"},
    },
    "Plomería": {
        Icono:            "plumbing",
        ProductosTipicos: []string{"tubo PVC", "codo 90°", "codo 45°", "tee PVC", "válvula", "llave stillson"},
        Necesita:         []string{"teflón", "pegamento PVC", "cinta selladora", "codo"},
        Descripcion:      "Materiales y herramientas para instalación y reparación de tuberías",
        Keywords:         []string{"pvc", "codo", "tee", "válvula", "tubo", "plomería"},
    },
    // ... las 8 categorías
}
```

**Productos relacionales** (para cross-sell):
```go
var RelacionesProducto = map[string]ProductoConocimiento{
    "taladro": {
        Categoria:    "Herramientas Eléctricas",
        Compatibles:  []string{"broca", "disco corte", "cinta métrica", "gafas", "guantes"},
        Descripcion:  "Herramienta eléctrica para perforar superficies",
        Usos:         []string{"perforar concreto", "perforar madera", "perforar metal", "atornillar"},
    },
    "pvc": { ... },
    "broca": { ... },
    // ... 20-30 productos clave
}
```

### 1.2 Frontend: `assets/conocimiento_ferreteria.json`

Réplica del mapa Go para uso offline (sin red). Mismo contenido, formato JSON.

**Archivo nuevo:** `frontend/assets/conocimiento_ferreteria.json`

Y agregar a `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/conocimiento_ferreteria.json
```

---

## 📦 FASE 2 — IA Conversacional (el "Chat que sabe de ferreterías")

**Objetivo:** Reemplazar el `ChatScreen` actual (regex hardcoded) con un chat conversacional real.

### 2.1 Backend: nuevo endpoint `POST /api/v1/ia/chat`

**Archivo nuevo:** `backend/internal/ia/chat.go`

```go
type ChatRequest struct {
    Mensaje    string    `json:"mensaje"`
    Contexto   string    `json:"contexto,omitempty"`  // "caja" | "inventario" | "general"
    Historial  []ChatMsg `json:"historial,omitempty"`
    CarritoIDs []int     `json:"carrito_ids,omitempty"`
}

type ChatMsg struct {
    Rol   string `json:"rol"`   // "user" | "assistant"
    Texto string `json:"texto"`
}

type ChatResponse struct {
    Texto       string       `json:"texto"`
    Sugerencias []Sugerencia `json:"sugerencias,omitempty"`
    Fuente      string       `json:"fuente"`  // "reglas" | "llm" | "hibrido"
    Confianza   float64      `json:"confianza"`
}
```

**Lógica:**
1. **Detección de intención** (regex + keywords):
   - `recomendar|ofrecer|sugerir|vender` → recomienda
   - `qué es|para qué sirve|usos` → explica
   - `comparar|diferencia|vs` → compara
   - `alternativa|sustituto|más barato` → sustituto
   - `complemento|junto con|se usa con` → co-ocurrencias
   - `stock|bajo|agotar` → predicciones
   - `vendí|ventas` → dashboard
   - `ayuda` → listado de capacidades

2. **Búsqueda de productos en catálogo**:
   - Extraer keywords del mensaje (quitar stopwords)
   - Buscar `nombre LIKE '%keyword%'` o por categoría
   - Cruzar con la base de conocimiento para dar contexto

3. **Generación de respuesta** (reglas + plantillas en español):
   - "Para usar X típicamente se necesita: A, B, C."
   - "Alternativas más baratas a X: Y, Z."
   - "El taladro sirve para perforar X, Y, Z."
   - "Tus productos más vendidos son..."

4. **Refinamiento LLM** (si `IA_API_KEY` configurada Y toggle activo):
   - Prompt corto con la respuesta base
   - Pide que la reescriba en lenguaje natural
   - Si falla → fallback a reglas

5. **Toggle de activación**:
   - `POST /api/v1/ia/toggle` con `{"activo": true/false}`
   - Persistir en archivo `backend/.ia_state.json` (o env var)
   - El endpoint `chat` solo llama al LLM si el toggle está activo

### 2.2 Router

```go
// router.go
ia.POST("/chat", iaHandler.Chat)
ia.POST("/toggle", iaHandler.ToggleIA)
ia.GET("/estado", iaHandler.GetEstadoIA)
```

### 2.3 Frontend: refactorizar `chat_ejecutivo_service.dart`

**Archivo modificado:** `frontend/lib/services/chat_ejecutivo_service.dart`

- Mantener las funciones de **datos de negocio** como fallback
- Nuevo método `enviarConversacional(mensaje, historial, carritoIds)`
- Devolver `ChatRespuesta` con `sugerencias: List<Sugerencia>`

### 2.4 Frontend: mejorar `chat_screen.dart`

**Archivo modificado:** `frontend/lib/screens/chat/chat_screen.dart`

**Mejoras visuales:**
- Burbujas con avatares (robot para IA, usuario para cliente)
- Chips de sugerencias inline (tap = agregar al carrito y volver a Caja)
- Quick-prompt chips arriba: `¿Qué vendo junto con X?`, `¿Para qué sirve Y?`, `¿Qué está por agotarse?`, `Dame un resumen`
- Indicador de fuente: `🧠 LLM` o `⚡ Local`
- Markdown ligero: `**bold**`, `* bullets`, saltos de línea
- Historial persistente en `shared_preferences` (últimas 20 conversaciones)
- Indicador de "Pensando..." con 3 dots animados

### 2.5 Frontend: nuevo widget `sugerencia_chip.dart`

**Archivo nuevo:** `frontend/lib/widgets/chat/sugerencia_chip.dart`

Chip tappable con icono `add_circle_outline` que llama a `agregarAlCarrito(sugerencia)`.

### 2.6 Frontend: FAB de chat en Caja

**Archivo modificado:** `frontend/lib/screens/caja/caja_screen.dart`

- FAB con icono `chat_bubble_outline`
- Tap → `context.push('/chat?contexto=caja&carrito=1,2,3')`

### 2.7 Toggle de IA en Dashboard

**Archivo modificado:** `frontend/lib/screens/dashboard/dashboard_screen.dart`

- En la barra superior, un `Switch` con label "IA Asistida"
- Al togglear, llama a `POST /api/v1/ia/toggle`
- Muestra tooltip: "Activa el LLM para respuestas enriquecidas (consume API)"

---

## 📦 FASE 3 — Cross-sell Dinámico en el POS

**Objetivo:** El `CopilotPanel` actual muestra sugerencias planas. Expandirlo para que explique usos, muestre comparaciones y sugiera sustitutos.

### 3.1 Backend: enriquecer `/ia/sugerencias`

**Archivo modificado:** `backend/internal/ia/copilot.go`

Agregar campos a `Sugerencia`:
```go
type Sugerencia struct {
    Tipo          string  `json:"tipo"`
    ProductoID    int     `json:"producto_id"`
    Nombre        string  `json:"nombre"`
    Precio        float64 `json:"precio"`
    Razon         string  `json:"razon"`
    
    // NUEVOS
    Descripcion   string   `json:"descripcion,omitempty"`
    Compatibles   []int    `json:"compatibles,omitempty"`
    EsSustitutoDe *int     `json:"es_sustituto_de,omitempty"`
    NivelUrgencia string   `json:"nivel_urgencia,omitempty"`
    StockActual   int      `json:"stock_actual,omitempty"`
}
```

Cargar la base de conocimiento al inicializar el copilot y cruzar con el catálogo.

### 3.2 Frontend: mejorar `CopilotPanel`

**Archivo modificado:** `frontend/lib/widgets/ia/copilot_panel.dart`

**Cambios:**
- Cards expandibles en lugar de lista plana
- Header: nombre + precio + badge de tipo
- Tap expande → descripción de uso + compatibles
- Botón "Agregar" siempre visible
- Animación de entrada staggered

### 3.3 Nuevo widget `uso_tooltip.dart`

**Archivo nuevo:** `frontend/lib/widgets/caja/uso_tooltip.dart`

- Icono `lightbulb_outline` al lado de cada producto en el carrito
- Tap → bottom sheet con descripción, compatibles, alternativas

**Archivo modificado:** `frontend/lib/widgets/caja/quick_cart_summary.dart`

Integrar el tooltip en cada item.

---

## 📦 FASE 4 — Registro Rápido por Escaneo

**Objetivo:** Vendedor registra producto nuevo en <30 segundos escaneando código.

### 4.1 Backend: endpoint `GET /api/v1/productos/escanear`

**Archivo modificado:** `backend/internal/handler/producto_handler.go` y `router.go`

```go
// GET /api/v1/productos/escanear?codigo=XXX
func (h *ProductoHandler) Escanear(c *gin.Context) {
    codigo := c.Query("codigo")
    producto, err := h.service.BuscarPorCodigo(codigo)
    if err == nil {
        c.JSON(200, gin.H{"existe": true, "producto": producto})
        return
    }
    c.JSON(200, gin.H{"existe": false, "codigo": codigo})
}
```

### 4.2 Backend: endpoint `GET /api/v1/ia/sugerir-producto`

**Archivo nuevo:** `backend/internal/ia/sugeridor_producto.go`

```go
// GET /api/v1/ia/sugerir-producto?nombre=Taladro Bosch
type SugerenciaProducto struct {
    Nombre            string  `json:"nombre"`
    CategoriaSugerida string  `json:"categoria_sugerida"`
    CategoriaID       *int    `json:"categoria_id,omitempty"`
    PrecioMin         float64 `json:"precio_min"`
    PrecioMax         float64 `json:"precio_max"`
    PrecioPromedio    float64 `json:"precio_promedio"`
    Descripcion       string  `json:"descripcion"`
    Necesita          []int   `json:"necesita,omitempty"`
    Coincidencias     int     `json:"coincidencias"`
}
```

**Lógica:**
1. Buscar en BD productos similares
2. Si hay matches → usar categoría más frecuente + rango de precios
3. Si no hay matches → usar base de conocimiento
4. Generar descripción automática

### 4.3 Frontend: nueva pantalla `escanear_producto_screen.dart`

**Archivo nuevo:** `frontend/lib/screens/inventario/escanear_producto_screen.dart`

**Flujo de 3 pasos:**

1. **Pantalla 1: Escaneo**
   - Full-screen con `mobile_scanner`
   - Overlay con marco de enfoque animado
   - Beep + vibración al detectar
   - Verifica con `GET /productos/escanear?codigo=XXX`
   - Si existe → "¿Ya registrado. Ir a editar?"
   - Si no → Pantalla 2

2. **Pantalla 2: Autocompletado**
   - Form con campos pre-llenados desde `GET /ia/sugerir-producto`
   - Nombre + botón "Buscar en base de conocimiento"
   - Categoría sugerida en dropdown
   - Precio sugerido con rango "$X - $Y"
   - Descripción autogenerada
   - Botón "📷 Escanear" junto al campo código (re-escaneo)
   - Botón "Continuar" → Pantalla 3

3. **Pantalla 3: Confirmación**
   - Preview del producto
   - Botón "Registrar" → `POST /productos`
   - SnackBar verde + opción "Registrar otro"

### 4.4 Pistola HID (desktop)

**Archivo:** `frontend/lib/screens/inventario/escanear_producto_screen.dart` (en el mismo flujo)

- Si `kIsWeb` o `Platform.isLinux/Windows/Mac` → mostrar también input de texto para pistola HID
- Listener de teclado con debounce
- Al recibir código completo → mismo flujo que cámara

### 4.5 Botón dual en Inventario

**Archivo modificado:** `frontend/lib/screens/inventario/inventario_screen.dart`

- Reemplazar el botón "Nuevo Producto" por un `BottomAppBar` con 2 botones:
  - `✍️ Manual` → form actual
  - `📷 Escanear` → nueva pantalla

---

## 📦 FASE 5 — Polish, Badge de IA, Atajos

### 5.1 Badge de fuente IA en AppBar

**Archivo nuevo:** `frontend/lib/widgets/ia/fuente_ia_badge.dart`

- Pill pequeña en el AppBar de Caja y Chat
- Indica modo: `🧠 LLM` (verde) o `⚡ Local` (gris)
- Tooltip explicativo

### 5.2 Atajos de teclado para desktop

**Archivo modificado:** `frontend/lib/screens/caja/caja_screen.dart`

- `Ctrl+K` → abre chat IA
- `Ctrl+N` → nuevo producto (abre selector manual/escanear)
- `F2` → enfoca input código (ya existe)

### 5.3 Historial de chat consultable

**Archivo nuevo:** `frontend/lib/screens/chat/historial_chat_screen.dart`

- Pantalla con lista de conversaciones pasadas
- Tap → reabre la conversación
- Botón "Borrar historial"
- Almacenamiento en `shared_preferences` (key: `chat_historial`)

---

## 🗓️ Plan de Ejecución

| # | Tarea | Archivos | Esfuerzo |
|---|---|---|---|
| **0.1** | Fix `Venta.fromJson` (created_at + nulls) | `frontend/lib/models/venta.dart` | S (15min) |
| **0.2** | Verificar historial_ventas | `frontend/lib/screens/ventas/historial_ventas_screen.dart` | S (15min) |
| **1.1** | Base de conocimiento Go | `internal/ia/conocimiento_ferreteria.go` | M (2h) |
| **1.2** | Base de conocimiento JSON frontend | `assets/conocimiento_ferreteria.json` + `pubspec.yaml` | S (1h) |
| **2.1** | Endpoint `POST /ia/chat` | `internal/ia/chat.go`, `router.go` | M (3h) |
| **2.2** | Endpoint toggle IA | `internal/ia/ia_state.go`, `router.go` | S (1h) |
| **4.1** | Endpoint `GET /productos/escanear` | `producto_handler.go`, `router.go` | S (30min) |
| **4.2** | Endpoint `GET /ia/sugerir-producto` | `internal/ia/sugeridor_producto.go`, `router.go` | M (2h) |
| **2.3** | Refactor `chat_ejecutivo_service.dart` | `frontend/lib/services/chat_ejecutivo_service.dart` | S (1h) |
| **2.4** | Mejorar `chat_screen.dart` | `frontend/lib/screens/chat/chat_screen.dart` | M (3h) |
| **2.5** | Widget `sugerencia_chip.dart` | `frontend/lib/widgets/chat/sugerencia_chip.dart` | S (1h) |
| **2.6** | FAB chat en Caja | `frontend/lib/screens/caja/caja_screen.dart` | S (30min) |
| **2.7** | Toggle IA en Dashboard | `frontend/lib/screens/dashboard/dashboard_screen.dart` | S (1h) |
| **3.1** | Enriquecer `/ia/sugerencias` | `internal/ia/copilot.go` | M (2h) |
| **3.2** | Mejorar `CopilotPanel` | `frontend/lib/widgets/ia/copilot_panel.dart` | M (2h) |
| **3.3** | Widget `uso_tooltip.dart` | `frontend/lib/widgets/caja/uso_tooltip.dart` | M (2h) |
| **4.3** | Pantalla `escanear_producto_screen.dart` | `frontend/lib/screens/inventario/escanear_producto_screen.dart` | L (4h) |
| **4.5** | Botón dual en Inventario | `frontend/lib/screens/inventario/inventario_screen.dart` | S (1h) |
| **5.1** | Badge de fuente IA | `frontend/lib/widgets/ia/fuente_ia_badge.dart` | S (1h) |
| **5.2** | Atajos de teclado | `frontend/lib/screens/caja/caja_screen.dart` | S (30min) |
| **5.3** | Historial de chat | `frontend/lib/screens/chat/historial_chat_screen.dart` | M (2h) |
| **6** | Compilar + probar end-to-end | — | M (3h) |
| **TOTAL** | | | **~32h** |

---

## 🔄 Out of scope

- ❌ Multi-tenant
- ❌ Integración con OpenStreetMap
- ❌ Reconocimiento de imagen con cámara
- ❌ App móvil nativa separada

---

## 📋 Verificación final

- [ ] Compila sin errores: `go build` + `flutter analyze`
- [ ] Funciona sin LLM: todas las funciones operan con reglas locales
- [ ] Funciona con LLM: toggle activa el LLM, respuestas enriquecidas
- [ ] Flujo escaneo end-to-end: cámara/HID → código nuevo → form autocompletado → guardado
- [ ] Chat funcional: "¿qué vendo junto con un taladro?" → devuelve productos
- [ ] Historial consultable: conversaciones previas visibles y reabribles
- [ ] No regresiones: venta/cobro/ticket siguen funcionando
- [ ] Bug de fecha en ventas corregido: historial muestra fechas correctas

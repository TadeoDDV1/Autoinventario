# Plan — Bug de ventas (verificación) + Burbuja IA con recuadro de definición

**Fecha:** 2026-06-11
**Estado:** Pendiente aprobación
**Stack:** Go 1.21+ / Gin / sqlx / MySQL + Flutter 3.x / Riverpod 2.x

---

## Contexto

Dos frentes del proyecto `Autoinventario` que el usuario pidió retomar:

1. **Bug crítico histórico de ventas** — la auditoría `flutter-pos → references/backend-audit-pos.md` documentaba dos bugs:
   - Frontend nunca llamaba a `POST /api/v1/ventas` (ventas "fantasma" que el cajero creía exitosas).
   - `GET /api/v1/ventas` escaneaba `detalles_raw` con `GROUP_CONCAT` pero lo ignoraba (historial mostraba ventas sin productos).

2. **IA chat: burbuja con recuadro de definición/sugerencia** — el chat IA actual tiene burbujas con markdown + chips de sugerencias FUERA de la burbuja. El usuario quiere que las **definiciones y sugerencias se muestren dentro de un recuadro inset** (estilo "tarjeta" pequeña dentro de la burbuja), más legible y con jerarquía visual.

---

## Hallazgo de auditoría (sorpresa: ya están arreglados)

Al revisar el código actual **ambos bugs del audit doc ya están resueltos**:

### Bug #1 (Frontend no persiste ventas) — RESUELTO
- `frontend/lib/widgets/caja/quick_cart_summary.dart:88` llama correctamente a `api.createVenta({...})`.
- El response del backend (`{id, folio}`) se usa para construir la `Venta` persistida (líneas 99-119).
- Se invalida `productosProvider` después del éxito (línea 122).
- El handler de errores distingue `ApiException.isStockInsuficiente` con SnackBar rojo (línea 132-145).
- **No existe** un `cobros_screen.dart` separado — el cobro es inline en `QuickCartSummary` (consolidado correctamente).

### Bug #2 (Scan-and-ignore detalles) — RESUELTO
- `backend/internal/repository/venta_repo.go:79-101` (`GetAll`) ya NO usa `GROUP_CONCAT`.
- Usa `hydrateDetalles(ventas)` (líneas 96, 136-169) que:
  - Hace una segunda query batch con `sqlx.In` + `WHERE venta_id IN (?)`.
  - Construye un `map[int][]DetalleVenta` para evitar N+1.
  - Asigna los detalles a cada venta, con fallback a `[]` si no hay.
- `GetByID` y `GetByFecha` también usan este patrón.

### Lo único que falta verificar end-to-end
- Que el JSON que devuelve `GET /api/v1/ventas` realmente incluya `detalles` poblado cuando hay ventas en la BD.
- Que el frontend `historial_ventas_screen.dart` muestre los productos en el detalle expandible.

**Acción:** un test curl + inspección visual del historial, NO cambio de código backend.

---

## Plan de ejecución

### Paso 1 — Verificar end-to-end de ventas (sin código)

```bash
# 1.a — Verificar que el backend está corriendo
curl -s http://localhost:8080/api/v1/health
# Esperado: 200 {"status":"ok"}

# 1.b — Hacer una venta de prueba
curl -s -X POST http://localhost:8080/api/v1/ventas \
  -H 'Content-Type: application/json' \
  -d '{"detalles":[{"producto_id":1,"cantidad":1,"precio_unitario":10,"subtotal":10}],"subtotal":10,"iva":1.6,"total":11.6,"metodo_pago":"efectivo","monto_recibido":20,"cambio":8.4}'
# Esperado: 201 + JSON con id y folio (ej: V-1234567890123456789)

# 1.c — Verificar que GET /ventas devuelve la venta CON detalles
curl -s http://localhost:8080/api/v1/ventas | jq '.data[0]'
# Esperado: objeto con `detalles: [...]` poblado, no vacío
```

Si 1.c devuelve `detalles: []` para ventas que sí tienen productos → bug de hidratación activo. Si está poblado → bug arreglado, solo documentar.

### Paso 2 — Definir la UI del "recuadro de definición" en el chat IA

**Decisión de diseño:** el recuadro va **dentro** de la burbuja del asistente, debajo del texto principal, con un **borde izquierdo acentuado** (estilo quote-block) y un fondo más claro. NO es un tooltip, NO es un modal, NO reemplaza la burbuja — es una **sección de la burbuja**.

**Estructura visual objetivo:**

```
┌─ Burbuja asistente (gris claro, borde redondo 16px) ─────┐
│ Texto de la respuesta con markdown (lo que ya hay)        │
│                                                            │
│ ┌─ Recuadro inset (borde izq azul 4px, fondo claro) ─┐   │
│ │ 📦 Sugerencia: Martillo de uña                       │   │
│ │ *Comprado junto con clavos en 12 ventas*            │   │
│ │ $145 · en stock (32 uds)              [+ Agregar]   │   │
│ │                                                       │   │
│ │ Compatible con: clavos, gafas, guantes               │   │
│ └──────────────────────────────────────────────────────┘   │
│                                                            │
│ 🧠 LLM · intencion:recomendar                              │
└────────────────────────────────────────────────────────────┘
```

**Datos a mostrar en el recuadro (de `Sugerencia`):**
- Icono según tipo (`add_circle_outline` / `swap_horiz` / `warning_amber` / `lightbulb`)
- Nombre del producto (bold)
- Razón en cursiva (la que ya viene en `sugerencia.razon`)
- Precio formateado con `money.format()`
- Stock actual (si >0) o "Sin stock" con badge rojo
- Botón `+ Agregar` que llama `api.getProductoById` + `carrito.agregarProducto()` + SnackBar verde
- Lista de "Compatible con: X, Y, Z" si la sugerencia tiene el campo `compatibles` poblado

### Paso 3 — Extender el modelo `Sugerencia` (Dart)

**Archivo:** `frontend/lib/models/sugerencia.dart`

Agregar campos opcionales:
```dart
class Sugerencia {
  // ... campos existentes ...
  final String? descripcion;     // ← NUEVO
  final List<int> compatibles;   // ← NUEVO
  final int? stockActual;        // ← NUEVO
  final String nivelUrgencia;    // ← NUEVO: "bajo" | "medio" | "alto"
}
```

**Archivo:** `frontend/lib/services/chat_ejecutivo_service.dart` (línea 52)

Mapear los campos nuevos en `Sugerencia.fromJson` (el constructor se actualiza para leerlos con fallbacks).

### Paso 4 — Backend: poblar `descripcion` y `compatibles` en respuestas del chat

**Archivo:** `backend/internal/ia/chat.go`

El struct `Sugerencia` en `copilot.go:24-28` ya tiene `Descripcion`, `Compatibles`, `StockActual` con tags `omitempty`, pero el endpoint `/ia/chat` probablemente no los está poblando.

**Tarea:** en la función que construye las sugerencias del chat (buscar `sugerencias = append(sugerencias, Sugerencia{...})`), agregar:

```go
// En chat.go, después de construir la Sugerencia:
if p, ok := buscarProductoEnCatalogo(s.ProductoID); ok {
    s.Descripcion = p.Descripcion  // de la base de conocimiento
    s.StockActual = p.Stock
    s.Compatibles = buscarCompatibles(s.ProductoID)  // ids de productos relacionados
}
```

Si la lógica actual no lo hace, **agregar** sin romper el comportamiento existente. Verificar con un curl de prueba:
```bash
curl -s -X POST http://localhost:8080/api/v1/ia/chat \
  -d '{"mensaje":"que le ofrezco a alguien que compra un martillo","carrito_ids":[3]}' | jq '.sugerencias[0]'
# Esperado: objeto con campos descripcion, stock_actual, compatibles poblados
```

### Paso 5 — Crear el widget `TarjetaSugerencia`

**Archivo nuevo:** `frontend/lib/widgets/chat/tarjeta_sugerencia.dart`

Widget `ConsumerStatefulWidget` que muestra el recuadro inset. Reemplaza el `Wrap` de `SugerenciaChip` que está actualmente en `chat_screen.dart:395-404`.

**Diseño:**
```dart
class TarjetaSugerencia extends ConsumerStatefulWidget {
  final Sugerencia sugerencia;
  // Mismo onTap que SugerenciaChip: getProductoById → carrito.agregarProducto
}
```

**Estructura visual:** `Container` con:
- `border: Border(left: BorderSide(color: color, width: 4))`
- `color: color.withValues(alpha: 0.06)`
- `borderRadius: BorderRadius.circular(8)`
- Padding 12
- Column: Row(icon + nombre bold) / Text(razón italic) / Row(precio, stock, botón +)

**Estados:**
- Normal: borde azul (complemento), naranja (alerta), verde (sustituto).
- Cargando: spinner 14px mientras llama `getProductoById`.
- Agregado: check verde + "Agregado" 1.5s, vuelve a normal.
- Sin stock: badge rojo "Sin stock" + botón deshabilitado.

### Paso 6 — Refactor de `chat_screen.dart` para usar `TarjetaSugerencia`

**Archivo:** `frontend/lib/screens/chat/chat_screen.dart:395-404`

Reemplazar:
```dart
if (respuesta!.sugerencias.isNotEmpty) ...[
  const SizedBox(height: 6),
  Wrap(
    spacing: 6,
    runSpacing: 6,
    children: respuesta!.sugerencias
        .map((s) => SugerenciaChip(sugerencia: s))
        .toList(),
  ),
],
```

Por:
```dart
if (respuesta!.sugerencias.isNotEmpty) ...[
  const SizedBox(height: 8),
  Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: respuesta!.sugerencias
        .map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: TarjetaSugerencia(sugerencia: s),
            ))
        .toList(),
  ),
],
```

**Decisión:** cambiar de `Wrap` (chips horizontales) a `Column` (recuadros verticales apilados). Esto da más espacio para mostrar descripción + compatibles + stock + botón.

**Conservar `SugerenciaChip`** — el `CopilotPanel` del modo caja (`lib/widgets/ia/copilot_panel.dart`) puede seguir usándolo para mantener la densidad de "chips" en una vista compacta.

### Paso 7 — Mejoras de pulido visual

Para que el recuadro se vea intencional y no improvisado:

1. **Header del recuadro** con etiqueta semántica según el tipo:
   - `complemento` → "💡 Sugerencia"
   - `sustituto` → "🔄 Alternativa"
   - `alerta_stock` → "⚠️ Stock bajo"
   - `upgrade` → "⬆️ Versión mejorada"

2. **Animación de entrada** con `AnimatedSize` + `FadeTransition` (250ms ease-out). Solo la primera vez que aparece el recuadro, no al re-renderizar.

3. **Hover effect** (desktop): en hover, fondo sube a `alpha 0.10` y borde a `alpha 0.6` con `AnimatedContainer`.

4. **Tap en el nombre del producto** (no en el botón) → navegar a `/inventario/editar/{id}` para ver detalles. No conflicto con el botón "+ Agregar" porque están en zonas separadas.

### Paso 8 — Verificación

```bash
# Build
cd frontend
flutter build linux --release
# Esperado: 240-300s, exit 0

# Run con display
pkill -9 ferreteria_app 2>/dev/null
sleep 1
WAYLAND_DISPLAY=wayland-1 DISPLAY=:1 \
  ./build/linux/x64/release/bundle/ferreteria_app &
# Verificar ventana con hyprctl clients | grep ferreteria
```

**Test manual en la app:**
1. Ir a Chat → escribir "¿qué le ofrezco a alguien que compra un taladro?"
2. Verificar que la respuesta de la IA muestra el texto + 1-3 recuadros de sugerencia con:
   - Nombre del producto
   - Razón en cursiva
   - Precio
   - Stock
   - Botón "Agregar"
3. Tap en "Agregar" → SnackBar verde "X agregado al carrito"
4. Verificar en el carrito de Caja que el producto aparece.
5. Verificar con toggle IA ON (si hay API key) que las respuestas son similares pero con badge "🧠 LLM".

---

## Riesgos

- **Compatibilidad backwards:** El modelo `Sugerencia` agrega campos opcionales. No rompe consumidores existentes (`sugerencia_chip.dart` solo lee `nombre, precio`).
- **Backend no rompe:** Los tags `omitempty` en `Sugerencia` (Go) ya estaban; solo agregamos código que los puebla, no cambian firmas.
- **Performance:** Un `TarjetaSugerencia` por sugerencia (max 3) es trivial; no hay impacto.
- **Test LLM:** No hay `IA_API_KEY` configurada en este entorno, así que el toggle "LLM" no se probará end-to-end. La UI debe degradar graciosamente a "reglas_locales" — eso es lo que probaremos.

---

## Archivos a tocar

| Archivo | Cambio |
|---------|--------|
| `frontend/lib/models/sugerencia.dart` | Agregar 4 campos opcionales al modelo |
| `frontend/lib/services/chat_ejecutivo_service.dart` | Mapear campos nuevos en fromJson |
| `frontend/lib/widgets/chat/tarjeta_sugerencia.dart` | **NUEVO** — widget del recuadro |
| `frontend/lib/screens/chat/chat_screen.dart` | Reemplazar Wrap por Column de TarjetaSugerencia |
| `backend/internal/ia/chat.go` | Poblar `descripcion`, `compatibles`, `stock_actual` en sugerencias |
| `.hermes/plans/2026-06-11_*.md` | Este plan |

**No tocar:** `sugerencia_chip.dart` (lo sigue usando `copilot_panel.dart`), `quick_cart_summary.dart` (venta ya funciona), `venta_repo.go` (ya arreglado).

---

## Estimación

- Paso 1 (verificación): 5 min
- Paso 3-4 (modelo + backend): 15 min
- Paso 5-6 (widget + integración): 25 min
- Paso 7 (pulido): 15 min
- Paso 8 (build + test): 5 min + 5 min build
- **Total:** ~70 min de trabajo, ~5 min de build

---

## Out of scope (para futuras sesiones)

- Migrar `copilot_panel.dart` a usar `TarjetaSugerencia` (mantiene `SugerenciaChip` por ahora para no romper la vista compacta de caja).
- Soporte para respuestas multimodales del LLM (imágenes, tablas).
- Historial de chat: filtrar por fuente (LLM vs reglas) — útil pero no crítico.

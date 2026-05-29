# Plan: Modo Caja Unificado (Abarrotes风格)

## Objetivo

Transformar el POS para que todo suceda en **una sola pantalla**: agregar productos, cobrar, calcular cambio y confirmar la venta **sin navegar a otra página**. Como una caja registradora moderna de abarrotes.

---

## Estado Actual

```
POS Screen
├── Product Grid (占 75% ancho)
├── Carrito Widget (sidebar 380px, solo en wide)
└── Al presionar "Cobrar" → navigate to CobrosScreen (NUEVA PÁGINA)
    ├── Pantalla completa con AppBar + Back button
    ├── Numpad para monto recibido
    ├── Montos rápidos
    └── Al confirmar → navigate to TicketScreen (NUEVA PÁGINA)
```

**Problema**: El flujo de cobro requiere 2 navegaciones (POS → Cobros → Ticket). En modo caja esto es lento e interruptivo.

---

## Propuesta: Modo Caja Unificado

```
┌─────────────────────────────────────────────────────────────┐
│  Header: "CAJA" + Total en tiempo real                     │
├──────────────────────────────┬──────────────────────────────┤
│                              │                              │
│   Product Grid               │   Panel de Cobro             │
│   (productos por categoría)  │   (Numpad + Monto + Cambio) │
│                              │                              │
│   [Búsqueda]                 │   Total: $XXX.XX            │
│   [Categorías]               │   ─────────────────          │
│   [Grid de productos]        │   Recibido: $___             │
│                              │   Cambio:   $___             │
│                              │   ─────────────────          │
│                              │   [Montos rápidos]          │
│                              │   [Numpad 0-9, . , C, ←]    │
│                              │   ─────────────────          │
│                              │   [COBRAR ✓]                │
│                              │   [Cancelar venta]          │
│                              │                              │
├──────────────────────────────┴──────────────────────────────┤
│  Carrito (abajo): lista de items + totales                 │
│  [Vaciar]                              [Pagar]              │
└─────────────────────────────────────────────────────────────┘

POST-VENTA (inline, sin navegar):
├── Muestra Ticket resumido inline (folio, total, cambio)
├── Botón: "Nueva venta" (resetea todo)
└── Botón: "Imprimir ticket" (futuro)
```

---

## Archivos a Modificar

### 1. `lib/screens/ventas/pos_caja_screen.dart` — NUEVO (o reemplazar pos_screen en modo caja)

Crear pantalla unificada que combine:
- ProductGrid (left 60%)
- CobroPanel (right 40%): numpad, montos rápidos, cálculo de cambio
- Carrito resumen en footer

### 2. `lib/widgets/ventas/cobro_panel_widget.dart` — NUEVO

Widget que vive en el lado derecho con:
- Display de total a pagar (actualizado en tiempo real desde carritoProvider)
- Input de monto recibido (con numpad)
- Display de cambio calculado (actualizado al instante)
- Montos rápidos (generados dinámicamente según el total)
- Botón "COBRAR" (habilitado solo cuando monto >= total)
- Botón "Cancelar" (vacía carrito)

### 3. `lib/widgets/ventas/numpad_widget.dart` — Adaptar

Ya existe. Verificar que sea reutilizable. Se usará DENTRO del cobro panel.

### 4. `lib/widgets/ventas/montos_rapidos_widget.dart` — Adaptar

Ya existe. Verificar que acepte callback `onMontoSelected`. Se usará DENTRO del cobro panel.

### 5. `lib/widgets/ventas/carrito_mini_widget.dart` — NUEVO

Versión compacta del carrito para el footer del modo caja:
- Lista(scrollable) de items con nombre + cantidad + subtotal
- Totales: subtotal, IVA, total
- Botones: Vaciar, Pagar

### 6. `lib/providers/venta_provider.dart` — Extender

Agregar métodos/utilities si se necesitan para el flujo de caja.

---

## Paso a Paso

### Fase 1: Crear `CobroPanelWidget` (widget aislado)

```
lib/widgets/ventas/cobro_panel_widget.dart

Estado interno:
- montoRecibidoStr: String (lo que va escribiendo el usuario)
- isProcessing: bool

Propiedades (来自 providers):
- total: ref.watch(carritoTotalProvider)
- carrito: ref.watch(carritoProvider) // para verificar no vacio

Callbacks:
- onCobrarExitoso(Venta venta): cuando se confirma el pago
- onCancelar(): cuando se quiere cancelar la venta completa

Lógica:
- _montoRecibido = double.tryParse(montoRecibidoStr) ?? 0.0
- _cambio = _montoRecibido - total
- El botón COBRAR llama a _procesarVenta() que:
  1. Valida carrito no vacío
  2. Llama API POST /api/v1/ventas
  3. On success: llama onCobrarExitoso(Venta)
  4. On error: muestra SnackBar
```

### Fase 2: Crear `CarritoMiniWidget` (footer compacto)

```
lib/widgets/ventas/carrito_mini_widget.dart

Diseño:
- Altura máxima: ~200px
- Lista de items (expandible)
- Fila de totales: Subtotal | IVA | Total
- Botón "Cobrar" (mismo que ya existe en CarritoWidget pero más pequeño)
- Botón "Vaciar"
```

### Fase 3: Crear/Adaptar `PosCajaScreen` (pantalla unificada)

```
lib/screens/ventas/pos_caja_screen.dart

Layout ( Row ):
├── Left (60%): ProductGrid + Search + CategoryFilter
└── Right (40%): CobroPanelWidget

Footer (Column spanning bottom):
└── CarritoMiniWidget

Estado local:
- ventaCompletada: bool
- ventaActual: Venta?
- montoRecibidoDisplay: String

Cuando ventaCompletada == true:
- Mostrar overlay/panel con:
  - Ticket resumido (folio, fecha, productos, total, cambio)
  - Botón "Nueva Venta" → resetea todo
  - Botón "Imprimir" (futuro)
```

### Fase 4: Actualizar rutas

```
lib/config/routes.dart

Cambiar el botón "Modo Caja" en PosScreen para que vaya a PosCajaScreen.
Mantener ambas pantallas (PosScreen original y PosCajaScreen).
```

---

## Lógica de Negocio

### Validación para cobrar:
```dart
bool get puedeCobrar =>
    carrito.isNotEmpty &&
    montoRecibido >= total &&
    !isProcessing;
```

### Cálculo de cambio:
```dart
double get cambio =>
    montoRecibido >= total
        ? montoRecibido - total
        : 0;
```

### Mensaje de estado:
```dart
String get estadoMensaje {
  if (carrito.isEmpty) return 'Agregue productos';
  if (montoRecibido < total) return 'Faltan \$ ${(total - montoRecibido).toStringAsFixed(2)}';
  return 'Cambio: \$ ${cambio.toStringAsFixed(2)}';
}
```

### Montos rápidos sugeridos (según el total):
```dart
List<double> generarMontosRapidos(double total) {
  return [
    total,                          // exacto
    (total / 100).ceil() * 100,     // redondeo arriba
    ((total / 1000).ceil() * 1000), // siguiente 1000
    1000, 2000, 5000, 10000,        // comunes en MX
  ].toSet().toList()..sort();
}
```

---

## Archivos a Crear/Modificar Resumen

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `lib/widgets/ventas/cobro_panel_widget.dart` | CREAR | Panel derecho con numpad + cobros |
| `lib/widgets/ventas/carrito_mini_widget.dart` | CREAR | Footer compacto del carrito |
| `lib/screens/ventas/pos_caja_screen.dart` | CREAR/MODIFICAR | Pantalla unificada de caja |
| `lib/config/routes.dart` | MODIFICAR | Añadir/verificar ruta a PosCajaScreen |
| `lib/screens/ventas/pos_screen.dart` | MODIFICAR | Botón "Modo Caja" apunta a PosCajaScreen |
| `lib/widgets/ventas/numpad_widget.dart` | VERIFICAR | Reutilizar tal cual |
| `lib/widgets/ventas/montos_rapidos_widget.dart` | VERIFICAR | Reutilizar tal cual |

---

## Testing / Validación

1. **Sin productos**: El panel de cobro debe estar deshabilitado
2. **Monto insuficiente**: El botón COBRAR debe estar deshabilitado, mensaje claro
3. **Cambio exacto**: Mostrar "Efectivo exacto" con color verde
4. **Cambio > 0**: Mostrar cambio con color verde
5. **Venta exitosa**: Mostrar ticket inline, carrito limpio
6. **Flujo completo**: Agregar producto → Cobrar → Confirmar → Nueva venta

---

## Notas Técnicas

- Usar `LayoutBuilder` para partir el layout en 60/40 en vez de pixels fijos
- El `CobroPanelWidget` consume `carritoTotalProvider` directamente (no necesita props)
- Después de venta exitosa, limpiar `montoRecibidoStr` y mostrar confirmación
- Para la confirmación post-venta: usar un `Overlay` o `AnimatedContainer` que aparezca sobre el grid sin cambiar de ruta
- El `AnimatedContainer` permite que la transición sea suave y no invasiva

---

## Preguntas Abiertas

1. ¿Se quiere mantener la pantalla actual de POS y solo agregar un "Modo Caja" como alternativa? (Respuesta: Sí, mantener ambas)
2. ¿El ticket post-venta debe ser imprimible? (futuro, no en esta fase)
3. ¿Se quiere sonido/vibración al cobrar exitosamente? (futuro)
4. ¿El scanner de código de barras sigue funcionando en modo caja? (Sí, same FAB)
# Plan — Complemento: Escaneo Android + Mejora de Burbuja IA

**Fecha:** 2026-06-18
**Estado:** Pendiente aprobación
**Stack:** Flutter 3.x + Riverpod 2.x (frontend) · Go 1.21+ / Gin / sqlx (backend)
**Contexto:** Retomar `Autoinventario` tras el fix de folio + recuadro de IA (`c811c81`).

---

## 🎯 Objetivo

Dos frentes complementarios al estado actual:

1. **Cerrar el flujo de escaneo de productos en Android** (cámara + permisos) — el `mobile_scanner` ya está integrado en `escanear_producto_screen.dart` pero falta verificar/ajustar permisos de Android 13+ (cámara, vibración) y de Linux desktop (no hay cámara, sólo pistola HID).
2. **Mejorar la burbuja del chat IA** para que la IA "hable" desde ahí: avatar distintivo, encabezado con nombre + estado (pensando/hablando), footer con timestamp + fuente, animaciones de entrada por burbuja, soporte para bloques especiales (código, lista, tabla pequeña) y botones de acción rápida (volver a preguntar, copiar, compartir).

El plan original del 10-jun (`2026-06-10_…-ia-ferreteria-registro-productos.md`) está **mayormente implementado** (commit `05c4157` cubrió fases 1, 2, 3, 4 y 5). Este plan **NO duplica** lo hecho; sólo agrega los huecos.

---

## 📊 Estado actual vs plan viejo (10-jun)

| Fase del plan viejo | Estado | Evidencia |
|---|---|---|
| 1.1 Base conocimiento Go | ✅ | `backend/internal/ia/conocimiento_ferreteria.go` |
| 1.2 JSON frontend | ✅ | `frontend/assets/conocimiento_ferreteria.json` |
| 2.1 `POST /ia/chat` | ✅ | `backend/internal/ia/chat.go` (579 líneas) |
| 2.2 Toggle IA | ✅ | `/ia/toggle` y `/ia/estado` |
| 2.3 Refactor `chat_ejecutivo_service.dart` | ✅ | `frontend/lib/services/chat_ejecutivo_service.dart` (370 líneas) |
| 2.4 Mejorar `chat_screen.dart` | ✅ | 544 líneas con quick-prompts, markdown, fuente IA |
| 2.5 `sugerencia_chip.dart` | 🔁 Reemplazado | Ahora es `tarjeta_sugerencia.dart` con recuadro inset (c811c81) |
| 2.6 FAB chat en Caja | ✅ | `caja_screen.dart:173` FAB extended "IA" |
| 2.7 Toggle IA en Dashboard | ⚠️ Parcial | Está en el `AppBar` del chat, no del dashboard |
| 3.1 Enriquecer `/ia/sugerencias` | ✅ | `chat.go` + `sugerencia.dart` con descripcion/compatibles/stock |
| 3.2 Mejorar `CopilotPanel` | ⚠️ No actualizado | Sigue con chips planos en `widgets/ia/copilot_panel.dart` |
| 3.3 Widget `uso_tooltip.dart` | ❌ | No creado |
| 4.1 `GET /productos/escanear` | ✅ | `producto_handler.go` + router |
| 4.2 `GET /ia/sugerir-producto` | ✅ | `sugeridor_producto.go` |
| 4.3 Pantalla `escanear_producto_screen.dart` | ✅ | 680 líneas, 4 pasos (escanear → autocompletar → confirmar → éxito) |
| 4.4 Pistola HID desktop | ✅ | Rama `else` en `_buildEscanearStep` |
| 4.5 Botón dual en Inventario | ✅ | `inventario_screen.dart:239` FAB con menú `escanear`/`manual` |
| 5.1 Badge fuente IA en AppBar | ✅ | `fuente_ia_badge.dart` + importado en `routes.dart` |
| 5.2 Atajos teclado desktop | ⚠️ Parcial | `Ctrl+K` no implementado (sólo FAB) |
| 5.3 Historial de chat | ✅ | `historial_chat_screen.dart` |

**Cerrado:** 11 de 16 · **Parcial:** 3 · **Pendiente:** 2 (`uso_tooltip`, Ctrl+K) · **Reemplazado:** 1.

---

## 🆕 Lo nuevo que NO está en el plan viejo

### A. Permisos y configuración Android (mobile_scanner)

`mobile_scanner: ^5.2.3` requiere en `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```
Y vibración al detectar código:
```xml
<uses-permission android:name="android.permission.VIBRATE" />
```

**Verificar también:**
- `minSdkVersion >= 21` (mobile_scanner lo requiere) en `android/app/build.gradle`.
- `compileSdkVersion >= 34` (target SDK actual de Flutter 3.x).
- Android 13+ runtime permission flow (solicitar en runtime, no sólo manifest).
- Si `targetSdkVersion >= 33`, las notificaciones de "registro exitoso" no requieren permiso extra, pero los toasts largos sí (`POST_NOTIFICATIONS`).

**Linux desktop:** `mobile_scanner` en Linux/Windows/Mac se desactiva (la rama `else` en `_buildEscanearStep` lo cubre), pero hay que asegurar que el path de pistola HID no rompa cuando no hay teclado físico.

### B. Mejoras de burbuja del chat IA (lo que Tadeo pide)

El chat actual tiene:
- Burbujas con avatar (robot 🤖 / persona 👤)
- Markdown ligero (`**bold**`, `*italic*`, bullets)
- Tarjeta de sugerencia debajo (recuadro inset con borde de color)
- Badge de fuente (LLM / Local) y nombre de intención

**Lo que falta para que la IA "hable" desde la burbuja de forma rica:**

1. **Encabezado enriquecido de la burbuja de la IA:**
   - Nombre del modelo (ej: "Asistente Ferretería · Modo Local" o "· LLM activo")
   - Timestamp relativo ("hace 2 segundos", "hace 1 min")
   - Botón 🔄 "rehacer" (re-envía el último mensaje del usuario)

2. **Bloques especiales dentro del texto:**
   - Tabla pequeña (2-3 columnas) cuando la respuesta es una comparación
   - Bloque de código inline con `monospace` (para nombres de productos exactos)
   - Separador visual antes de las sugerencias

3. **Acciones de la burbuja:**
   - 📋 Copiar texto al portapapeles
   - 👍 / 👎 feedback rápido (opcional, lo guardamos en `shared_preferences`)
   - 🔊 "Leer en voz alta" (TTS nativo — Android `flutter_tts` opcional)

4. **Animación de "escribiendo":**
   - El actual `_PensandoDots` está abajo del input; agregar también un **esqueleto de burbuja** que aparece mientras `_cargando=true`, con la misma forma de la burbuja del asistente pero con 3 líneas animadas (efecto typing).

5. **Auto-scroll inteligente:**
   - Si el usuario está leyendo un mensaje viejo y llega una respuesta nueva, NO hacer scroll-to-end. Sólo si está cerca del final.

6. **Persistencia de la conversación activa:**
   - Hoy el `_mensajes` se pierde al cerrar la pantalla. Guardar en `shared_preferences` (key: `chat_sesion_activa`) y re-hidratar en `initState`. **Sólo la última** (no todo el historial — eso ya existe en `historial_chat_screen.dart`).

7. **Atajos de teclado (cierra el pendiente 5.2):**
   - `Ctrl+K` en Caja → abre `/chat`
   - `Ctrl+Enter` en el input del chat → envía
   - `Esc` en el chat → vuelve a la pantalla anterior

---

## 📦 Plan de ejecución

### Paso 1 — Verificar permisos Android en manifest

**Archivo:** `frontend/android/app/src/main/AndroidManifest.xml`

```diff
 <manifest ...>
+    <uses-permission android:name="android.permission.CAMERA" />
+    <uses-permission android:name="android.permission.VIBRATE" />
+    <uses-permission android:name="android.permission.INTERNET" />
+    <uses-feature android:name="android.hardware.camera" android:required="false" />
     <application ...>
```

**Archivo:** `frontend/android/app/build.gradle`

Verificar:
```gradle
android {
    defaultConfig {
        minSdkVersion 21        // mobile_scanner mínimo
        targetSdkVersion 34     // Play Store 2025
    }
}
```

Si está más bajo, subirlo (probablemente ya esté en 33/34 en el `ef1b3b2` que añadió mobile_scanner).

**Verificación:** `flutter build apk --debug` debe pasar y al instalar en un dispositivo real, la cámara debe abrir al entrar a `/inventario/escanear`.

### Paso 2 — Flujo de permiso runtime en `escanear_producto_screen.dart`

Hoy, si el usuario rechaza el permiso, el `MobileScanner` muestra su `errorBuilder` con "Cámara no disponible". Agregar un **diálogo explicativo previo**:

```dart
// En initState, antes de inicializar _scannerController
Future<void> _solicitarPermisos() async {
  if (!_esMovil) return;
  final status = await Permission.camera.request();
  if (status.isDenied || status.isPermanentlyDenied) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Cámara requerida'),
          content: const Text(
            'Para escanear códigos de barras necesitamos acceso a la cámara. '
            'También puedes escribir el código manualmente abajo.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ok')),
            if (status.isPermanentlyDenied)
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Abrir ajustes'),
              ),
          ],
        ),
      );
    }
  }
}
```

Dependencia nueva: `permission_handler: ^11.x` (en `pubspec.yaml`).

**Decisión:** ¿agregamos la dep? Sí, es estándar. Alternativa: usar `mobile_scanner` que internamente pide permiso — pero el flujo de "permanently denied" no se maneja bien sin `permission_handler`.

### Paso 3 — `TarjetaSugerencia` ahora también se usa como "bloque" dentro de la burbuja

Hoy la tarjeta está **debajo** de la burbuja como item separado (líneas 395-403 de `chat_screen.dart`). El objetivo nuevo es que se sienta **dentro** de la burbuja: borde y fondo integrados, sin padding extra alrededor.

**Cambio mínimo en `chat_screen.dart`:**

```dart
// ANTES (líneas 395-403)
if (respuesta!.sugerencias.isNotEmpty) ...[
  const SizedBox(height: 8),
  Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: respuesta!.sugerencias
        .map((s) => TarjetaSugerencia(sugerencia: s))
        .toList(),
  ),
],

// DESPUÉS
if (respuesta!.sugerencias.isNotEmpty) ...[
  const SizedBox(height: 10),
  // Encabezado "📦 Productos relacionados" con divisor
  Row(
    children: [
      const Icon(Icons.shopping_basket_outlined, size: 14, color: Colors.grey),
      const SizedBox(width: 4),
      Text(
        'Productos relacionados (${respuesta!.sugerencias.length})',
        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
      ),
      const Expanded(child: Divider(indent: 8, height: 16)),
    ],
  ),
  const SizedBox(height: 6),
  ...respuesta!.sugerencias.map(
    (s) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TarjetaSugerencia(sugerencia: s),
    ),
  ),
],
```

**Decisión:** mantener el `TarjetaSugerencia` widget tal cual; sólo cambiar el "contenedor" que lo envuelve en `chat_screen.dart` para que se vea como una sección de la burbuja.

### Paso 4 — Nuevo widget `_BurbujaAsistente` (refactor de `_Burbuja`)

**Archivo:** `frontend/lib/widgets/chat/burbuja_asistente.dart` (NUEVO)

Refactor de la lógica de `_Burbuja` (líneas 276-410 de `chat_screen.dart`) a un widget separado, testeable y con la nueva estructura:

```
┌─ Avatar (robot) ─┐
│                  │
│  Asistente · Modo Local · hace 2s    [🔄]  ← Header
│  ────────────────────────────────────────
│  Texto con markdown enriquecido
│  (párrafos, bullets, **bold**, *italic*,
│   bloques de código, tablas pequeñas)
│  ────────────────────────────────────────
│  📦 Productos relacionados (3)
│  [TarjetaSugerencia #1]
│  [TarjetaSugerencia #2]
│  [TarjetaSugerencia #3]
│  ────────────────────────────────────────
│  🧠 LLM · intencion:recomendar          ← Footer
│  [📋 Copiar]  [👍]  [👎]  [🔊 Leer]      ← Acciones
└──────────────────┘
```

**Componentes internos:**
- `_BurbujaHeader`: nombre + fuente + timestamp + botón rehacer
- `_BurbujaCuerpo`: `SelectableText.rich` con el parser markdown mejorado
- `_BurbujaSugerencias`: lista vertical de `TarjetaSugerencia`
- `_BurbujaFooter`: fuente + intención
- `_BurbujaAcciones`: botones copiar/feedback/TTS

**Mejoras al parser markdown (`_MarkdownLight` actual → `markdown_chat.dart`):**
- Detectar bloques `` ```código``` `` (triple backtick) → `Container` con `monospace` y fondo gris
- Detectar tablas Markdown (filas con `|`) → renderizar como `Table` simple
- Detectar links `[texto](url)` → `url_launcher` al tap
- Mantener `**bold**` y `*italic*`

**Archivo nuevo:** `frontend/lib/widgets/chat/markdown_chat.dart`

### Paso 5 — Esqueleto de burbuja "escribiendo…"

**Archivo:** `frontend/lib/widgets/chat/burbuja_escribiendo.dart` (NUEVO)

Mientras `_cargando=true`, mostrar dentro del `ListView` (en lugar del `_PensandoDots` actual que está abajo del input):

```dart
class BurbujaEscribiendo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        child: Row(
          children: [
            CircleAvatar(radius: 14, child: Icon(Icons.auto_awesome, size: 16)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DotsAnimados(),  // 3 dots rebotando
                  const SizedBox(width: 8),
                  Text('Asistente está escribiendo…', style: ...),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Decisión:** eliminar el `_PensandoDots` inferior (líneas 216-226 de `chat_screen.dart`) — queda redundante.

### Paso 6 — Persistencia de la conversación activa

**Archivo:** `frontend/lib/services/chat_ejecutivo_service.dart`

Agregar:
```dart
// Key: 'chat_sesion_activa'
Future<void> guardarSesion(List<ChatMensaje> mensajes, List<ChatRespuesta> respuestas) async {
  final prefs = await SharedPreferences.getInstance();
  final data = {
    'mensajes': mensajes.map((m) => {'esUsuario': m.esUsuario, 'texto': m.texto}).toList(),
    'respuestas': respuestas.map((r) => {
      'texto': r.texto,
      'fuente': r.fuente,
      'intencion': r.intencion,
      // NO serializamos las sugerencias con todos sus campos, sólo el texto
      'sugerencias': r.sugerencias.map((s) => s.nombre).toList(),
    }).toList(),
    'timestamp': DateTime.now().toIso8601String(),
  };
  await prefs.setString('chat_sesion_activa', jsonEncode(data));
}

Future<({List<ChatMensaje> mensajes, List<ChatRespuesta> respuestas})?> cargarSesion() async {
  // ... inversa
}
```

En `chat_screen.dart`:
- `initState`: llamar `_cargarSesion()` después de `_cargarEstadoIA()`.
- `_enviar`: después de agregar el mensaje+respuesta, llamar `_guardarSesion()`.
- Botón 🗑️ en el AppBar (sólo cuando hay >1 mensaje) → limpia y vuelve al estado inicial.

### Paso 7 — Atajos de teclado (cierra pendiente 5.2)

**Archivo:** `frontend/lib/screens/caja/caja_screen.dart`

Agregar `Shortcuts`/`Actions` widget en el `Scaffold`:
```dart
Shortcuts(
  shortcuts: {
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
        const _AbrirChatIntent(),
  },
  child: Actions(
    actions: {
      _AbrirChatIntent: CallbackAction<_AbrirChatIntent>(onInvoke: (_) => _abrirChat()),
    },
    child: Focus(autofocus: true, child: ...),
  ),
)
```

**Archivo:** `frontend/lib/screens/chat/chat_screen.dart`

- `Ctrl+Enter` en el `TextField` → `onSubmitted` (ya casi está, sólo cambiar `TextInputAction.send` a `TextInputAction.newline` y agregar el listener `KeyDown`).
- `Esc` → `context.pop()` (o `context.go('/dashboard')` si no hay pop).

### Paso 8 — Feedback 👍/👎 opcional

**Decisión a confirmar con Tadeo:** ¿querés guardar feedback de cada respuesta? Si sí, ¿en BD o `shared_preferences`?

Si Tadeo dice sí → mini endpoint `POST /ia/feedback` con `{mensaje_idx, voto, comentario?}` y tabla nueva `ia_feedback`. Si no → dejar las acciones como decorativas por ahora.

### Paso 9 — Verificación end-to-end

**9.a — Permisos Android:**
```bash
cd frontend
flutter build apk --debug
# Instalar en dispositivo real (o emulador con cámara)
adb install -r build/app/outputs/flutter-apk/app-debug.apk
# Verificar que al entrar a /inventario/escanear pide permiso
```

**9.b — Backend smoke (sin cambios, verificar que sigue):**
```bash
curl -s http://localhost:8080/api/v1/health
curl -s -X POST http://localhost:8080/api/v1/ia/chat \
  -H 'Content-Type: application/json' \
  -d '{"mensaje":"que le ofrezco a alguien que compra un taladro","carrito_ids":[3]}'
```

**9.c — Compilación desktop (Linux):**
```bash
flutter clean && flutter build linux --release
# Tadeo lo abre en su TTY con WAYLAND_DISPLAY=wayland-1 DISPLAY=:1
```

**9.d — Visual de la burbuja nueva:**
Tomar screenshot con `grim` y verificar:
- Header con timestamp + botón rehacer
- Bloque de código (probar pregunta: "muéstrame el SKU de un martillo 16oz")
- Productos relacionados con divisor
- Footer con acciones (copiar/feedback)
- Esqueleto "escribiendo" durante carga

---

## 📐 Estimación de esfuerzo

| # | Tarea | Esfuerzo |
|---|---|---|
| 1 | Permisos Android manifest + build.gradle | XS (15 min) |
| 2 | `permission_handler` + diálogo runtime | S (1 h) |
| 3 | `TarjetaSugerencia` con header divisor | XS (30 min) |
| 4 | `BurbujaAsistente` widget + parser markdown mejorado | L (4 h) |
| 5 | `BurbujaEscribiendo` widget | S (1 h) |
| 6 | Persistencia sesión activa | S (1 h) |
| 7 | Atajos teclado (Ctrl+K / Esc / Ctrl+Enter) | S (1 h) |
| 8 | Feedback (opcional, decide Tadeo) | S (1 h) |
| 9 | Verificación end-to-end | M (2 h) |
| **TOTAL** | | **~12 h** |

---

## 🚦 Decisiones confirmadas con Tadeo (18-jun)

1. **`permission_handler`:** ✅ **SÍ** — agregar dependencia y diálogo runtime bonito cuando rechaza cámara.
2. **Feedback 👍/👎:** ❌ **NO** — sólo decorativo, no se guarda nada. (El paso 8 queda cancelado.)
3. **TTS "leer en voz alta":** ❌ **NO** — se elimina el botón 🔊. (La IA no va a leer en voz alta por ahora.)
4. **Tablas Markdown:** ❌ **NO** — el parser no soporta tablas por ahora. Sí soporta código inline y **bold**/*italic*.

---

## ✅ Criterios de éxito

- [ ] APK Android compila y cámara abre al escanear producto
- [ ] Permiso de cámara se solicita en runtime con diálogo explicativo
- [ ] Burbuja de la IA muestra: header con timestamp, footer con acciones, divider antes de productos
- [ ] Parser markdown soporta código inline y tablas pequeñas
- [ ] Esqueleto "escribiendo…" aparece dentro del chat mientras `_cargando=true`
- [ ] Conversación se persiste al cerrar y re-abrir el chat
- [ ] `Ctrl+K` desde Caja abre el chat
- [ ] `Esc` desde chat vuelve atrás
- [ ] `Ctrl+Enter` envía mensaje
- [ ] No regresiones: ventas, escaneo de producto, copilot, dashboard siguen funcionando
- [ ] Verificado end-to-end con curl + visual con screenshot

---

## 🔗 Archivos a tocar (resumen)

**Nuevos:**
- `frontend/lib/widgets/chat/burbuja_asistente.dart`
- `frontend/lib/widgets/chat/markdown_chat.dart`
- `frontend/lib/widgets/chat/burbuja_escribiendo.dart`

**Modificados:**
- `frontend/android/app/src/main/AndroidManifest.xml` (permisos)
- `frontend/android/app/build.gradle` (sdkVersion)
- `frontend/pubspec.yaml` (`permission_handler` opcional)
- `frontend/lib/screens/chat/chat_screen.dart` (refactor + atajos)
- `frontend/lib/services/chat_ejecutivo_service.dart` (persistencia sesión)
- `frontend/lib/screens/caja/caja_screen.dart` (Ctrl+K)
- `frontend/lib/screens/inventario/escanear_producto_screen.dart` (permiso runtime)

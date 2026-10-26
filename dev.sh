#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
FLUTTER="$HOME/flutter/bin/flutter"

# ── Flags ────────────────────────────────────────────────────────────────
SKIP_TESTS=0
TARGET="auto"      # auto | android | linux | web
for arg in "$@"; do
  case "$arg" in
    --skip-tests) SKIP_TESTS=1 ;;
    --target=android) TARGET="android" ;;
    --target=linux) TARGET="linux" ;;
    --target=web) TARGET="web" ;;
    --help|-h)
      echo "Uso: ./dev.sh [flags]"
      echo ""
      echo "Flags:"
      echo "  --skip-tests      Omite 'dart analyze' y 'flutter test' pre-arranque"
      echo "  --target=android  Fuerza target Android (no auto-detecta)"
      echo "  --target=linux    Fuerza target Linux"
      echo "  --target=web      Corre en web (Chrome)"
      echo "  --help, -h        Muestra esta ayuda"
      exit 0
      ;;
  esac
done

detect_lan_ip() {
  ip -4 addr show | grep -oP 'inet \K[0-9.]+' | grep -E '^(192\.168|10\.|172\.(1[6-9]|2[0-9]|3[01])\.)' | head -1
}

detect_android_device() {
  $FLUTTER devices 2>/dev/null | grep -E 'android-arm|android-arm64' | grep -v 'emulator' | head -1 | awk -F' • ' '{print $2}'
}

cleanup() {
  echo ""
  echo "Deteniendo servicios..."
  [ -n "$BACKEND_PID" ] && kill "$BACKEND_PID" 2>/dev/null
  [ -n "$FLUTTER_PID" ] && kill "$FLUTTER_PID" 2>/dev/null
  exit 0
}
trap cleanup SIGINT SIGTERM

run_checks() {
  echo "=== 0. Verificación: analyze + tests ==="
  cd "$ROOT/frontend"

  echo "--- dart analyze ---"
  # Solo errores rompen el pipeline; warnings/infos (lints) se muestran
  # pero no bloquean para correr la app en dev.
  $FLUTTER analyze --no-fatal-infos --no-fatal-warnings || { echo "❌ dart analyze falló (errores). Corrige antes de continuar."; exit 1; }

  echo "--- flutter test ---"
  $FLUTTER test || { echo "❌ flutter test falló. Corrige antes de continuar."; exit 1; }
  echo "✅ Checks en verde."
  echo ""
}

if [ "$SKIP_TESTS" -eq 0 ]; then
  run_checks
else
  echo "=== 0. Checks omitidos (--skip-tests) ==="
  echo ""
fi

echo "=== 1. Iniciando backend ==="
cd "$ROOT/backend"
pkill -f "bin/server" 2>/dev/null || true
sleep 1
go build -o bin/server ./cmd/server/
./bin/server &
BACKEND_PID=$!

echo "Esperando backend en :8080..."
for i in $(seq 1 30); do
  if curl -s 'http://localhost:8080/api/v1/productos?page=1&page_size=1' >/dev/null 2>&1; then
    echo "Backend listo"
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "Backend no respondio"
    kill "$BACKEND_PID" 2>/dev/null
    exit 1
  fi
  sleep 1
done

echo "=== 2. Regenerando código drift (app_database.g.dart) ==="
cd "$ROOT/frontend"
$FLUTTER pub run build_runner build --delete-conflicting-outputs

# ── Selección de target ──────────────────────────────────────────────────
if [ "$TARGET" = "auto" ]; then
  ANDROID_DEVICE=$(detect_android_device)
  if [ -n "$ANDROID_DEVICE" ]; then
    TARGET="android"
  else
    TARGET="linux"
  fi
fi

# Para Android (auto o forzado) necesitamos el device-id.
if [ "$TARGET" = "android" ] && [ -z "${ANDROID_DEVICE:-}" ]; then
  ANDROID_DEVICE=$(detect_android_device)
  if [ -z "$ANDROID_DEVICE" ]; then
    echo "❌ No se detectó un dispositivo Android. Conecta uno o usa --target=linux|web"
    exit 1
  fi
fi

LAN_IP="10.0.2.2"
if [ "$TARGET" = "android" ]; then
  LAN_IP=$(detect_lan_ip)
  if [ -z "$LAN_IP" ]; then
    echo "No se pudo detectar IP LAN. Usando 10.0.2.2 (solo emulador)"
    LAN_IP="10.0.2.2"
  fi
fi

echo "=== 3. Lanzando frontend ($TARGET) ==="
case "$TARGET" in
  android)
    echo "IP backend: $LAN_IP"
    $FLUTTER run --device-id="$ANDROID_DEVICE" --dart-define=BACKEND_HOST="$LAN_IP" &
    ;;
  linux)
    $FLUTTER run -d linux &
    ;;
  web)
    $FLUTTER run -d chrome --web-port=5000 &
    ;;
esac
FLUTTER_PID=$!

echo ""
echo "---"
echo "  Backend:  http://localhost:8080"
echo "  Frontend: $TARGET"
echo ""
echo "  NOTA: la app corre con 'flutter run', así que verás en esta consola:"
echo "        - debugPrint del sync (conexión, subidas, errores)"
echo "        - errores de la BD / sync"
echo "        - hot reload (tecla 'r' recarga, 'q' sale)"
echo ""
echo "  Para probar sync entre dispositivos:"
echo "    - Arranca el backend en otro dispositivo con acceso a la red"
echo "    - En Configuración de la app apunta al host:puerto del backend"
echo "  Ctrl+C para detener todo"
echo "---"
echo ""

wait
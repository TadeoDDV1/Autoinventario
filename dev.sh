#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
FLUTTER="$HOME/flutter/bin/flutter"

detect_lan_ip() {
  ip -4 addr show | grep -oP 'inet \K[0-9.]+' | grep '^192\.' | head -1
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

echo "Iniciando backend..."
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

ANDROID_DEVICE=$(detect_android_device)

if [ -n "$ANDROID_DEVICE" ]; then
  LAN_IP=$(detect_lan_ip)
  if [ -z "$LAN_IP" ]; then
    echo "No se pudo detectar IP LAN. Usando 10.0.2.2 (solo emulador)"
    LAN_IP="10.0.2.2"
  fi
  echo "Dispositivo Android: $ANDROID_DEVICE"
  echo "IP backend: $LAN_IP"
  cd "$ROOT/frontend"
  $FLUTTER run --device-id="$ANDROID_DEVICE" --dart-define=BACKEND_HOST="$LAN_IP" &
  FLUTTER_PID=$!
else
  echo "Sin Android. Iniciando Linux..."
  cd "$ROOT/frontend"
  if [ -f build/linux/x64/debug/bundle/ferreteria_app ]; then
    "$ROOT/frontend/build/linux/x64/debug/bundle/ferreteria_app" &
  else
    $FLUTTER build linux --debug
    "$ROOT/frontend/build/linux/x64/debug/bundle/ferreteria_app" &
  fi
  FLUTTER_PID=$!
fi

echo ""
echo "---"
echo "  Backend:  http://localhost:8080"
[ -n "$ANDROID_DEVICE" ] && echo "  Frontend:  Android ($ANDROID_DEVICE)" || echo "  Frontend:  Linux"
echo "  Ctrl+C para detener todo"
echo "---"
echo ""

wait

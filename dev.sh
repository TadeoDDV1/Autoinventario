#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
FLUTTER="$HOME/flutter/bin/flutter"

cleanup() {
  echo ""
  echo "Deteniendo servicios..."
  [ -n "$BACKEND_PID" ] && kill "$BACKEND_PID" 2>/dev/null
  [ -n "$FRONTEND_PID" ] && kill "$FRONTEND_PID" 2>/dev/null
  exit 0
}
trap cleanup SIGINT SIGTERM

echo "🚀 Iniciando backend..."
cd "$ROOT/backend"
go run cmd/server/main.go &
BACKEND_PID=$!

echo "⏳ Esperando backend en :8080..."
for i in $(seq 1 30); do
  if curl -s 'http://localhost:8080/api/v1/productos?page=1&page_size=1' >/dev/null 2>&1; then
    echo "✅ Backend listo"
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "❌ Backend no respondió"
    kill "$BACKEND_PID" 2>/dev/null
    exit 1
  fi
  sleep 1
done

echo "🖥️  Iniciando frontend..."
cd "$ROOT/frontend"

# Si el binario ya existe y no ha cambiado, lo ejecuta directo
if [ -f build/linux/x64/debug/bundle/ferreteria_app ]; then
  echo "Usando binario existente..."
  "$ROOT/frontend/build/linux/x64/debug/bundle/ferreteria_app" &
else
  echo "Compilando frontend (primera vez, será más lento)..."
  "$FLUTTER" build linux --debug
  "$ROOT/frontend/build/linux/x64/debug/bundle/ferreteria_app" &
fi
FRONTEND_PID=$!

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Backend:  http://localhost:8080"
echo "  Frontend:  ventana nativa"
echo "  Ctrl+C para detener todo"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

wait

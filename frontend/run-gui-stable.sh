#!/usr/bin/env bash
# Watchdog para la app Ferretería GUI (Linux desktop).
# Si la ventana muere, espera 2s y la vuelve a abrir.
# Log: /tmp/ferreteria-gui.log
# Detener: kill $(cat /tmp/ferreteria-gui.pid)
set -u
cd "$(dirname "$0")"

LOG="/tmp/ferreteria-gui.log"
PID_FILE="/tmp/ferreteria-gui.pid"
BIN="./build/linux/x64/release/bundle/ferreteria_app"

# Wayland vars para que la ventana se abra en Hyprland.
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export DISPLAY="${DISPLAY:-:1}"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; }

cleanup() {
  log "watchdog_terminated (SIGTERM/SIGINT)"
  if [ -f "$PID_FILE" ]; then
    local pid; pid=$(cat "$PID_FILE")
    pkill -P "$pid" 2>/dev/null
    kill "$pid" 2>/dev/null
    rm -f "$PID_FILE"
  fi
  pkill -f "$BIN" 2>/dev/null
  exit 0
}
trap cleanup INT TERM

if [ ! -x "$BIN" ]; then
  log "ERROR: binario no encontrado en $BIN"
  echo "ERROR: binario no encontrado en $BIN" >&2
  exit 1
fi

echo $$ > "$PID_FILE"
log "watchdog_started pid=$$"

while true; do
  log "starting_gui"
  # `setsid` para que la app no quede atada al wrapper bash del sandbox.
  setsid "$BIN" >> "$LOG" 2>&1 &
  app_pid=$!
  wait "$app_pid"
  rc=$?
  log "gui_exited rc=$rc"
  sleep 2
done

#!/usr/bin/env bash
# Watchdog del backend Ferretería.
# Si el server muere, espera 2s y lo vuelve a levantar.
# Log: /tmp/ferreteria-backend.log
# Detener: kill $(pgrep -f "go run cmd/server/main.go")
set -u
cd "$(dirname "$0")"

LOG="/tmp/ferreteria-backend.log"
HEALTH_URL="http://localhost:8080/api/v1/health"
PID_FILE="/tmp/ferreteria-backend.pid"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; }

cleanup() {
  log "watchdog_terminated (SIGTERM/SIGINT)"
  if [ -f "$PID_FILE" ]; then
    local pid; pid=$(cat "$PID_FILE")
    pkill -P "$pid" 2>/dev/null
    kill "$pid" 2>/dev/null
    rm -f "$PID_FILE"
  fi
  pkill -f "go run cmd/server/main.go" 2>/dev/null
  pkill -f "/tmp/go-build.*server" 2>/dev/null
  exit 0
}
trap cleanup INT TERM

start_server() {
  log "starting_backend"
  # Compilar a binario nativo (más estable que go run)
  if [ ! -x ./bin/server ] || [ cmd/server/main.go -nt ./bin/server ]; then
    log "compiling"
    go build -o ./bin/server ./cmd/server || { log "compile_failed"; return 1; }
  fi
  nohup ./bin/server >> "$LOG" 2>&1 &
  echo $! > "$PID_FILE"
  log "started pid=$(cat "$PID_FILE")"
}

start_server

# Loop de vigilancia
HEALTH_FAILS=0
while true; do
  sleep 5
  # 1) Verificar que el proceso existe
  if [ -f "$PID_FILE" ] && ! kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    log "process_dead_restarting"
    rm -f "$PID_FILE"
    HEALTH_FAILS=0
    start_server
    sleep 2
    continue
  fi
  # 2) Health-check proactivo
  if curl -sS --max-time 3 -o /dev/null -w "%{http_code}" "$HEALTH_URL" 2>/dev/null | grep -q "^200$"; then
    HEALTH_FAILS=0
  else
    HEALTH_FAILS=$((HEALTH_FAILS + 1))
    log "health_fail count=$HEALTH_FAILS"
    if [ "$HEALTH_FAILS" -ge 3 ]; then
      log "health_unresponsive_restarting"
      if [ -f "$PID_FILE" ]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null
        sleep 1
        kill -9 "$(cat "$PID_FILE")" 2>/dev/null
        rm -f "$PID_FILE"
      fi
      HEALTH_FAILS=0
      start_server
    fi
  fi
done

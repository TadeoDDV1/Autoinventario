#!/bin/bash

# Script para iniciar la aplicación Ferreteria completa
# Uso: ./start-app.sh

set -e

PROJECT_ROOT="/home/tadeo/Desktop/Greenalgorithm/Ferreteria"

echo "════════════════════════════════════════════════"
echo "   🔧 Iniciando Ferreteria POS"
echo "════════════════════════════════════════════════"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para verificar si MariaDB está corriendo
check_database() {
    echo -e "${BLUE}[1/3]${NC} Verificando MariaDB..."
    if mysql -h 127.0.0.1 -u ferreteria -p1234 -e "SELECT 1;" &>/dev/null; then
        echo -e "${GREEN}✓${NC} MariaDB conectado correctamente\n"
        return 0
    else
        echo -e "${RED}✗${NC} Error: No se puede conectar a MariaDB"
        echo "    Usuario: ferreteria"
        echo "    Host: 127.0.0.1"
        echo "    Puerto: 3306"
        echo ""
        echo "Iniciando MariaDB..."
        sudo systemctl start mariadb || sudo systemctl start mysql || {
            echo -e "${RED}Error: No se pudo iniciar MariaDB${NC}"
            return 1
        }
        sleep 2
        return 0
    fi
}

# Función para iniciar backend
start_backend() {
    echo -e "${BLUE}[2/3]${NC} Iniciando Backend (Go + Gin)..."
    cd "$PROJECT_ROOT/backend"
    
    if [ ! -f "server" ]; then
        echo -e "${YELLOW}Compilando backend...${NC}"
        go build -o server ./cmd/server
    fi
    
    echo -e "${GREEN}✓${NC} Backend compilado\n"
    echo "Abriendo backend en una nueva ventana..."
    
    # Abrir backend en nueva terminal
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal -- bash -c "cd '$PROJECT_ROOT/backend' && echo 'Backend iniciándose...' && sleep 1 && ./server; exec bash" &
    elif command -v xterm &> /dev/null; then
        xterm -e "cd '$PROJECT_ROOT/backend' && ./server" &
    elif command -v konsole &> /dev/null; then
        konsole -e "cd '$PROJECT_ROOT/backend' && ./server" &
    else
        echo -e "${YELLOW}No se encontró terminal gráfica, ejecutando en background...${NC}"
        cd "$PROJECT_ROOT/backend"
        nohup ./server > backend.log 2>&1 &
        echo -e "${YELLOW}Backend corriendo en background. Log: backend/backend.log${NC}\n"
    fi
    
    sleep 2
}

# Función para iniciar frontend
start_frontend() {
    echo -e "${BLUE}[3/3]${NC} Iniciando Frontend (Flutter)..."
    cd "$PROJECT_ROOT/frontend"
    
    if [ ! -d ".dart_tool" ]; then
        echo -e "${YELLOW}Instalando dependencias Flutter...${NC}"
        flutter pub get
    fi
    
    echo -e "${GREEN}✓${NC} Frontend listo\n"
    echo "Abriendo aplicación Flutter..."
    flutter run -v
}

# Ejecución principal
main() {
    check_database || {
        echo -e "${RED}Error verificando base de datos${NC}"
        exit 1
    }
    
    start_backend
    
    echo ""
    echo "════════════════════════════════════════════════"
    echo -e "${GREEN}✓ Backend iniciado en http://localhost:8080${NC}"
    echo -e "${YELLOW}Esperando 3 segundos para iniciar frontend...${NC}"
    echo "════════════════════════════════════════════════"
    echo ""
    
    sleep 3
    
    start_frontend
}

# Capturar Ctrl+C para limpiar
trap 'echo -e "\n${YELLOW}Deteniendo aplicación...${NC}"; exit 0' INT

# Iniciar
main

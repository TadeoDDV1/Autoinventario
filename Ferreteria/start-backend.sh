#!/bin/bash

# Script simple para iniciar solo el backend
# Usa esto si ya tienes Flutter corriendo en otra terminal

PROJECT_ROOT="/home/tadeo/Desktop/Greenalgorithm/Ferreteria"

echo "🔧 Iniciando Backend Ferreteria..."
echo ""

# Verificar MariaDB
if ! mysql -h 127.0.0.1 -u ferreteria -p1234 -e "SELECT 1;" &>/dev/null; then
    echo "⚠️  MariaDB no está corriendo. Intentando iniciar..."
    sudo systemctl start mariadb || sudo systemctl start mysql || {
        echo "❌ Error: No se pudo iniciar MariaDB"
        exit 1
    }
    sleep 2
fi

echo "✅ MariaDB conectado"
echo ""

# Ir al backend
cd "$PROJECT_ROOT/backend"

# Compilar si es necesario
if [ ! -f "server" ]; then
    echo "🔨 Compilando backend..."
    go build -o server ./cmd/server
    if [ $? -ne 0 ]; then
        echo "❌ Error en compilación"
        exit 1
    fi
    echo ""
fi

echo "🚀 Backend iniciando..."
echo ""
echo "✅ Abierto en: http://localhost:8080"
echo ""

# Ejecutar backend
./server

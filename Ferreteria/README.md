# Ferreteria - Sistema POS (Point of Sale)

Sistema de punto de venta para ferretería construido con Flutter (frontend) y Go/Gin (backend), con base de datos MySQL.

---

## Inicio Rápido

### 1️⃣ Opción Automática (Recomendado)

```bash
./start-app.sh
```

Inicia automáticamente MariaDB, backend y frontend en nuevas ventanas.

### 2️⃣ Opción Manual (Control Total)

**Terminal 1 - Backend:**
```bash
./start-backend.sh
# o manualmente:
cd backend && ./server
```

**Terminal 2 - Frontend:**
```bash
cd frontend && flutter run
```

**Terminal 3 - Verificación (Opcional):**
```bash
curl http://localhost:8080/api/v1/productos
```

### 3️⃣ Verificar que Funciona

Cuando ves esto en el backend:
```
✅ Conexión a MySQL exitosa
✅ Listening and serving HTTP on :8080
```

Y en el frontend:
```
✅ Running on http://localhost:XXXXX
```

¡Todo listo! La app debería conectarse correctamente.

---

## Documentación Adicional

- **Guía Rápida Completa:** Ver [`QUICKSTART.md`](QUICKSTART.md)
- **Troubleshooting Detallado:** Ver sección [Troubleshooting](#troubleshooting) abajo

---

1. [Inicio Rápido](#inicio-rápido)
2. [Arquitectura](#arquitectura)
3. [Requisitos](#requisitos)
4. [Configuración](#configuración)
   - [Base de Datos](#1-base-de-datos)
   - [Backend](#2-backend)
   - [Frontend](#3-frontend)
5. [Compilación](#compilación)
   - [Backend](#backend-1)
   - [Frontend](#frontend-1)
6. [API REST](#api-rest)
7. [Esquema de Base de Datos](#esquema-de-base-de-datos)
8. [Pantallas del Frontend](#pantallas-del-frontend)
9. [Stack Tecnológico](#stack-tecnológico)
10. [Backup de Base de Datos](#backup-de-base-de-datos)
11. [Levantar el Sistema](#levantar-el-sistema-completo)
12. [Troubleshooting](#troubleshooting)

---

## Arquitectura

```
Ferreteria/
├── backend/                         # API REST en Go + Gin
│   ├── cmd/server/main.go          # Punto de entrada
│   ├── config/
│   │   └── database.go             # Configuración de DB
│   ├── internal/
│   │   ├── handler/                # Controladores HTTP
│   │   │   ├── producto.go
│   │   │   ├── venta.go
│   │   │   └── entrada.go
│   │   ├── models/                # Modelos de datos
│   │   ├── repository/            # Capa de acceso a datos
│   │   ├── router/router.go       # Definición de rutas
│   │   └── service/               # Lógica de negocio
│   ├── migrations/                # Scripts SQL
│   │   ├── 001_init.sql
│   │   └── 002_ventas_entradas.sql
│   ├── go.mod
│   ├── go.sum
│   ├── .env                        # Variables de entorno
│   └── server                      # Binario compilado (31MB)
│
└── frontend/                        # App Flutter
    ├── lib/
    │   ├── main.dart              # Entry point
    │   ├── app.dart               # Root widget
    │   ├── config/
    │   │   ├── api_config.dart    # URL base API
    │   │   └── routes.dart        # GoRouter config
    │   ├── models/
    │   │   ├── producto.dart
    │   │   ├── categoria.dart
    │   │   ├── venta.dart
    │   │   └── paginated_response.dart
    │   ├── providers/
    │   │   ├── producto_provider.dart
    │   │   └── venta_provider.dart
    │   ├── screens/
    │   │   ├── inventario/
    │   │   │   ├── inventario_screen.dart
    │   │   │   └── producto_form_screen.dart
    │   │   └── ventas/
    │   │       ├── pos_screen.dart
    │   │       ├── cobros_screen.dart
    │   │       ├── ticket_screen.dart
    │   │       └── historial_ventas_screen.dart
    │   ├── services/
    │   │   └── api_service.dart   # Cliente HTTP (Dio)
    │   └── widgets/
    │       ├── category_filter.dart
    │       ├── producto_card.dart
    │       ├── producto_search_bar.dart
    │       └── ventas/
    │           ├── producto_grid.dart
    │           ├── carrito_widget.dart
    │           ├── numpad_widget.dart
    │           └── metodo_pago_selector.dart
    ├── build/web/                  # Build web compilado
    ├── pubspec.yaml
    └── pubspec.lock
```

---

## Requisitos

| Componente | Versión | Notas |
|------------|---------|-------|
| **Go** | 1.26.2+ | Backend |
| **Flutter** | 3.11.4+ | Frontend |
| **MySQL** | 8.0+ / MariaDB 10.5+ | Base de datos |
| **Dart** | ^3.11.4 | SDK de Flutter |

---

## Configuración

### 1. Base de Datos

Crear la base de datos y ejecutar migraciones:

```bash
mysql -u root -p < backend/migrations/001_init.sql
mysql -u root -p < backend/migrations/002_ventas_entradas.sql
```

O de forma interactiva:

```bash
mysql -u root -p
source backend/migrations/001_init.sql;
source backend/migrations/002_ventas_entradas.sql;
```

### 2. Backend

```bash
cd backend

# Editar credenciales en .env si es necesario
nano .env

# Descargar dependencias
go mod download

# Compilar
go build -o server ./cmd/server

# Ejecutar (servidor en http://localhost:8080)
./server
```

**Variables de entorno (`.env`):**

```env
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=ferreteria
DB_PASSWORD=1234
DB_NAME=ferreteria_db
SERVER_PORT=8080
```

### 3. Frontend

```bash
cd frontend

# Instalar dependencias
flutter pub get

# Desarrollo
flutter run

# Producción web
flutter build web
```

**Endpoint API** configurable en `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8080';
}
```

Para producción, cambiar `baseUrl` a la IP/dominio del servidor backend.

---

## Compilación

### Backend

```bash
cd backend
go build -o server ./cmd/server
./server
```

El binario `server` queda disponible en `backend/`. Servidor escucha en `http://localhost:8080`.

### Frontend

```bash
cd frontend

# Web (recomendado)
flutter build web

# Linux desktop
flutter build linux

# Android APK
flutter build apk

# iOS (requiere macOS)
flutter build ios
```

**Ubicación de builds:**

| Plataforma | Ruta |
|------------|------|
| Web | `frontend/build/web/` |
| Linux | `frontend/build/linux/` |
| Android | `frontend/build/app/outputs/flutter-apk/` |

---

## API REST

Base URL: `http://localhost:8080/api/v1`

### Productos

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/productos` | Listar todos los productos |
| GET | `/productos/:id` | Obtener producto por ID |
| POST | `/productos` | Crear producto |
| PUT | `/productos/:id` | Actualizar producto |
| DELETE | `/productos/:id` | Eliminar producto |

### Categorías

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/categorias` | Listar todas |
| POST | `/categorias` | Crear categoría |

### Ventas

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/ventas` | Listar todas las ventas |
| GET | `/ventas/hoy` | Ventas del día |
| GET | `/ventas/:id` | Obtener venta por ID |
| POST | `/ventas` | Registrar venta |

### Entradas de Inventario

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/entradas` | Listar todas |
| GET | `/entradas/:id` | Obtener entrada por ID |
| POST | `/entradas` | Registrar entrada |

---

## Esquema de Base de Datos

### Tablas

| Tabla | Descripción |
|-------|-------------|
| `categorias` | Categorías de productos |
| `productos` | Catálogo con precios y stock |
| `ventas` | Transacciones de venta |
| `detalle_ventas` | Items por venta |
| `entradas_inventario` | Compras a proveedores |
| `detalle_entradas` | Items por entrada |

### Estructura de `productos`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INT | Primary key |
| `codigo_barras` | VARCHAR(50) | Único |
| `nombre` | VARCHAR(200) | Nombre del producto |
| `descripcion` | TEXT | Descripción |
| `precio_compra` | DECIMAL(10,2) | Precio de compra |
| `precio_venta` | DECIMAL(10,2) | Precio de venta |
| `stock_actual` | INT | Stock actual |
| `stock_minimo` | INT | Stock mínimo (alerta) |
| `categoria_id` | INT | FK a categorias |
| `imagen_url` | TEXT | URL de imagen |
| `activo` | BOOLEAN | ¿Activo? |
| `created_at` | TIMESTAMP | Fecha creación |
| `updated_at` | TIMESTAMP | Última modificación |

### Estructura de `ventas`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INT | Primary key |
| `folio` | VARCHAR(20) | Identificador único |
| `subtotal` | DECIMAL(10,2) | Subtotal |
| `iva` | DECIMAL(10,2) | IVA |
| `total` | DECIMAL(10,2) | Total |
| `metodo_pago` | ENUM | 'efectivo' o 'tarjeta' |
| `monto_recibido` | DECIMAL(10,2) | Monto recibido |
| `cambio` | DECIMAL(10,2) | Cambio |
| `created_at` | TIMESTAMP | Fecha/hora |

### Categorías Pre-cargadas

1. Herramientas Manuales
2. Herramientas Eléctricas
3. Electricidad
4. Plomería
5. Tornillería y Fijaciones
6. Pintura y Acabados
7. Construcción
8. Seguridad Industrial

---

## Pantallas del Frontend

### Módulo de Ventas (POS)

| Pantalla | Descripción |
|----------|-------------|
| **POS Screen** | Grid de productos, carrito, numpad, búsqueda |
| **Cobros Screen** | Confirmación de pago, cálculo de cambio |
| **Ticket Screen** | Comprobante de venta imprimible |
| **Historial Ventas** | Lista de ventas con filtros por fecha |

### Módulo de Inventario

| Pantalla | Descripción |
|----------|-------------|
| **Inventario Screen** | Lista de productos con filtros por categoría |
| **Producto Form Screen** | Crear/editar producto |

---

## Stack Tecnológico

### Backend

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| Go | 1.26.2 | Lenguaje |
| Gin | v1.12.0 | Web framework |
| sqlx | v1.4.0 | Acceso a DB |
| go-sql-driver/mysql | v1.9.3 | Driver MySQL |
| godotenv | v1.5.1 | Carga .env |
| go-playground/validator | v10.30.2 | Validación |

### Frontend

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| Flutter | 3.11.4 | Framework |
| flutter_riverpod | 3.3.1 | State management |
| go_router | 17.2.2 | Routing |
| dio | 5.9.2 | HTTP client |
| flutter_animate | 4.5.2 | Animaciones |
| flex_color_scheme | 8.4.0 | Theming |
| google_fonts | 8.0.2 | Tipografías |
| barcode_widget | 2.0.4 | Códigos de barras |
| intl | 0.20.2 | Formato de fechas |

---

## Backup de Base de Datos

```bash
mysqldump -u ferreteria -p ferreteria_db > backend/ferreteria_db_backup.sql
```

Restaurar:

```bash
mysql -u ferreteria -p ferreteria_db < backend/ferreteria_db_backup.sql
```

**Nota:** El archivo `backend/ferreteria_db_backup.sql` contiene un backup reciente. Verificar fecha y contenido antes de restaurar en producción.

---

## Levantar el Sistema Completo

### Opción 1: Inicio Automático (Recomendado)

```bash
./start-app.sh
```

Este script automatizado:
- ✅ Verifica MariaDB
- ✅ Compila el backend si es necesario
- ✅ Abre el backend en una nueva terminal
- ✅ Inicia Flutter en la terminal actual

### Opción 2: Inicio Manual (Paso a paso)

Necesitas **3 terminales** abiertas simultáneamente:

#### Terminal 1: Backend

```bash
cd backend
./server
```

Debe mostrar:
```
Conexión a MySQL exitosa
Servidor iniciando en http://localhost:8080
[GIN-debug] Listening and serving HTTP on :8080
```

#### Terminal 2: Frontend

```bash
cd frontend
flutter run
```

#### Terminal 3: Verificación (Opcional)

```bash
# Listar productos (debe devolver JSON)
curl http://localhost:8080/api/v1/productos

# O probar todas las rutas
curl http://localhost:8080/api/v1/categorias
curl http://localhost:8080/api/v1/ventas
```

### Despliegue Web en Producción

Para desplegar el build web, copiar el contenido de `frontend/build/web/` a un servidor web (nginx, Apache, Caddy, etc.):

```bash
# Compilar web en modo producción
cd frontend
flutter build web --release

# Copiar a servidor web
cp -r build/web/* /var/www/ferreteria/
```

**Nginx (ejemplo):**
```nginx
server {
    listen 80;
    server_name ferreteria.com;
    
    root /var/www/ferreteria;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Proxy al backend
    location /api/v1/ {
        proxy_pass http://localhost:8080/api/v1/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

**Backend en Producción:**

```bash
# Compilar en modo release
cd backend
go build -o server ./cmd/server

# Cambiar .env a valores de producción
nano .env
# Cambiar DB_PASSWORD, SERVER_PORT si es necesario

# Usar systemd para iniciar en background
sudo cp server /opt/ferreteria/server
sudo systemctl start ferreteria
sudo systemctl enable ferreteria
```

**Frontend - Cambiar URL API:**

En `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'https://ferreteria.com/api/v1';  // Cambiar localhost
}
```

Recompilar:
```bash
flutter build web --release
```

---

## Troubleshooting

### Error: "Connection refused" en Flutter

**Problema:** El app Flutter muestra `DioException: Connection refused on localhost:8080`

**Causa:** El backend no está corriendo.

**Solución:**

1. Asegurar que el backend esté ejecutándose en Terminal 1:
   ```bash
   cd backend
   ./server
   ```
   
2. Verificar que escuche en puerto 8080:
   ```bash
   curl http://localhost:8080/api/v1/productos
   ```

3. Si aun así no conecta, verificar que el puerto no esté bloqueado:
   ```bash
   sudo lsof -i :8080
   # Si hay algo corriendo, matar el proceso:
   kill -9 <PID>
   ```

### Error de conexión a DB

Verificar que MariaDB está corriendo y las credenciales en `.env` son correctas:

```bash
# Probar conexión
mysql -h 127.0.0.1 -u ferreteria -p1234 -e "SELECT 1;"

# Si falla, iniciar MariaDB
sudo systemctl start mariadb
# o
sudo systemctl start mysql
```

**Credenciales esperadas (en `.env`):**
```env
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=ferreteria
DB_PASSWORD=1234
DB_NAME=ferreteria_db
```

### Flutter web no conecta al backend

Verificar CORS en el backend. En desarrollo ya permite todos los orígenes. Para producción, cambiar el header `Access-Control-Allow-Origin` en `internal/router/router.go`.

### Error "RenderFlex overflowed"

Este es un error de UI (layout), no de conexión. Significa que un widget no cabe en la pantalla. Soluciones:

- Ajustar tamaño de pantalla/dispositivo
- Usar `Expanded` o `SingleChildScrollView` en el widget que overflowea
- Revisar `lib/screens/ventas/pos_screen.dart:214`

### Build de Android falla

```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --release
```

### Backend no inicia después de cambios

Recompilar:
```bash
cd backend
go mod tidy
go mod download
go build -o server ./cmd/server
./server
```

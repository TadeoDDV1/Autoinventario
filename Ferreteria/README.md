# Ferreteria - Sistema POS (Point of Sale)

Sistema de punto de venta para ferretería construido con Flutter (frontend) y Go/Gin (backend), con base de datos MySQL.

---

## Tabla de Contenidos

1. [Arquitectura](#arquitectura)
2. [Requisitos](#requisitos)
3. [Configuración](#configuración)
   - [Base de Datos](#1-base-de-datos)
   - [Backend](#2-backend)
   - [Frontend](#3-frontend)
4. [Compilación](#compilación)
   - [Backend](#backend-1)
   - [Frontend](#frontend-1)
5. [API REST](#api-rest)
6. [Esquema de Base de Datos](#esquema-de-base-de-datos)
7. [Pantallas del Frontend](#pantallas-del-frontend)
8. [Stack Tecnológico](#stack-tecnológico)
9. [Backup de Base de Datos](#backup-de-base-de-datos)
10. [Levantar el Sistema](#levantar-el-sistema-completo)

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

### Paso a paso

1. **MySQL/MariaDB** - Asegurar que el servicio esté corriendo:

   ```bash
   sudo systemctl status mysql
   # o
   sudo systemctl status mariadb
   ```

2. **Backend** - En terminal separada:

   ```bash
   cd backend
   ./server
   ```

3. **Frontend** - En terminal separada:

   ```bash
   cd frontend
   flutter run
   ```

### Despliegue Web en Producción

Para desplegar el build web, copiar el contenido de `frontend/build/web/` a un servidor web (nginx, Apache, Caddy, etc.):

```bash
# Ejemplo con Python como servidor simple para pruebas
cd frontend/build/web
python3 -m http.server 8081
```

Para nginx, configurar `server {}` con `root /path/to/frontend/build/web;`.

---

## Troubleshooting

### Error de conexión a DB

Verificar que MySQL esté corriendo y las credenciales en `.env` sean correctas:

```bash
mysql -u ferreteria -p1234 -e "SELECT 1;"
```

### Flutter web no conecta al backend

Verificar CORS en el backend (ya configurado para permitir todos los orígenes en desarrollo). En producción, cambiar `Access-Control-Allow-Origin` al dominio correspondiente.

### Build de Android falla

```bash
cd frontend
flutter clean
flutter pub get
flutter build apk
```

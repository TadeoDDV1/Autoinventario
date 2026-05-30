# Autoinventario — Sistema POS para Ferretería

Sistema de punto de venta (POS) y gestión de inventario para ferretería, construido con **Flutter** (frontend) y **Go/Gin** (backend), con base de datos MySQL.

---

## 🏗️ Arquitectura

```
autoinventario/
├── backend/                    # API REST en Go + Gin
│   ├── cmd/server/           # Punto de entrada
│   ├── config/               # Configuración de base de datos
│   ├── internal/
│   │   ├── handler/          # Controladores HTTP (productos, ventas, entradas)
│   │   ├── models/           # Modelos de datos
│   │   ├── repository/       # Capa de acceso a datos
│   │   ├── router/           # Definición de rutas API
│   │   └── service/         # Lógica de negocio
│   ├── migrations/           # Scripts SQL de migración
│   └── ferreteria_db_backup.sql
│
└── frontend/                  # Aplicación Flutter
    ├── lib/
    │   ├── config/          # Rutas y configuración API
    │   ├── models/          # Modelos de datos
    │   ├── providers/       # Estado con Riverpod
    │   ├── screens/         # Pantallas (ventas, inventario)
    │   ├── services/        # Cliente API HTTP
    │   └── widgets/         # Componentes reutilizables
    └── build/               # Build web (generado)
```

---

## 🚀 Inicio Rápido

### Backend

```bash
cd backend
go run ./cmd/server
# Servidor en http://localhost:8080
```

### Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

### Verificación

```bash
curl http://localhost:8080/api/v1/productos
```

---

## 🛠️ Stack Tecnológico

| Capa    | Tecnología                          |
|---------|-------------------------------------|
| Frontend| Flutter 3.41, Riverpod, GoRouter    |
| Backend | Go 1.21+, Gin, GORM                |
| DB      | MySQL / MariaDB                    |
| UI      | Flex Color Scheme, Google Fonts    |

---

## 📦 API REST

| Método | Endpoint                    | Descripción              |
|--------|-----------------------------|--------------------------|
| GET    | `/api/v1/productos`         | Listar productos         |
| POST   | `/api/v1/productos`         | Crear producto           |
| PUT    | `/api/v1/productos/:id`     | Actualizar producto      |
| DELETE | `/api/v1/productos/:id`     | Eliminar producto        |
| GET    | `/api/v1/categorias`        | Listar categorías        |
| POST   | `/api/v1/ventas`            | Registrar venta          |
| GET    | `/api/v1/ventas`            | Historial de ventas      |
| POST   | `/api/v1/entradas`          | Registrar entrada stock  |

---

## 📋 Funcionalidades

- **Punto de Venta (POS)** — Carrito de compras, selector de método de pago, teclado numérico
- **Inventario** — CRUD de productos con categorías, búsqueda, filtros
- **Historial de Ventas** — Registro completo de transacciones
- **Modo Oscuro** — Tema oscuro/claro conmutado automáticamente
- **Diseño Responsivo** — Adaptado para tablets y escritorio

---

## 🔧 Configuración

### Base de Datos

Crear base de datos MySQL y ejecutar las migraciones en `backend/migrations/`.

Variables de entorno en `backend/.env`:
```
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=ferreteria
DB_PASSWORD=1234
DB_NAME=ferreteria_db
```

---

## 📁 Estructura de la Base de Datos

- **productos** — Catálogo de productos con stock
- **categorias** — Categorización de productos
- **ventas** — Encabezado de ventas
- **detalle_ventas** — Línea de productos por venta
- **entradas** — Control de ingreso de mercancía
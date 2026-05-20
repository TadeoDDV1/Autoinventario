# 🚀 Inicio Rápido - Ferreteria POS

## En 30 segundos

### Opción 1: Automático (Lo más fácil)

```bash
./start-app.sh
```

### Opción 2: Manual (Control total)

**Terminal 1 - Backend:**
```bash
cd backend && ./server
```

**Terminal 2 - Frontend:**
```bash
cd frontend && flutter run
```

---

## Requisitos Previos

✅ MariaDB/MySQL corriendo
```bash
sudo systemctl start mariadb  # o mysql
```

✅ Base de datos creada
```bash
mysql -u ferreteria -p1234 ferreteria_db < /dev/null
```

✅ Go 1.26.2+
```bash
go version
```

✅ Flutter 3.11.4+
```bash
flutter --version
```

---

## Verificar que Todo Funciona

### Backend está listo cuando ves:
```
Conexión a MySQL exitosa
Listening and serving HTTP on :8080
```

### Frontend está listo cuando ves:
```
Running "flutter pub get" in frontend...
Starting application: ./flutter_app
```

### Probar API:
```bash
curl http://localhost:8080/api/v1/productos
```

---

## Problemas Comunes

| Problema | Solución |
|----------|----------|
| `Connection refused` | Backend no está corriendo. Ejecutar `./backend/server` |
| `Access denied for user 'ferreteria'` | Verificar credenciales en `backend/.env` |
| `Database not found` | Restaurar BD: `mysql -u ferreteria -p1234 < backend/ferreteria_db_backup.sql` |
| `Port 8080 already in use` | Matar proceso: `sudo lsof -i :8080 \| kill -9 $(awk 'NR==2 {print $2}')` |

---

## Compilación

```bash
# Backend
cd backend && go build -o server ./cmd/server

# Frontend Web
cd frontend && flutter build web

# Frontend Android
cd frontend && flutter build apk

# Frontend Linux
cd frontend && flutter build linux
```

Los builds compilados están en:
- Web: `frontend/build/web/`
- Android: `frontend/build/app/outputs/flutter-apk/`
- Linux: `frontend/build/linux/release/bundle/`

---

## Variables de Entorno

Archivo: `backend/.env`

```env
DB_HOST=127.0.0.1       # Host de MariaDB
DB_PORT=3306            # Puerto de MariaDB
DB_USER=ferreteria      # Usuario de BD
DB_PASSWORD=1234        # Contraseña (cambiar en producción!)
DB_NAME=ferreteria_db   # Nombre de la BD
SERVER_PORT=8080        # Puerto del API
```

---

## API Base URL

**Desarrollo:** `http://localhost:8080/api/v1`

**Producción:** Cambiar en `frontend/lib/config/api_config.dart`

---

## Endpoints Principales

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/productos` | Listar productos |
| POST | `/productos` | Crear producto |
| GET | `/categorias` | Listar categorías |
| POST | `/ventas` | Registrar venta |
| GET | `/ventas/hoy` | Ventas del día |

---

## Más Información

Ver `README.md` para documentación completa.

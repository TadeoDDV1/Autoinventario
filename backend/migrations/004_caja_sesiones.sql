-- Migración 004: sesión de caja compartida (sync multi-dispositivo via SSE)
-- Almacena el carrito activo en el servidor para que todos los clientes
-- conectados a la misma sesión vean los mismos items.

USE ferreteria_db;

CREATE TABLE IF NOT EXISTS caja_sesiones (
    id              VARCHAR(36) PRIMARY KEY COMMENT 'UUID de la sesión activa',
    version         BIGINT NOT NULL DEFAULT 0 COMMENT 'Versión incremental, para detección de conflictos',
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_touch_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_sesion_touch (last_touch_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS caja_sesion_items (
    sesion_id       VARCHAR(36) NOT NULL,
    producto_id     INT NOT NULL,
    cantidad        INT NOT NULL DEFAULT 1,
    version         BIGINT NOT NULL DEFAULT 0 COMMENT 'Versión al momento de este cambio',
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by      VARCHAR(60) DEFAULT NULL COMMENT 'device_id que hizo el cambio',
    PRIMARY KEY (sesion_id, producto_id),
    CONSTRAINT fk_sesion_item_sesion FOREIGN KEY (sesion_id) REFERENCES caja_sesiones(id) ON DELETE CASCADE,
    CONSTRAINT fk_sesion_item_producto FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

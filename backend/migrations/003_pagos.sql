-- Migración 003: módulo de pagos (Stripe primero, arquitectura multi-proveedor)
-- Aplica cambios al esquema para soportar pagos con tarjeta vía proveedor externo.
-- Idempotente: se puede reaplicar sin errores.
-- Plan: .hermes/plans/2026-06-22_pagos-multiples-mejoras-pendientes.md

USE ferreteria_db;

-- 1. Ampliar ENUM de metodo_pago en ventas (transferencia y mixto son futuros casos)
--    Migramos de ('efectivo','tarjeta') a ('efectivo','tarjeta','transferencia','mixto').
--    MODIFY es idempotente: si el ENUM ya está en el estado deseado, no hace nada.
ALTER TABLE ventas
    MODIFY COLUMN metodo_pago ENUM('efectivo','tarjeta','transferencia','mixto') NOT NULL DEFAULT 'efectivo';

-- 2. Columna referencia_pago en ventas: ID del charge aprobado en el proveedor externo.
--    Nullable porque ventas en efectivo no tienen referencia.
--    Chequeo por INFORMATION_SCHEMA para hacerlo idempotente.
SET @col_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'ventas'
      AND COLUMN_NAME = 'referencia_pago'
);
SET @sql := IF(@col_exists = 0,
    'ALTER TABLE ventas ADD COLUMN referencia_pago VARCHAR(128) DEFAULT NULL AFTER cambio',
    'SELECT "referencia_pago ya existe" AS msg');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 3. Tabla pagos: auditoría de TODAS las transacciones con proveedor externo.
--    Una venta puede tener varios intentos de pago (ej. tarjeta declinada → efectivo).
CREATE TABLE IF NOT EXISTS pagos (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    venta_id        INT NOT NULL,                       -- alinea con ventas.id (INT AUTO_INCREMENT)
    proveedor       ENUM('stripe','conekta','mercadopago','efectivo','transferencia') NOT NULL,
    referencia      VARCHAR(128) NOT NULL,
    monto_centavos  BIGINT NOT NULL,
    moneda          CHAR(3) NOT NULL DEFAULT 'MXN',
    estado          ENUM('pendiente','aprobado','rechazado','reembolsado') NOT NULL,
    metodo_pago     VARCHAR(64) DEFAULT NULL,
    installments    INT NOT NULL DEFAULT 1,
    ult_4           CHAR(4) DEFAULT NULL,
    metadata_json   JSON DEFAULT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_pagos_venta (venta_id),
    INDEX idx_pagos_proveedor_ref (proveedor, referencia),
    CONSTRAINT fk_pago_venta FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

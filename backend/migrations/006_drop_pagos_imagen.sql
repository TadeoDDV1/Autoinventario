-- Migración 006: limpieza post-eliminación de Stripe
-- Plan: fase 1 — quitar pagos con tarjeta y referencias.
-- Idempotente: se puede reaplicar sin errores.

USE ferreteria_db;

-- 1. Quitar columna referencia_pago de ventas si existe.
SET @col_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'ventas'
      AND COLUMN_NAME = 'referencia_pago'
);
SET @sql := IF(@col_exists > 0,
    'ALTER TABLE ventas DROP COLUMN referencia_pago',
    'SELECT "referencia_pago ya no existe" AS msg');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 2. Quitar columna imagen_url de productos si existe.
SET @col_img := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'productos'
      AND COLUMN_NAME = 'imagen_url'
);
SET @sql := IF(@col_img > 0,
    'ALTER TABLE productos DROP COLUMN imagen_url',
    'SELECT "imagen_url ya no existe" AS msg');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 3. Eliminar tabla pagos si existe.
DROP TABLE IF EXISTS pagos;
-- Migración 007: campos extra para productos
-- Plan: fase 2 — enriquecer el registro de producto con marca, sku, unidad
-- de medida, ubicación y precio de mayoreo.
-- Idempotente: se puede reaplicar sin errores. Compatible con MariaDB 10.0.2+
-- y MySQL 8.0.29+ (soporte nativo de IF NOT EXISTS en ALTER TABLE ... ADD).

USE ferreteria_db;

-- 1. marca
ALTER TABLE productos
  ADD COLUMN IF NOT EXISTS marca VARCHAR(100) DEFAULT NULL AFTER nombre;

-- 2. sku
ALTER TABLE productos
  ADD COLUMN IF NOT EXISTS sku VARCHAR(50) DEFAULT NULL AFTER codigo_barras;

-- 3. unidad_medida (ENUM con default 'pieza' para registros legacy)
ALTER TABLE productos
  ADD COLUMN IF NOT EXISTS unidad_medida ENUM('pieza','metro','kg','litro','caja','rollo','par','otro') NOT NULL DEFAULT 'pieza' AFTER precio_venta;

-- 4. precio_mayoreo
ALTER TABLE productos
  ADD COLUMN IF NOT EXISTS precio_mayoreo DECIMAL(10,2) DEFAULT NULL AFTER precio_venta;

-- 5. ubicacion
ALTER TABLE productos
  ADD COLUMN IF NOT EXISTS ubicacion VARCHAR(100) DEFAULT NULL AFTER unidad_medida;

-- Índice de ayuda para filtrar por ubicación.
-- Creamos primero la columna (no-op si existe) y luego el índice condicional.
CREATE INDEX IF NOT EXISTS idx_ubicacion ON productos (ubicacion);
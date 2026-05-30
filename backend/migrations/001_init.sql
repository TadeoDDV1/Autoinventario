CREATE DATABASE IF NOT EXISTS ferreteria_db
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ferreteria_db;

CREATE TABLE IF NOT EXISTS categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_barras VARCHAR(50) UNIQUE,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio_compra DECIMAL(10,2) NOT NULL DEFAULT 0,
    precio_venta DECIMAL(10,2) NOT NULL DEFAULT 0,
    stock_actual INT DEFAULT 0,
    stock_minimo INT DEFAULT 5,
    categoria_id INT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL,
    INDEX idx_codigo_barras (codigo_barras),
    INDEX idx_nombre (nombre),
    INDEX idx_categoria (categoria_id)
);

INSERT INTO categorias (nombre, descripcion) VALUES
('Herramientas Manuales', 'Martillos, destornilladores, llaves, etc.'),
('Herramientas Eléctricas', 'Taladros, sierras, lijadoras, etc.'),
('Electricidad', 'Cables, interruptores, contactores, etc.'),
('Plomería', 'Tubos, válvulas, conexiones, etc.'),
('Tornillería y Fijaciones', 'Tornillos, taquetes, anclas, etc.'),
('Pintura y Acabados', 'Pinturas, barnices, brochas, etc.'),
('Construcción', 'Cemento, arena, blocks, etc.'),
('Seguridad Industrial', 'Cascos, guantes, lentes, etc.');

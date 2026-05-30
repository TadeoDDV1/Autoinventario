/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-12.2.2-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: ferreteria_db
-- ------------------------------------------------------
-- Server version	12.2.2-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `categorias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES
(1,'Herramientas Manuales','Martillos, destornilladores, llaves, etc.',1,'2026-04-30 02:28:46','2026-04-30 02:28:46'),
(2,'Herramientas Eléctricas','Taladros, sierras, lijadoras, etc.',1,'2026-04-30 02:28:46','2026-04-30 02:28:46'),
(3,'Electricidad','Cables, interruptores, contactores, etc.',1,'2026-04-30 02:28:46','2026-04-30 02:28:46'),
(4,'Plomería','Tubos, válvulas, conexiones, etc.',1,'2026-04-30 02:28:46','2026-04-30 02:28:46'),
(5,'Tornillería y Fijaciones','Tornillos, taquetes, anclas, etc.',1,'2026-04-30 02:28:46','2026-04-30 02:28:46'),
(6,'Pintura y Acabados','Pinturas, barnices, brochas, etc.',1,'2026-04-30 02:28:46','2026-04-30 02:28:46'),
(7,'Construcción','Cemento, arena, blocks, etc.',1,'2026-04-30 02:28:46','2026-04-30 02:28:46'),
(8,'Seguridad Industrial','Cascos, guantes, lentes, etc.',1,'2026-04-30 02:28:46','2026-04-30 02:28:46');
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `productos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo_barras` varchar(50) DEFAULT NULL,
  `nombre` varchar(200) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `precio_compra` decimal(10,2) NOT NULL DEFAULT 0.00,
  `precio_venta` decimal(10,2) NOT NULL DEFAULT 0.00,
  `stock_actual` int(11) DEFAULT 0,
  `stock_minimo` int(11) DEFAULT 5,
  `categoria_id` int(11) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `imagen_url` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo_barras` (`codigo_barras`),
  KEY `idx_codigo_barras` (`codigo_barras`),
  KEY `idx_nombre` (`nombre`),
  KEY `idx_categoria` (`categoria_id`),
  CONSTRAINT `1` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES
(1,'750100000001','Martillo 16oz','Mango fibra, cabeza acero',80.00,125.00,24,5,1,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1541604193435-22287d32c2c2?w=150&q=80'),
(2,'750100000002','Juego de destornilladores','6 piezas punta plana/philips',90.00,150.00,15,4,1,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1541604193435-22287d32c2c2?w=150&q=80'),
(3,'750100000003','Taladro percutor 600W','Velocidad variable, 13mm',900.00,1250.00,6,2,2,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1541604193435-22287d32c2c2?w=150&q=80'),
(4,'750100000004','Disco corte metal 4.5','Pack 10 piezas',120.00,220.00,18,6,2,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1541604193435-22287d32c2c2?w=150&q=80'),
(5,'750100000005','Cable THW 12 AWG','Rollo 100m',700.00,980.00,8,2,3,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1558611848-73f7eb4001a1?w=150&q=80'),
(6,'750100000006','Contactos dobles','Blanco, paquete 5',85.00,140.00,30,8,3,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1558611848-73f7eb4001a1?w=150&q=80'),
(7,'750100000007','Codo PVC 1/2','Paquete 10',22.00,55.00,60,15,4,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=150&q=80'),
(8,'750100000008','Llave de paso 1/2','Bronce',65.00,110.00,20,5,4,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=150&q=80'),
(9,'750100000009','Tornillo 1/4 x 1','Bolsa 100 pzas',45.00,85.00,40,10,5,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1586864387789-228f090c7414?w=150&q=80'),
(10,'750100000010','Taquete 1/4','Bolsa 50 pzas',30.00,60.00,50,12,5,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1586864387789-228f090c7414?w=150&q=80'),
(11,'750100000011','Pintura vinilica 19L','Blanco mate',520.00,790.00,12,3,6,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1562259929-b7e181d8d002?w=150&q=80'),
(12,'750100000012','Brocha 2 pulgadas','Cerda mixta',20.00,45.00,35,10,6,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1562259929-b7e181d8d002?w=150&q=80'),
(13,'750100000013','Cemento gris 50kg','Uso general',160.00,210.00,18,6,7,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=150&q=80'),
(14,'750100000014','Arena 1m3','Arena fina',220.00,320.00,10,3,7,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=150&q=80'),
(15,'750100000015','Guantes de carnaza','Talla L',35.00,65.00,25,8,8,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1581646271589-9a00cedfabce?w=150&q=80'),
(16,'750100000016','Lentes de seguridad','Antiempañantes',40.00,75.00,28,8,8,1,'2026-04-30 03:43:16','2026-04-30 03:46:51','https://images.unsplash.com/photo-1581646271589-9a00cedfabce?w=150&q=80');
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-05-12 13:29:02

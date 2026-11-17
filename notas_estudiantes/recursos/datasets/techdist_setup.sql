-- ============================================================
--  CURSO: MODELO DE DATOS
--  Clase 16 — PRÁCTICA ESTUDIANTIL
--  Tema: DML — SELECT básico, filtros y funciones de agregación
--  Fecha: 9 de septiembre
-- ============================================================


-- ============================================================
--  PARTE 1 — PREPARACIÓN DEL ENTORNO
--  Ejecuta este bloque completo antes de comenzar los ejercicios
-- ============================================================

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;

CREATE TABLE productos (
    id_producto  SERIAL          PRIMARY KEY,
    nombre       VARCHAR(100)    NOT NULL,
    categoria    VARCHAR(50)     NOT NULL,
    precio       NUMERIC(10,2)   NOT NULL CHECK (precio > 0),
    stock        INT             NOT NULL DEFAULT 0
);

CREATE TABLE ventas (
    id_venta    SERIAL          PRIMARY KEY,
    id_producto INT             NOT NULL REFERENCES productos(id_producto),
    ciudad      VARCHAR(50),
    vendedor    VARCHAR(100),
    cantidad    INT             NOT NULL CHECK (cantidad > 0),
    fecha       DATE            NOT NULL
);

-- Datos: TechDist S.A.S. — distribuidora de accesorios tecnológicos
INSERT INTO productos (nombre, categoria, precio, stock) VALUES
('Teclado Mecánico RGB',  'Periféricos',    189000, 25),
('Mouse Gamer Pro',       'Periféricos',     95000, 40),
('Audífonos Bluetooth',   'Audio',          215000, 15),
('SSD 500GB',             'Almacenamiento', 178000, 30),
('Memoria USB 64GB',      'Almacenamiento',  42000, 80),
('Control Xbox Series',   'Gaming',         289000, 10),
('Silla Ergonómica',      'Accesorios',     540000,  5),
('Mousepad XL',           'Accesorios',      35000, 60),
('Webcam HD 1080p',       'Periféricos',    128000, 20),
('Parlantes 2.1',         'Audio',          165000, 18),
('Hub USB-C 7en1',        'Accesorios',      89000, 35),
('Headset Gamer',         'Gaming',         245000, 12);

INSERT INTO ventas (id_producto, ciudad, vendedor, cantidad, fecha) VALUES
(1,  'Bogotá',        'Laura Martínez',  3,  '2024-03-10'),
(2,  'Medellín',      'Carlos Ríos',     5,  '2024-03-11'),
(3,  'Cali',          'Ana García',      2,  '2024-03-12'),
(4,  'Bogotá',        'Laura Martínez',  4,  '2024-03-13'),
(5,  'Barranquilla',  'Pedro Gómez',    10,  '2024-03-14'),
(1,  'Medellín',      'Carlos Ríos',     2,  '2024-03-15'),
(6,  'Bogotá',        'Laura Martínez',  1,  '2024-04-01'),
(7,  'Cali',          'Ana García',      1,  '2024-04-02'),
(8,  'Bogotá',        'Laura Martínez',  6,  '2024-04-03'),
(9,  'Bucaramanga',   'Sofía Herrera',   3,  '2024-04-05'),
(2,  'Bogotá',        'Laura Martínez',  8,  '2024-04-10'),
(10, 'Medellín',      'Carlos Ríos',     2,  '2024-04-11'),
(11, 'Cali',          'Ana García',      4,  '2024-04-12'),
(3,  'Bogotá',         NULL,             1,  '2024-04-15'),
(12, 'Medellín',      'Carlos Ríos',     2,  '2024-05-01'),
(4,  'Barranquilla',  'Pedro Gómez',     3,  '2024-05-03'),
(5,  'Bogotá',        'Laura Martínez', 15,  '2024-05-05'),
(1,  'Cali',          'Ana García',      2,  '2024-05-07'),
(6,  'Bucaramanga',   'Sofía Herrera',   1,  '2024-05-08'),
(8,  'Medellín',      'Carlos Ríos',     3,  '2024-05-10'),
(9,   NULL,           'Pedro Gómez',     2,  '2024-05-12'),
(2,  'Cali',          'Ana García',      4,  '2024-05-15'),
(11, 'Bogotá',        'Laura Martínez',  5,  '2024-05-16'),
(7,  'Barranquilla',  'Pedro Gómez',     1,  '2024-05-18'),
(12, 'Bogotá',        'Laura Martínez',  3,  '2024-05-20');

-- Verificación: deben aparecer 12 productos y 25 ventas
SELECT COUNT(*) AS productos FROM productos;
SELECT COUNT(*) AS ventas    FROM ventas;

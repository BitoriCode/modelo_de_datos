-- =============================================================
-- ShopEasy — Tienda de e-commerce
-- Dataset para Clase 22: JOINs avanzados, optimización e índices
-- =============================================================

DROP TABLE IF EXISTS detalle_pedido CASCADE;
DROP TABLE IF EXISTS pedido          CASCADE;
DROP TABLE IF EXISTS producto        CASCADE;
DROP TABLE IF EXISTS categoria       CASCADE;
DROP TABLE IF EXISTS cliente         CASCADE;

-- -----------------------------------------------------------
-- TABLAS
-- -----------------------------------------------------------

-- categoria.id_padre → FK a sí misma (permite Self-JOIN)
CREATE TABLE categoria (
    id_categoria INT         PRIMARY KEY,
    nombre       VARCHAR(60) NOT NULL,
    id_padre     INT         REFERENCES categoria(id_categoria)
);

CREATE TABLE producto (
    id_producto  VARCHAR(10)  PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    precio_cop   INT          NOT NULL,
    stock        INT          NOT NULL DEFAULT 0,
    id_categoria INT          REFERENCES categoria(id_categoria)
    -- NULL = sin categoría asignada
);

CREATE TABLE cliente (
    id_cliente VARCHAR(10)  PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    email      VARCHAR(100),
    ciudad     VARCHAR(60),
    plan       VARCHAR(10)  NOT NULL CHECK (plan IN ('regular', 'vip'))
);

CREATE TABLE pedido (
    id_pedido  INT         PRIMARY KEY,
    id_cliente VARCHAR(10) NOT NULL REFERENCES cliente(id_cliente),
    fecha      DATE        NOT NULL,
    estado     VARCHAR(12) NOT NULL CHECK (estado IN ('entregado', 'cancelado', 'pendiente'))
);

CREATE TABLE detalle_pedido (
    id_detalle      SERIAL      PRIMARY KEY,
    id_pedido       INT         NOT NULL REFERENCES pedido(id_pedido),
    id_producto     VARCHAR(10) NOT NULL REFERENCES producto(id_producto),
    cantidad        INT         NOT NULL,
    precio_unitario INT         NOT NULL
);

-- -----------------------------------------------------------
-- DATOS
-- -----------------------------------------------------------

-- 8 categorías: 4 raíz + 4 hijas
INSERT INTO categoria VALUES
  (1, 'Electrónica',  NULL),
  (2, 'Ropa',         NULL),
  (3, 'Hogar',        NULL),   -- sin productos → útil para FULL OUTER JOIN
  (4, 'Deportes',     NULL),   -- sin productos → útil para FULL OUTER JOIN
  (5, 'Smartphones',  1),
  (6, 'Laptops',      1),
  (7, 'Camisetas',    2),
  (8, 'Pantalones',   2);

-- 14 productos: 12 con categoría, 2 sin categoría asignada
INSERT INTO producto VALUES
  ('PRD-01', 'iPhone 14 Pro',       3800000,  5, 5),
  ('PRD-02', 'Samsung Galaxy S23',  2900000,  8, 5),
  ('PRD-03', 'MacBook Air M2',      6500000,  3, 6),
  ('PRD-04', 'Dell XPS 13',         5200000,  4, 6),
  ('PRD-05', 'Camiseta Polo',          89000, 50, 7),
  ('PRD-06', 'Camiseta Básica',        45000,120, 7),
  ('PRD-07', 'Jean Slim Fit',         185000, 30, 8),
  ('PRD-08', 'Pantalón Cargo',        145000, 25, 8),
  ('PRD-09', 'Auriculares Sony',      450000, 15, 5),
  ('PRD-10', 'Tablet Samsung',       1200000,  6, 5),
  ('PRD-11', 'Teclado Mecánico',      320000, 20, 6),
  ('PRD-12', 'Mouse Inalámbrico',      95000, 40, 6),
  ('PRD-13', 'Zapatillas Running',    280000,  0, NULL),  -- sin categoría, sin ventas
  ('PRD-14', 'Botella Deportiva',      35000, 60, NULL);  -- sin categoría, sin ventas

-- 10 clientes: 8 con pedidos, 2 sin ningún pedido
INSERT INTO cliente VALUES
  ('CLI-01', 'Ana Torres',      'ana@email.com',      'Bogotá',       'vip'),
  ('CLI-02', 'Carlos Ruiz',     'carlos@email.com',   'Medellín',     'regular'),
  ('CLI-03', 'Diana Leal',      'diana@email.com',    'Cali',         'vip'),
  ('CLI-04', 'Eduardo Mora',    'eduardo@email.com',  'Bogotá',       'regular'),
  ('CLI-05', 'Fernanda Castro', 'fernanda@email.com', 'Barranquilla', 'regular'),
  ('CLI-06', 'Gabriel Ríos',    'gabriel@email.com',  'Medellín',     'vip'),
  ('CLI-07', 'Helena Vargas',   'helena@email.com',   'Bogotá',       'regular'),
  ('CLI-08', 'Ignacio Peña',    'ignacio@email.com',  'Cali',         'regular'),
  ('CLI-09', 'Juliana Soto',    'juliana@email.com',  'Bogotá',       'vip'),    -- sin pedidos
  ('CLI-10', 'Kevin Álvarez',   'kevin@email.com',    'Medellín',     'regular');-- sin pedidos

-- 18 pedidos
INSERT INTO pedido VALUES
  (1,  'CLI-01', '2024-01-15', 'entregado'),
  (2,  'CLI-01', '2024-02-10', 'entregado'),
  (3,  'CLI-02', '2024-01-20', 'entregado'),
  (4,  'CLI-02', '2024-03-05', 'cancelado'),
  (5,  'CLI-03', '2024-01-25', 'entregado'),
  (6,  'CLI-03', '2024-02-28', 'entregado'),
  (7,  'CLI-04', '2024-02-14', 'entregado'),
  (8,  'CLI-04', '2024-03-20', 'pendiente'),
  (9,  'CLI-05', '2024-01-30', 'entregado'),
  (10, 'CLI-05', '2024-02-20', 'cancelado'),
  (11, 'CLI-06', '2024-01-10', 'entregado'),
  (12, 'CLI-06', '2024-02-05', 'entregado'),
  (13, 'CLI-06', '2024-03-15', 'entregado'),
  (14, 'CLI-07', '2024-02-25', 'entregado'),
  (15, 'CLI-07', '2024-03-10', 'pendiente'),
  (16, 'CLI-08', '2024-01-18', 'entregado'),
  (17, 'CLI-08', '2024-03-01', 'entregado'),
  (18, 'CLI-01', '2024-03-25', 'pendiente');

-- 30 líneas de detalle
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
  (1,  'PRD-01', 1, 3800000),
  (1,  'PRD-09', 2,  450000),
  (2,  'PRD-03', 1, 6500000),
  (3,  'PRD-05', 3,   89000),
  (3,  'PRD-07', 1,  185000),
  (4,  'PRD-04', 1, 5200000),
  (5,  'PRD-02', 1, 2900000),
  (5,  'PRD-11', 1,  320000),
  (6,  'PRD-06', 5,   45000),
  (6,  'PRD-08', 2,  145000),
  (7,  'PRD-10', 1, 1200000),
  (7,  'PRD-12', 2,   95000),
  (8,  'PRD-01', 1, 3800000),
  (8,  'PRD-03', 1, 6500000),
  (9,  'PRD-05', 2,   89000),
  (9,  'PRD-06', 3,   45000),
  (10, 'PRD-04', 1, 5200000),
  (11, 'PRD-01', 1, 3800000),
  (11, 'PRD-02', 1, 2900000),
  (12, 'PRD-03', 1, 6500000),
  (12, 'PRD-11', 2,  320000),
  (13, 'PRD-09', 3,  450000),
  (14, 'PRD-07', 2,  185000),
  (14, 'PRD-08', 1,  145000),
  (15, 'PRD-10', 1, 1200000),
  (16, 'PRD-02', 1, 2900000),
  (16, 'PRD-12', 3,   95000),
  (17, 'PRD-05', 4,   89000),
  (17, 'PRD-06', 2,   45000),
  (18, 'PRD-04', 1, 5200000);

-- -----------------------------------------------------------
-- VERIFICACIÓN
-- -----------------------------------------------------------
SELECT COUNT(*) AS categorias    FROM categoria;     -- 8
SELECT COUNT(*) AS productos     FROM producto;      -- 14
SELECT COUNT(*) AS clientes      FROM cliente;       -- 10
SELECT COUNT(*) AS pedidos       FROM pedido;        -- 18
SELECT COUNT(*) AS lineas        FROM detalle_pedido;-- 30
SELECT COUNT(*) AS sin_categoria FROM producto WHERE id_categoria IS NULL; -- 2
SELECT COUNT(*) AS sin_pedidos   FROM cliente c
  WHERE NOT EXISTS (SELECT 1 FROM pedido p WHERE p.id_cliente = c.id_cliente); -- 2

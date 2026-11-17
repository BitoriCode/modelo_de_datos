# Práctica guiada — Clase 17
**DML: INSERT, UPDATE, DELETE + subconsultas**

---

```sql
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;

CREATE TABLE productos (
    id_producto  SERIAL         PRIMARY KEY,
    nombre       VARCHAR(100)   NOT NULL,
    categoria    VARCHAR(50)    NOT NULL,
    precio       NUMERIC(10,2)  NOT NULL CHECK (precio > 0),
    stock        INT            NOT NULL DEFAULT 0
);
CREATE TABLE ventas (
    id_venta    SERIAL  PRIMARY KEY,
    id_producto INT     NOT NULL REFERENCES productos(id_producto),
    ciudad      VARCHAR(50),
    vendedor    VARCHAR(100),
    cantidad    INT     NOT NULL CHECK (cantidad > 0),
    fecha       DATE    NOT NULL
);

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

SELECT COUNT(*) AS productos FROM productos;  -- debe dar 12
SELECT COUNT(*) AS ventas    FROM ventas;     -- debe dar 25
```

---

## INSERT

**1.** Inserta un nuevo producto: `'Micrófono USB'`, categoría `'Periféricos'`, precio `175000`, stock `20`.

**2.** Inserta dos productos en un solo `INSERT`:
- `'Impresora Laser'`, `'Periféricos'`, `380000`, stock `8`
- `'Soporte Monitor'`, `'Accesorios'`, `95000`, stock `15`

**3.** Intenta insertar un producto con `precio = -1000`. Observa el error y explícalo.

**4.** Registra una venta del Micrófono USB (`id_producto = 13`): ciudad `'Bogotá'`, vendedor `'Laura Martínez'`, cantidad `3`, fecha `'2024-06-01'`.

---

## UPDATE

**5.** Actualiza el precio de `'Silla Ergonómica'` a `520000`.

**6.** Aumenta un 15% el precio de todos los productos de la categoría `'Almacenamiento'`.

**7.** Todas las ventas registradas sin ciudad (`NULL`) corresponden a `'Bogotá'`. Corrígelas.

---

## DELETE

**8.** Elimina todas las ventas realizadas en `'Bucaramanga'`.

**9.** Intenta eliminar el producto `'Mouse Gamer Pro'` (`id_producto = 2`). Observa el error y explica por qué ocurre.

**10.** Elimina todas las ventas donde `cantidad = 1`.

---

## Subconsultas

**11.** Lista los productos con precio mayor al promedio general de todos los productos.

**12.** Lista los productos que **nunca** han sido vendidos.

**13.** Lista las ventas de productos de la categoría `'Gaming'`.

**14.** Aplica un descuento del 10% a los productos cuyo precio supere el promedio general.

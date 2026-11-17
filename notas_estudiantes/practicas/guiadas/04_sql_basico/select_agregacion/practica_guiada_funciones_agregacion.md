# Práctica guiada — Clase 16
**DML: SELECT, filtros y funciones de agregación**

---

```sql
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
```

## Bloque 1 — SELECT básico

1. Trae todas las columnas de la tabla `productos`.
2. Trae solo el `nombre` y el `precio` de cada producto.
3. Trae nombre y precio renombrando las columnas como `producto` y `precio_unitario`.
4. Calcula el precio con IVA (19%) de cada producto, redondeado a 2 decimales. Llama a la columna `precio_con_iva`.
5. Muestra cada producto en el formato `"nombre [categoria]"` en una sola columna llamada `descripcion`.
6. ¿Qué categorías distintas existen en `productos`? (sin repetidos)
7. ¿Qué ciudades distintas aparecen en `ventas`? (sin repetidos)

---

## Bloque 2 — WHERE: filtros

8. Lista los productos con precio mayor a $200.000.
9. Lista los productos con stock menor o igual a 10.
10. Lista los productos de la categoría `'Gaming'`.
11. Lista los productos que **no** sean de la categoría `'Accesorios'`.
12. Lista los productos de `'Gaming'` con precio menor a $300.000. *(AND)*
13. Lista los productos de `'Audio'` o `'Gaming'`. *(OR)*
14. Lista los productos con precio entre $100.000 y $250.000. *(BETWEEN)*
15. Lista las ventas registradas durante abril de 2024. *(BETWEEN con fechas)*
16. Lista los productos cuya categoría sea `'Audio'` o `'Gaming'`. *(IN)*
17. Lista los productos cuya categoría **no** sea `'Accesorios'` ni `'Almacenamiento'`. *(NOT IN)*
18. Lista los productos cuyo nombre empiece con `"Mouse"`. *(LIKE)*
19. Lista los productos cuyo nombre contenga la palabra `"Gamer"` en cualquier posición. *(LIKE)*
20. Lista las ventas sin ciudad registrada. *(IS NULL)*
21. Lista las ventas que sí tienen ciudad registrada. *(IS NOT NULL)*

---

## Bloque 3 — ORDER BY y LIMIT

22. Lista nombre y precio de los productos, ordenados de mayor a menor precio.
23. Lista nombre, categoría y precio, ordenado por categoría (A→Z) y dentro de cada categoría por precio (mayor→menor).
24. ¿Cuáles son los 5 productos más caros? *(LIMIT)*

---

## Bloque 4 — Funciones de agregación

25. ¿Cuántas ventas hay en total?
26. En una sola consulta: ¿cuántas ventas hay en total y cuántas tienen ciudad registrada?
27. ¿Cuántas unidades se han vendido en total? *(SUM)*
28. ¿Cuál es el precio promedio de los productos? Redondea a 2 decimales. *(AVG)*
29. ¿Cuál es el producto más caro y el más barato? *(MAX y MIN)*
30. En una sola consulta: total de ventas, total de unidades, promedio de unidades por venta, venta máxima y mínima.

---

## Bloque 5 — GROUP BY y HAVING

31. ¿Cuántas unidades se vendieron en cada ciudad? Ordena de mayor a menor.
32. ¿Cuántas ventas realizó cada vendedor? Ordena de mayor a menor.
33. Por categoría: número de productos, precio promedio y producto más caro. Ordena por precio promedio descendente.
34. Muestra solo las ciudades con **más de 3 ventas** registradas. *(HAVING)*
35. Muestra solo los vendedores que hayan vendido **más de 15 unidades** en total. *(HAVING)*
36. Ventas de abril de 2024: ciudades donde se realizaron **más de 2 transacciones** ese mes. *(WHERE + GROUP BY + HAVING)*

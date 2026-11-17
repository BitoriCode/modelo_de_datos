-- ============================================================
--  CURSO: MODELO DE DATOS
--  Clase 16 — PRÁCTICA GUIADA (seguimiento de la demo del profesor)
--  Tema: DML — SELECT, filtros y funciones de agregación
--  Base de datos: TechDist S.A.S. (el profesor carga los datos)
-- ============================================================

-- Esquema de referencia:
--   productos (id_producto, nombre, categoria, precio, stock)
--   ventas    (id_venta, id_producto, ciudad, vendedor, cantidad, fecha)


-- ============================================================
--  BLOQUE 1 — SELECT básico
-- ============================================================

-- 1-A. Trae todas las columnas de la tabla productos.



-- 1-B. Trae solo el nombre y el precio de cada producto.



-- 1-C. Trae nombre y precio, pero renombra las columnas como
--      "producto" y "precio_unitario".



-- 1-D. Calcula el precio con IVA (19%) de cada producto.
--      Redondea a 2 decimales. Llama a la columna "precio_con_iva".



-- 1-E. Muestra cada producto en el formato "nombre [categoria]"
--      en una sola columna llamada "descripcion".
--      (Pista: concatenar con ||)



-- 1-F. ¿Qué categorías distintas existen en la tabla productos?
--      (Sin repetidos)



-- 1-G. ¿Qué ciudades distintas aparecen en la tabla ventas?
--      (Sin repetidos)



-- ============================================================
--  BLOQUE 2 — WHERE: filtros
-- ============================================================

-- 2-A. Lista los productos con precio mayor a $200.000.



-- 2-B. Lista los productos con stock menor o igual a 10.



-- 2-C. Lista los productos de la categoría 'Gaming'.



-- 2-D. Lista los productos que NO sean de la categoría 'Accesorios'.



-- 2-E. Lista los productos de la categoría 'Gaming' cuyo precio
--      sea menor a $300.000. (AND)



-- 2-F. Lista los productos de la categoría 'Audio' o 'Gaming'. (OR)



-- 2-G. Lista los productos cuyo precio esté entre $100.000 y $250.000.
--      (BETWEEN, incluyente)



-- 2-H. Lista las ventas registradas durante abril de 2024.
--      (BETWEEN con fechas)



-- 2-I. Lista los productos cuya categoría sea 'Audio' o 'Gaming',
--      usando la cláusula IN.



-- 2-J. Lista los productos cuya categoría NO sea 'Accesorios'
--      ni 'Almacenamiento'. (NOT IN)



-- 2-K. Lista los productos cuyo nombre empiece con la palabra "Mouse".
--      (LIKE con %)



-- 2-L. Lista los productos cuyo nombre contenga la palabra "Gamer"
--      en cualquier posición. (LIKE con %)



-- 2-M. Lista las ventas registradas sin ciudad (ciudad no informada).
--      (IS NULL)



-- 2-N. Lista las ventas que sí tienen ciudad registrada.
--      (IS NOT NULL)



-- ============================================================
--  BLOQUE 3 — ORDER BY y LIMIT
-- ============================================================

-- 3-A. Lista nombre y precio de los productos, ordenados de mayor
--      a menor precio.



-- 3-B. Lista nombre, categoría y precio, ordenado primero por
--      categoría (A→Z) y luego por precio de mayor a menor.



-- 3-C. ¿Cuáles son los 5 productos más caros?



-- ============================================================
--  BLOQUE 4 — Funciones de agregación
-- ============================================================

-- 4-A. ¿Cuántas ventas hay en total?



-- 4-B. En una sola consulta:
--      - ¿Cuántas ventas hay en total?
--      - ¿Cuántas ventas tienen ciudad registrada?



-- 4-C. ¿Cuántas unidades se han vendido en total?
--      (SUM sobre la columna cantidad)



-- 4-D. ¿Cuál es el precio promedio de los productos?
--      Redondea a 2 decimales.



-- 4-E. ¿Cuál es el producto más caro y el más barato?
--      (MAX y MIN en una sola consulta)



-- 4-F. En una sola consulta: total de ventas, total de unidades,
--      promedio de unidades por venta, venta máxima y venta mínima.



-- ============================================================
--  BLOQUE 5 — GROUP BY y HAVING
-- ============================================================

-- 5-A. ¿Cuántas unidades se vendieron en cada ciudad?
--      Ordena de mayor a menor total.



-- 5-B. ¿Cuántas ventas realizó cada vendedor?
--      Ordena de mayor a menor.



-- 5-C. Por categoría, muestra: número de productos, precio promedio
--      (redondeado) y el producto más caro.
--      Ordena por precio promedio descendente.



-- 5-D. Muestra solo las ciudades con más de 3 ventas registradas.
--      (GROUP BY + HAVING)



-- 5-E. Muestra solo los vendedores que hayan vendido más de 15
--      unidades en total. (GROUP BY + HAVING sobre SUM)



-- 5-F. Ventas de abril de 2024: muestra las ciudades donde se
--      realizaron más de 2 transacciones ese mes.
--      (WHERE + GROUP BY + HAVING combinados)

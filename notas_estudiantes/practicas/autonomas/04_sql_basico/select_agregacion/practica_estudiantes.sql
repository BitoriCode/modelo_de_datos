-- Preparación compartida (recursos/datasets desde la raíz de notas): techdist_setup.sql
-- en una base de práctica. Las tablas y datos tienen una sola fuente.



-- ============================================================
--  PARTE 2 — EJERCICIOS
--  Escribe tu consulta debajo de cada enunciado.
-- ============================================================

-- -------------------------------------------------------------
--  BLOQUE A — SELECT básico
-- -------------------------------------------------------------

-- EJERCICIO 1
-- Lista el nombre, categoría y precio de todos los productos.
-- Renombra las columnas como: producto, categoria, precio_unitario.



-- EJERCICIO 2
-- ¿Cuántas categorías distintas de productos existen?
-- (Pista: DISTINCT + COUNT)



-- EJERCICIO 3
-- Lista el nombre de cada producto junto con su precio con IVA (19%).
-- Muestra el resultado ordenado de mayor a menor precio con IVA.
-- Redondea a 2 decimales.



-- -------------------------------------------------------------
--  BLOQUE B — WHERE: filtros
-- -------------------------------------------------------------

-- EJERCICIO 4
-- Lista todos los productos cuyo precio supere los $200.000.



-- EJERCICIO 5
-- Lista los productos de la categoría 'Gaming' o 'Audio',
-- ordenados por precio de menor a mayor.



-- EJERCICIO 6
-- Lista los productos cuyo precio esté entre $80.000 y $200.000 (incluyente).



-- EJERCICIO 7
-- Lista todos los productos cuyo nombre contenga la palabra "Gamer".



-- EJERCICIO 8
-- Lista todas las ventas registradas en abril de 2024.



-- EJERCICIO 9
-- ¿Cuáles ventas no tienen ciudad registrada?
-- Muestra el id_venta, vendedor, cantidad y fecha.



-- EJERCICIO 10
-- Lista las ventas realizadas en Bogotá o Medellín por Laura Martínez.



-- -------------------------------------------------------------
--  BLOQUE C — Funciones de agregación
-- -------------------------------------------------------------

-- EJERCICIO 11
-- ¿Cuántas ventas hay en total?
-- ¿Cuántas de esas ventas tienen ciudad registrada?
-- Muéstralo en una sola consulta con dos columnas.



-- EJERCICIO 12
-- ¿Cuál es el precio más caro, el más barato y el precio promedio
-- de todos los productos? (todo en una sola consulta)



-- EJERCICIO 13
-- ¿Cuántas unidades en total se han vendido?
-- ¿Cuál fue la venta más grande (más unidades en una sola transacción)?



-- EJERCICIO 14
-- ¿Cuál es el stock total disponible de productos de la categoría 'Accesorios'?



-- -------------------------------------------------------------
--  BLOQUE D — GROUP BY y HAVING
-- -------------------------------------------------------------

-- EJERCICIO 15
-- Muestra cuántos productos hay en cada categoría.
-- Ordena de mayor a menor cantidad.



-- EJERCICIO 16
-- Muestra el total de unidades vendidas por ciudad.
-- Ordena de mayor a menor total.



-- EJERCICIO 17
-- Muestra el número de ventas y el total de unidades vendidas por vendedor.
-- Ordena por total de unidades de forma descendente.



-- EJERCICIO 18
-- Muestra solo los vendedores que hayan vendido más de 15 unidades en total.



-- EJERCICIO 19
-- Muestra las categorías cuyo precio promedio supere los $150.000.
-- Incluye el número de productos y el precio promedio (redondeado).



-- EJERCICIO 20  ★ Desafío
-- Lista las ciudades donde se realizaron ventas en marzo de 2024
-- y cuyo total de unidades vendidas ese mes supere las 5 unidades.
-- (Pista: WHERE para filtrar el mes + GROUP BY ciudad + HAVING)

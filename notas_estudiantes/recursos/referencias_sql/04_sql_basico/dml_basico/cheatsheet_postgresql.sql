-- ============================================================
--  CHEATSHEET — DML: INSERT, UPDATE, DELETE + Subconsultas
--  Clase 17 | Modelo de Datos
-- ============================================================


-- ============================================================
--  1. INSERT
-- ============================================================

-- Insertar una fila (especificando columnas — recomendado)
INSERT INTO tabla (col1, col2, col3)
VALUES (val1, val2, val3);

-- Insertar múltiples filas en un solo comando
INSERT INTO tabla (col1, col2)
VALUES
    (val1a, val2a),
    (val1b, val2b),
    (val1c, val2c);

-- Errores comunes:
--   PK duplicada          → duplicate key value violates unique constraint
--   FK inexistente        → violates foreign key constraint
--   NOT NULL vacío        → null value violates not-null constraint
--   CHECK fallido         → violates check constraint


-- ============================================================
--  2. UPDATE
-- ============================================================

-- Modificar una columna
UPDATE tabla
SET col1 = nuevo_valor
WHERE condicion;

-- Modificar múltiples columnas
UPDATE tabla
SET col1 = val1, col2 = val2
WHERE condicion;

-- Modificar con expresión
UPDATE tabla
SET precio = ROUND(precio * 1.10)   -- aumento del 10%
WHERE condicion;

-- ⚠️  SIN WHERE actualiza TODAS las filas
-- Técnica defensiva: primero SELECT con la misma condición, luego UPDATE


-- ============================================================
--  3. DELETE
-- ============================================================

-- Eliminar filas que cumplen la condición
DELETE FROM tabla WHERE condicion;

-- ⚠️  SIN WHERE elimina TODAS las filas de la tabla

-- No se puede eliminar un registro padre si tiene hijos con FK
--   → primero eliminar los hijos, luego el padre


-- ============================================================
--  4. TRUNCATE vs DELETE
-- ============================================================

TRUNCATE TABLE tabla;   -- elimina todo, rápido, resetea SERIAL
DELETE  FROM  tabla;    -- elimina todo, lento, no resetea SERIAL

-- TRUNCATE no acepta WHERE
-- DELETE acepta WHERE y es reversible con ROLLBACK


-- ============================================================
--  5. Subconsultas
-- ============================================================

-- Subconsulta ESCALAR — devuelve un único valor
-- Usar con: = > < >= <=

SELECT * FROM tabla
WHERE col > (SELECT AVG(col) FROM tabla);

UPDATE tabla
SET col = col * 0.9
WHERE col > (SELECT AVG(col) FROM tabla);

-- Subconsulta de LISTA — devuelve múltiples valores
-- Usar con: IN / NOT IN

SELECT * FROM tabla_a
WHERE id IN (SELECT id FROM tabla_b WHERE condicion);

DELETE FROM tabla
WHERE id NOT IN (SELECT id FROM otra_tabla);

-- Esquema mental:
--
--   SELECT externo
--   WHERE col operador (
--       SELECT ...      ← se ejecuta primero
--   );


-- ============================================================
--  6. Orden de operaciones recomendado
-- ============================================================

-- Antes de un UPDATE o DELETE, siempre:
-- 1. SELECT con la misma condición para ver qué filas se afectan
-- 2. Verificar que el resultado es el esperado
-- 3. Ejecutar el UPDATE / DELETE

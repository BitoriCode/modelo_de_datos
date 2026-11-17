-- ============================================================
--  CHEATSHEET — DML: SELECT, WHERE, Agregación
--  Clase 16 | Modelo de Datos
-- ============================================================


-- ============================================================
--  1. SELECT — estructura básica
-- ============================================================

-- Todas las columnas
SELECT * FROM tabla;

-- Columnas específicas
SELECT col1, col2 FROM tabla;

-- Alias
SELECT col1 AS alias1, col2 AS alias2 FROM tabla;

-- Expresiones calculadas
SELECT col1, col2 * 1.19 AS col2_con_iva FROM tabla;

-- Eliminar duplicados
SELECT DISTINCT col1 FROM tabla;


-- ============================================================
--  2. WHERE — filtrar filas
-- ============================================================

-- Comparadores
-- =    igual
-- <>   distinto (también !=)
-- >    mayor que
-- <    menor que
-- >=   mayor o igual
-- <=   menor o igual

SELECT * FROM tabla WHERE col1 = 'valor';
SELECT * FROM tabla WHERE col2 > 100;

-- AND, OR, NOT
SELECT * FROM tabla WHERE col1 = 'A' AND col2 > 50;
SELECT * FROM tabla WHERE col1 = 'A' OR col1 = 'B';
SELECT * FROM tabla WHERE NOT col1 = 'A';

-- BETWEEN (incluyente en ambos extremos)
SELECT * FROM tabla WHERE col2 BETWEEN 100 AND 500;
SELECT * FROM tabla WHERE fecha BETWEEN '2024-01-01' AND '2024-12-31';

-- IN (lista de valores)
SELECT * FROM tabla WHERE col1 IN ('X', 'Y', 'Z');
SELECT * FROM tabla WHERE col1 NOT IN ('X', 'Y');

-- LIKE / ILIKE (patrones de texto)
-- %  →  cero o más caracteres cualquiera
-- _  →  exactamente un carácter
SELECT * FROM tabla WHERE col1 LIKE 'Ana%';       -- empieza con Ana
SELECT * FROM tabla WHERE col1 LIKE '%García';    -- termina en García
SELECT * FROM tabla WHERE col1 LIKE '%ria%';      -- contiene "ria"
SELECT * FROM tabla WHERE col1 ILIKE '%ria%';     -- igual, sin distinción mayúsc.

-- IS NULL / IS NOT NULL
SELECT * FROM tabla WHERE col1 IS NULL;
SELECT * FROM tabla WHERE col1 IS NOT NULL;
-- NUNCA usar: WHERE col1 = NULL  (siempre devuelve vacío)


-- ============================================================
--  3. ORDER BY y LIMIT
-- ============================================================

SELECT col1, col2 FROM tabla ORDER BY col2 ASC;   -- ascendente (por defecto)
SELECT col1, col2 FROM tabla ORDER BY col2 DESC;  -- descendente

-- Múltiples criterios
SELECT col1, col2, col3 FROM tabla ORDER BY col2 ASC, col3 DESC;

-- Limitar resultados
SELECT col1 FROM tabla ORDER BY col2 DESC LIMIT 10;

-- Paginación
SELECT col1 FROM tabla ORDER BY col2 LIMIT 10 OFFSET 20;  -- registros 21 al 30


-- ============================================================
--  4. Funciones de agregación
-- ============================================================

-- COUNT: contar filas
SELECT COUNT(*) FROM tabla;                 -- cuenta todas las filas
SELECT COUNT(col1) FROM tabla;              -- ignora NULLs en col1

-- SUM: sumar
SELECT SUM(col_numerica) FROM tabla;

-- AVG: promedio
SELECT AVG(col_numerica) FROM tabla;
SELECT ROUND(AVG(col_numerica), 2) FROM tabla;   -- con 2 decimales

-- MAX y MIN
SELECT MAX(col_numerica) FROM tabla;
SELECT MIN(col_numerica) FROM tabla;

-- Combinadas
SELECT
    COUNT(*)              AS total_filas,
    SUM(col_num)          AS suma,
    ROUND(AVG(col_num),2) AS promedio,
    MAX(col_num)          AS maximo,
    MIN(col_num)          AS minimo
FROM tabla;


-- ============================================================
--  5. GROUP BY — agrupar resultados
-- ============================================================

-- Regla: toda columna en SELECT que NO sea función de agregación
--        debe aparecer en GROUP BY

SELECT col_grupo, COUNT(*) AS total
FROM tabla
GROUP BY col_grupo;

SELECT col_grupo, SUM(col_num) AS suma_total
FROM tabla
GROUP BY col_grupo
ORDER BY suma_total DESC;

SELECT col_grupo1, col_grupo2, AVG(col_num) AS promedio
FROM tabla
GROUP BY col_grupo1, col_grupo2;


-- ============================================================
--  6. HAVING — filtrar grupos
-- ============================================================

-- WHERE filtra FILAS antes de agrupar
-- HAVING filtra GRUPOS después de agrupar

SELECT col_grupo, COUNT(*) AS total
FROM tabla
GROUP BY col_grupo
HAVING COUNT(*) > 5;

SELECT col_grupo, SUM(col_num) AS suma
FROM tabla
GROUP BY col_grupo
HAVING SUM(col_num) > 1000;


-- ============================================================
--  7. Consulta completa — orden de escritura
-- ============================================================

SELECT   columnas / funciones_de_agregación
FROM     tabla
WHERE    condición_sobre_filas
GROUP BY columna(s)
HAVING   condición_sobre_grupos
ORDER BY columna ASC|DESC
LIMIT    n OFFSET m;

-- Orden de EJECUCIÓN (no de escritura):
-- FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT


-- ============================================================
--  8. Referencia rápida — operadores y funciones útiles
-- ============================================================

-- Redondear
ROUND(valor, decimales)          -- ROUND(3.14159, 2) → 3.14

-- Valor absoluto
ABS(valor)                       -- ABS(-15) → 15

-- Concatenar texto
col1 || ' ' || col2              -- 'Juan' || ' ' || 'Pérez' → 'Juan Pérez'

-- Longitud de texto
LENGTH(col_texto)                -- LENGTH('Bogotá') → 6

-- Convertir a mayúsculas / minúsculas
UPPER(col_texto)
LOWER(col_texto)

-- Fecha actual
CURRENT_DATE                     -- '2024-09-09'

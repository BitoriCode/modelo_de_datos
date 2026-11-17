-- ============================================================
--  CHEATSHEET — Subconsultas avanzadas + JOINs
--  Clase 18 | Modelo de Datos
-- ============================================================


-- ============================================================
--  1. Subconsulta correlacionada
-- ============================================================

-- Referencia una columna de la consulta exterior (alias de tabla externo)
-- Se ejecuta UNA VEZ POR FILA de la consulta exterior

-- Escalar en SELECT: calcular un valor por cada fila
SELECT
    col_exterior,
    (SELECT funcion(col) FROM tabla_b b WHERE b.fk = a.pk) AS valor
FROM tabla_a a;

-- En WHERE: filtrar por un valor calculado por fila
SELECT * FROM tabla_a a
WHERE (SELECT COUNT(*) FROM tabla_b b WHERE b.fk = a.pk) > n;


-- ============================================================
--  2. EXISTS / NOT EXISTS
-- ============================================================

-- EXISTS: TRUE si la subconsulta devuelve al menos una fila
SELECT * FROM tabla_a a
WHERE EXISTS (
    SELECT 1 FROM tabla_b b WHERE b.fk = a.pk
);

-- NOT EXISTS: TRUE si la subconsulta no devuelve ninguna fila
SELECT * FROM tabla_a a
WHERE NOT EXISTS (
    SELECT 1 FROM tabla_b b WHERE b.fk = a.pk
);

-- EXISTS vs IN: misma semántica, EXISTS más eficiente en tablas grandes
-- IN:     WHERE pk IN (SELECT fk FROM tabla_b WHERE condicion)
-- EXISTS: WHERE EXISTS (SELECT 1 FROM tabla_b b WHERE b.fk = a.pk AND condicion)


-- ============================================================
--  3. INNER JOIN
-- ============================================================

-- Devuelve solo las filas que tienen coincidencia en AMBAS tablas
SELECT a.col1, b.col2
FROM tabla_a a
INNER JOIN tabla_b b ON a.pk = b.fk;

-- Con filtro
SELECT a.col1, b.col2
FROM tabla_a a
INNER JOIN tabla_b b ON a.pk = b.fk
WHERE b.col = 'valor';

-- Con agregación
SELECT a.col1, COUNT(*) AS total, SUM(b.num) AS suma
FROM tabla_a a
INNER JOIN tabla_b b ON a.pk = b.fk
GROUP BY a.pk, a.col1;

-- JOIN con 3 tablas
SELECT a.c1, b.c2, c.c3
FROM tabla_a a
INNER JOIN tabla_b b ON a.pk  = b.fk_a
INNER JOIN tabla_c c ON b.pk  = c.fk_b;

-- JOIN con 4 tablas
SELECT a.c1, b.c2, c.c3, d.c4
FROM tabla_a a
INNER JOIN tabla_b b ON a.pk  = b.fk_a
INNER JOIN tabla_c c ON b.pk  = c.fk_b
INNER JOIN tabla_d d ON c.pk  = d.fk_c;


-- ============================================================
--  4. LEFT JOIN
-- ============================================================

-- Devuelve TODAS las filas de la izquierda
-- Las que no tienen coincidencia a la derecha → NULL en columnas derechas
SELECT a.col1, b.col2
FROM tabla_a a
LEFT JOIN tabla_b b ON a.pk = b.fk;

-- Encontrar filas SIN coincidencia (anti-join)
SELECT a.col1
FROM tabla_a a
LEFT JOIN tabla_b b ON a.pk = b.fk
WHERE b.fk IS NULL;

-- LEFT JOIN + GROUP BY (incluye filas con 0 en el conteo)
SELECT a.col1, COUNT(b.pk) AS total
FROM tabla_a a
LEFT JOIN tabla_b b ON a.pk = b.fk
GROUP BY a.pk, a.col1;
-- COUNT(b.pk) cuenta solo las no-NULL (ignora los LEFT JOIN sin coincidencia)
-- COUNT(*) contaría 1 para filas sin coincidencia — incorrecto aquí


-- ============================================================
--  5. Tipos de JOIN — resumen visual
-- ============================================================

--  INNER JOIN  →  solo intersección
--  LEFT JOIN   →  todo A + intersección
--  RIGHT JOIN  →  intersección + todo B  (= LEFT JOIN con tablas invertidas)
--  FULL JOIN   →  todo A + intersección + todo B


-- ============================================================
--  6. Orden completo de una consulta con JOIN
-- ============================================================

SELECT   columnas / agregaciones
FROM     tabla_principal alias
JOIN     otra_tabla alias2 ON condicion_join
JOIN     otra_tabla alias3 ON condicion_join
WHERE    condicion_filas
GROUP BY columna(s)
HAVING   condicion_grupos
ORDER BY columna
LIMIT    n;

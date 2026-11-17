-- ============================================================
--  CHEATSHEET — JOINs avanzados + Tablas derivadas
--  Clase 19 | Modelo de Datos
-- ============================================================


-- ============================================================
--  1. RIGHT JOIN
-- ============================================================

-- Devuelve TODAS las filas de la tabla DERECHA + coincidencias de la izquierda
-- Es el espejo de LEFT JOIN: convención = usar siempre LEFT JOIN

SELECT a.col1, b.col2
FROM tabla_izq a
RIGHT JOIN tabla_der b ON a.fk = b.pk;

-- Equivalente exacto con LEFT JOIN (swap de tablas):
SELECT a.col1, b.col2
FROM tabla_der b
LEFT JOIN tabla_izq a ON a.fk = b.pk;


-- ============================================================
--  2. FULL OUTER JOIN
-- ============================================================

-- Devuelve TODAS las filas de AMBAS tablas
-- NULL en columnas del lado sin coincidencia

SELECT a.col1, b.col2
FROM tabla_a a
FULL OUTER JOIN tabla_b b ON a.pk = b.fk;

-- Encontrar filas sin coincidencia en la derecha:
SELECT a.col1 FROM tabla_a a
FULL OUTER JOIN tabla_b b ON a.pk = b.fk
WHERE b.fk IS NULL;

-- Encontrar filas sin coincidencia en la izquierda:
SELECT b.col2 FROM tabla_a a
FULL OUTER JOIN tabla_b b ON a.pk = b.fk
WHERE a.pk IS NULL;


-- ============================================================
--  3. CROSS JOIN
-- ============================================================

-- Producto cartesiano: cada fila de A × cada fila de B
-- NO lleva condición ON
-- N filas en A × M filas en B = N×M filas resultado

SELECT a.col1, b.col2
FROM tabla_a a
CROSS JOIN tabla_b b;

-- Contar combinaciones posibles:
SELECT COUNT(*) FROM tabla_a CROSS JOIN tabla_b;


-- ============================================================
--  4. Subconsulta como tabla derivada (en FROM)
-- ============================================================

-- La subconsulta en FROM se ejecuta UNA SOLA VEZ como tabla temporal
-- Debe tener alias obligatorio

-- Patrón básico: pre-agregar y luego unir
SELECT t_principal.col1, derivada.col_calculada
FROM tabla_principal t_principal
INNER JOIN (
    SELECT fk_col, COUNT(*) AS col_calculada
    FROM otra_tabla
    GROUP BY fk_col
) AS derivada ON t_principal.pk = derivada.fk_col;

-- Con LEFT JOIN para incluir filas sin coincidencia:
SELECT t_principal.col1, COALESCE(derivada.col_calculada, 0) AS col_calculada
FROM tabla_principal t_principal
LEFT JOIN (
    SELECT fk_col, SUM(num_col) AS col_calculada
    FROM otra_tabla
    GROUP BY fk_col
) AS derivada ON t_principal.pk = derivada.fk_col;

-- Con LIMIT dentro de la tabla derivada (top N):
SELECT t_principal.col1, top_n.col_calculada
FROM tabla_principal t_principal
INNER JOIN (
    SELECT fk_col, SUM(num_col) AS col_calculada
    FROM otra_tabla
    GROUP BY fk_col
    ORDER BY col_calculada DESC
    LIMIT 3
) AS top_n ON t_principal.pk = top_n.fk_col;


-- ============================================================
--  5. Resumen tipos de JOIN
-- ============================================================

--  INNER JOIN      →  solo filas con coincidencia en AMBAS tablas
--  LEFT  JOIN      →  TODAS las filas de la izquierda + coincidencias
--  RIGHT JOIN      →  TODAS las filas de la derecha  + coincidencias
--  FULL OUTER JOIN →  TODAS las filas de AMBAS tablas
--  CROSS JOIN      →  producto cartesiano (sin condición ON)

--  LEFT JOIN  con WHERE b.pk IS NULL   →  anti-join (filas sin coincidencia)
--  RIGHT JOIN con WHERE a.pk IS NULL   →  anti-join inverso


-- ============================================================
--  6. Orden completo de una consulta con JOIN y tabla derivada
-- ============================================================

SELECT   columnas / agregaciones / COALESCE(derivada.col, 0)
FROM     tabla_principal  alias
JOIN     otra_tabla       alias2  ON condicion
LEFT JOIN (
    SELECT fk, COUNT(*) AS total
    FROM tabla_detalle
    GROUP BY fk
) AS derivada ON alias.pk = derivada.fk
WHERE    condicion_filas
GROUP BY columna(s)
HAVING   condicion_grupos
ORDER BY columna
LIMIT    n;

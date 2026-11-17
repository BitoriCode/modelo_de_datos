-- ============================================================
--  CLASE 2 — CHEAT SHEET PostgreSQL para principiantes
--  Para compartir con estudiantes al inicio de la práctica
-- ============================================================

-- CREAR TABLA
CREATE TABLE tabla (
    columna1  TIPO  RESTRICCION,
    columna2  TIPO
);

-- TIPOS DE DATOS COMUNES
--   INT           → números enteros          (edad, cantidad)
--   SERIAL        → entero auto-incremental  (id)
--   VARCHAR(n)    → texto de hasta n chars   (nombre, email)
--   TEXT          → texto sin límite
--   BOOLEAN       → verdadero/falso
--   DATE          → fecha (YYYY-MM-DD)
--   NUMERIC(p,s)  → número decimal           (precio)

-- RESTRICCIONES COMUNES
--   PRIMARY KEY   → identificador único de la fila
--   NOT NULL      → el campo no puede quedar vacío
--   REFERENCES    → clave foránea (apunta a otra tabla)

-- INSERTAR DATOS
INSERT INTO tabla (col1, col2) VALUES ('valor1', 42);

-- CONSULTAR DATOS
SELECT *           FROM tabla;               -- todas las columnas
SELECT col1, col2  FROM tabla;               -- columnas específicas
SELECT *           FROM tabla WHERE col2 > 20; -- con filtro
SELECT col1, COUNT(*) FROM tabla GROUP BY col1; -- agrupar

-- MODIFICAR ESTRUCTURA (independencia lógica)
ALTER TABLE tabla ADD COLUMN nueva_col VARCHAR(50);
ALTER TABLE tabla DROP COLUMN columna_vieja;

-- AGREGAR ÍNDICE (independencia física)
CREATE INDEX nombre_idx ON tabla (columna);

-- ELIMINAR TABLA
DROP TABLE tabla;

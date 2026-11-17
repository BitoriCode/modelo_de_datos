-- ============================================================
--  CLASE 11 — CHEAT SHEET: Tipos de dato + CREATE TABLE básico
--  (versión reducida — restricciones completas en clase 13)
-- ============================================================


-- ── TIPOS DE DATO ESENCIALES ────────────────────────────────

--   SERIAL          → entero auto-incremental (1, 2, 3…)  · IDs generados por la BD
--   INT             → número entero                        · edad, cantidad, minutos
--   NUMERIC(p,s)    → decimal exacto                       · precios: NUMERIC(10,2)
--   VARCHAR(n)      → texto de hasta n caracteres          · nombres, códigos, correos
--   TEXT            → texto sin límite de caracteres       · descripciones, notas largas
--   BOOLEAN         → verdadero / falso                    · activo, pagado, disponible
--   DATE            → solo fecha  (YYYY-MM-DD)             · fecha_nacimiento, fecha_inicio
--   TIMESTAMP       → fecha y hora                         · created_at, updated_at


-- ── CREATE TABLE — PK simple (inline) ───────────────────────

CREATE TABLE ejemplo_simple (
    id          VARCHAR(10)   PRIMARY KEY,   -- PK inline: solo cuando es una sola columna
    nombre      VARCHAR(100)  NOT NULL,      -- NOT NULL = campo obligatorio
    descripcion TEXT,                        -- sin NOT NULL = campo opcional (admite NULL)
    activo      BOOLEAN
);


-- ── CREATE TABLE — PK compuesta (a nivel de tabla) ──────────

CREATE TABLE ejemplo_compuesto (
    codigo_a    VARCHAR(10)   NOT NULL,
    codigo_b    INT           NOT NULL,
    nombre      VARCHAR(100),
    PRIMARY KEY (codigo_a, codigo_b)         -- PK compuesta: siempre a nivel de tabla
);

-- Regla: si la PK tiene más de una columna → declarar al final con PRIMARY KEY (col1, col2)


-- ── NOT NULL ─────────────────────────────────────────────────

--   NOT NULL  → la columna no puede quedar vacía al insertar un registro
--   (sin NOT NULL) → la columna es opcional; admite NULL si no se proporciona valor


-- ── DROP TABLE IF EXISTS ──────────────────────────────────────

DROP TABLE IF EXISTS ejemplo_simple;        -- elimina sin error aunque la tabla no exista
DROP TABLE IF EXISTS ejemplo_compuesto;


-- ── VERIFICAR EN pgAdmin ──────────────────────────────────────

SELECT * FROM nombre_tabla;                 -- ver todos los registros

-- Ver columnas y tipos de una tabla:
SELECT column_name, data_type, is_nullable
  FROM information_schema.columns
 WHERE table_name = 'nombre_tabla'
 ORDER BY ordinal_position;

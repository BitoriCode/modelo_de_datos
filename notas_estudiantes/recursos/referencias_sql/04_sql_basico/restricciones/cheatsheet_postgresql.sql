-- ============================================================
--  CLASE 14 — CHEAT SHEET DDL para principiantes
--  Para compartir con estudiantes al inicio de la práctica
-- ============================================================


-- ── CREATE TABLE ────────────────────────────────────────────

CREATE TABLE nombre_tabla (
    columna1  TIPO         RESTRICCIONES,
    columna2  TIPO         RESTRICCIONES,
    columna3  TIPO                          -- última columna sin coma
);


-- ── TIPOS DE DATO MÁS USADOS ────────────────────────────────

--   SERIAL          → entero auto-incremental      (siempre para "id")
--   INT / BIGINT    → número entero                (edad, stock, cantidad)
--   NUMERIC(p, s)   → decimal preciso              (precio: NUMERIC(10,2))
--   VARCHAR(n)      → texto de hasta n caracteres  (nombre, email)
--   TEXT            → texto sin límite             (descripción, notas)
--   BOOLEAN         → verdadero / falso            (activo, pagado)
--   DATE            → fecha sin hora               (YYYY-MM-DD)
--   TIMESTAMP       → fecha y hora                 (created_at)


-- ── RESTRICCIONES (CONSTRAINTS) ─────────────────────────────

--   PRIMARY KEY            → único + obligatorio (una por tabla)
--   NOT NULL               → campo obligatorio
--   UNIQUE                 → no se puede repetir el valor
--   DEFAULT valor          → valor si no se proporciona ninguno
--   CHECK (condición)      → la condición debe ser TRUE

-- Ejemplos combinados:
--   id        SERIAL        PRIMARY KEY
--   nombre    VARCHAR(100)  NOT NULL
--   email     VARCHAR(150)  NOT NULL UNIQUE
--   precio    NUMERIC(8,2)  NOT NULL CHECK (precio >= 0)
--   stock     INT           NOT NULL DEFAULT 0 CHECK (stock >= 0)
--   activo    BOOLEAN       DEFAULT TRUE


-- ── ALTER TABLE ─────────────────────────────────────────────

-- Agregar columna:
ALTER TABLE tabla ADD COLUMN nueva_col TIPO;

-- Agregar columna con restricción:
ALTER TABLE tabla ADD COLUMN nueva_col TIPO NOT NULL DEFAULT valor;

-- Eliminar columna:
ALTER TABLE tabla DROP COLUMN columna;

-- Renombrar columna:
ALTER TABLE tabla RENAME COLUMN nombre_viejo TO nombre_nuevo;

-- Cambiar tipo de dato:
ALTER TABLE tabla ALTER COLUMN columna TYPE NUEVO_TIPO;

-- Agregar restricción CHECK:
ALTER TABLE tabla ADD CONSTRAINT nombre_constraint CHECK (condición);

-- Eliminar restricción:
ALTER TABLE tabla DROP CONSTRAINT nombre_constraint;

-- Renombrar tabla:
ALTER TABLE tabla RENAME TO nuevo_nombre;


-- ── DROP TABLE ──────────────────────────────────────────────

DROP TABLE tabla;                -- elimina la tabla (error si no existe)
DROP TABLE IF EXISTS tabla;      -- elimina solo si existe (sin error)


-- ── VERIFICAR RESULTADOS EN pgAdmin ─────────────────────────

-- Ver todas las filas de una tabla:
SELECT * FROM tabla;

-- Ver la estructura de una tabla (en pgAdmin: expandir la tabla en el panel izquierdo)
-- O con SQL:
\d tabla   -- solo funciona en psql (terminal), no en pgAdmin Query Tool

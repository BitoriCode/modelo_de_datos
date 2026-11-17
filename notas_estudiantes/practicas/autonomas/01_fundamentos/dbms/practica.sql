-- ============================================================
--  CURSO: MODELOS DE DATOS
--  Clase 2 - 6 de febrero | DEMO DEL PROFESOR
--  Tema: Tablas, Tipos de datos, Independencias
--  Herramienta: https://onecompiler.com/postgresql
--               https://db-fiddle.com (seleccionar PostgreSQL)
-- ============================================================


-- ============================================================
--  SECCIÓN 1: CREAR TABLAS
--  El profesor explica cada columna y su tipo de dato.
--  Esto representa el NIVEL CONCEPTUAL (arquitectura ANSI/SPARC).
-- ============================================================

CREATE TABLE estudiantes (
    id      SERIAL        PRIMARY KEY,   -- SERIAL: entero auto-incremental (lo asigna PostgreSQL solo)
    nombre  VARCHAR(100)  NOT NULL,      -- VARCHAR(100): texto de hasta 100 caracteres
    edad    INT,                          -- INT: número entero
    carrera VARCHAR(80),                  -- VARCHAR(80): texto de hasta 80 caracteres
    activo  BOOLEAN       DEFAULT TRUE    -- BOOLEAN: verdadero (TRUE) o falso (FALSE)
);

CREATE TABLE cursos (
    id           SERIAL        PRIMARY KEY,
    nombre       VARCHAR(100)  NOT NULL,   -- VARCHAR: texto
    creditos     INT           NOT NULL,   -- INT: número entero
    fecha_inicio DATE,                     -- DATE: fecha en formato YYYY-MM-DD
    costo        NUMERIC(8,2)              -- NUMERIC(8,2): decimal con 2 cifras (ej: 150000.00)
);


-- ============================================================
--  SECCIÓN 2: INSERTAR DATOS
--  Cada fila es un registro. SERIAL asigna el id automáticamente.
--  Observar los valores BOOLEAN (TRUE/FALSE) y DATE.
-- ============================================================

INSERT INTO estudiantes (nombre, edad, carrera, activo) VALUES
    ('Ana García',    22, 'Ingeniería de Sistemas',     TRUE),
    ('Luis Martínez', 25, 'Ciencias de la Computación', TRUE),
    ('María Pérez',   21, 'Ingeniería de Sistemas',     FALSE),
    ('Carlos Ruiz',   23, 'Matemáticas',                TRUE);

INSERT INTO cursos (nombre, creditos, fecha_inicio, costo) VALUES
    ('Introducción a Bases de Datos', 3, '2025-02-04', 150000.00),
    ('Cálculo Diferencial',           4, '2025-02-04', 180000.00),
    ('Programación I',                3, '2025-02-04', 150000.00);


-- ============================================================
--  SECCIÓN 3: CONSULTAS — NIVEL EXTERNO
--  Cada SELECT muestra una "vista" diferente de los mismos datos.
-- ============================================================

-- Ver todos los estudiantes con todos sus campos
SELECT * FROM estudiantes;

-- Ver solo nombre y carrera (el usuario ve solo lo que necesita)
SELECT nombre, carrera FROM estudiantes;

-- Filtrar usando la columna BOOLEAN
SELECT nombre, carrera FROM estudiantes WHERE activo = TRUE;


-- ============================================================
--  SECCIÓN 4: INDEPENDENCIA FÍSICA
--  Cambio INTERNO: agregar un índice acelera las búsquedas.
--  Las tablas y consultas no cambian en absoluto.
-- ============================================================

CREATE INDEX idx_carrera ON estudiantes (carrera);

-- Misma consulta, resultado idéntico, más rápida internamente:
SELECT nombre, carrera FROM estudiantes WHERE carrera = 'Ingeniería de Sistemas';


-- ============================================================
--  SECCIÓN 5: INDEPENDENCIA LÓGICA
--  Cambio ESTRUCTURAL: agregar columna no rompe consultas previas.
-- ============================================================

ALTER TABLE estudiantes ADD COLUMN email VARCHAR(150);

-- Esta consulta sigue funcionando sin ningún cambio:
SELECT nombre, carrera FROM estudiantes;

-- Solo quien necesite el nuevo campo lo usa:
SELECT nombre, email FROM estudiantes;

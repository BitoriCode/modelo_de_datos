-- Dataset: CinePlay — plataforma de streaming
-- Clase 20: CTEs (Common Table Expressions)

DROP TABLE IF EXISTS reproduccion CASCADE;
DROP TABLE IF EXISTS usuario      CASCADE;
DROP TABLE IF EXISTS pelicula     CASCADE;
DROP TABLE IF EXISTS plan         CASCADE;
DROP TABLE IF EXISTS genero       CASCADE;

CREATE TABLE genero (
    id_genero VARCHAR(10)  PRIMARY KEY,
    nombre    VARCHAR(50)  NOT NULL
);

CREATE TABLE plan (
    id_plan     VARCHAR(10) PRIMARY KEY,
    nombre_plan VARCHAR(50) NOT NULL,
    precio_mes  INT         NOT NULL CHECK (precio_mes > 0)
);

CREATE TABLE pelicula (
    id_pelicula  VARCHAR(10)  PRIMARY KEY,
    titulo       VARCHAR(150) NOT NULL,
    anio         INT          NOT NULL,
    duracion_min INT          NOT NULL CHECK (duracion_min > 0),
    id_genero    VARCHAR(10)  NOT NULL REFERENCES genero(id_genero)
);

CREATE TABLE usuario (
    id_usuario VARCHAR(10)  PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    email      VARCHAR(150),
    id_plan    VARCHAR(10)  REFERENCES plan(id_plan)  -- NULL = sin plan activo
);

CREATE TABLE reproduccion (
    id_rep      SERIAL      PRIMARY KEY,
    id_usuario  VARCHAR(10) NOT NULL REFERENCES usuario(id_usuario),
    id_pelicula VARCHAR(10) NOT NULL REFERENCES pelicula(id_pelicula),
    fecha_rep   DATE        NOT NULL,
    completada  BOOLEAN     NOT NULL DEFAULT TRUE
);

-- ── DATOS ──────────────────────────────────────────────────────────────────────

INSERT INTO genero VALUES
    ('GEN-1', 'Acción'),
    ('GEN-2', 'Drama'),
    ('GEN-3', 'Comedia'),
    ('GEN-4', 'Terror'),
    ('GEN-5', 'Ciencia ficción'),
    ('GEN-6', 'Documental');

INSERT INTO plan VALUES
    ('PLN-1', 'Básico',   12900),
    ('PLN-2', 'Estándar', 19900),
    ('PLN-3', 'Premium',  29900);

INSERT INTO pelicula VALUES
    ('PEL-001', 'Velocidad Máxima', 2020, 118, 'GEN-1'),
    ('PEL-002', 'Entre Montañas',   2019, 132, 'GEN-2'),
    ('PEL-003', 'La Gran Risa',     2021,  95, 'GEN-3'),
    ('PEL-004', 'La Sombra',        2022, 102, 'GEN-4'),
    ('PEL-005', 'Galaxia 7',        2021, 145, 'GEN-5'),
    ('PEL-006', 'Naturaleza Viva',  2020,  88, 'GEN-6'),
    ('PEL-007', 'Código Rojo',      2023, 125, 'GEN-1'),
    ('PEL-008', 'Silencio',         2022, 140, 'GEN-2'),
    ('PEL-009', 'Risas en Casa',    2020,  90, 'GEN-3'),
    ('PEL-010', 'La Noche Eterna',  2021, 110, 'GEN-4'),
    ('PEL-011', 'Planeta X',        2023, 155, 'GEN-5'),
    ('PEL-012', 'Mar Profundo',     2022,  75, 'GEN-6');

INSERT INTO usuario VALUES
    ('USR-001', 'Andrés Cano',    'andres@cineplay.co',   'PLN-3'),
    ('USR-002', 'Beatriz López',  'beatriz@cineplay.co',  'PLN-2'),
    ('USR-003', 'Carlos Mora',    'carlos@cineplay.co',   'PLN-1'),
    ('USR-004', 'Diana Reyes',    'diana@cineplay.co',    'PLN-3'),
    ('USR-005', 'Eduardo Suárez', 'eduardo@cineplay.co',  'PLN-2'),
    ('USR-006', 'Fernanda Villa', NULL,                   'PLN-1'),
    ('USR-007', 'Gastón Ortiz',   'gaston@cineplay.co',   NULL),
    ('USR-008', 'Helena Niño',    NULL,                   NULL),
    ('USR-009', 'Iván Pérez',     'ivan@cineplay.co',     'PLN-3'),
    ('USR-010', 'Juliana Toro',   'juliana@cineplay.co',  'PLN-2');

INSERT INTO reproduccion (id_usuario, id_pelicula, fecha_rep, completada) VALUES
    ('USR-001', 'PEL-001', '2024-01-05', TRUE),
    ('USR-001', 'PEL-002', '2024-01-12', TRUE),
    ('USR-001', 'PEL-005', '2024-02-03', TRUE),
    ('USR-001', 'PEL-007', '2024-02-20', FALSE),
    ('USR-001', 'PEL-011', '2024-03-10', TRUE),
    ('USR-002', 'PEL-003', '2024-01-08', TRUE),
    ('USR-002', 'PEL-009', '2024-02-14', TRUE),
    ('USR-002', 'PEL-004', '2024-03-01', FALSE),
    ('USR-003', 'PEL-001', '2024-02-05', TRUE),
    ('USR-003', 'PEL-007', '2024-02-28', TRUE),
    ('USR-004', 'PEL-002', '2024-01-15', TRUE),
    ('USR-004', 'PEL-005', '2024-01-22', TRUE),
    ('USR-004', 'PEL-006', '2024-02-10', TRUE),
    ('USR-004', 'PEL-008', '2024-03-05', TRUE),
    ('USR-004', 'PEL-012', '2024-03-18', FALSE),
    ('USR-005', 'PEL-003', '2024-01-20', TRUE),
    ('USR-005', 'PEL-010', '2024-02-25', TRUE),
    ('USR-006', 'PEL-006', '2024-03-12', TRUE),
    ('USR-007', 'PEL-004', '2024-01-30', TRUE),
    ('USR-007', 'PEL-010', '2024-03-08', FALSE),
    ('USR-008', 'PEL-009', '2024-02-18', TRUE),
    ('USR-009', 'PEL-001', '2024-01-10', TRUE),
    ('USR-009', 'PEL-005', '2024-02-02', TRUE),
    ('USR-009', 'PEL-007', '2024-02-22', TRUE),
    ('USR-009', 'PEL-011', '2024-03-15', TRUE);

-- ── VERIFICACIÓN ───────────────────────────────────────────────────────────────
SELECT COUNT(*) AS generos       FROM genero;       -- 6
SELECT COUNT(*) AS planes        FROM plan;          -- 3
SELECT COUNT(*) AS peliculas     FROM pelicula;      -- 12
SELECT COUNT(*) AS usuarios      FROM usuario;       -- 10
SELECT COUNT(*) AS reproducciones FROM reproduccion; -- 25

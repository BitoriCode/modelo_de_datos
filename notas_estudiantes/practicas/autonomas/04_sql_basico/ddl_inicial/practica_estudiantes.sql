-- ============================================================
--  CURSO: MODELOS DE DATOS
--  Clase 11 — PRÁCTICA: DDL — Primer CREATE TABLE en pgAdmin
--  Dominio: sistema de campamento de verano (continuación clase 10)
-- ============================================================
-- Objetivo: implementar en SQL el esquema relacional que construiste
--           la clase pasada. Hoy: las 5 tablas con PK, NOT NULL y FK (REFERENCES).
-- ============================================================


-- ── PASO 0: Limpiar por si las tablas ya existen ─────────────
-- El orden importa: las tablas con FK deben caer antes que las referenciadas

DROP TABLE IF EXISTS actividad;
DROP TABLE IF EXISTS participante;
DROP TABLE IF EXISTS monitor;
DROP TABLE IF EXISTS cabana;
DROP TABLE IF EXISTS campamento;


-- ============================================================
--  PARTE 1 — EJERCICIOS GUIADOS (lee, predice, ejecuta)
-- ============================================================

-- ── EJERCICIO 1-A: CAMPAMENTO (PK simple, inline) ────────────
-- Antes de ejecutar, responde:
--   ¿Cuál columna es la clave primaria?
--   ¿Cuáles columnas son obligatorias?
--   ¿Qué tipo de dato tiene cada columna?

CREATE TABLE campamento (
    cod_campamento  VARCHAR(10)   PRIMARY KEY,
    nombre          VARCHAR(100)  NOT NULL,
    ciudad          VARCHAR(50)   NOT NULL,
    calle           VARCHAR(100),
    numero          VARCHAR(10),
    telefono        VARCHAR(15),
    email           VARCHAR(150)
);

INSERT INTO campamento VALUES
    ('CAMP01', 'Campamento Sol',  'Medellín', 'Calle 10', '15A', '3001234567', 'sol@camp.co'),
    ('CAMP02', 'Campamento Luna', 'Bogotá',   'Carrera 5', '80', '3019876543', NULL);

SELECT * FROM campamento;

-- Predice antes de ejecutar — ¿error o éxito?
-- a) Insertar cod_campamento = 'CAMP01' de nuevo (duplicado de PK)
-- b) Insertar un campamento sin nombre
-- Descomenta para verificar:
-- INSERT INTO campamento VALUES ('CAMP01', 'Duplicado', 'Cali', NULL, NULL, NULL, NULL);
-- INSERT INTO campamento (cod_campamento, ciudad) VALUES ('CAMP03', 'Cali');


-- ── EJERCICIO 1-B: CABANA (PK compuesta + FK) ──────────────────
-- Observa:
--   · La PK se declara AL FINAL cuando tiene más de una columna
--   · REFERENCES declara una llave foránea: PostgreSQL rechaza cualquier
--     cod_campamento que no exista en la tabla campamento

CREATE TABLE cabana (
    cod_campamento  VARCHAR(10)  NOT NULL  REFERENCES campamento(cod_campamento),
    num_cabana      INT          NOT NULL,
    nombre_cabana   VARCHAR(50),
    capacidad       INT,
    PRIMARY KEY (cod_campamento, num_cabana)
);

INSERT INTO cabana VALUES
    ('CAMP01', 1, 'El Roble', 8),
    ('CAMP01', 2, 'El Pino',  6),
    ('CAMP02', 1, 'La Ceiba', 10);

SELECT * FROM cabana;

-- Analiza:
-- ¿Por qué num_cabana = 1 aparece dos veces sin error?
-- ¿Qué par de valores sería un duplicado de PK?
-- ¿Qué error produce intentar insertar un cod_campamento que no existe?
-- Descomenta para verificar la FK:
-- INSERT INTO cabana VALUES ('CAMP99', 1, 'Fantasma', 5);


-- ============================================================
--  PARTE 2 — RETOS (escribe el SQL tú mismo)
-- ============================================================

-- ── RETO 1: MONITOR ──────────────────────────────────────────
-- Columnas:
--   cod_monitor    → texto hasta 10 chars · clave primaria
--   primer_nombre  → texto hasta 50 chars · obligatorio
--   apellidos      → texto hasta 100 chars · obligatorio
--   telefono       → texto hasta 15 chars · opcional
--   cod_campamento → texto hasta 10 chars · obligatorio
--                    FK → REFERENCES campamento(cod_campamento)

-- TODO: escribe el CREATE TABLE monitor


-- Verifica insertando:
-- INSERT INTO monitor VALUES ('MON001', 'Carlos', 'Gómez Pérez', '3101112233', 'CAMP01');
-- SELECT * FROM monitor;


-- ── RETO 2: PARTICIPANTE ─────────────────────────────────────
-- Columnas:
--   num_participante → texto hasta 20 chars · clave primaria
--   primer_nombre    → texto hasta 50 chars · obligatorio
--   apellidos        → texto hasta 100 chars · obligatorio
--   fecha_nacimiento → fecha · obligatorio
--   email_tutor      → texto hasta 150 chars · opcional
--   nombre_tutor     → texto hasta 100 chars · obligatorio

-- TODO: escribe el CREATE TABLE participante


-- Verifica insertando:
-- INSERT INTO participante VALUES ('CC-123456', 'Valentina', 'Ríos López', '2015-03-14', 'padre@mail.co', 'Juan Ríos');
-- SELECT * FROM participante;


-- ── RETO 3: ACTIVIDAD ────────────────────────────────────────
-- Columnas:
--   cod_actividad    → texto hasta 10 chars · clave primaria
--   nombre           → texto hasta 100 chars · obligatorio
--   descripcion      → texto sin límite · opcional
--   duracion_minutos → número entero · opcional
--   nivel            → texto hasta 20 chars · opcional
--   cod_monitor      → texto hasta 10 chars · obligatorio
--                      FK → REFERENCES monitor(cod_monitor)

-- TODO: escribe el CREATE TABLE actividad


-- Verifica insertando:
-- INSERT INTO actividad VALUES ('ACT01', 'Natación', 'Piscina olímpica', 90, 'basico', 'MON001');
-- SELECT * FROM actividad;


-- ── RETO 4 — OPCIONAL (desafío) ──────────────────────────────
-- Intenta violar las restricciones de las tablas que creaste:
--   a) Insertar un participante sin nombre_tutor             → ¿qué restricción viola?
--   b) Insertar una actividad con cod_actividad ya existente → ¿qué restricción viola?
--   c) Insertar un monitor sin cod_campamento                → ¿qué restricción viola?
--   d) Insertar un monitor con cod_campamento = 'CAMP99'     → ¿qué restricción viola?
-- ¿Qué mensajes de error produce PostgreSQL en cada caso? ¿PK, NOT NULL o FK?

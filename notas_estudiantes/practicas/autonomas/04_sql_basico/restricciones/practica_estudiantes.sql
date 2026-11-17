-- ============================================================
--  CURSO: MODELOS DE DATOS
--  Clase 3 — PRÁCTICA ESTUDIANTIL
--  Tema: DDL — CREATE TABLE, ALTER TABLE, DROP TABLE
--  Los estudiantes completan los retos marcados con TODO
-- ============================================================

-- ============================================================
--  PREPARACIÓN: limpiar tablas si ya existen
-- ============================================================

DROP TABLE IF EXISTS empleados;
DROP TABLE IF EXISTS departamentos;
DROP TABLE IF EXISTS clientes;


-- ============================================================
--  PARTE 1 — EJERCICIOS GUIADOS (leer, predecir, ejecutar)
-- ============================================================

-- EJERCICIO 1-A: Crear tabla con restricciones
-- Antes de ejecutar, responde: ¿qué hace cada restricción?

CREATE TABLE departamentos (
    id      SERIAL       PRIMARY KEY,
    nombre  VARCHAR(80)  NOT NULL  UNIQUE,
    piso    INT          CHECK (piso BETWEEN 1 AND 20)
);

-- Insertar datos válidos:
INSERT INTO departamentos (nombre, piso) VALUES ('Sistemas',     3);
INSERT INTO departamentos (nombre, piso) VALUES ('Contabilidad', 5);
INSERT INTO departamentos (nombre, piso) VALUES ('Recursos Humanos', NULL);  -- piso vacío: ¿funciona?

SELECT * FROM departamentos;

-- ¿Qué pasará con estas instrucciones? Predice antes de ejecutar:
-- a) INSERT INTO departamentos (nombre) VALUES ('Sistemas');
-- b) INSERT INTO departamentos (nombre, piso) VALUES ('Bodega', 25);
-- c) INSERT INTO departamentos (nombre) VALUES (NULL);

-- Descomenta una por una para verificar tu predicción:
-- INSERT INTO departamentos (nombre) VALUES ('Sistemas');
-- INSERT INTO departamentos (nombre, piso) VALUES ('Bodega', 25);
-- INSERT INTO departamentos (nombre) VALUES (NULL);


-- EJERCICIO 1-B: Ver el efecto de DEFAULT
CREATE TABLE clientes (
    id            SERIAL        PRIMARY KEY,
    nombre        VARCHAR(100)  NOT NULL,
    email         VARCHAR(150)  UNIQUE,
    activo        BOOLEAN       DEFAULT TRUE,
    puntos        INT           DEFAULT 0  CHECK (puntos >= 0),
    fecha_registro DATE         DEFAULT CURRENT_DATE
);

-- Insertar solo los campos obligatorios:
INSERT INTO clientes (nombre, email) VALUES ('Juan Pérez', 'juan@mail.com');
INSERT INTO clientes (nombre)        VALUES ('María López');  -- sin email: ¿funciona?

SELECT * FROM clientes;
-- Observa: activo = TRUE, puntos = 0, fecha_registro = hoy. Los puso PostgreSQL solo.


-- ============================================================
--  PARTE 2 — RETOS (los estudiantes escriben el SQL)
-- ============================================================

-- RETO 1: Crear la tabla empleados
-- Requisitos:
--   - id: entero auto-incremental, clave primaria
--   - nombre: texto hasta 100 chars, obligatorio
--   - salario: número decimal, obligatorio, debe ser mayor que 0
--   - cargo: texto hasta 60 chars, opcional
--   - departamento_id: entero, opcional (luego lo conectaremos)
--   - activo: booleano, por defecto TRUE

-- TODO: escribe aquí el CREATE TABLE

-- Verificar con estos INSERTs (ejecutar después de crear la tabla):
-- INSERT INTO empleados (nombre, salario, cargo, departamento_id) VALUES ('Carlos Ruiz', 2500000.00, 'Analista', 1);
-- INSERT INTO empleados (nombre, salario) VALUES ('Laura Díaz', 3200000.00);


-- RETO 2: Modificar la tabla empleados
-- Requisitos:
--   a) Agregar columna "email" de tipo VARCHAR(150), debe ser UNIQUE
--   b) Renombrar la columna "cargo" a "puesto"
--   c) Agregar restricción CHECK: salario debe ser <= 50000000

-- TODO: escribe los 3 ALTER TABLE aquí


-- RETO 3: Crear una tabla con verificación de rango
-- Diseña la tabla "calificaciones" para guardar las notas de los estudiantes:
--   - id: clave primaria auto-incremental
--   - estudiante: texto obligatorio
--   - asignatura: texto obligatorio
--   - nota: decimal con 1 cifra decimal, obligatorio
--           → restricción: debe estar entre 0.0 y 5.0
--   - periodo: texto (ej: '2025-1'), por defecto '2025-1'

-- TODO: escribe el CREATE TABLE aquí


-- RETO 4 (desafío): Eliminar y recrear
-- a) Elimina la tabla "clientes" de forma segura (sin error si no existe)
-- b) Vuelve a crearla con una restricción adicional:
--    la columna "email" debe ser NOT NULL además de UNIQUE

-- TODO: escribe DROP TABLE y el nuevo CREATE TABLE aquí

-- =============================================================
-- StaffHub — Gestión de Recursos Humanos
-- Dataset para Clase 23: Funciones nativas de PostgreSQL
-- =============================================================

DROP TABLE IF EXISTS cargo        CASCADE;
DROP TABLE IF EXISTS empleado     CASCADE;
DROP TABLE IF EXISTS departamento CASCADE;

-- -----------------------------------------------------------
-- TABLAS
-- -----------------------------------------------------------

CREATE TABLE departamento (
    id_departamento   INT          PRIMARY KEY,
    nombre            VARCHAR(60)  NOT NULL,
    ciudad            VARCHAR(40)  NOT NULL,
    presupuesto_anual INT          NOT NULL
);

CREATE TABLE empleado (
    id_empleado     VARCHAR(10)   PRIMARY KEY,
    nombre          VARCHAR(100)  NOT NULL,
    email           VARCHAR(100),
    fecha_ingreso   DATE          NOT NULL,
    salario_cop     INT           NOT NULL,
    calificacion    NUMERIC(3,1),           -- desempeño: 1.0 a 5.0
    id_departamento INT           REFERENCES departamento(id_departamento)
    -- NULL = sin departamento asignado todavía
);

CREATE TABLE cargo (
    id_empleado VARCHAR(10)  PRIMARY KEY REFERENCES empleado(id_empleado),
    titulo      VARCHAR(80)  NOT NULL,
    nivel       VARCHAR(10)  NOT NULL CHECK (nivel IN ('junior', 'senior', 'lead'))
);

-- -----------------------------------------------------------
-- DATOS
-- -----------------------------------------------------------

INSERT INTO departamento VALUES
  (1, 'Tecnología',   'Bogotá',   180000000),
  (2, 'Marketing',    'Medellín',  95000000),
  (3, 'Finanzas',     'Bogotá',   120000000),
  (4, 'Operaciones',  'Cali',      75000000);

-- 12 empleados: 10 con departamento, 2 sin departamento asignado
INSERT INTO empleado VALUES
  ('EMP-01', 'Ana Torres',       'ana.torres@staffhub.com',      '2019-03-15', 4200000, 4.8, 1),
  ('EMP-02', 'Carlos Ruiz',      'carlos.ruiz@staffhub.com',     '2020-07-01', 3500000, 3.7, 1),
  ('EMP-03', 'Diana Leal',       'diana.leal@staffhub.com',      '2018-01-10', 5800000, 4.5, 1),
  ('EMP-04', 'Eduardo Mora',     'eduardo.mora@staffhub.com',    '2021-11-20', 2900000, 3.2, 2),
  ('EMP-05', 'Fernanda Castro',  'fernanda.castro@staffhub.com', '2022-04-05', 2600000, 4.1, 2),
  ('EMP-06', 'Gabriel Ríos',     'gabriel.rios@staffhub.com',    '2019-08-15', 3800000, 4.6, 3),
  ('EMP-07', 'Helena Vargas',    'helena.vargas@staffhub.com',   '2020-02-28', 4500000, 3.9, 3),
  ('EMP-08', 'Ignacio Peña',     'ignacio.pena@staffhub.com',    '2017-06-01', 6200000, 4.7, 3),
  ('EMP-09', 'Juliana Soto',     'juliana.soto@staffhub.com',    '2023-01-16', 2400000, 3.5, 4),
  ('EMP-10', 'Kevin Álvarez',    'kevin.alvarez@staffhub.com',   '2021-09-10', 3100000, 4.0, 4),
  ('EMP-11', 'Laura Medina',     'laura.medina@staffhub.com',    '2024-03-01', 2200000, 3.8, NULL),
  ('EMP-12', 'Manuel Torres',    'manuel.torres@staffhub.com',   '2023-07-15', 2800000, 4.2, NULL);

INSERT INTO cargo VALUES
  ('EMP-01', 'Desarrolladora Full Stack',         'senior'),
  ('EMP-02', 'Analista de Datos',                 'junior'),
  ('EMP-03', 'Arquitecta de Software',            'lead'),
  ('EMP-04', 'Especialista en Marketing Digital', 'junior'),
  ('EMP-05', 'Diseñadora UX/UI',                  'junior'),
  ('EMP-06', 'Analista Financiero',               'senior'),
  ('EMP-07', 'Contadora',                         'senior'),
  ('EMP-08', 'Director Financiero',               'lead'),
  ('EMP-09', 'Coordinadora de Logística',         'junior'),
  ('EMP-10', 'Supervisor de Operaciones',         'senior'),
  ('EMP-11', 'Consultora',                        'junior'),
  ('EMP-12', 'Analista de Proyectos',             'junior');

-- -----------------------------------------------------------
-- VERIFICACIÓN
-- -----------------------------------------------------------
SELECT COUNT(*) AS departamentos  FROM departamento;   -- 4
SELECT COUNT(*) AS empleados      FROM empleado;       -- 12
SELECT COUNT(*) AS cargos         FROM cargo;          -- 12
SELECT COUNT(*) AS sin_depto      FROM empleado WHERE id_departamento IS NULL; -- 2

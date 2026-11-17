-- ============================================================
--  CURSO: MODELO DE DATOS
--  Base de datos: MediCare (clínica médica)
--  Dataset: 4 especialidades · 10 médicos · 13 pacientes · 33 turnos
-- ============================================================

DROP TABLE IF EXISTS turno        CASCADE;
DROP TABLE IF EXISTS medico       CASCADE;
DROP TABLE IF EXISTS paciente     CASCADE;
DROP TABLE IF EXISTS especialidad CASCADE;

-- ------------------------------------------------------------

CREATE TABLE especialidad (
    id_especialidad     VARCHAR(10) PRIMARY KEY,
    nombre_especialidad VARCHAR(60) NOT NULL
);

CREATE TABLE medico (
    id_medico       VARCHAR(10)  PRIMARY KEY,
    nombre_medico   VARCHAR(100) NOT NULL,
    id_especialidad VARCHAR(10)  NOT NULL REFERENCES especialidad(id_especialidad)
);

CREATE TABLE paciente (
    id_paciente     VARCHAR(10)  PRIMARY KEY,
    nombre_paciente VARCHAR(100) NOT NULL,
    email_paciente  VARCHAR(150)
);

CREATE TABLE turno (
    id_paciente   VARCHAR(10) NOT NULL REFERENCES paciente(id_paciente),
    id_medico     VARCHAR(10) NOT NULL REFERENCES medico(id_medico),
    fecha_turno   DATE        NOT NULL,
    tipo_consulta VARCHAR(20) NOT NULL,
    costo_cop     INT         NOT NULL CHECK (costo_cop > 0),
    PRIMARY KEY (id_paciente, id_medico)
);

-- ------------------------------------------------------------

INSERT INTO especialidad VALUES
    ('ESP-1', 'Medicina General'),
    ('ESP-2', 'Pediatría'),
    ('ESP-3', 'Cardiología'),
    ('ESP-4', 'Urgencias Generales');  -- sin médicos asignados aún

-- MED-005, MED-006, MED-010: sin turnos (para RIGHT JOIN / FULL OUTER)
INSERT INTO medico VALUES
    ('MED-001', 'Dr. Carlos Torres',     'ESP-1'),
    ('MED-002', 'Dra. Laura Sánchez',    'ESP-2'),
    ('MED-003', 'Dr. Jorge Vargas',      'ESP-3'),
    ('MED-004', 'Dra. Ana Ríos',         'ESP-1'),
    ('MED-005', 'Dra. Sofía Herrera',    'ESP-3'),
    ('MED-006', 'Dr. Miguel Castro',     'ESP-2'),
    ('MED-007', 'Dr. Pablo Mendoza',     'ESP-3'),
    ('MED-008', 'Dra. Carmen López',     'ESP-2'),
    ('MED-009', 'Dr. Felipe Mora',       'ESP-1'),
    ('MED-010', 'Dra. Valentina Torres', 'ESP-1');

-- PAC-007, PAC-008, PAC-013: sin turnos (para LEFT JOIN / FULL OUTER)
INSERT INTO paciente VALUES
    ('PAC-001', 'Carlos Ruiz',     'carlos@mail.co'),
    ('PAC-002', 'Laura Mesa',      'laura@mail.co'),
    ('PAC-003', 'Jorge Vega',      'jorge@mail.co'),
    ('PAC-004', 'Ana Torres',       NULL),
    ('PAC-005', 'Sofía Herrera',   'sofia@mail.co'),
    ('PAC-006', 'Miguel Castro',    NULL),
    ('PAC-007', 'Patricia Leal',   'patricia@mail.co'),
    ('PAC-008', 'Andrés Morales',  'andres@mail.co'),
    ('PAC-009', 'Diana Parra',     'diana@mail.co'),
    ('PAC-010', 'Tomás Gómez',     'tomas@mail.co'),
    ('PAC-011', 'Hernán López',     NULL),
    ('PAC-012', 'Natalia Soto',    'natalia@mail.co'),
    ('PAC-013', 'Camilo Vargas',    NULL);

-- Costos por médico y tipo:
--   MED-001 (ESP-1): Primera vez 50 000 | Control 45 000 | Urgencia  80 000
--   MED-002 (ESP-2): Primera vez 65 000 | Control 60 000 | Urgencia  90 000
--   MED-003 (ESP-3): Primera vez 120 000| Control 100 000| Urgencia 180 000
--   MED-004 (ESP-1): Primera vez 55 000 | Control 48 000 | Urgencia  85 000
--   MED-007 (ESP-3): Primera vez 125 000| Control 105 000| Urgencia 195 000
--   MED-008 (ESP-2): Primera vez 70 000 | Control 65 000 | Urgencia  95 000
--   MED-009 (ESP-1): Primera vez 52 000 | Control 46 000 | Urgencia  82 000
INSERT INTO turno VALUES
    -- MED-001 (Medicina General)
    ('PAC-001', 'MED-001', '2024-08-05', 'Primera vez',  50000),
    ('PAC-002', 'MED-001', '2024-08-08', 'Primera vez',  50000),
    ('PAC-003', 'MED-001', '2024-08-12', 'Control',      45000),
    ('PAC-005', 'MED-001', '2024-08-22', 'Primera vez',  50000),
    ('PAC-010', 'MED-001', '2024-08-19', 'Control',      45000),
    -- MED-002 (Pediatría)
    ('PAC-001', 'MED-002', '2024-08-16', 'Control',      60000),
    ('PAC-002', 'MED-002', '2024-08-20', 'Control',      60000),
    ('PAC-004', 'MED-002', '2024-08-14', 'Primera vez',  65000),
    ('PAC-005', 'MED-002', '2024-09-01', 'Control',      60000),
    ('PAC-011', 'MED-002', '2024-09-09', 'Primera vez',  65000),
    -- MED-003 (Cardiología)
    ('PAC-001', 'MED-003', '2024-09-02', 'Urgencia',    180000),
    ('PAC-003', 'MED-003', '2024-08-17', 'Urgencia',    180000),
    ('PAC-005', 'MED-003', '2024-09-11', 'Control',     100000),
    ('PAC-006', 'MED-003', '2024-08-30', 'Control',     100000),
    ('PAC-012', 'MED-003', '2024-09-05', 'Primera vez', 120000),
    -- MED-004 (Medicina General)
    ('PAC-002', 'MED-004', '2024-09-05', 'Primera vez',  55000),
    ('PAC-003', 'MED-004', '2024-08-25', 'Control',      48000),
    ('PAC-004', 'MED-004', '2024-09-01', 'Urgencia',     85000),
    ('PAC-006', 'MED-004', '2024-09-07', 'Primera vez',  55000),
    ('PAC-010', 'MED-004', '2024-09-15', 'Control',      48000),
    -- MED-007 (Cardiología)
    ('PAC-003', 'MED-007', '2024-09-12', 'Primera vez', 125000),
    ('PAC-005', 'MED-007', '2024-09-20', 'Primera vez', 125000),
    ('PAC-009', 'MED-007', '2024-08-26', 'Urgencia',    195000),
    ('PAC-011', 'MED-007', '2024-09-16', 'Control',     105000),
    ('PAC-012', 'MED-007', '2024-09-13', 'Urgencia',    195000),
    -- MED-008 (Pediatría)
    ('PAC-002', 'MED-008', '2024-09-22', 'Primera vez',  70000),
    ('PAC-009', 'MED-008', '2024-08-09', 'Primera vez',  70000),
    ('PAC-010', 'MED-008', '2024-09-08', 'Control',      65000),
    ('PAC-011', 'MED-008', '2024-09-20', 'Urgencia',     95000),
    -- MED-009 (Medicina General)
    ('PAC-002', 'MED-009', '2024-09-25', 'Control',      46000),
    ('PAC-003', 'MED-009', '2024-09-18', 'Urgencia',     82000),
    ('PAC-009', 'MED-009', '2024-09-14', 'Control',      46000),
    ('PAC-011', 'MED-009', '2024-08-23', 'Primera vez',  52000);

-- ------------------------------------------------------------
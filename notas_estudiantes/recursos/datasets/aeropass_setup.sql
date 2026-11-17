-- ============================================================
--  CURSO: MODELO DE DATOS
--  Clase 16 — TALLER INDEPENDIENTE
--  Tema: DML — SELECT, filtros y funciones de agregación
--  Base de datos: AeroPass (esquema de clase 13, datos ampliados)
-- ============================================================


-- ============================================================
--  PARTE 1 — PREPARACIÓN
--  Ejecuta este bloque completo antes de comenzar.
-- ============================================================

DROP TABLE IF EXISTS reserva   CASCADE;
DROP TABLE IF EXISTS vuelo     CASCADE;
DROP TABLE IF EXISTS pasajero  CASCADE;
DROP TABLE IF EXISTS aerolinea CASCADE;

CREATE TABLE aerolinea (
    id_aerolinea     VARCHAR(10)  PRIMARY KEY,
    nombre_aerolinea VARCHAR(50)  NOT NULL
);

CREATE TABLE pasajero (
    id_pasajero     VARCHAR(10)  PRIMARY KEY,
    nombre_pasajero VARCHAR(100) NOT NULL,
    email_pasajero  VARCHAR(150)             -- nullable: algunos no tienen email
);

CREATE TABLE vuelo (
    id_vuelo      VARCHAR(10) PRIMARY KEY,
    origen_vuelo  VARCHAR(50) NOT NULL,
    destino_vuelo VARCHAR(50) NOT NULL,
    id_aerolinea  VARCHAR(10) NOT NULL REFERENCES aerolinea(id_aerolinea)
);

CREATE TABLE reserva (
    id_pasajero   VARCHAR(10)    NOT NULL REFERENCES pasajero(id_pasajero),
    id_vuelo      VARCHAR(10)    NOT NULL REFERENCES vuelo(id_vuelo),
    fecha_reserva DATE           NOT NULL,
    num_asiento   VARCHAR(5)     NOT NULL,
    clase         VARCHAR(20)    NOT NULL,
    precio_cop    INT            NOT NULL CHECK (precio_cop > 0),
    PRIMARY KEY (id_pasajero, id_vuelo)
);

-- ============================================================
--  Datos
-- ============================================================

INSERT INTO aerolinea VALUES
    ('AER-1', 'Avianca'),
    ('AER-2', 'LATAM'),
    ('AER-3', 'Wingo');

INSERT INTO pasajero VALUES
    ('PAS-001', 'Carlos Ruiz',      'carlos@mail.co'),
    ('PAS-002', 'Laura Mesa',       'laura@mail.co'),
    ('PAS-003', 'Jorge Vega',       'jorge@mail.co'),
    ('PAS-004', 'Ana Torres',        NULL),             -- sin email
    ('PAS-005', 'Sofía Herrera',    'sofia@mail.co'),
    ('PAS-006', 'Miguel Castro',     NULL),             -- sin email
    ('PAS-007', 'Patricia Leal',    'patricia@mail.co'),
    ('PAS-008', 'Andrés Morales',   'andres@mail.co');

INSERT INTO vuelo VALUES
    ('VUE-101', 'Medellín',      'Bogotá',        'AER-1'),
    ('VUE-205', 'Bogotá',        'Cali',          'AER-2'),
    ('VUE-312', 'Cali',          'Barranquilla',  'AER-2'),
    ('VUE-408', 'Bogotá',        'Cartagena',     'AER-3'),
    ('VUE-510', 'Bogotá',        'Medellín',      'AER-1'),
    ('VUE-613', 'Pereira',       'Bogotá',        'AER-3'),
    ('VUE-720', 'Medellín',      'Cartagena',     'AER-1'),
    ('VUE-815', 'Barranquilla',  'Bogotá',        'AER-2');

INSERT INTO reserva VALUES
--   pasajero    vuelo      fecha           asiento  clase         precio
    ('PAS-001', 'VUE-101', '2024-08-10',  '12A',  'Económica',   280000),
    ('PAS-001', 'VUE-205', '2024-08-16',  '5C',   'Ejecutiva',   720000),
    ('PAS-001', 'VUE-408', '2024-09-02',  '8D',   'Primera',    1500000),
    ('PAS-002', 'VUE-101', '2024-08-10',  '12B',  'Económica',   220000),
    ('PAS-002', 'VUE-312', '2024-08-20',  '7A',   'Económica',   310000),
    ('PAS-002', 'VUE-720', '2024-09-05',  '2A',   'Ejecutiva',   840000),
    ('PAS-003', 'VUE-312', '2024-08-17',  '3C',   'Económica',   195000),
    ('PAS-003', 'VUE-510', '2024-08-25',  '9B',   'Económica',   340000),
    ('PAS-003', 'VUE-408', '2024-09-06',  '10C',  'Económica',   260000),
    ('PAS-004', 'VUE-408', '2024-08-18',  '3B',   'Ejecutiva',   650000),
    ('PAS-004', 'VUE-613', '2024-08-28',  '1A',   'Primera',    1350000),
    ('PAS-005', 'VUE-101', '2024-08-22',  '15A',  'Económica',   215000),
    ('PAS-005', 'VUE-205', '2024-09-01',  '6C',   'Ejecutiva',   780000),
    ('PAS-006', 'VUE-815', '2024-08-30',  '4D',   'Económica',   290000),
    ('PAS-006', 'VUE-510', '2024-09-03',  '11A',  'Económica',   305000),
    ('PAS-007', 'VUE-720', '2024-08-12',  '7C',   'Ejecutiva',   810000),
    ('PAS-007', 'VUE-613', '2024-09-01',  '2B',   'Económica',   175000),
    ('PAS-007', 'VUE-815', '2024-09-04',  '8A',   'Primera',    1650000),
    ('PAS-008', 'VUE-101', '2024-08-15',  '14B',  'Económica',   250000),
    ('PAS-008', 'VUE-205', '2024-09-05',  '3A',   'Ejecutiva',   695000);

-- Verificación: 3 / 8 / 8 / 20
SELECT 'aerolinea' AS tabla, COUNT(*) AS filas FROM aerolinea
UNION ALL SELECT 'pasajero',  COUNT(*) FROM pasajero
UNION ALL SELECT 'vuelo',     COUNT(*) FROM vuelo
UNION ALL SELECT 'reserva',   COUNT(*) FROM reserva;

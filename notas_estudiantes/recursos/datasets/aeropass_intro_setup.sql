-- ============================================================
-- AeroPass — esquema normalizado + datos + consultas DML
-- Clase 13 · Práctica estudiantes
-- ============================================================


-- ============================================================
-- LIMPIEZA
-- ============================================================

DROP TABLE IF EXISTS reserva    CASCADE;
DROP TABLE IF EXISTS vuelo      CASCADE;
DROP TABLE IF EXISTS pasajero   CASCADE;
DROP TABLE IF EXISTS aerolinea  CASCADE;


-- ============================================================
-- CREATE TABLE — orden: padres antes que hijos
-- ============================================================

CREATE TABLE aerolinea (
    id_aerolinea    VARCHAR(10)  PRIMARY KEY,
    nombre_aerolinea VARCHAR(50) NOT NULL
);

CREATE TABLE pasajero (
    id_pasajero     VARCHAR(10)  PRIMARY KEY,
    nombre_pasajero VARCHAR(100) NOT NULL,
    email_pasajero  VARCHAR(150)
);

CREATE TABLE vuelo (
    id_vuelo      VARCHAR(10)  PRIMARY KEY,
    origen_vuelo  VARCHAR(50)  NOT NULL,
    destino_vuelo VARCHAR(50)  NOT NULL,
    id_aerolinea  VARCHAR(10)  NOT NULL REFERENCES aerolinea(id_aerolinea)
);

CREATE TABLE reserva (
    id_pasajero    VARCHAR(10)  NOT NULL REFERENCES pasajero(id_pasajero),
    id_vuelo       VARCHAR(10)  NOT NULL REFERENCES vuelo(id_vuelo),
    fecha_reserva  DATE         NOT NULL,
    num_asiento    VARCHAR(5)   NOT NULL,
    clase          VARCHAR(20)  NOT NULL,
    PRIMARY KEY (id_pasajero, id_vuelo)
);


-- ============================================================
-- INSERT — datos de ejemplo
-- ============================================================

INSERT INTO aerolinea VALUES
    ('AER-1', 'Avianca'),
    ('AER-2', 'LATAM'),
    ('AER-3', 'Wingo');

INSERT INTO pasajero VALUES
    ('PAS-001', 'Carlos Ruiz', 'carlos@mail.co'),
    ('PAS-002', 'Laura Mesa',  'laura@mail.co'),
    ('PAS-003', 'Jorge Vega',  'jorge@mail.co'),
    ('PAS-004', 'Ana Torres',  'ana@mail.co');

INSERT INTO vuelo VALUES
    ('VUE-101', 'Medellín',    'Bogotá',       'AER-1'),
    ('VUE-205', 'Bogotá',      'Cali',         'AER-2'),
    ('VUE-312', 'Cali',        'Barranquilla', 'AER-2'),
    ('VUE-408', 'Bogotá',      'Cartagena',    'AER-3');

INSERT INTO reserva VALUES
    ('PAS-001', 'VUE-101', '2024-08-15', '12A', 'Económica'),
    ('PAS-001', 'VUE-205', '2024-08-16', '5C',  'Ejecutiva'),
    ('PAS-002', 'VUE-101', '2024-08-15', '12B', 'Económica'),
    ('PAS-003', 'VUE-312', '2024-08-17', '7A',  'Económica'),
    ('PAS-004', 'VUE-408', '2024-08-18', '3B',  'Ejecutiva');


-- ============================================================
-- VERIFICACIÓN — contar filas por tabla
-- ============================================================

SELECT 'aerolinea' AS tabla, COUNT(*) AS filas FROM aerolinea
UNION ALL SELECT 'pasajero',  COUNT(*) FROM pasajero
UNION ALL SELECT 'vuelo',     COUNT(*) FROM vuelo
UNION ALL SELECT 'reserva',   COUNT(*) FROM reserva;
-- Esperado: 3, 4, 4, 5

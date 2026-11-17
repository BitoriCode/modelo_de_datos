-- Dataset: UrbanBike — empresa de alquiler de bicicletas urbanas
-- Clase 21: DML avanzado (INSERT...SELECT, UPDATE...FROM, DELETE USING, CTE + DML)

DROP TABLE IF EXISTS viaje      CASCADE;
DROP TABLE IF EXISTS bicicleta  CASCADE;
DROP TABLE IF EXISTS cliente    CASCADE;
DROP TABLE IF EXISTS estacion   CASCADE;

CREATE TABLE estacion (
    id_estacion VARCHAR(10)  PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    barrio      VARCHAR(60)  NOT NULL,
    capacidad   INT          NOT NULL CHECK (capacidad > 0)
);

CREATE TABLE bicicleta (
    id_bici     VARCHAR(10) PRIMARY KEY,
    modelo      VARCHAR(50) NOT NULL,
    estado      VARCHAR(15) NOT NULL CHECK (estado IN ('disponible', 'en_uso', 'mantenimiento')),
    id_estacion VARCHAR(10) REFERENCES estacion(id_estacion)  -- NULL = en tránsito
);

CREATE TABLE cliente (
    id_cliente VARCHAR(10)  PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    email      VARCHAR(150),
    plan       VARCHAR(10)  NOT NULL CHECK (plan IN ('básico', 'premium'))
);

CREATE TABLE viaje (
    id_viaje     SERIAL      PRIMARY KEY,
    id_cliente   VARCHAR(10) NOT NULL REFERENCES cliente(id_cliente),
    id_bici      VARCHAR(10) NOT NULL REFERENCES bicicleta(id_bici),
    id_origen    VARCHAR(10) NOT NULL REFERENCES estacion(id_estacion),
    id_destino   VARCHAR(10)          REFERENCES estacion(id_estacion), -- NULL = en curso
    fecha        DATE        NOT NULL,
    duracion_min INT                  CHECK (duracion_min > 0),         -- NULL = en curso
    tarifa_cop   INT                  CHECK (tarifa_cop   > 0)          -- NULL = en curso
);

-- ── DATOS ──────────────────────────────────────────────────────────────────────

INSERT INTO estacion VALUES
    ('EST-1', 'Parque Central',     'Chapinero',     10),
    ('EST-2', 'Portal Norte',       'Usaquén',        8),
    ('EST-3', 'Plaza Sur',          'Bosa',          12),
    ('EST-4', 'Centro Histórico',   'La Candelaria', 15),
    ('EST-5', 'Simón Bolívar',      'Teusaquillo',    6),
    ('EST-6', 'Aeropuerto',         'Fontibón',      20);

INSERT INTO bicicleta VALUES
    ('BIC-01', 'Trek 3',      'disponible',   'EST-1'),
    ('BIC-02', 'Trek 3',      'disponible',   'EST-1'),
    ('BIC-03', 'Giant Escape','disponible',   'EST-2'),
    ('BIC-04', 'Giant Escape','mantenimiento','EST-2'),
    ('BIC-05', 'Cannondale',  'disponible',   'EST-3'),
    ('BIC-06', 'Cannondale',  'en_uso',       'EST-3'),
    ('BIC-07', 'Trek 3',      'en_uso',        NULL),
    ('BIC-08', 'Giant Escape','disponible',   'EST-4'),
    ('BIC-09', 'Cannondale',  'disponible',   'EST-5'),
    ('BIC-10', 'Trek 3',      'mantenimiento', NULL);

INSERT INTO cliente VALUES
    ('CLI-001', 'Andrés Morales', 'andres@urbanbike.co',  'premium'),
    ('CLI-002', 'Beatriz Castro', 'beatriz@urbanbike.co', 'básico'),
    ('CLI-003', 'Carlos Leal',    'carlos@urbanbike.co',  'premium'),
    ('CLI-004', 'Diana Ortiz',     NULL,                  'básico'),
    ('CLI-005', 'Eduardo Niño',   'edu@urbanbike.co',     'básico'),
    ('CLI-006', 'Fernanda Mora',  'fer@urbanbike.co',     'premium'),
    ('CLI-007', 'Gastón Villa',    NULL,                  'básico'),
    ('CLI-008', 'Helena Ríos',    'helena@urbanbike.co',  'premium');

-- Viajes completados (16 filas — tienen id_destino, duracion_min y tarifa_cop)
INSERT INTO viaje (id_cliente, id_bici, id_origen, id_destino, fecha, duracion_min, tarifa_cop) VALUES
    ('CLI-001', 'BIC-01', 'EST-1', 'EST-2', '2024-03-01', 45, 4500),
    ('CLI-002', 'BIC-03', 'EST-2', 'EST-3', '2024-03-02', 30, 3000),
    ('CLI-003', 'BIC-05', 'EST-3', 'EST-4', '2024-03-05', 35, 3500),
    ('CLI-001', 'BIC-02', 'EST-1', 'EST-4', '2024-03-08', 50, 5000),
    ('CLI-004', 'BIC-08', 'EST-4', 'EST-5', '2024-03-10', 30, 3000),
    ('CLI-003', 'BIC-05', 'EST-3', 'EST-1', '2024-03-12', 30, 3000),
    ('CLI-006', 'BIC-09', 'EST-5', 'EST-2', '2024-03-15', 45, 4500),
    ('CLI-002', 'BIC-01', 'EST-1', 'EST-3', '2024-03-18', 40, 4000),
    ('CLI-005', 'BIC-03', 'EST-2', 'EST-4', '2024-03-20', 35, 3500),
    ('CLI-008', 'BIC-02', 'EST-1', 'EST-2', '2024-03-22', 30, 3000),
    ('CLI-001', 'BIC-08', 'EST-4', 'EST-1', '2024-03-01', 55, 5500),
    ('CLI-006', 'BIC-05', 'EST-3', 'EST-5', '2024-03-03', 40, 4000),
    ('CLI-003', 'BIC-09', 'EST-5', 'EST-3', '2024-03-07', 35, 3500),
    ('CLI-008', 'BIC-08', 'EST-4', 'EST-3', '2024-03-14', 30, 3000),
    ('CLI-005', 'BIC-03', 'EST-2', 'EST-1', '2024-03-19', 25, 2500),
    ('CLI-007', 'BIC-01', 'EST-1', 'EST-4', '2024-03-21', 50, 5000);

-- Viajes en curso recientes — id_destino, duracion_min y tarifa_cop son NULL
INSERT INTO viaje (id_cliente, id_bici, id_origen, fecha) VALUES
    ('CLI-001', 'BIC-07', 'EST-1', '2024-03-24'),
    ('CLI-006', 'BIC-06', 'EST-3', '2024-03-24');

-- Viajes abandonados — comenzaron en enero, nunca se cerraron
INSERT INTO viaje (id_cliente, id_bici, id_origen, fecha) VALUES
    ('CLI-007', 'BIC-04', 'EST-2', '2024-01-10'),
    ('CLI-003', 'BIC-06', 'EST-3', '2024-01-15'),
    ('CLI-004', 'BIC-08', 'EST-4', '2024-01-20');

-- ── VERIFICACIÓN ───────────────────────────────────────────────────────────────
SELECT COUNT(*) AS estaciones   FROM estacion;              -- 6
SELECT COUNT(*) AS bicicletas   FROM bicicleta;             -- 10
SELECT COUNT(*) AS clientes     FROM cliente;               -- 8
SELECT COUNT(*) AS viajes       FROM viaje;                 -- 21
SELECT COUNT(*) AS completados  FROM viaje WHERE tarifa_cop IS NOT NULL;  -- 16
SELECT COUNT(*) AS en_curso     FROM viaje WHERE tarifa_cop IS NULL;      -- 5

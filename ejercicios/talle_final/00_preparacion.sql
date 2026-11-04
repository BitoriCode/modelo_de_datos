-- Ejecutar completo en una base de practica con la cuenta propietaria.
-- Si ya existen los esquemas, se detiene sin borrar ni modificar su contenido.
BEGIN;
DO $$
BEGIN
    IF EXISTS (
        SELECT FROM pg_namespace
        WHERE nspname IN ('mt_museo', 'mt_mensajeria', 'mt_reparaciones', 'mt_directorio')
    ) THEN
        RAISE EXCEPTION 'Preparacion previa detectada. Use otra base de practica vacia; no se ha reiniciado ningun esquema.';
    END IF;
END;
$$;

CREATE SCHEMA mt_museo;
CREATE SCHEMA mt_mensajeria;
CREATE SCHEMA mt_reparaciones;
CREATE SCHEMA mt_directorio;

CREATE TABLE mt_museo.r5_ficha (
    id_pieza INTEGER, numero_ficha INTEGER, titulo TEXT,
    id_sala INTEGER, nombre_sala TEXT, etiquetas TEXT, texto_ficha TEXT
);
INSERT INTO mt_museo.r5_ficha VALUES
    (10, 1, 'Mapa del puerto', 1, 'Navegacion', 'papel;tinta', 'Anverso'),
    (10, 2, 'Mapa del puerto', 1, 'Navegacion', 'papel;tinta', 'Reverso'),
    (20, 1, 'Brujula de viaje', 1, 'Navegacion', 'metal', 'Base');

CREATE TABLE mt_museo.r8_sala (
    id_sala INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL
);
INSERT INTO mt_museo.r8_sala VALUES (1, 'Navegacion'), (2, 'Cartografia');
-- Borrador deliberadamente permisivo: no es un modelo a imitar.
CREATE TABLE mt_museo.r8_registro_inseguro (
    id_registro INTEGER, id_sala INTEGER, codigo TEXT,
    fragilidad NUMERIC(4,1), estado TEXT
);
INSERT INTO mt_museo.r8_registro_inseguro VALUES
    (1, 999, NULL, -2, NULL);

CREATE TABLE mt_mensajeria.r4_envio (
    id_envio INTEGER PRIMARY KEY,
    cliente TEXT NOT NULL,
    importe NUMERIC(10,2) NOT NULL CHECK (importe >= 0)
);
CREATE TABLE mt_mensajeria.r4_evento (
    id_evento INTEGER PRIMARY KEY,
    id_envio INTEGER NOT NULL REFERENCES mt_mensajeria.r4_envio,
    estado TEXT NOT NULL
);
INSERT INTO mt_mensajeria.r4_envio VALUES
    (1, 'Ana', 100), (2, 'Ana', 80), (3, 'Beto', 70), (4, 'Cora', 50);
INSERT INTO mt_mensajeria.r4_evento VALUES
    (1, 1, 'entregado'), (2, 1, 'entregado'),
    (3, 2, 'entregado'), (4, 3, 'entregado'), (5, 4, 'en_ruta');

CREATE TABLE mt_mensajeria.r7_cliente (
    id_cliente INTEGER PRIMARY KEY, nombre TEXT NOT NULL
);
CREATE TABLE mt_mensajeria.r7_aviso (
    id_aviso INTEGER PRIMARY KEY,
    id_cliente INTEGER REFERENCES mt_mensajeria.r7_cliente
);
CREATE TABLE mt_mensajeria.r7_baja (
    id_cliente INTEGER PRIMARY KEY REFERENCES mt_mensajeria.r7_cliente
);
INSERT INTO mt_mensajeria.r7_cliente VALUES
    (1, 'Ada'), (2, 'Bruno'), (3, 'Celia'), (4, 'Dario');
INSERT INTO mt_mensajeria.r7_aviso VALUES (11, 1), (12, 1), (13, 3), (14, NULL);
INSERT INTO mt_mensajeria.r7_baja VALUES (3), (4);

CREATE TABLE mt_mensajeria.r9_guia (
    id_guia INTEGER PRIMARY KEY,
    fecha DATE NOT NULL,
    importe NUMERIC(10,2) NOT NULL
);
INSERT INTO mt_mensajeria.r9_guia VALUES
    (1, DATE '2026-03-01', 80),
    (2, DATE '2026-03-02', 60), (3, DATE '2026-03-02', 60),
    (4, DATE '2026-03-03', 110),
    (5, DATE '2025-03-02', 999), (6, DATE '2026-04-01', 200);

CREATE TABLE mt_reparaciones.r6_orden (
    id_orden INTEGER PRIMARY KEY, estado TEXT NOT NULL
);
CREATE TABLE mt_reparaciones.r6_auditoria (
    id_auditoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_orden INTEGER NOT NULL REFERENCES mt_reparaciones.r6_orden,
    antes TEXT NOT NULL, despues TEXT NOT NULL
);
INSERT INTO mt_reparaciones.r6_orden VALUES (1, 'abierta'), (2, 'revision');
-- El defecto es de comportamiento; crear estos objetos no produce errores SQL.
CREATE FUNCTION mt_reparaciones.r6_auditar() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO mt_reparaciones.r6_auditoria (id_orden, antes, despues)
    VALUES (NEW.id_orden, NEW.estado, NEW.estado);
    RETURN NULL;
END;
$$;
CREATE TRIGGER r6_cambio BEFORE UPDATE OF estado ON mt_reparaciones.r6_orden
FOR EACH ROW EXECUTE FUNCTION mt_reparaciones.r6_auditar();

CREATE TABLE mt_reparaciones.r10_orden (
    id_orden INTEGER PRIMARY KEY,
    costo_base NUMERIC(10,2) NOT NULL CHECK (costo_base >= 0),
    total_final NUMERIC(10,2),
    estado TEXT NOT NULL CHECK (estado IN ('abierta', 'cerrada'))
);
INSERT INTO mt_reparaciones.r10_orden VALUES
    (1, 200, NULL, 'abierta'), (2, 80, NULL, 'abierta');

CREATE TABLE mt_reparaciones.r11_orden (
    id_orden INTEGER PRIMARY KEY,
    estado TEXT NOT NULL CHECK (estado IN ('abierta', 'cerrada'))
);
CREATE TABLE mt_reparaciones.r11_movimiento (
    id_movimiento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_orden INTEGER NOT NULL REFERENCES mt_reparaciones.r11_orden,
    concepto TEXT NOT NULL
);
CREATE TABLE mt_reparaciones.r11_borrador (
    id_orden INTEGER PRIMARY KEY REFERENCES mt_reparaciones.r11_orden,
    detalle TEXT NOT NULL
);
INSERT INTO mt_reparaciones.r11_orden VALUES (7, 'abierta'), (8, 'abierta');
INSERT INTO mt_reparaciones.r11_borrador VALUES (7, 'Pendiente'), (8, 'Revisar');

CREATE TABLE mt_directorio.r2_entrada (
    id_entrada INTEGER PRIMARY KEY,
    codigo TEXT, nombre TEXT NOT NULL
);
INSERT INTO mt_directorio.r2_entrada VALUES
    (1, ' pv-0042 ', '  ana lopez '), (2, 'PV-1289', 'luis mora'),
    (3, 'xPV-0042', 'eva rios'), (4, 'PV-12', 'teo cruz'),
    (5, 'PV-99999', 'luz mesa'), (6, 'PV-ABCD', 'leo sol'), (7, NULL, 'sin codigo');

CREATE TABLE mt_directorio.r12_proveedor (
    id_proveedor INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL, ciudad TEXT NOT NULL,
    contacto_interno TEXT NOT NULL
);
INSERT INTO mt_directorio.r12_proveedor VALUES
    (1, 'Proveedor Norte', 'Pasto', 'extension-ficticia-101'),
    (2, 'Proveedor Sur', 'Tunja', 'extension-ficticia-202');
-- Vista defectuosa: incluye una columna innecesaria para el reporte.
CREATE VIEW mt_directorio.r12_directorio AS
SELECT * FROM mt_directorio.r12_proveedor;
COMMIT;

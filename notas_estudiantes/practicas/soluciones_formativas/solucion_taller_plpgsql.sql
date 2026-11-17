-- Solución del taller S31. Ejecutar una vez sobre una base de práctica
-- con StaffHub recién cargado. No confirma operaciones de negocio.
-- La función bono_desempeno se reutiliza desde la nota de funciones.

CREATE TABLE solicitud_traslado (
    id_solicitud INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empleado VARCHAR(10) NOT NULL REFERENCES empleado(id_empleado),
    departamento_origen INT REFERENCES departamento(id_departamento),
    departamento_destino INT NOT NULL REFERENCES departamento(id_departamento),
    motivo VARCHAR(80) NOT NULL CHECK (LENGTH(BTRIM(motivo)) > 0)
);

CREATE TABLE auditoria_departamento (
    id_auditoria INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empleado VARCHAR(10) NOT NULL,
    departamento_anterior INT,
    departamento_nuevo INT,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION auditar_departamento_taller()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO auditoria_departamento (
        id_empleado, departamento_anterior, departamento_nuevo
    ) VALUES (NEW.id_empleado, OLD.id_departamento, NEW.id_departamento);
    RETURN NULL;  -- AFTER ignora el retorno
END;
$$;

CREATE TRIGGER tg_departamento_taller
    AFTER UPDATE OF id_departamento ON empleado
    FOR EACH ROW
    WHEN (OLD.id_departamento IS DISTINCT FROM NEW.id_departamento)
    EXECUTE FUNCTION auditar_departamento_taller();

CREATE OR REPLACE PROCEDURE solicitar_traslado(
    p_id VARCHAR, p_destino INT, p_motivo TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_origen INT;
BEGIN
    IF p_destino IS NULL OR p_motivo IS NULL OR BTRIM(p_motivo) = '' THEN
        RAISE EXCEPTION 'Destino y motivo son obligatorios';
    END IF;

    -- El bloqueo evita que otra sesión cambie el origen antes de registrar el traslado.
    SELECT id_departamento INTO v_origen
    FROM empleado WHERE id_empleado = p_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Empleado % inexistente', p_id; END IF;

    IF NOT EXISTS (SELECT 1 FROM departamento WHERE id_departamento = p_destino) THEN
        RAISE EXCEPTION 'Departamento % inexistente', p_destino;
    END IF;

    IF v_origen IS NOT DISTINCT FROM p_destino THEN
        RAISE NOTICE 'El empleado ya pertenece al departamento %', p_destino;
        RETURN;
    END IF;

    UPDATE empleado SET id_departamento = p_destino WHERE id_empleado = p_id;
    INSERT INTO solicitud_traslado (
        id_empleado, departamento_origen, departamento_destino, motivo
    ) VALUES (p_id, v_origen, p_destino, p_motivo);
    -- Si falla este INSERT, también se revierten UPDATE y auditoría del trigger.
    -- No se utiliza COMMIT intermedio ni se oculta el error con un NOTICE.
END;
$$;

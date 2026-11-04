-- NO EJECUTAR COMPLETO: contiene defectos deliberados y marcas __COMPLETAR__.
-- Ejecutar solo el bloque del reto que se esta trabajando, tras corregirlo.
-- Trabajar con la misma cuenta propietaria de los esquemas en todos los retos.
-- Retos 1, 3 y 5: intervencion escrita/grafica; no necesitan SQL nuevo.

-- RETO 2: acepta codigos incompletos y coincidencias dentro de otras cadenas.
SELECT id_entrada, codigo, nombre
FROM mt_directorio.r2_entrada
WHERE codigo ~* 'PV-[0-9]+'
ORDER BY id_entrada;
-- Corregir filtro y presentar codigo normalizado y nombre sin espacios
-- exteriores, con iniciales en mayuscula. No modificar la tabla.

-- RETO 4: el historial multiplica el importe de un envio.
SELECT e.cliente, SUM(e.importe) AS facturable
FROM mt_mensajeria.r4_envio e
JOIN mt_mensajeria.r4_evento h ON h.id_envio = e.id_envio
WHERE h.estado = 'entregado'
GROUP BY e.cliente
HAVING SUM(e.importe) >= 150
ORDER BY e.cliente;

-- RETO 6: observar el defecto SIN conservar los cambios de la prueba.
BEGIN;
UPDATE mt_reparaciones.r6_orden SET estado = 'cerrada' WHERE id_orden = 1;
SELECT * FROM mt_reparaciones.r6_orden ORDER BY id_orden;
SELECT id_orden, antes, despues FROM mt_reparaciones.r6_auditoria ORDER BY id_auditoria;
ROLLBACK;
-- Corregir la funcion y reemplazar el trigger: auditar despues del cambio,
-- solo si el estado cambia realmente. Volver a probar dentro de BEGIN/ROLLBACK.

-- RETO 7: se esperaba encontrar clientes sin aviso.
SELECT id_cliente, nombre FROM mt_mensajeria.r7_cliente
WHERE id_cliente NOT IN (SELECT id_cliente FROM mt_mensajeria.r7_aviso)
ORDER BY id_cliente;
-- Reparar sin eliminar el NULL de los datos.
-- Conjuntos en papel, ignorando NULL: A = clientes con aviso; B = bajas.
-- Anotar A UNION B, A INTERSECT B y A EXCEPT B.

-- RETO 8: sustituir las marcas por restricciones, NO por nuevos datos.
-- Ejecutar la creacion una sola vez; si debe rehacerla use ROLLBACK
-- durante sus pruebas de DDL antes de confirmar la version definitiva.
CREATE TABLE mt_museo.r8_registro_corregido (
    id_registro INTEGER __COMPLETAR__,
    id_sala INTEGER __COMPLETAR__,
    codigo TEXT __COMPLETAR__,
    fragilidad NUMERIC(4,1) __COMPLETAR__,
    estado TEXT __COMPLETAR__
);
-- Contrato completo y casos de prueba: ficha 8 del taller.

-- RETO 9: este informe pierde un dia y admite otro anio.
WITH diario AS (
    SELECT fecha, AVG(importe) AS total
    FROM mt_mensajeria.r9_guia
    WHERE EXTRACT(MONTH FROM fecha) = 3
    GROUP BY fecha
)
SELECT TO_CHAR(fecha, 'DD/MM') AS dia, ROUND(total, 2) AS total
FROM diario WHERE total > 100 ORDER BY fecha;
-- Reparar y contrastar con una tabla derivada equivalente.
-- Revisar EXPLAIN antes/despues de un indice sobre fecha.

-- RETO 10: reparar la funcion y completar un procedimiento acotado.
CREATE OR REPLACE FUNCTION mt_reparaciones.r10_neto(p_costo NUMERIC, p_descuento INTEGER)
RETURNS NUMERIC LANGUAGE plpgsql AS $$
BEGIN
    -- Falta validar NULL, costo negativo y porcentaje fuera de 0..100.
    RETURN ROUND(p_costo * (1 - p_descuento / 100), 2);
END;
$$;

CREATE OR REPLACE PROCEDURE mt_reparaciones.r10_cerrar(p_id INTEGER, p_descuento INTEGER)
LANGUAGE plpgsql AS $$
DECLARE
    v_costo NUMERIC;
    v_estado TEXT;
BEGIN
    SELECT costo_base, estado INTO v_costo, v_estado
    FROM mt_reparaciones.r10_orden WHERE id_orden = p_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Orden inexistente' USING ERRCODE = 'P0002';
    END IF;
    IF v_estado <> 'abierta' THEN
        RAISE EXCEPTION 'La orden no esta abierta' USING ERRCODE = '22023';
    END IF;
    -- Completar UN UPDATE que use r10_neto y cierre SOLO p_id.
    __COMPLETAR__;
END;
$$;

-- RETO 11: NO EJECUTAR EL BORRADOR SIN CORREGIR.
-- Fue copiado de una aplicacion con autocommit. Tiene cambios sin filtro.
-- INSERT INTO mt_reparaciones.r11_movimiento(id_orden, concepto)
-- VALUES (7, 'cierre');
-- COMMIT;
-- UPDATE mt_reparaciones.r11_orden SET estado = 'cerrada';
-- DELETE FROM mt_reparaciones.r11_borrador;
-- Reparar como una unidad BEGIN...COMMIT con predicados para la orden 7.
-- Ensayar primero con ROLLBACK. No tocar las tablas r6_ ni r10_.

-- RETO 12: una vista es una consulta reutilizable, no una copia congelada.
SELECT * FROM mt_directorio.r12_directorio ORDER BY id_proveedor;
SELECT * FROM mt_directorio.r12_proveedor ORDER BY id_proveedor;
-- Reemplazar la vista: DROP VIEW del objeto concreto y CREATE VIEW,
-- dentro de una transaccion, sin CASCADE.
-- Contrato: vista con id_proveedor, nombre, ciudad; no contacto_interno.
-- Despues de reparar la vista, ejecutar este ensayo reversible:
BEGIN;
UPDATE mt_directorio.r12_proveedor SET ciudad = 'Armenia' WHERE id_proveedor = 1;
SELECT * FROM mt_directorio.r12_directorio ORDER BY id_proveedor;
ROLLBACK;
SELECT * FROM mt_directorio.r12_directorio ORDER BY id_proveedor;
-- Comprobar que contacto_interno sigue en la tabla base y no fue modificado.

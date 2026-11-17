# DML básico — INSERT, UPDATE, DELETE y subconsultas iniciales

[Índice de notas](../README.md) · [Ruta de estudio](../ruta_estudio_programacion.md)

## Antes de empezar

**Sesión de referencia:** S16, 100 minutos. Repasa [SELECT y filtros](select_agregacion.md) y [restricciones](ddl_restricciones.md). Carga [StaffHub](../recursos/datasets/staffhub_setup.sql) y comprueba 12 empleados, de los cuales dos no tienen departamento. Consulta las [instrucciones de reinicio](../recursos/datasets/README.md).

**Al finalizar podrás:** insertar una fila coherente, modificar o eliminar solo las filas previstas y utilizar una subconsulta escalar o de lista. En estas prácticas, `BEGIN` abre una transacción y `ROLLBACK` revierte los cambios; no modifica las tablas permanentemente.

## 1. INSERT — Crear una fila

Enumera las columnas para que la intención sea clara. Omitir una columna usa su DEFAULT si existe; en otro caso intenta asignar NULL y las restricciones deciden si es válido.

```sql
BEGIN;
INSERT INTO empleado (id_empleado, nombre, fecha_ingreso, salario_cop, id_departamento)
VALUES ('EMP-90', 'Lina Prado', DATE '2026-01-15', 3000000, 2)
RETURNING id_empleado, nombre, id_departamento;
ROLLBACK;
```

Esperado: una fila, EMP-90 en departamento 2. No hay cargo asignado automáticamente: es otra tabla. Una PK repetida o un departamento inexistente provocarían un error.

## 2. UPDATE — Modificar filas existentes

Primero comprueba el filtro con SELECT. Sin WHERE, UPDATE modifica todas las filas. RETURNING muestra cuáles cambió; no impide un filtro equivocado.

```sql
BEGIN;
SELECT id_empleado, salario_cop FROM empleado WHERE id_departamento = 2;
UPDATE empleado
SET salario_cop = ROUND(salario_cop * 1.05)
WHERE id_departamento = 2
RETURNING id_empleado, salario_cop;
ROLLBACK;
```

Esperado: EMP-04 pasa a 3045000 y EMP-05 a 2730000 durante la transacción. Al terminar, sus salarios originales se conservan. Repetir un aumento sin reiniciar los datos acumula cambios.

## 3. DELETE — Eliminar filas

DELETE elimina filas; DROP TABLE elimina el objeto completo. La FK de cargo impide borrar un empleado que tenga un cargo mientras siga existiendo esa referencia.

```sql
BEGIN;
INSERT INTO empleado (id_empleado, nombre, fecha_ingreso, salario_cop)
VALUES ('EMP-90', 'Lina Prado', DATE '2026-01-15', 3000000);
DELETE FROM empleado WHERE id_empleado = 'EMP-90' RETURNING id_empleado;
SELECT COUNT(*) AS restantes FROM empleado WHERE id_empleado = 'EMP-90';
ROLLBACK;
```

Esperado: se elimina solo EMP-90 y el recuento es 0. El ejemplo crea su propia fila para no depender del INSERT anterior, que se revirtió.

## 4. Subconsultas escalares y de lista

Una subconsulta escalar aporta una columna y como máximo una fila. Si no devuelve filas, su valor es NULL; si devuelve varias, provoca un error. Las agregaciones sin GROUP BY son útiles para producir un único valor:

```sql
SELECT id_empleado, salario_cop
FROM empleado
WHERE salario_cop > (SELECT AVG(salario_cop) FROM empleado)
ORDER BY id_empleado;
```

Esperado con los datos iniciales: EMP-01, EMP-03, EMP-06, EMP-07 y EMP-08.

`IN` compara con una lista de valores de una sola columna. Esta subconsulta puede devolver varios departamentos:

```sql
SELECT id_empleado
FROM empleado
WHERE id_departamento IN (
    SELECT id_departamento FROM departamento WHERE ciudad = 'Bogotá'
)
ORDER BY id_empleado;
```

Esperado: EMP-01, EMP-02, EMP-03, EMP-06, EMP-07 y EMP-08. Con `NOT IN`, un NULL en el resultado de la subconsulta puede convertir una comparación en desconocida; estudia después `NOT EXISTS` para expresar ausencia de coincidencias.

## 5. Práctica autónoma — 30 minutos

**Reto A.** Inserta EMP-90 y su cargo `junior`. Comprueba la unión de las dos tablas y elimínalo sin incumplir las FK. Usa una única transacción y revierte al terminar.

**Reto B.** Aumenta un 2% a los empleados cuyos departamentos estén en Medellín. Usa IN con una subconsulta; predice cuántas filas se modifican y comprueba sus salarios antes de revertir.

<details>
<summary>Soluciones razonadas</summary>

```sql
-- practica_dml_a
BEGIN;
INSERT INTO empleado (id_empleado, nombre, fecha_ingreso, salario_cop)
VALUES ('EMP-90', 'Lina Prado', DATE '2026-01-15', 3000000);
INSERT INTO cargo (id_empleado, titulo, nivel)
VALUES ('EMP-90', 'Asistente', 'junior');
SELECT e.id_empleado, c.nivel FROM empleado e
JOIN cargo c USING (id_empleado) WHERE e.id_empleado = 'EMP-90';
DELETE FROM cargo WHERE id_empleado = 'EMP-90';
DELETE FROM empleado WHERE id_empleado = 'EMP-90';
ROLLBACK;
```

Primero se crea el padre y luego la fila que lo referencia; para eliminar se hace el recorrido inverso. La consulta devuelve EMP-90 y junior. No hacen falta CASCADE ni desactivar restricciones.

```sql
-- practica_dml_b
BEGIN;
UPDATE empleado
SET salario_cop = ROUND(salario_cop * 1.02)
WHERE id_departamento IN (
    SELECT id_departamento FROM departamento WHERE ciudad = 'Medellín'
)
RETURNING id_empleado, salario_cop;
ROLLBACK;
```

Solo se modifican dos filas: EMP-04 queda en 2958000 y EMP-05 en 2652000 dentro de la transacción. Una subconsulta en WHERE filtra filas; no actualiza la tabla departamento.

</details>

## 6. Comprueba tu aprendizaje

1. ¿Qué protege WHERE? Selecciona las filas; si falta, la operación alcanza toda la tabla.
2. ¿Por qué borrar primero cargo? Contiene la FK que referencia empleado.
3. ¿Qué sucede si una subconsulta usada con `=` devuelve dos filas? Error: no es un valor escalar válido.
4. ¿Por qué comprobar un resultado antes de COMMIT? Un resultado sintácticamente válido puede afectar filas equivocadas. En este material de práctica se usa ROLLBACK para conservar el estado inicial.

Continúa con [subconsultas avanzadas y JOINs](../05_sql_avanzado/subconsultas_joins.md). Referencia: [transacciones en PostgreSQL](https://www.postgresql.org/docs/18/tutorial-transactions.html).

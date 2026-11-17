# PL/pgSQL IV — Procedimientos y operaciones sobre varias tablas

[Índice de notas](../README.md) · [Ruta de estudio](../ruta_estudio_programacion.md)

## Antes de empezar

**Sesión de referencia:** S28, 100 minutos. **Conocimientos previos:** Funciones, DML básico y relaciones mediante FK.

**Al finalizar podrás:** Invocar procedimientos con CALL, comprobar filas afectadas y ejecutar varias modificaciones de forma atómica.

Carga [StaffHub](../recursos/datasets/staffhub_setup.sql) en una base de práctica siguiendo las [instrucciones de preparación](../recursos/datasets/README.md). Antes de cada práctica autónoma restaura el dataset para partir de los mismos datos: 4 departamentos, 12 empleados y 12 cargos. El setup no elimina todas las rutinas o tablas auxiliares.

**Núcleo de la sesión:** CREATE PROCEDURE, CALL y atomicidad. COMMIT por etapas, OUT y permisos son ampliación; no requisitos simultáneos de la práctica inicial.

Distingue bloques completos (`DO ... $$;` o `CREATE ... $$;`) de fragmentos como DECLARE o IF aislados. Las plantillas con TIPO, tabla o puntos suspensivos y los errores intencionados no se ejecutan como scripts completos.

[Ir a la práctica autónoma](#práctica-de-la-sesión).

## 1. Procedimientos — `CREATE PROCEDURE`

### 1.1 ¿Por qué existen los procedimientos?

Los procedimientos almacenados existen en la mayoría de motores de bases de datos (Oracle, SQL Server, MySQL) desde hace décadas. PostgreSQL, sin embargo, no los tuvo hasta la **versión 11 (2018)**. Antes, todo se implementaba como funciones.

Se agregaron por dos razones fundamentales:

1. **Separación semántica:** hay una diferencia conceptual entre *calcular algo* (función) y *ejecutar una acción* (procedimiento). Tener tipos distintos hace el código más claro y mantenible.
2. **Control de transacciones:** las funciones no pueden hacer `COMMIT` ni `ROLLBACK`; participan en la transacción que las llama. Los procedimientos pueden finalizar transacciones solo en los contextos de invocación permitidos. No necesitan hacerlo para ejecutar varias operaciones como una unidad atómica.

### 1.2 Diferencias con las funciones

| Característica | Función | Procedimiento |
|----------------|---------|---------------|
| **Devuelve valor** | Sí — con `RETURN valor` | No (o usa parámetros `OUT`) |
| **Cómo se invoca** | `SELECT funcion()` | `CALL procedimiento()` |
| **Usable en WHERE/SELECT** | Sí | No |
| **Control de transacciones** | No puede finalizar la transacción | Puede usar `COMMIT`/`ROLLBACK` si el contexto de `CALL` lo permite |
| **Propósito semántico** | Calcular y devolver un resultado | Ejecutar una acción |
| **Disponible desde** | Siempre | PostgreSQL 11 (2018) |

### 1.3 ¿Cuándo usar función y cuándo procedimiento?

La pregunta clave es: **¿estás calculando algo o ejecutando algo?**

```
¿Necesitas usar el resultado en un SELECT, WHERE o expresión?
    → FUNCIÓN

¿Necesitas devolver múltiples filas como tabla?
    → FUNCIÓN con RETURNS TABLE

¿Estás ejecutando una acción (INSERT/UPDATE/DELETE) como objetivo principal
   y no necesitas el resultado en una expresión SQL?
    → PROCEDIMIENTO

¿Necesitas hacer COMMIT o ROLLBACK en momentos distintos del proceso?
    → PROCEDIMIENTO (las funciones no pueden)
```

### 1.4 Casos de uso reales

| Caso de uso | Por qué un procedimiento |
|-------------|--------------------------|
| **Cierre de mes contable** | Agrupar cálculos y actualizaciones; mantener una sola transacción cuando el cierre deba completarse entero o revertirse |
| **Migración de datos** | INSERT masivo desde una tabla a otra + DELETE en la original; sin necesidad de devolver valor |
| **Proceso de facturación** | Calcular y guardar facturas para todos los clientes activos del período |
| **Onboarding de empleado** | INSERT en `empleado` + INSERT en `cargo` + UPDATE de presupuesto del departamento en un solo proceso |
| **Archivado de registros** | Mover registros a una tabla histórica y eliminarlos de la tabla activa |
| **Reajuste masivo de precios** | UPDATE con condiciones complejas sobre miles de filas, con validaciones previas y reportes |
| **Recalcular estadísticas** | Actualizar tablas de resumen/caché que se consultan frecuentemente |

### 1.5 Estructura

```sql
CREATE OR REPLACE PROCEDURE nombre_procedimiento(
    param1 TIPO,
    param2 TIPO
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- variables locales (opcional)
BEGIN
    -- acciones DML: INSERT, UPDATE, DELETE
    -- NO se usa RETURN con valor
    -- Se puede usar RETURN solo para terminar antes del final
END;
$$;
```

La invocación es siempre con `CALL`:

```sql
CALL nombre_procedimiento(arg1, arg2);
```

### 1.6 Ejemplo 1 — actualización masiva con GET DIAGNOSTICS

```sql
-- Aplica un aumento de salario a todos los empleados de un departamento
CREATE OR REPLACE PROCEDURE aplicar_aumento(
    p_id_depto   INT,
    p_porcentaje NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_afectados INT;
BEGIN
    UPDATE empleado
    SET salario_cop = ROUND(salario_cop * (1 + p_porcentaje / 100))
    WHERE id_departamento = p_id_depto;

    -- GET DIAGNOSTICS captura cuántas filas modificó la última operación DML
    GET DIAGNOSTICS v_afectados = ROW_COUNT;

    RAISE NOTICE 'Aumento del % %% aplicado a % empleados del departamento %',
                 p_porcentaje, v_afectados, p_id_depto;
END;
$$;
```

```sql
CALL aplicar_aumento(1, 5.0);
-- NOTICE: Aumento del 5 % aplicado a 3 empleados del departamento 1

CALL aplicar_aumento(2, 8.5);
-- NOTICE: Aumento del 8.5 % aplicado a 2 empleados del departamento 2
```

### 1.7 Ejemplo 2 — procedimiento con validaciones

El patrón estándar de un procedimiento de producción es: **validar → actuar → confirmar**.

```sql
-- Transfiere un empleado a otro departamento con validación completa
CREATE OR REPLACE PROCEDURE transferir_empleado(
    p_id_empleado VARCHAR,
    p_nuevo_depto INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nombre       TEXT;
    v_depto_actual INT;
BEGIN
    -- 1. Validar que el empleado existe
    SELECT nombre, id_departamento
    INTO v_nombre, v_depto_actual
    FROM empleado WHERE id_empleado = p_id_empleado;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El empleado % no existe', p_id_empleado;
    END IF;

    -- 2. Validar que el departamento destino existe
    IF NOT EXISTS (
        SELECT 1 FROM departamento WHERE id_departamento = p_nuevo_depto
    ) THEN
        RAISE EXCEPTION 'El departamento % no existe', p_nuevo_depto;
    END IF;

    -- 3. Evitar transferencias innecesarias
    IF v_depto_actual = p_nuevo_depto THEN
        RAISE NOTICE '% ya pertenece al departamento %. Sin cambios.',
                     v_nombre, p_nuevo_depto;
        RETURN;
    END IF;

    -- 4. Ejecutar la transferencia
    UPDATE empleado
    SET id_departamento = p_nuevo_depto
    WHERE id_empleado = p_id_empleado;

    RAISE NOTICE '% transferido al departamento %', v_nombre, p_nuevo_depto;
END;
$$;
```

```sql
CALL transferir_empleado('EMP-11', 2);    -- OK: transferido a Marketing
CALL transferir_empleado('EMP-11', 99);   -- ERROR: departamento no existe
CALL transferir_empleado('EMP-99', 1);    -- ERROR: empleado no existe
CALL transferir_empleado('EMP-11', 2);    -- NOTICE: ya pertenece al depto, sin cambios
```

### 1.8 Ejemplo 3 — control de transacciones con COMMIT

Una función no puede ejecutar `COMMIT` o `ROLLBACK`. Los procedimientos y los bloques `DO` pueden hacerlo bajo condiciones específicas: la invocación debe ser de nivel superior o una cadena permitida de `CALL`/`DO`, sin una llamada a función mediante `SELECT` interpuesta. Un `CALL` dentro de una transacción explícita tampoco puede finalizarla. No se puede finalizar una transacción dentro de un bloque con manejadores `EXCEPTION`.

El siguiente ejemplo es una demostración de **confirmación por etapas**; no es una receta para un cierre contable que deba ser atómico. Antes de crear el procedimiento, crea su tabla de trabajo:

```sql
CREATE TABLE IF NOT EXISTS cierre_salario (
    id_cierre   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_empleado VARCHAR(10) NOT NULL,
    salario_cop INT NOT NULL,
    fecha_hora  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

```sql
-- Proceso de cierre de período: guarda el estado paso a paso
-- Si el paso 2 falla, el paso 1 ya quedó guardado (no se pierde)
CREATE OR REPLACE PROCEDURE cierre_mensual(p_id_depto INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INT;
BEGIN
    -- PASO 1: registrar estado actual de salarios
    INSERT INTO cierre_salario (id_empleado, salario_cop)
    SELECT id_empleado, salario_cop
    FROM empleado
    WHERE id_departamento = p_id_depto;

    GET DIAGNOSTICS v_total = ROW_COUNT;
    RAISE NOTICE 'Paso 1 OK: % registros guardados en log', v_total;

    COMMIT;  -- ← guarda el paso 1 aunque el paso 2 falle

    -- PASO 2: operación sin cambio de valor, solo para mostrar otra etapa
    UPDATE departamento
    SET presupuesto_anual = presupuesto_anual  -- (ejemplo simplificado)
    WHERE id_departamento = p_id_depto;

    RAISE NOTICE 'Proceso de cierre completado para departamento %', p_id_depto;

    COMMIT;  -- ← confirma el paso 2
END;
$$;
```

Ejecuta `CALL cierre_mensual(1);` como una sentencia independiente, fuera de `BEGIN; ... COMMIT;`, con el autocommit del cliente activado.

> Un `COMMIT` intermedio conserva cambios aunque falle una etapa posterior. Eso elimina la atomicidad del proceso completo. Reanudar un proceso por lotes también requiere identificar lo ya procesado y evitar duplicados; confirmar una etapa no implementa por sí solo esa recuperación.

### 1.9 Parámetros OUT — "devolver" información de un procedimiento

Aunque los procedimientos no tienen `RETURN`, pueden usar parámetros `OUT` para comunicar resultados al código que los llama.

```sql
CREATE OR REPLACE PROCEDURE resumen_departamento(
    p_id_depto     INT,
    OUT p_total    INT,           -- parámetro de salida: cantidad de empleados
    OUT p_promedio NUMERIC        -- parámetro de salida: salario promedio
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT COUNT(*), ROUND(AVG(salario_cop), 2)
    INTO p_total, p_promedio
    FROM empleado
    WHERE id_departamento = p_id_depto;
END;
$$;
```

```sql
-- CALL devuelve una fila con los parámetros OUT en el cliente SQL
CALL resumen_departamento(1, NULL, NULL);

-- En psql o pgAdmin los valores OUT se muestran directamente
-- Para usarlos en PL/pgSQL:
DO $$
DECLARE
    v_total    INT;
    v_promedio NUMERIC;
BEGIN
    CALL resumen_departamento(1, v_total, v_promedio);
    RAISE NOTICE 'Depto 1: % empleados, promedio $%', v_total, v_promedio;
END;
$$;
```

### 1.10 Ver y eliminar procedimientos

```sql
-- Ver procedimientos definidos por el usuario
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type   = 'PROCEDURE'
ORDER BY routine_name;

-- Eliminar un procedimiento
DROP PROCEDURE aplicar_aumento(INT, NUMERIC);
DROP PROCEDURE IF EXISTS aplicar_aumento(INT, NUMERIC);
```

### 1.11 Niveles de RAISE — tabla completa

| Nivel | Efecto | Cuándo usarlo |
|-------|--------|---------------|
| `RAISE DEBUG` | Solo visible en modo debug | Depuración interna |
| `RAISE INFO` | Informativo, siempre visible | Progreso de un proceso largo |
| `RAISE NOTICE` | Aviso en la consola del cliente | Confirmaciones normales |
| `RAISE WARNING` | Advertencia visible | Situaciones inusuales pero válidas |
| `RAISE EXCEPTION` | Lanza error, **aborta** la ejecución | Violaciones de reglas de negocio |

---

**Ampliación:** los roles de este ejemplo deben existir; créalos con el material de [DCL](../05_sql_avanzado/vistas_dcl.md). Las rutinas usan por defecto los privilegios de quien las invoca.

## 2. Permisos sobre funciones y procedimientos

Al igual que las tablas y las vistas, las funciones tienen un sistema de permisos:

```sql
-- Otorgar permiso de ejecución
GRANT EXECUTE ON FUNCTION calcular_bono(VARCHAR)  TO rol_rrhh_consulta;
GRANT EXECUTE ON PROCEDURE aplicar_aumento(INT, NUMERIC) TO rol_rrhh_editor;

-- Quitar permiso
REVOKE EXECUTE ON FUNCTION calcular_bono(VARCHAR) FROM rol_rrhh_consulta;

-- Por defecto, PUBLIC (todos los usuarios) tiene EXECUTE en las funciones
-- Para restringir el acceso a una función:
REVOKE EXECUTE ON FUNCTION calcular_bono(VARCHAR) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION calcular_bono(VARCHAR) TO   rol_rrhh_consulta;
```

---

## Práctica de la sesión

### Práctica guiada — Una acción sobre dos tablas

Un alta requiere crear empleado y cargo. Si falla el cargo, no debe quedar un empleado a medias. El procedimiento no confirma pasos intermedios: una llamada se ejecuta dentro de la transacción de quien la invoca.

```sql
-- guiada_s28_alta
CREATE OR REPLACE PROCEDURE registrar_alta(
    p_id VARCHAR, p_nombre TEXT, p_depto INT, p_salario INT, p_nivel VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_nombre IS NULL OR BTRIM(p_nombre) = '' OR p_salario IS NULL OR p_salario <= 0 THEN
        RAISE EXCEPTION 'Nombre y salario positivo son obligatorios';
    END IF;
    INSERT INTO empleado (id_empleado, nombre, fecha_ingreso, salario_cop, id_departamento)
    VALUES (p_id, p_nombre, CURRENT_DATE, p_salario, p_depto);
    INSERT INTO cargo (id_empleado, titulo, nivel)
    VALUES (p_id, 'Ingreso reciente', p_nivel);
END;
$$;
```

Prueba en una transacción independiente y revierte al terminar:

```sql
BEGIN;
CALL registrar_alta('EMP-90', 'Lina Prado', 2, 3000000, 'junior');
SELECT e.id_empleado, c.nivel FROM empleado e JOIN cargo c USING (id_empleado)
WHERE e.id_empleado = 'EMP-90';
ROLLBACK;
```

Esperado: una fila EMP-90/junior. Luego, como prueba negativa separada, llama con nivel `director`: el CHECK de cargo rechaza el segundo INSERT y la llamada no conserva el primero. Si la prueba está dentro de BEGIN, ejecuta ROLLBACK después del error antes de seguir. La FK comprueba el departamento y el CHECK comprueba el nivel: no se duplican todas esas reglas en el procedimiento.

### Práctica autónoma — 30 minutos

Organización de 100 minutos: 10 de repaso, 25 de explicación, 25 para el alta guiada, 30 para los retos y 10 para comprobar atomicidad. Los ejemplos de COMMIT por etapas y OUT se consultan después.

**Reto A.** Con `registrar_alta`, prueba un alta válida, un nombre vacío, un departamento inexistente y un nivel inválido. Antes de cada prueba debe estar libre EMP-90. Anota en qué paso falla y qué filas quedan. No uses COMMIT intermedio para evitar errores.

**Reto B.** Escribe `asignar_departamento(p_id VARCHAR, p_depto INT)`, que actualice un empleado y lance una excepción si no existe. El departamento puede ser NULL para desasignarlo. Si es no nulo, su existencia se garantiza con la FK.

<details>
<summary>Soluciones razonadas</summary>

En A, el alta válida crea dos filas dentro de la transacción; ROLLBACK las elimina. Nombre vacío falla antes del primer INSERT. Departamento inexistente falla por FK y nivel inválido por CHECK en cargo. En los dos últimos casos tampoco se conserva una mitad del alta. Los datos inválidos son errores esperados, no pasos para ejecutar como un único script de éxito.

```sql
-- practica_s28_b
CREATE OR REPLACE PROCEDURE asignar_departamento(p_id VARCHAR, p_depto INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_filas BIGINT;
BEGIN
    UPDATE empleado SET id_departamento = p_depto WHERE id_empleado = p_id;
    GET DIAGNOSTICS v_filas = ROW_COUNT;
    IF v_filas = 0 THEN RAISE EXCEPTION 'Empleado % inexistente', p_id; END IF;
END;
$$;
BEGIN;
CALL asignar_departamento('EMP-11', 2);
SELECT id_departamento FROM empleado WHERE id_empleado = 'EMP-11';
ROLLBACK;
```

Esperado: departamento 2 durante la prueba; después vuelve a NULL. ROW_COUNT cuantifica filas afectadas; FOUND solo informa si hubo alguna. La inexistencia se trata explícitamente porque un UPDATE que afecta cero filas no genera por sí solo un error.

</details>

**Autoevaluación:** ¿CALL devuelve una función tabular? No. ¿Un procedimiento necesita COMMIT interno para ser atómico? No. ¿Capturar cualquier error e imprimir NOTICE equivale a completar correctamente el alta? No: puede ocultar que la acción falló.

**Criterio de logro:** demostrar el éxito y el fallo del segundo paso sin registros parciales. Continúa con [errores y pruebas](05_errores.md).

Referencia de consulta: [documentación oficial de PostgreSQL](https://www.postgresql.org/docs/18/plpgsql-transactions.html).

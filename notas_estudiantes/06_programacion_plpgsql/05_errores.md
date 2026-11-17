# PL/pgSQL V — Validaciones, excepciones y pruebas

[Índice de notas](../README.md) · [Ruta de estudio](../ruta_estudio_programacion.md)

## Antes de empezar

**Sesión de referencia:** S29, 100 minutos. **Conocimientos previos:** Funciones y procedimientos, FOUND, restricciones y transacciones.

**Al finalizar podrás:** Distinguir ausencia de filas, datos inválidos y errores del motor; diseñar pruebas positivas y negativas.

Carga [StaffHub](../recursos/datasets/staffhub_setup.sql) en una base de práctica siguiendo las [instrucciones de preparación](../recursos/datasets/README.md). Antes de cada práctica autónoma restaura el dataset para partir de los mismos datos: 4 departamentos, 12 empleados y 12 cargos. El setup no elimina todas las rutinas o tablas auxiliares.

**Núcleo de la sesión:** INTO STRICT, RAISE EXCEPTION y manejadores concretos. Las plantillas y el catálogo de errores se usan como referencia.

Distingue bloques completos (`DO ... $$;` o `CREATE ... $$;`) de fragmentos como DECLARE o IF aislados. Las plantillas con TIPO, tabla o puntos suspensivos y los errores intencionados no se ejecutan como scripts completos.

[Ir a la práctica autónoma](#práctica-de-la-sesión).

## 1. Manejo de errores — `EXCEPTION`

PL/pgSQL permite capturar errores y reaccionar de forma controlada, en lugar de interrumpir la ejecución.

### Estructura

```sql
BEGIN
    -- código que puede generar un error
EXCEPTION
    WHEN tipo_error THEN
        -- qué hacer si ocurre ese error
    WHEN OTHERS THEN
        -- captura cualquier otro error
END;
```

### Tipos de error más comunes

| Condición | Cuándo ocurre |
|-----------|--------------|
| `NO_DATA_FOUND` | `SELECT INTO STRICT` no encontró ninguna fila |
| `TOO_MANY_ROWS` | `SELECT INTO STRICT` encontró más de una fila |
| `DIVISION_BY_ZERO` | División entre cero |
| `UNIQUE_VIOLATION` | Insertar un valor duplicado en una columna UNIQUE |
| `FOREIGN_KEY_VIOLATION` | Violar una restricción de FK |
| `OTHERS` | Captura otros errores, excepto `QUERY_CANCELED` y `ASSERT_FAILURE` |

Sin `STRICT`, un `SELECT INTO` asigna nulos si no encuentra filas y conserva solo la primera si encuentra varias. Sin `ORDER BY`, no hay una primera fila garantizada. Comprueba `FOUND` inmediatamente después del `SELECT INTO` cuando no utilices `STRICT`.

### Ejemplo — capturar NO_DATA_FOUND

```sql
CREATE OR REPLACE FUNCTION buscar_empleado(p_id VARCHAR)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_nombre TEXT;
BEGIN
    SELECT nombre INTO STRICT v_nombre   -- STRICT: falla si hay 0 o más de 1 resultado
    FROM empleado
    WHERE id_empleado = p_id;

    RETURN v_nombre;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Empleado ' || p_id || ' no encontrado';
    WHEN TOO_MANY_ROWS THEN
        RETURN 'Error: múltiples resultados para ' || p_id;
END;
$$;
```

```sql
SELECT buscar_empleado('EMP-01');    -- 'Ana Torres'
SELECT buscar_empleado('EMP-99');    -- 'Empleado EMP-99 no encontrado'
```

### Variables especiales de error

Dentro del bloque `EXCEPTION` están disponibles:

```sql
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error: %', SQLERRM;   -- mensaje del error
        RAISE NOTICE 'Código: %', SQLSTATE; -- código estándar SQL (ej: '23505')
```

---

## 2. `RAISE` — mensajes y errores

`RAISE` tiene varios niveles de severidad:

```sql
RAISE DEBUG   'Mensaje de depuración (solo en modo debug)';
RAISE INFO    'Información general';
RAISE NOTICE  'Aviso — el más usado en desarrollo';
RAISE WARNING 'Advertencia';
RAISE EXCEPTION 'Esto lanza un error y aborta la ejecución';
```

```sql
-- Formato con % como placeholder (igual que printf)
RAISE NOTICE 'Empleado %: salario = $%', v_nombre, v_salario;
-- NOTICE:  Empleado Ana Torres: salario = $4200000

-- RAISE EXCEPTION con código de error personalizado
RAISE EXCEPTION 'Valor inválido: %', p_valor
    USING ERRCODE = 'P0001';   -- código de error definido por el usuario
```

---

## 3. Referencia rápida — estructura general

```sql
-- ── FUNCIÓN ──────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION mi_funcion(param1 TIPO, param2 TIPO DEFAULT val)
RETURNS tipo_retorno   -- INT | TEXT | BOOLEAN | TABLE(...) | VOID | etc.
LANGUAGE plpgsql
AS $$
DECLARE
    v_var1  TIPO;
    v_var2  tabla.columna%TYPE;
    v_fila  tabla%ROWTYPE;
    v_rec   RECORD;
BEGIN
    -- asignación
    v_var1 := expresion;
    SELECT col INTO v_var1 FROM tabla WHERE condicion;

    -- condicional
    IF condicion THEN
        ...
    ELSIF otra_condicion THEN
        ...
    ELSE
        ...
    END IF;

    -- bucle sobre consulta
    FOR v_rec IN SELECT ... FROM ... LOOP
        ...
    END LOOP;

    -- bucle numérico
    FOR i IN 1..10 LOOP
        ...
    END LOOP;

    RETURN valor;

EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
    WHEN OTHERS        THEN RAISE EXCEPTION '%', SQLERRM;
END;
$$;

-- ── PROCEDIMIENTO ────────────────────────────────────────────────────
CREATE OR REPLACE PROCEDURE mi_procedimiento(param1 TIPO)
LANGUAGE plpgsql
AS $$
DECLARE
    v_n BIGINT;
BEGIN
    UPDATE ...;
    GET DIAGNOSTICS v_n = ROW_COUNT;
    RAISE NOTICE '% filas afectadas', v_n;
END;
$$;

-- ── LLAMADAS ─────────────────────────────────────────────────────────
SELECT mi_funcion(arg1, arg2);          -- función en SELECT
SELECT * FROM mi_funcion_tabla(arg);    -- función que devuelve tabla
CALL mi_procedimiento(arg);             -- procedimiento con CALL
```

---

## 4. Errores frecuentes

### Olvidar el punto y coma dentro del bloque

```sql
-- ❌ Falta ; al final de cada instrucción interna
BEGIN
    v_total := 0
    v_total := v_total + 1
END;
-- → ERROR: syntax error at or near "v_total"

-- ✅ Cada instrucción termina en ;
BEGIN
    v_total := 0;
    v_total := v_total + 1;
END;
```

### `SELECT INTO` sin verificar `FOUND`

```sql
-- ❌ Si no existe la fila, v_nombre queda NULL sin error visible
SELECT nombre INTO v_nombre FROM empleado WHERE id_empleado = 'EMP-99';
RAISE NOTICE 'Nombre: %', v_nombre;    -- imprime: Nombre: <NULL>

-- ✅ Verificar con FOUND o usar STRICT
SELECT nombre INTO STRICT v_nombre FROM empleado WHERE id_empleado = 'EMP-99';
-- Con STRICT lanza NO_DATA_FOUND automáticamente si no hay resultado
```

### Confundir `RETURN` con `RETURN QUERY`

```sql
-- ❌ RETURN no funciona para devolver el resultado de un SELECT
CREATE FUNCTION f() RETURNS TABLE(id INT) AS $$
BEGIN
    RETURN SELECT id FROM tabla;   -- incorrecto
END; $$ LANGUAGE plpgsql;

-- ✅ Para devolver el resultado de una consulta se usa RETURN QUERY
BEGIN
    RETURN QUERY SELECT id FROM tabla;
END;
```

### Llamar una función con `CALL` o un procedimiento con `SELECT`

```sql
-- ❌ Las funciones no se llaman con CALL
CALL calcular_bono('EMP-01');
-- → ERROR: calcular_bono is not a procedure

-- ❌ Los procedimientos no se llaman con SELECT
SELECT aplicar_aumento(1, 5.0);
-- → ERROR: aplicar_aumento is not a function

-- ✅
SELECT calcular_bono('EMP-01');    -- función
CALL aplicar_aumento(1, 5.0);     -- procedimiento
```

### Usar `%` literal en RAISE NOTICE

```sql
-- ❌ El % sin par genera error porque RAISE lo interpreta como placeholder
RAISE NOTICE 'Porcentaje: 15%';
-- → ERROR: too few arguments for format

-- ✅ Duplicar %% para que sea un % literal
RAISE NOTICE 'Porcentaje: 15%%';
-- NOTICE: Porcentaje: 15%
```

---

## Práctica de la sesión

Distribuye 10 minutos en revisar fallos anteriores, 25 en STRICT/EXCEPTION, 25 en escritura guiada, 30 en casos de prueba y 10 en explicar sus resultados. El catálogo final es una referencia de consulta.

**Reto A.** Crea `nombre_personal(p_id VARCHAR)` con INTO STRICT. Devuelve el nombre si existe y el texto `No encontrado` si no existe. No captures errores ajenos a la ausencia de filas como si fueran el mismo caso.

**Reto B.** Diseña y ejecuta cuatro pruebas de `bono_desempeno`: calificación alta, baja, NULL y empleado inexistente. Reutiliza la función de [la nota de funciones](03_funciones.md); no escribas otra versión del código para hacer pasar las pruebas.

<details>
<summary>Soluciones razonadas</summary>

```sql
-- practica_s29_a
CREATE OR REPLACE FUNCTION nombre_personal(p_id VARCHAR)
RETURNS TEXT LANGUAGE plpgsql AS $$
DECLARE v_nombre TEXT;
BEGIN
    SELECT nombre INTO STRICT v_nombre FROM empleado WHERE id_empleado = p_id;
    RETURN v_nombre;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'No encontrado';
END;
$$;
SELECT nombre_personal('EMP-01'), nombre_personal('EMP-99');
```

Esperado: Ana Torres y No encontrado. La PK impide encontrar varias filas para el mismo id. En una consulta por una columna no única, STRICT podría lanzar TOO_MANY_ROWS; no conviene esconder ese defecto devolviendo un nombre arbitrario.

```sql
-- practica_s29_b
BEGIN;
SELECT bono_desempeno('EMP-01') = 420000 AS caso_alto;
SELECT bono_desempeno('EMP-02') = 175000 AS caso_bajo;
UPDATE empleado SET calificacion = NULL WHERE id_empleado = 'EMP-01';
SELECT bono_desempeno('EMP-01') = 0 AS caso_nulo;
SELECT bono_desempeno('EMP-99') IS NULL AS caso_ausente;
ROLLBACK;
```

Los cuatro resultados deben ser TRUE. Para comprobar NULL se usa IS NULL, no `= NULL`. ROLLBACK restaura la calificación original; una prueba no debe alterar la entrada de la siguiente de forma oculta.

</details>

**Autoevaluación:** ¿qué ocurre con INTO sin STRICT y cero filas? Variables nulas y FOUND en FALSE. ¿Por qué no capturar todo con OTHERS? Podría ocultar errores imprevistos. ¿Una excepción manejada revierte toda la transacción externa? No necesariamente: se revierten los cambios del bloque protegido que falló, y el manejador puede permitir continuar. Para volver a propagar el error se usa `RAISE;` dentro del manejador.

**Criterio de logro:** registrar entrada, resultado esperado y observado para cada caso. Continúa con [triggers](triggers.md).

Referencia de consulta: [documentación oficial de PostgreSQL](https://www.postgresql.org/docs/18/plpgsql-control-structures.html).

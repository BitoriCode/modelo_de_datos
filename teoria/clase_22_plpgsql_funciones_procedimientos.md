# Clase 22 — PL/pgSQL: funciones y procedimientos almacenados
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**
**Herramienta:** PostgreSQL + pgAdmin

---


## Base de datos de referencia — StaffHub

```
DEPARTAMENTO (id_departamento, nombre, ciudad, presupuesto_anual)
EMPLEADO     (id_empleado, nombre, email, fecha_ingreso, salario_cop,
              calificacion NUMERIC(3,1), id_departamento FK)
CARGO        (id_empleado FK, titulo, nivel: 'junior' | 'senior' | 'lead')
```

---

## 1. ¿Qué es PL/pgSQL?

**PL/pgSQL** (Procedural Language / PostgreSQL) es el lenguaje procedimental nativo de PostgreSQL. Extiende SQL añadiendo estructuras de programación: variables, condicionales, bucles y manejo de errores.

### SQL vs. PL/pgSQL

| | SQL puro | PL/pgSQL |
|-|----------|----------|
| **Estilo** | Declarativo: describe *qué* quieres | Imperativo: describe *cómo* obtenerlo paso a paso |
| **Variables** | No | Sí — `DECLARE v_total INT;` |
| **Condicionales** | Solo en expresiones (`CASE`) | `IF / ELSIF / ELSE` completo |
| **Bucles** | No | `LOOP`, `WHILE`, `FOR` |
| **Manejo de errores** | No | `BEGIN ... EXCEPTION ... END` |
| **Reutilización** | Copiar y pegar | Guardar como función con nombre |

### ¿Por qué usarlo?

- Encapsular lógica compleja que se repite en múltiples consultas.
- Implementar reglas de negocio directamente en la base de datos.
- Ejecutar múltiples operaciones DML como una unidad atómica.
- Calcular resultados que dependen de lógica condicional o iterativa.

---

## 2. Bloques anónimos — `DO`

El bloque `DO` ejecuta código PL/pgSQL sin crear ningún objeto en la base de datos. Es útil para probar lógica rápidamente.

### Estructura

```sql
DO $$
DECLARE
    -- declaración de variables (opcional)
    nombre_variable TIPO := valor_inicial;
BEGIN
    -- código ejecutable
END;
$$;
```

- `$$` es el delimitador de la cadena que contiene el código. Se puede usar también `$cuerpo$` o cualquier par de `$etiqueta$`.
- `DECLARE` es opcional — solo se escribe si hay variables.
- Todo el código ejecutable va entre `BEGIN` y `END`.
- Cada instrucción termina en `;`.

### Ejemplo básico

```sql
DO $$
DECLARE
    v_mensaje TEXT := 'Hola desde PL/pgSQL';
BEGIN
    RAISE NOTICE '%', v_mensaje;
END;
$$;
-- Salida: NOTICE:  Hola desde PL/pgSQL
```

`RAISE NOTICE` imprime un mensaje en la consola de pgAdmin (pestaña "Messages"). Es el equivalente a `print()` o `console.log()`.

---

## 3. Variables y tipos de datos

### Declaración de variables

```sql
DECLARE
    v_nombre      TEXT;                   -- sin valor inicial (es NULL)
    v_contador    INT       := 0;         -- con valor inicial
    v_salario     NUMERIC   := 3500000;
    v_activo      BOOLEAN   := TRUE;
    v_fecha       DATE      := CURRENT_DATE;
    v_constante   CONSTANT INT := 100;   -- no se puede modificar
```

Convención: prefijo `v_` para variables locales.

### Tipos especiales de PL/pgSQL

**`%TYPE`** — hereda el tipo de una columna de tabla. Si la columna cambia de tipo, la variable se adapta automáticamente:

```sql
DECLARE
    v_nombre   empleado.nombre%TYPE;        -- mismo tipo que empleado.nombre (TEXT)
    v_salario  empleado.salario_cop%TYPE;   -- mismo tipo que salario_cop (INT)
```

**`%ROWTYPE`** — hereda la estructura completa de una fila de tabla:

```sql
DECLARE
    v_fila  empleado%ROWTYPE;   -- una variable que representa una fila entera
BEGIN
    SELECT * INTO v_fila FROM empleado WHERE id_empleado = 'EMP-01';
    RAISE NOTICE 'Nombre: %, Salario: %', v_fila.nombre, v_fila.salario_cop;
END;
```

**`RECORD`** — similar a `%ROWTYPE` pero sin estructura fija; se adapta a lo que reciba:

```sql
DECLARE
    v_reg RECORD;
BEGIN
    SELECT nombre, salario_cop INTO v_reg FROM empleado WHERE id_empleado = 'EMP-01';
    RAISE NOTICE '%', v_reg.nombre;
END;
```

### Asignación de valores

```sql
-- Con := (asignación directa)
v_contador := v_contador + 1;
v_nombre   := 'Ana Torres';

-- Con SELECT INTO (resultado de una consulta)
SELECT nombre INTO v_nombre FROM empleado WHERE id_empleado = 'EMP-01';
SELECT COUNT(*) INTO v_contador FROM empleado WHERE id_departamento = 1;
```

---

## 4. Condicionales — `IF / ELSIF / ELSE`

```sql
IF condición THEN
    -- instrucciones
ELSIF otra_condición THEN
    -- instrucciones
ELSE
    -- instrucciones
END IF;
```

### Ejemplo — categorizar un salario

```sql
DO $$
DECLARE
    v_salario  INT;
    v_categoria TEXT;
BEGIN
    SELECT salario_cop INTO v_salario
    FROM empleado WHERE id_empleado = 'EMP-08';

    IF v_salario >= 5000000 THEN
        v_categoria := 'Alto';
    ELSIF v_salario >= 3000000 THEN
        v_categoria := 'Medio';
    ELSE
        v_categoria := 'Básico';
    END IF;

    RAISE NOTICE 'Salario: % → Categoría: %', v_salario, v_categoria;
END;
$$;
-- Salida: NOTICE:  Salario: 6200000 → Categoría: Alto
```

### Diferencia con `CASE`

`CASE` es una expresión SQL (devuelve un valor en un `SELECT`). `IF` es una instrucción PL/pgSQL (ejecuta código). No son intercambiables:

```sql
-- CASE: dentro de un SELECT
SELECT nombre,
       CASE WHEN salario_cop >= 5000000 THEN 'Alto' ELSE 'Básico' END AS categoria
FROM empleado;

-- IF: dentro de un bloque PL/pgSQL
IF v_salario >= 5000000 THEN
    v_categoria := 'Alto';
END IF;
```

---

## 5. Bucles

### 5.1 `LOOP` — bucle infinito con salida explícita

```sql
DO $$
DECLARE
    v_i INT := 1;
BEGIN
    LOOP
        RAISE NOTICE 'Iteración %', v_i;
        v_i := v_i + 1;
        EXIT WHEN v_i > 3;    -- condición de salida
    END LOOP;
END;
$$;
-- NOTICE: Iteración 1
-- NOTICE: Iteración 2
-- NOTICE: Iteración 3
```

### 5.2 `WHILE` — mientras se cumpla una condición

```sql
DO $$
DECLARE
    v_i INT := 1;
BEGIN
    WHILE v_i <= 3 LOOP
        RAISE NOTICE 'Iteración %', v_i;
        v_i := v_i + 1;
    END LOOP;
END;
$$;
-- Mismo resultado que el LOOP anterior
```

### 5.3 `FOR` sobre un rango numérico

```sql
DO $$
BEGIN
    FOR i IN 1..5 LOOP
        RAISE NOTICE 'Número: %', i;
    END LOOP;
END;
$$;
-- NOTICE: Número: 1  ...  NOTICE: Número: 5

-- Recorrido inverso
FOR i IN REVERSE 5..1 LOOP ...
-- Con paso diferente a 1
FOR i IN 1..10 BY 2 LOOP ...   -- 1, 3, 5, 7, 9
```

### 5.4 `FOR` sobre el resultado de una consulta

Es el más útil: itera fila a fila sobre el resultado de un `SELECT`:

```sql
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        SELECT nombre, salario_cop
        FROM empleado
        WHERE id_departamento = 1
        ORDER BY salario_cop DESC
    LOOP
        RAISE NOTICE '% → $%', v_rec.nombre, v_rec.salario_cop;
    END LOOP;
END;
$$;
-- NOTICE: Diana Leal → $5800000
-- NOTICE: Ana Torres → $4200000
-- NOTICE: Carlos Ruiz → $3500000
```

---

## 6. Funciones — `CREATE FUNCTION`

Una función guarda un bloque PL/pgSQL con un nombre, parámetros de entrada y un tipo de retorno. Se puede llamar desde cualquier consulta SQL.

### Estructura

```sql
CREATE OR REPLACE FUNCTION nombre_funcion(
    param1 TIPO,
    param2 TIPO
)
RETURNS tipo_retorno
LANGUAGE plpgsql
AS $$
DECLARE
    -- variables locales
BEGIN
    -- código
    RETURN valor;
END;
$$;
```

- `CREATE OR REPLACE` — crea la función o la reemplaza si ya existe (equivalente a OR REPLACE en vistas).
- `RETURNS` — tipo del valor que devuelve (`INT`, `TEXT`, `BOOLEAN`, `TABLE(...)`, etc.).
- `LANGUAGE plpgsql` — indica que el cuerpo está escrito en PL/pgSQL.
- `RETURN` — termina la función y devuelve el valor.

### Ejemplo 1 — función escalar (devuelve un valor)

```sql
-- Función que calcula los años de antigüedad de un empleado
CREATE OR REPLACE FUNCTION calcular_anos(p_id_empleado VARCHAR)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_fecha_ingreso DATE;
    v_anos          INT;
BEGIN
    SELECT fecha_ingreso INTO v_fecha_ingreso
    FROM empleado
    WHERE id_empleado = p_id_empleado;

    IF NOT FOUND THEN
        RETURN NULL;    -- el empleado no existe
    END IF;

    v_anos := DATE_PART('year', AGE(CURRENT_DATE, v_fecha_ingreso))::INT;
    RETURN v_anos;
END;
$$;
```

```sql
-- Llamar la función desde un SELECT
SELECT nombre, calcular_anos(id_empleado) AS anos_en_empresa
FROM empleado
ORDER BY anos_en_empresa DESC;

-- O directamente
SELECT calcular_anos('EMP-01');   -- 7
```

### Ejemplo 2 — función con lógica de negocio

```sql
-- Función que calcula el bono según la antigüedad
CREATE OR REPLACE FUNCTION calcular_bono(p_id_empleado VARCHAR)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_salario INT;
    v_anos    INT;
    v_pct     NUMERIC;
BEGIN
    SELECT salario_cop INTO v_salario
    FROM empleado WHERE id_empleado = p_id_empleado;

    v_anos := calcular_anos(p_id_empleado);   -- llama a la función anterior

    IF v_anos >= 7 THEN
        v_pct := 0.15;
    ELSIF v_anos >= 4 THEN
        v_pct := 0.10;
    ELSE
        v_pct := 0.05;
    END IF;

    RETURN ROUND(v_salario * v_pct);
END;
$$;
```

```sql
SELECT nombre,
       salario_cop,
       calcular_anos(id_empleado)  AS anos,
       calcular_bono(id_empleado)  AS bono_cop
FROM empleado
ORDER BY bono_cop DESC;
```

### Ejemplo 3 — función que devuelve texto

```sql
CREATE OR REPLACE FUNCTION etiqueta_empleado(p_id VARCHAR)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_rec RECORD;
BEGIN
    SELECT e.nombre, d.nombre AS depto, c.titulo, c.nivel
    INTO v_rec
    FROM empleado e
    LEFT JOIN departamento d ON e.id_departamento = d.id_departamento
    JOIN cargo c ON e.id_empleado = c.id_empleado
    WHERE e.id_empleado = p_id;

    IF NOT FOUND THEN
        RETURN 'Empleado no encontrado';
    END IF;

    RETURN v_rec.nombre
        || ' | ' || COALESCE(v_rec.depto, 'Sin departamento')
        || ' | ' || v_rec.titulo
        || ' (' || v_rec.nivel || ')';
END;
$$;
```

```sql
SELECT etiqueta_empleado('EMP-03');
-- 'Diana Leal | Tecnología | Arquitecta de Software (lead)'

SELECT id_empleado, etiqueta_empleado(id_empleado) AS etiqueta
FROM empleado;
```

### Ejemplo 4 — función que devuelve una tabla (`RETURNS TABLE`)

```sql
CREATE OR REPLACE FUNCTION empleados_por_depto(p_id_depto INT)
RETURNS TABLE(
    id_empleado  VARCHAR,
    nombre       TEXT,
    titulo       TEXT,
    nivel        TEXT,
    salario_cop  INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT e.id_empleado,
               e.nombre,
               c.titulo,
               c.nivel,
               e.salario_cop
        FROM empleado e
        JOIN cargo c ON e.id_empleado = c.id_empleado
        WHERE e.id_departamento = p_id_depto
        ORDER BY e.salario_cop DESC;
END;
$$;
```

```sql
-- Llamar como si fuera una tabla
SELECT * FROM empleados_por_depto(1);   -- Tecnología
SELECT * FROM empleados_por_depto(3);   -- Finanzas

-- Incluso con filtros adicionales
SELECT nombre, salario_cop
FROM empleados_por_depto(1)
WHERE nivel = 'senior';
```

### Parámetros con valor por defecto

```sql
CREATE OR REPLACE FUNCTION resumen_depto(
    p_id_depto INT,
    p_incluir_sin_nivel BOOLEAN DEFAULT FALSE
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INT;
    v_promedio INT;
BEGIN
    SELECT COUNT(*), ROUND(AVG(salario_cop))
    INTO v_total, v_promedio
    FROM empleado
    WHERE id_departamento = p_id_depto;

    RETURN 'Empleados: ' || v_total || ' | Salario promedio: $' || v_promedio;
END;
$$;

SELECT resumen_depto(1);            -- usa el valor por defecto de p_incluir_sin_nivel
SELECT resumen_depto(1, TRUE);      -- pasa el valor explícito
```

### Ver y eliminar funciones

```sql
-- Ver funciones definidas por el usuario
SELECT routine_name, data_type AS tipo_retorno
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type   = 'FUNCTION'
ORDER BY routine_name;

-- Eliminar una función
DROP FUNCTION calcular_anos(VARCHAR);
DROP FUNCTION IF EXISTS calcular_anos(VARCHAR);
```

---

## 7. Procedimientos — `CREATE PROCEDURE`

Un procedimiento es similar a una función pero **no devuelve un valor**. Se usa para operaciones que modifican datos (INSERT, UPDATE, DELETE) o que ejecutan acciones complejas. Se invoca con `CALL`, no con `SELECT`.

### Estructura

```sql
CREATE OR REPLACE PROCEDURE nombre_procedimiento(
    param1 TIPO,
    param2 TIPO
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- variables locales
BEGIN
    -- código con INSERT, UPDATE, DELETE, etc.
    -- NO hay RETURN con valor
END;
$$;
```

### Diferencias clave con funciones

| | Función | Procedimiento |
|-|---------|---------------|
| Devuelve valor | Sí — `RETURN valor` | No |
| Se llama con | `SELECT funcion()` | `CALL procedimiento()` |
| Puede usar en `WHERE` | Sí | No |
| Controla transacciones | No (`COMMIT`/`ROLLBACK` no permitidos) | Sí |
| Cuándo usarlo | Calcular y devolver | Ejecutar acciones |

### Ejemplo 1 — procedimiento de actualización masiva

```sql
-- Procedimiento que aplica un aumento de salario a un departamento
CREATE OR REPLACE PROCEDURE aplicar_aumento(
    p_id_depto INT,
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

    GET DIAGNOSTICS v_afectados = ROW_COUNT;   -- cuántas filas modificó el UPDATE

    RAISE NOTICE 'Aumento del %% aplicado a % empleados del departamento %',
                 p_porcentaje, v_afectados, p_id_depto;
END;
$$;
```

```sql
-- Llamar con CALL
CALL aplicar_aumento(1, 5.0);    -- 5% de aumento al depto de Tecnología
-- NOTICE: Aumento del 5% aplicado a 3 empleados del departamento 1

CALL aplicar_aumento(2, 8.5);    -- 8.5% a Marketing
```

### Ejemplo 2 — procedimiento con validación

```sql
CREATE OR REPLACE PROCEDURE transferir_empleado(
    p_id_empleado  VARCHAR,
    p_nuevo_depto  INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existe_depto BOOLEAN;
    v_existe_emp   BOOLEAN;
BEGIN
    -- Validar que el departamento existe
    SELECT EXISTS (
        SELECT 1 FROM departamento WHERE id_departamento = p_nuevo_depto
    ) INTO v_existe_depto;

    IF NOT v_existe_depto THEN
        RAISE EXCEPTION 'El departamento % no existe', p_nuevo_depto;
    END IF;

    -- Validar que el empleado existe
    SELECT EXISTS (
        SELECT 1 FROM empleado WHERE id_empleado = p_id_empleado
    ) INTO v_existe_emp;

    IF NOT v_existe_emp THEN
        RAISE EXCEPTION 'El empleado % no existe', p_id_empleado;
    END IF;

    -- Realizar la transferencia
    UPDATE empleado
    SET id_departamento = p_nuevo_depto
    WHERE id_empleado = p_id_empleado;

    RAISE NOTICE 'Empleado % transferido al departamento %',
                 p_id_empleado, p_nuevo_depto;
END;
$$;
```

```sql
CALL transferir_empleado('EMP-11', 2);     -- transfiere a Marketing
CALL transferir_empleado('EMP-11', 99);    -- ERROR: El departamento 99 no existe
```

---

## 8. Manejo de errores — `EXCEPTION`

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
| `NO_DATA_FOUND` | `SELECT INTO` no encontró ninguna fila |
| `TOO_MANY_ROWS` | `SELECT INTO` encontró más de una fila |
| `DIVISION_BY_ZERO` | División entre cero |
| `UNIQUE_VIOLATION` | Insertar un valor duplicado en una columna UNIQUE |
| `FOREIGN_KEY_VIOLATION` | Violar una restricción de FK |
| `OTHERS` | Captura cualquier error no listado |

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

## 9. `RAISE` — mensajes y errores

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

## 10. `FOUND` y `NOT FOUND`

`FOUND` es una variable especial de PL/pgSQL que indica si la última instrucción encontró o modificó filas:

```sql
-- Después de SELECT INTO: TRUE si encontró una fila, FALSE si no
SELECT nombre INTO v_nombre FROM empleado WHERE id_empleado = p_id;
IF NOT FOUND THEN
    RAISE EXCEPTION 'Empleado no existe';
END IF;

-- Después de UPDATE/DELETE: TRUE si afectó al menos una fila
UPDATE empleado SET salario_cop = 5000000 WHERE id_empleado = 'EMP-99';
IF NOT FOUND THEN
    RAISE NOTICE 'No se encontró el empleado a actualizar';
END IF;

-- Después de FOR ... LOOP: TRUE si el loop ejecutó al menos una iteración
FOR v_rec IN SELECT * FROM empleado WHERE id_departamento = 99 LOOP
    -- ...
END LOOP;
IF NOT FOUND THEN
    RAISE NOTICE 'El departamento no tiene empleados';
END IF;
```

---

## 11. Permisos sobre funciones y procedimientos

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

## 12. Referencia rápida — estructura general

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

## 13. Errores frecuentes

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

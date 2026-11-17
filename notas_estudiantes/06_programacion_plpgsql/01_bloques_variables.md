# PL/pgSQL I — Bloques, variables y consultas

[Índice de notas](../README.md) · [Ruta de estudio](../ruta_estudio_programacion.md)

## Antes de empezar

**Sesión de referencia:** S25, 100 minutos. **Conocimientos previos:** SELECT, tipos de datos y filtros.

**Al finalizar podrás:** Escribir un bloque DO, capturar una consulta con SELECT INTO y distinguir una fila ausente de un valor nulo.

Carga [StaffHub](../recursos/datasets/staffhub_setup.sql) en una base de práctica siguiendo las [instrucciones de preparación](../recursos/datasets/README.md). Antes de cada práctica autónoma restaura el dataset para partir de los mismos datos: 4 departamentos, 12 empleados y 12 cargos. El setup no elimina todas las rutinas o tablas auxiliares.

**Núcleo de la sesión:** 1–3; FOUND tras SELECT INTO. RECORD y ROWTYPE son referencia de ampliación.

Distingue bloques completos (`DO ... $$;` o `CREATE ... $$;`) de fragmentos como DECLARE o IF aislados. Las plantillas con TIPO, tabla o puntos suspensivos y los errores intencionados no se ejecutan como scripts completos.

[Ir a la práctica autónoma](#práctica-de-la-sesión).

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
| **Reutilización** | Consultas, vistas y funciones SQL | Rutinas con lógica procedimental |

### ¿Por qué usarlo?

- Encapsular lógica compleja que se repite en múltiples consultas.
- Implementar reglas de negocio directamente en la base de datos.
- Ejecutar múltiples operaciones DML como una unidad atómica.
- Calcular resultados que dependen de lógica condicional o iterativa.

---

## 2. Bloques anónimos — `DO`

El bloque `DO` ejecuta código PL/pgSQL sin guardar una función o procedimiento con nombre. Puede crear objetos o modificar datos si su cuerpo contiene esas instrucciones. Es útil para probar lógica rápidamente.

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
    v_nombre   empleado.nombre%TYPE;        -- mismo tipo que empleado.nombre (VARCHAR)
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

## 4. `FOUND` y `NOT FOUND`

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

## Práctica de la sesión

Dedica 25 minutos al bloque DO básico y SELECT INTO, 25 a reproducirlo, 30 a los retos y 10 al cierre; reserva los primeros 10 para recordar SELECT y tipos.

**Reto A.** Captura el nombre de EMP-01 en una variable declarada con `%TYPE`. Muestra el nombre y FOUND. Repite con EMP-99: ¿cómo cambia cada valor?

**Reto B.** Captura con una sola consulta la cantidad de empleados y el salario promedio del departamento 1. No escribas valores calculados a mano.

<details>
<summary>Soluciones razonadas</summary>

```sql
-- practica_s25_a
DO $$
DECLARE
    v_nombre empleado.nombre%TYPE;
BEGIN
    SELECT nombre INTO v_nombre FROM empleado WHERE id_empleado = 'EMP-01';
    RAISE NOTICE 'Nombre: %, encontrado: %', v_nombre, FOUND;
    SELECT nombre INTO v_nombre FROM empleado WHERE id_empleado = 'EMP-99';
    RAISE NOTICE 'Nombre: %, encontrado: %', v_nombre, FOUND;
END;
$$;
```

Primero aparece Ana Torres y TRUE; después NULL y FALSE. Declarar la variable con `%TYPE` evita repetir el tipo de la columna. FOUND se consulta inmediatamente después del SELECT que interesa.

```sql
-- practica_s25_b
DO $$
DECLARE
    v_total BIGINT;
    v_promedio NUMERIC;
BEGIN
    SELECT COUNT(*), AVG(salario_cop) INTO v_total, v_promedio
    FROM empleado WHERE id_departamento = 1;
    RAISE NOTICE 'Personas: %, promedio: %', v_total, v_promedio;
END;
$$;
```

Esperado: 3 personas y promedio 4500000. COUNT sin GROUP BY produce una fila incluso si no hay coincidencias: en un departamento vacío el total sería 0 y el promedio NULL. FOUND no sirve por sí solo para distinguir esos grupos vacíos.

</details>

**Autoevaluación:** ¿DECLARE es obligatorio sin variables? No. ¿DO guarda una rutina con nombre? No, pero su cuerpo puede modificar datos. ¿Un nombre NULL prueba que no existe la persona? No: conviene comprobar FOUND; otras columnas sí podrían admitir NULL.

**Criterio de logro:** escribir el bloque sin copiar la solución y explicar los dos resultados. Continúa con [control de flujo](02_control_flujo.md).

Referencia de consulta: [documentación oficial de PostgreSQL](https://www.postgresql.org/docs/18/plpgsql-statements.html).

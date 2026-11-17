# PL/pgSQL III — Funciones y valores de retorno

[Índice de notas](../README.md) · [Ruta de estudio](../ruta_estudio_programacion.md)

## Antes de empezar

**Sesión de referencia:** S27, 100 minutos. **Conocimientos previos:** Bloques, control de flujo, JOIN y agregación.

**Al finalizar podrás:** Crear una función escalar y una tabular, usar parámetros y comprobar retornos nulos.

Carga [StaffHub](../recursos/datasets/staffhub_setup.sql) en una base de práctica siguiendo las [instrucciones de preparación](../recursos/datasets/README.md). Antes de cada práctica autónoma restaura el dataset para partir de los mismos datos: 4 departamentos, 12 empleados y 12 cargos. El setup no elimina todas las rutinas o tablas auxiliares.

**Núcleo de la sesión:** Un retorno escalar y RETURNS TABLE. Los ejemplos adicionales se consultan después de la práctica.

Distingue bloques completos (`DO ... $$;` o `CREATE ... $$;`) de fragmentos como DECLARE o IF aislados. Las plantillas con TIPO, tabla o puntos suspensivos y los errores intencionados no se ejecutan como scripts completos.

[Ir a la práctica autónoma](#práctica-de-la-sesión).

## 1. Funciones — `CREATE FUNCTION`

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
               e.nombre::TEXT,
               c.titulo::TEXT,
               c.nivel::TEXT,
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
    p_mostrar_promedio BOOLEAN DEFAULT TRUE
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

    IF p_mostrar_promedio THEN
        RETURN 'Empleados: ' || v_total || ' | Salario promedio: $'
            || COALESCE(v_promedio::TEXT, 'sin datos');
    END IF;
    RETURN 'Empleados: ' || v_total;
END;
$$;

SELECT resumen_depto(1);            -- usa el valor por defecto de p_mostrar_promedio
SELECT resumen_depto(1, FALSE);      -- pasa el valor explícito
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

## Práctica de la sesión

Distribución: 10 minutos de repaso, 25 de explicación, 25 de escritura guiada, 30 de retos y 10 de revisión. Crea primero la función escalar y luego una tabular; el catálogo de ejemplos restante sirve de ampliación.

**Reto A.** Escribe `bono_desempeno(p_id VARCHAR)`: devuelve 10% del salario para calificación desde 4.5, 5% para las demás calificaciones y 0 para una persona sin evaluar. Si no existe, devuelve NULL. Redondea a pesos enteros.

**Reto B.** Crea `personal_sin_departamento()` con id VARCHAR y nombre TEXT. Devuelve las personas sin departamento, ordenadas por id. Prueba el resultado como tabla.

<details>
<summary>Soluciones razonadas</summary>

```sql
-- practica_s27_a
CREATE OR REPLACE FUNCTION bono_desempeno(p_id VARCHAR)
RETURNS INT LANGUAGE plpgsql AS $$
DECLARE
    v_salario INT;
    v_cal NUMERIC;
BEGIN
    SELECT salario_cop, calificacion INTO v_salario, v_cal
    FROM empleado WHERE id_empleado = p_id;
    IF NOT FOUND THEN RETURN NULL; END IF;
    IF v_cal IS NULL THEN RETURN 0;
    ELSIF v_cal >= 4.5 THEN RETURN ROUND(v_salario * 0.10);
    ELSE RETURN ROUND(v_salario * 0.05);
    END IF;
END;
$$;
SELECT bono_desempeno('EMP-01'), bono_desempeno('EMP-02'), bono_desempeno('EMP-99');
```

Esperado: 420000, 175000 y NULL. Se documentan resultados distintos para «sin evaluar» y «no existe»; NULL no se convierte arbitrariamente en una calificación baja.

```sql
-- practica_s27_b
CREATE OR REPLACE FUNCTION personal_sin_departamento()
RETURNS TABLE (id_empleado VARCHAR, nombre TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT e.id_empleado, e.nombre::TEXT
    FROM empleado e WHERE e.id_departamento IS NULL ORDER BY e.id_empleado;
END;
$$;
SELECT * FROM personal_sin_departamento();
```

Esperado: EMP-11 Laura Medina y EMP-12 Manuel Torres. El alias evita ambigüedad con los nombres de salida, y el cast hace coincidir el VARCHAR de la tabla con TEXT declarado. RETURN QUERY agrega las filas del resultado; no se escribe RETURN SELECT.

</details>

**Autoevaluación:** ¿cómo invocas la función escalar? SELECT. ¿Qué declara RETURNS? El tipo del resultado. ¿CREATE OR REPLACE permite cambiar libremente el tipo de retorno? No: para cambiar la firma de retorno hay que revisar dependencias y recrear la función de forma controlada.

**Criterio de logro:** ambas funciones deben funcionar con datos normales, NULL y ausencia. Continúa con [procedimientos](04_procedimientos.md).

Referencia de consulta: [documentación oficial de PostgreSQL](https://www.postgresql.org/docs/18/plpgsql-control-structures.html).

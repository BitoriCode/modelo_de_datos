# PL/pgSQL II — Condicionales y ciclos

[Índice de notas](../README.md) · [Ruta de estudio](../ruta_estudio_programacion.md)

## Antes de empezar

**Sesión de referencia:** S26, 100 minutos. **Conocimientos previos:** Bloques, variables y FOUND.

**Al finalizar podrás:** Resolver decisiones con IF y recorrer resultados con FOR; justificar cuándo conviene una operación por conjuntos.

Carga [StaffHub](../recursos/datasets/staffhub_setup.sql) en una base de práctica siguiendo las [instrucciones de preparación](../recursos/datasets/README.md). Antes de cada práctica autónoma restaura el dataset para partir de los mismos datos: 4 departamentos, 12 empleados y 12 cargos. El setup no elimina todas las rutinas o tablas auxiliares.

**Núcleo de la sesión:** IF/ELSIF/ELSE y FOR sobre consulta; LOOP, WHILE y variantes numéricas como referencia.

Distingue bloques completos (`DO ... $$;` o `CREATE ... $$;`) de fragmentos como DECLARE o IF aislados. Las plantillas con TIPO, tabla o puntos suspensivos y los errores intencionados no se ejecutan como scripts completos.

[Ir a la práctica autónoma](#práctica-de-la-sesión).

## 1. Condicionales — `IF / ELSIF / ELSE`

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

## 2. Bucles

### 2.1 `LOOP` — bucle infinito con salida explícita

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

### 2.2 `WHILE` — mientras se cumpla una condición

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

### 2.3 `FOR` sobre un rango numérico

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

### 2.4 `FOR` sobre el resultado de una consulta

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

## Práctica de la sesión

Usa 10 minutos para recuperar variables y FOUND, 25 para IF/FOR, 25 para práctica guiada, 30 para retos y 10 para comparar decisiones. Los bucles numéricos adicionales se conservan como consulta.

**Reto A.** Clasifica la calificación de EMP-01: NULL → Sin evaluar; desde 4.5 → Destacado; desde 3.5 → Satisfactorio; el resto → En desarrollo. Distingue una persona inexistente de una calificación NULL.

**Reto B.** Recorre los salarios del departamento 2 y calcula su suma sin actualizarlos. Resuelve después lo mismo con SUM. ¿Cuál usarías si solo necesitas el total?

<details>
<summary>Soluciones razonadas</summary>

```sql
-- practica_s26_a
DO $$
DECLARE
    v_cal empleado.calificacion%TYPE;
    v_categoria TEXT;
BEGIN
    SELECT calificacion INTO v_cal FROM empleado WHERE id_empleado = 'EMP-01';
    IF NOT FOUND THEN v_categoria := 'Empleado inexistente';
    ELSIF v_cal IS NULL THEN v_categoria := 'Sin evaluar';
    ELSIF v_cal >= 4.5 THEN v_categoria := 'Destacado';
    ELSIF v_cal >= 3.5 THEN v_categoria := 'Satisfactorio';
    ELSE v_categoria := 'En desarrollo';
    END IF;
    RAISE NOTICE '%', v_categoria;
END;
$$;
```

Esperado: Destacado. Se comprueba ausencia antes de clasificar; una comparación con NULL no es TRUE y podría conducir indebidamente al ELSE si faltara la comprobación IS NULL.

```sql
-- practica_s26_b
DO $$
DECLARE
    v_fila RECORD;
    v_total BIGINT := 0;
BEGIN
    FOR v_fila IN SELECT salario_cop FROM empleado WHERE id_departamento = 2 LOOP
        v_total := v_total + v_fila.salario_cop;
    END LOOP;
    RAISE NOTICE 'Total: %', v_total;
END;
$$;
SELECT COALESCE(SUM(salario_cop), 0) AS total
FROM empleado WHERE id_departamento = 2;
```

Ambas soluciones producen 5500000. Si solo se necesita el total, SUM expresa directamente la operación por conjuntos. FOR es útil para practicar o cuando cada fila exige acciones procedimentales justificadas; no debe sustituir automáticamente cada consulta agregada.

</details>

**Autoevaluación:** ¿por qué inicializar el acumulador? NULL más un número sigue siendo NULL. ¿Cómo termina WHILE? Su condición debe llegar a FALSE. ¿Por qué ordenar un FOR? Solo cuando la lógica necesita un orden; sin ORDER BY no hay uno garantizado.

**Criterio de logro:** manejar NULL, ausencia y ramas de decisión, y justificar el uso o descarte del ciclo. Continúa con [funciones](03_funciones.md).

Referencia de consulta: [documentación oficial de PostgreSQL](https://www.postgresql.org/docs/18/plpgsql-control-structures.html).

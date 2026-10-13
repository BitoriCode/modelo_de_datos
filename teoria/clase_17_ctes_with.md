# Clase 17 — CTEs: Common Table Expressions (`WITH`)
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**
**Herramienta:** PostgreSQL + pgAdmin
---

## Base de datos de la clase — CinePlay

```
GENERO       (id_genero, nombre)
PLAN         (id_plan, nombre_plan, precio_mes)
PELICULA     (id_pelicula, titulo, anio, duracion_min, id_genero FK)
USUARIO      (id_usuario, nombre, email, id_plan FK — puede ser NULL)
REPRODUCCION (id_rep SERIAL PK, id_usuario FK, id_pelicula FK,
              fecha_rep, completada)
```

Datos clave:
- **6 géneros**, **3 planes** (Básico / Estándar / Premium), **12 películas**, **10 usuarios**, **25 reproducciones**.
- **USR-010 Juliana Toro** tiene plan Estándar pero **ninguna reproducción**.
- **USR-007 y USR-008** no tienen plan activo (`id_plan IS NULL`).
- Películas de Acción y Ciencia ficción son las más reproducidas.

---

## ¿Por qué existen los CTEs?

En la clase 19 aprendieron que una subconsulta puede ir en el `FROM` para actuar como tabla temporal. El problema aparece cuando la lógica se vuelve compleja y hay que anidar varios niveles:

```sql
-- ❌ Difícil de leer: subconsultas anidadas dentro de subconsultas
SELECT nombre, total
FROM (
    SELECT u.nombre, COUNT(r.id_rep) AS total
    FROM usuario u
    LEFT JOIN reproduccion r ON u.id_usuario = r.id_usuario
    GROUP BY u.id_usuario, u.nombre
) AS resumen
WHERE total >= 3;
```

```sql
-- ✓ Con CTE: misma lógica, separada y nombrada
WITH resumen AS (
    SELECT u.nombre, COUNT(r.id_rep) AS total
    FROM usuario u
    LEFT JOIN reproduccion r ON u.id_usuario = r.id_usuario
    GROUP BY u.id_usuario, u.nombre
)
SELECT nombre, total
FROM resumen
WHERE total >= 3;
```

Ambas consultas producen **el mismo resultado**. La diferencia es legibilidad y mantenibilidad.

> **CTE** (Common Table Expression) es una subconsulta con nombre que se define antes de la consulta principal. Es como declarar una variable en programación: nombras el concepto una vez y lo usas donde lo necesites.

---

## 1. CTE básico — `WITH nombre AS (...)`

### 1.1 Estructura

```
WITH  nombre_cte  AS  (
    SELECT ...       ← cualquier consulta válida: SELECT, JOIN, GROUP BY, etc.
)
SELECT ...
FROM  nombre_cte
WHERE ...;
```

Reglas importantes:
- El CTE se escribe **antes** del `SELECT` principal.
- Existe **solo durante esa consulta** — no se guarda en la base de datos.
- Se comporta como una tabla temporal con nombre.

### 1.2 Cuándo usar un CTE en lugar de una subconsulta en FROM

| Situación | Recomendación |
|-----------|---------------|
| Subconsulta simple, usada una sola vez | Subconsulta en `FROM` es suficiente |
| Lógica compleja que quieres nombrar | CTE — le da un nombre al concepto |
| Necesitas reutilizar el mismo resultado en varias partes | CTE — evita repetir código |
| El código lo va a leer alguien más | CTE — autodocumenta la intención |

### 1.3 Ejemplos con CinePlay

**Ejemplo 1 — usuarios con 3 o más reproducciones:**
```sql
WITH resumen AS (
    SELECT u.id_usuario, u.nombre, COUNT(r.id_rep) AS total
    FROM usuario u
    LEFT JOIN reproduccion r ON u.id_usuario = r.id_usuario
    GROUP BY u.id_usuario, u.nombre
)
SELECT id_usuario, nombre, total
FROM resumen
WHERE total >= 3
ORDER BY total DESC;
-- Resultado:
-- USR-001  Andrés Cano    5
-- USR-004  Diana Reyes    5
-- USR-009  Iván Pérez     4
-- USR-002  Beatriz López  3
```

**Ejemplo 2 — usuarios sin ninguna reproducción:**
```sql
WITH activos AS (
    SELECT DISTINCT id_usuario FROM reproduccion
)
SELECT u.id_usuario, u.nombre
FROM usuario u
WHERE u.id_usuario NOT IN (SELECT id_usuario FROM activos);
-- Resultado: USR-010  Juliana Toro
```

**Ejemplo 3 — películas más largas que el promedio:**
```sql
WITH duracion_promedio AS (
    SELECT AVG(duracion_min) AS promedio FROM pelicula
)
SELECT p.titulo, p.duracion_min, g.nombre AS genero
FROM pelicula p
JOIN genero g ON p.id_genero = g.id_genero,
     duracion_promedio
WHERE p.duracion_min > duracion_promedio.promedio
ORDER BY p.duracion_min DESC;
-- promedio ≈ 114.6 min
-- Resultado: Planeta X (155) · Galaxia 7 (145) · Silencio (140) · Entre Montañas (132) · Código Rojo (125) · Velocidad Máxima (118)
```

> En el ejemplo 3, `duracion_promedio` es un CTE que devuelve una sola fila con una sola columna. Se puede usar en el `FROM` sin condición de unión (produce 1 × N = N filas), lo que funciona bien para comparar cada fila contra un valor global.

---

## 2. CTEs encadenados — múltiples bloques `WITH`

Se pueden definir varios CTEs en una misma cláusula `WITH`, separados por coma. Cada CTE puede hacer referencia a los CTEs que se definieron **antes** que él.

### 2.1 Estructura

```
WITH
  cte_1 AS (
      SELECT ...
  ),
  cte_2 AS (
      SELECT ... FROM cte_1 ...   ← puede usar cte_1
  ),
  cte_3 AS (
      SELECT ... FROM cte_2 ...   ← puede usar cte_1 y cte_2
  )
SELECT ...
FROM cte_3;           ← puede usar cualquiera de los CTEs anteriores
```

### 2.2 Ejecución en capas

```
Capa 1: cte_1  →  produce datos crudos o agregados
Capa 2: cte_2  →  transforma o filtra el resultado de cte_1
Capa 3: ...
Consulta final →  usa las capas que necesita
```

### 2.3 Ejemplo — usuarios por encima del promedio de reproducciones

```sql
WITH
repros_por_usuario AS (
    -- Capa 1: contar reproducciones por usuario activo
    SELECT id_usuario, COUNT(*) AS total_repros
    FROM reproduccion
    GROUP BY id_usuario
),
estadisticas AS (
    -- Capa 2: calcular el promedio con los datos de la capa 1
    SELECT ROUND(AVG(total_repros), 2) AS promedio
    FROM repros_por_usuario
)
SELECT u.nombre, u.id_plan, rpu.total_repros, e.promedio
FROM usuario u
JOIN repros_por_usuario rpu ON u.id_usuario = rpu.id_usuario,
     estadisticas e
WHERE rpu.total_repros > e.promedio
ORDER BY rpu.total_repros DESC;
-- promedio = 2.78  (25 reproducciones / 9 usuarios activos)
-- Resultado:
-- Andrés Cano   PLN-3   5   2.78
-- Diana Reyes   PLN-3   5   2.78
-- Iván Pérez    PLN-3   4   2.78
-- Beatriz López PLN-2   3   2.78
```

### 2.4 Ejemplo — géneros con más reproducciones que el promedio de géneros

```sql
WITH
repros_genero AS (
    SELECT g.id_genero, g.nombre, COUNT(r.id_rep) AS total
    FROM genero g
    LEFT JOIN pelicula     p ON g.id_genero    = p.id_genero
    LEFT JOIN reproduccion r ON p.id_pelicula  = r.id_pelicula
    GROUP BY g.id_genero, g.nombre
),
promedio_generos AS (
    SELECT AVG(total) AS promedio FROM repros_genero
)
SELECT rg.nombre AS genero, rg.total, ROUND(pg.promedio, 1) AS promedio
FROM repros_genero rg, promedio_generos pg
WHERE rg.total > pg.promedio
ORDER BY rg.total DESC;
-- promedio ≈ 4.2  (25 reproducciones / 6 géneros)
-- Resultado: Acción (6) · Ciencia ficción (5)
```

---

## 3. CTE recursivo — `WITH RECURSIVE`

Un CTE recursivo es una consulta que **se llama a sí misma**. Se usa cuando los datos tienen estructura jerárquica (jefes/empleados, categorías/subcategorías) o cuando hay que **generar series** (fechas, números).

### 3.1 Estructura obligatoria

```
WITH RECURSIVE nombre AS (
    <caso base>           -- se ejecuta UNA sola vez; genera la primera fila
    UNION ALL
    <paso recursivo>      -- referencia a 'nombre'; debe incluir condición de parada
)
SELECT ... FROM nombre;
```

La ejecución funciona así:
```
Iteración 1:  caso base        → produce fila(s) iniciales
Iteración 2:  paso recursivo   → aplica sobre el resultado anterior
Iteración 3:  paso recursivo   → aplica sobre el resultado de iter. 2
...
Iteración N:  condición de parada falla → se detiene
```

### 3.2 Ejemplo 1 — contador (para entender la mecánica)

```sql
WITH RECURSIVE contador AS (
    SELECT 1 AS n                 -- caso base: primera fila
    UNION ALL
    SELECT n + 1
    FROM contador
    WHERE n < 5                   -- condición de parada: ¡siempre necesaria!
)
SELECT n FROM contador;
-- Resultado: 1  2  3  4  5
```

Traza de ejecución:
```
n = 1  → ¿1 < 5? sí → produce n = 2
n = 2  → ¿2 < 5? sí → produce n = 3
n = 3  → ¿3 < 5? sí → produce n = 4
n = 4  → ¿4 < 5? sí → produce n = 5
n = 5  → ¿5 < 5? NO → se detiene
```

### 3.3 ⚠️ Error más común — olvidar la condición de parada

```sql
-- ❌ Bucle infinito — PostgreSQL lo detiene con error
WITH RECURSIVE infinito AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM infinito  -- sin WHERE → nunca termina
)
SELECT n FROM infinito;
-- ERROR: max recursion depth exceeded
```

### 3.4 Ejemplo 2 — serie de meses con actividad real

```sql
WITH RECURSIVE meses AS (
    SELECT DATE '2024-01-01' AS mes                           -- caso base
    UNION ALL
    SELECT (mes + INTERVAL '1 month')::DATE
    FROM meses
    WHERE mes < DATE '2024-06-01'                            -- 6 iteraciones
)
SELECT TO_CHAR(m.mes, 'Mon YYYY') AS periodo,
       COUNT(r.id_rep)            AS reproducciones
FROM meses m
LEFT JOIN reproduccion r ON DATE_TRUNC('month', r.fecha_rep) = m.mes
GROUP BY m.mes
ORDER BY m.mes;
-- Resultado:
-- Jan 2024   8
-- Feb 2024  10
-- Mar 2024   7
-- Apr 2024   0   ← sin datos, pero aparece gracias al LEFT JOIN
-- May 2024   0
-- Jun 2024   0
```

> El CTE recursivo genera la lista de meses aunque no haya datos en esos meses. El `LEFT JOIN` garantiza que los meses vacíos aparezcan con `0` en lugar de desaparecer del resultado. Esto es **imposible de lograr** con un `GROUP BY` normal sobre la tabla de reproducciones.

### 3.5 Cuándo usar `WITH RECURSIVE`

| Caso de uso | Ejemplo |
|-------------|---------|
| Generar series de números o fechas | Meses del año, rangos de precios |
| Recorrer jerarquías padre-hijo | Empleado → jefe → gerente → director |
| Categorías anidadas | Categoría → subcategoría → subsubcategoría |
| Árboles o grafos en una tabla | Organigramas, menús de navegación |

---

## 4. Resumen — CTE vs subconsulta en FROM

| | Subconsulta en `FROM` | CTE (`WITH`) |
|---|---|---|
| Nombre | Sin nombre (o alias) | Nombre explícito |
| Reusabilidad | No — hay que repetir | Sí — se define una vez |
| Legibilidad | Baja cuando se anida | Alta — el nombre documenta la intención |
| Recursividad | No | Sí (`WITH RECURSIVE`) |
| Modifica la BD | No | No |
| Persiste después de la consulta | No | No |

---

## 5. Errores frecuentes

```sql
-- ❌ Olvidar la coma entre CTEs
WITH
cte1 AS (SELECT ...)   -- falta coma aquí
cte2 AS (SELECT ...)   -- ERROR: syntax error at or near "cte2"
SELECT * FROM cte2;

-- ✓ Correcto:
WITH
cte1 AS (SELECT ...),  -- coma aquí
cte2 AS (SELECT ...)
SELECT * FROM cte2;
```

```sql
-- ❌ Referenciar un CTE que se definió después
WITH
cte2 AS (SELECT ... FROM cte1 ...),  -- cte1 todavía no existe
cte1 AS (SELECT ...)
SELECT * FROM cte2;
-- ERROR: relation "cte1" does not exist

-- ✓ El orden importa: definir primero lo que se referencia
WITH
cte1 AS (SELECT ...),
cte2 AS (SELECT ... FROM cte1 ...)
SELECT * FROM cte2;
```

---

## Para recordar

```
WITH nombre AS (SELECT ...)          → CTE básico: nombre para una subconsulta
WITH a AS (...), b AS (... a ...)    → CTEs encadenados: b puede usar a
WITH RECURSIVE nombre AS (
    caso_base UNION ALL paso_rec     → CTEs recursivos: series y jerarquías
)
```

> **Regla de oro:** si una subconsulta anidada dificulta la lectura, conviértela en un CTE. Si necesitas generar datos que no existen en la tabla (fechas, números), usa `WITH RECURSIVE`.

# Clase 16 — JOINs avanzados y Tablas derivadas
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**
**Herramienta:** PostgreSQL + pgAdmin

--- 

## Base de datos de la clase — MediCare

```
ESPECIALIDAD  (id_especialidad, nombre_especialidad)
MEDICO        (id_medico, nombre_medico, id_especialidad)
PACIENTE      (id_paciente, nombre_paciente, email_paciente)
TURNO         (id_paciente, id_medico, fecha_turno, tipo_consulta, costo_cop)
              PK: (id_paciente, id_medico)
```

Datos clave para entender los resultados:
- **6 médicos**: MED-001 a MED-004 tienen turnos; **MED-005 y MED-006 no tienen ningún turno**.
- **8 pacientes**: PAC-001 a PAC-006 tienen turnos; **PAC-007 y PAC-008 no tienen ningún turno**.
- **16 turnos** en total.

---

## ¿Por qué hace falta algo más que LEFT JOIN?

En la clase anterior aprendieron que `LEFT JOIN` devuelve todas las filas de la tabla **izquierda** más las coincidencias de la derecha. Pero hay dos situaciones que no cubre:

1. **Quiero que aparezcan todas las filas de la tabla derecha** (no de la izquierda). Podrías dar vuelta el `LEFT JOIN`, o usar `RIGHT JOIN`.
2. **Quiero que aparezcan todas las filas de ambas tablas al mismo tiempo**, aunque no tengan coincidencia entre sí. Para eso existe `FULL OUTER JOIN`.

Y hay un tercer caso completamente diferente:

3. **Quiero generar todas las combinaciones posibles** entre dos tablas, sin condición de unión. Para eso existe `CROSS JOIN`.

Finalmente, a veces necesitas primero calcular un subtotal agrupado y luego unirlo con otra tabla. La solución es una **tabla derivada** — una subconsulta que vive dentro del `FROM`.

---

## 1. RIGHT JOIN

`RIGHT JOIN` devuelve **todas las filas de la tabla derecha** más las coincidencias de la tabla izquierda. Donde no hay coincidencia, las columnas de la tabla izquierda aparecen como `NULL`.

### 1.1 Cómo funciona — diagrama

```
TURNO (16 filas)                   MEDICO (6 filas)
┌─────────┬─────────┬──────────┐   ┌──────────┬────────────────────┐
│PAC-001  │MED-001  │Prim. vez │──►│MED-001   │Dr. Carlos Torres   │
│PAC-001  │MED-002  │Control   │──►│MED-002   │Dra. Laura Sánchez  │
│PAC-001  │MED-003  │Urgencia  │──►│MED-003   │Dr. Jorge Vargas    │
│PAC-002  │MED-001  │Prim. vez │──►│MED-001   │(ya estaba)         │
│...      │...      │...       │   │MED-004   │Dra. Ana Ríos       │
└─────────┴─────────┴──────────┘   │MED-005   │Dra. Sofía Herrera  │ ✕ sin turno
                                   │MED-006   │Dr. Miguel Castro   │ ✕ sin turno
                                   └──────────┴────────────────────┘
                                          ↓  RIGHT JOIN (tabla derecha: medico)

RESULTADO: 18 filas
┌────────────────────┬────────────┬───────────────┐
│nombre_medico        │id_paciente │tipo_consulta  │
├────────────────────┼────────────┼───────────────┤
│Dr. Carlos Torres   │PAC-001     │Primera vez    │
│Dr. Carlos Torres   │PAC-002     │Primera vez    │
│...                 │...         │...            │
│Dra. Sofía Herrera  │NULL        │NULL           │  ← sin turno registrado
│Dr. Miguel Castro   │NULL        │NULL           │  ← sin turno registrado
└────────────────────┴────────────┴───────────────┘
```

### 1.2 Sintaxis

```sql
-- RIGHT JOIN: todo lo de la derecha (medico)
SELECT m.nombre_medico, t.id_paciente, t.tipo_consulta
FROM turno t
RIGHT JOIN medico m ON t.id_medico = m.id_medico
ORDER BY m.nombre_medico;
```

### 1.3 Equivalencia con LEFT JOIN

`RIGHT JOIN` es el espejo exacto de `LEFT JOIN`. Se puede reescribir cualquier `RIGHT JOIN` invirtiendo el orden de las tablas:

```sql
-- Con RIGHT JOIN: turno a la izquierda, medico a la derecha
SELECT m.nombre_medico, t.id_paciente, t.tipo_consulta
FROM turno t
RIGHT JOIN medico m ON t.id_medico = m.id_medico;

-- Con LEFT JOIN: medico a la izquierda, turno a la derecha — resultado idéntico
SELECT m.nombre_medico, t.id_paciente, t.tipo_consulta
FROM medico m
LEFT JOIN turno t ON m.id_medico = t.id_medico;
```

> **Convención de industria:** casi siempre se usa `LEFT JOIN` en lugar de `RIGHT JOIN`, simplemente invirtiendo el orden de las tablas. El código es más fácil de leer cuando la tabla "principal" siempre está a la izquierda. `RIGHT JOIN` existe, pero se ve poco en código real.

---

## 2. FULL OUTER JOIN

`FULL OUTER JOIN` devuelve **todas las filas de ambas tablas**. Donde no hay coincidencia en ninguno de los dos lados, las columnas del lado sin match aparecen como `NULL`.

Es la unión de `LEFT JOIN` y `RIGHT JOIN`:

```
FULL OUTER JOIN = todas las filas del LEFT JOIN + todas las filas del RIGHT JOIN
```

### 2.1 Cómo funciona — diagrama

```
PACIENTE (8 filas)                TURNO (16 filas)
┌──────────┬──────────────┐       ┌──────────┬──────────┬──────────┐
│PAC-001   │Carlos Ruiz   │◄─────►│PAC-001   │MED-001   │Prim. vez │
│PAC-002   │Laura Mesa    │◄─────►│PAC-002   │MED-001   │Prim. vez │
│PAC-003   │Jorge Vega    │◄─────►│PAC-003   │MED-003   │Urgencia  │
│PAC-004   │Ana Torres    │◄─────►│PAC-004   │MED-002   │Prim. vez │
│PAC-005   │Sofía Herrera │◄─────►│PAC-005   │MED-001   │Prim. vez │
│PAC-006   │Miguel Castro │◄─────►│PAC-006   │MED-004   │Prim. vez │
│PAC-007   │Patricia Leal │  ✕    (sin turno)
│PAC-008   │Andrés Morales│  ✕    (sin turno)
└──────────┴──────────────┘       └──────────┴──────────┴──────────┘
                              ↓  FULL OUTER JOIN

RESULTADO: 18 filas
┌──────────────┬──────────┬───────────────┐
│nombre_paciente│id_medico│tipo_consulta  │
├──────────────┼──────────┼───────────────┤
│Carlos Ruiz   │MED-001   │Primera vez    │ ← coincidencia
│Carlos Ruiz   │MED-002   │Control        │ ← coincidencia
│...           │...       │...            │
│Patricia Leal │NULL      │NULL           │ ← solo en PACIENTE (sin turno)
│Andrés Morales│NULL      │NULL           │ ← solo en PACIENTE (sin turno)
└──────────────┴──────────┴───────────────┘
Nota: en este dataset no hay turnos huérfanos (FK garantiza que todo turno tiene
un paciente válido), por lo que no aparecen NULL del lado izquierdo.
```

### 2.2 Sintaxis

```sql
-- Todos los pacientes con sus turnos (incluyendo pacientes sin turno)
SELECT p.nombre_paciente, t.id_medico, t.tipo_consulta, t.costo_cop
FROM paciente p
FULL OUTER JOIN turno t ON p.id_paciente = t.id_paciente
ORDER BY p.nombre_paciente NULLS LAST;
```

```sql
-- Todos los médicos con sus turnos (incluyendo médicos sin turno)
SELECT m.nombre_medico, t.id_paciente, t.tipo_consulta
FROM medico m
FULL OUTER JOIN turno t ON m.id_medico = t.id_medico
ORDER BY m.nombre_medico NULLS LAST;
-- MED-005 y MED-006 aparecen con NULL en las columnas de turno
```

### 2.3 Comparación LEFT vs RIGHT vs FULL

```
Tabla A               Tabla B
┌───────────┐         ┌───────────┐
│  A1   ●──────────────►  B1     │  ← coincidencia
│  A2   ●──────────────►  B2     │  ← coincidencia
│  A3        │         │  B3     │  ← solo en B (sin match en A)
│  A4        │              └───────────────── solo en A (sin match en B)
└───────────┘         └───────────┘

INNER JOIN  →  A1+B1, A2+B2              (solo intersección)
LEFT  JOIN  →  A1+B1, A2+B2, A4+NULL    (todo A + intersección)
RIGHT JOIN  →  A1+B1, A2+B2, NULL+B3    (intersección + todo B)
FULL  JOIN  →  A1+B1, A2+B2, A4+NULL, NULL+B3  (todo de ambos)
```

### 2.4 Cuándo usar FULL OUTER JOIN

- **Auditorías y reconciliaciones**: ver qué registros existen en una tabla pero no en otra, y viceversa.
- **Comparar dos conjuntos**: todos los empleados vs todos los departamentos, para encontrar departamentos vacíos Y empleados sin departamento al mismo tiempo.
- **Detección de inconsistencias**: registros en tabla A sin correspondencia en tabla B, y registros en tabla B sin correspondencia en tabla A, en una sola consulta.

> `FULL OUTER JOIN` es menos común que `LEFT JOIN` pero muy poderoso para análisis y validación de datos. En bases de datos bien diseñadas con FKs, una de las mitades del FULL OUTER suele quedar vacía (por las restricciones de integridad referencial).

---

## 3. CROSS JOIN

`CROSS JOIN` genera el **producto cartesiano** de dos tablas: combina **cada fila** de la tabla A con **cada fila** de la tabla B. **No lleva condición `ON`**.

Si A tiene N filas y B tiene M filas, el resultado tiene **N × M filas**.

### 3.1 Cómo funciona — diagrama

```
PACIENTE (8 filas)          ESPECIALIDAD (3 filas)
┌──────────────┐            ┌──────────────────────┐
│Carlos Ruiz    │            │Medicina General       │
│Laura Mesa     │            │Pediatría              │
│Jorge Vega     │            │Cardiología            │
│Ana Torres     │            └──────────────────────┘
│Sofía Herrera  │
│...            │
└──────────────┘
            ↓  CROSS JOIN (8 × 3)

RESULTADO: 24 filas
┌──────────────┬──────────────────────┐
│nombre_paciente│nombre_especialidad  │
├──────────────┼──────────────────────┤
│Carlos Ruiz   │Medicina General      │  ← Carlos × todas las especialidades
│Carlos Ruiz   │Pediatría             │
│Carlos Ruiz   │Cardiología           │
│Laura Mesa    │Medicina General      │  ← Laura × todas las especialidades
│Laura Mesa    │Pediatría             │
│...           │...                   │
└──────────────┴──────────────────────┘
```

### 3.2 Sintaxis

```sql
-- Todas las combinaciones de pacientes y especialidades
SELECT p.nombre_paciente, e.nombre_especialidad
FROM paciente p
CROSS JOIN especialidad e;

-- Contar combinaciones posibles
SELECT COUNT(*) FROM medico CROSS JOIN paciente;
-- 6 × 8 = 48 (vs 16 turnos reales)
```

### 3.3 ¿Cuándo usar CROSS JOIN?

- **Generar matrices**: todos los horarios posibles para una agenda, todas las combinaciones de tallas y colores de un producto.
- **Análisis hipotético**: ¿cuántas citas tendría la clínica si cada paciente viera a cada médico?
- **Poblar tablas de prueba**: generar datos de test combinando valores de múltiples dimensiones.

### 3.4 ⚠️ Advertencia de rendimiento

```
  100 filas × 100 filas  =     10 000 filas   (manejable)
1 000 filas × 1 000 filas = 1 000 000 filas   (lento)
1 000 filas × 1 000 000 filas = 10⁹ filas    (colapso del servidor)
```

> Nunca apliques un `CROSS JOIN` sin conocer el tamaño de ambas tablas. Un error común es escribir una consulta con dos tablas y olvidar la condición `ON`, generando accidentalmente un producto cartesiano gigante.

---

## 4. Subconsulta como tabla derivada (en FROM)

Una **tabla derivada** es una subconsulta que se coloca dentro de la cláusula `FROM` y actúa como una tabla temporal. PostgreSQL la ejecuta primero y el resultado queda disponible para el resto de la consulta.

```
Tabla derivada:  subconsulta dentro del FROM  →  tabla temporal con alias
```

**Regla:** toda tabla derivada debe tener un **alias obligatorio** en PostgreSQL.

### 4.1 Problema que resuelve

Supón que quieres mostrar el nombre de cada médico junto al total que ha recaudado. Intuitivamente podrías pensar en:

```sql
-- ❌ No funciona: no se puede filtrar por un alias de GROUP BY en WHERE/SELECT de otro nivel
SELECT m.nombre_medico, SUM(t.costo_cop) AS total
FROM medico m
LEFT JOIN turno t ON m.id_medico = t.id_medico
GROUP BY m.id_medico;
-- Esto sí funciona, pero ¿y si queremos unir ese resultado con otra tabla más?
-- O ¿si quisiéramos filtrar solo los médicos con total > promedio?
-- La tabla derivada permite componer consultas complejas paso a paso.
```

### 4.2 Cómo funciona — paso a paso

```
Paso 1: la subconsulta se ejecuta primero y genera una "tabla" temporal

  subconsulta (tabla derivada "totales"):
  ┌──────────┬──────────────┐
  │id_medico │total_recauda │
  ├──────────┼──────────────┤
  │MED-001   │200 000       │
  │MED-002   │260 000       │
  │MED-003   │480 000       │
  │MED-004   │200 000       │
  └──────────┴──────────────┘

Paso 2: se une con medico como si fuera una tabla real

  medico JOIN totales ON id_medico = id_medico
  ┌────────────────────┬──────────────┐
  │nombre_medico        │total_recauda │
  ├────────────────────┼──────────────┤
  │Dr. Carlos Torres   │200 000       │
  │Dra. Laura Sánchez  │260 000       │
  │Dr. Jorge Vargas    │480 000       │
  │Dra. Ana Ríos       │200 000       │
  └────────────────────┴──────────────┘
  (solo los médicos con turnos; INNER JOIN excluye MED-005 y MED-006)
```

### 4.3 Sintaxis básica

```sql
-- La subconsulta en FROM calcula totales; luego se une con medico
SELECT m.nombre_medico, totales.total_recaudado
FROM medico m
INNER JOIN (
    SELECT id_medico, SUM(costo_cop) AS total_recaudado
    FROM turno
    GROUP BY id_medico
) AS totales ON m.id_medico = totales.id_medico
ORDER BY totales.total_recaudado DESC;
```

### 4.4 Con LEFT JOIN para incluir filas sin coincidencia

```sql
-- Incluir también médicos sin turnos (MED-005, MED-006)
SELECT
    m.nombre_medico,
    COALESCE(totales.num_turnos, 0)       AS num_turnos,
    COALESCE(totales.total_recaudado, 0)  AS total_recaudado
FROM medico m
LEFT JOIN (
    SELECT id_medico, COUNT(*) AS num_turnos, SUM(costo_cop) AS total_recaudado
    FROM turno
    GROUP BY id_medico
) AS totales ON m.id_medico = totales.id_medico
ORDER BY total_recaudado DESC;
```

> **`COALESCE(valor, alternativa)`** — devuelve `valor` si no es `NULL`; si es `NULL`, devuelve `alternativa`. Es la forma estándar de reemplazar `NULL` por un valor por defecto en los resultados de un `LEFT JOIN`.

### 4.5 Tabla derivada con ORDER BY + LIMIT (top-N)

```sql
-- Los 3 médicos con mayor recaudación
SELECT m.nombre_medico, top3.total_recaudado
FROM medico m
INNER JOIN (
    SELECT id_medico, SUM(costo_cop) AS total_recaudado
    FROM turno
    GROUP BY id_medico
    ORDER BY total_recaudado DESC
    LIMIT 3
) AS top3 ON m.id_medico = top3.id_medico
ORDER BY top3.total_recaudado DESC;
-- Dr. Jorge Vargas (480 000), Dra. Laura Sánchez (260 000), Dr. Carlos Torres (200 000)
```

### 4.6 Tabla derivada vs subconsulta correlacionada

Ambas resuelven problemas parecidos pero funcionan de forma distinta:

| | Tabla derivada | Subconsulta correlacionada |
|---|---|---|
| **Dónde va** | En `FROM` | En `SELECT` o `WHERE` |
| **Se ejecuta** | **Una sola vez** (tabla temporal) | **Una vez por cada fila** exterior |
| **Puede agregar (GROUP BY)** | ✓ | ✓ (con COUNT, SUM, etc.) |
| **Puede traer múltiples columnas** | ✓ | Solo si es escalar (1 columna, 1 fila) |
| **Útil para** | Pre-agregar, top-N, transformaciones complejas | Valor calculado por fila, filtros dinámicos |

```sql
-- Lo mismo con subconsulta correlacionada (ejecuta 6 veces)
SELECT m.nombre_medico,
    (SELECT SUM(costo_cop) FROM turno t WHERE t.id_medico = m.id_medico) AS total
FROM medico m;

-- Lo mismo con tabla derivada (ejecuta 1 vez)
SELECT m.nombre_medico, totales.total_recaudado
FROM medico m
LEFT JOIN (
    SELECT id_medico, SUM(costo_cop) AS total_recaudado
    FROM turno GROUP BY id_medico
) AS totales ON m.id_medico = totales.id_medico;
```

> En tablas grandes, la tabla derivada es considerablemente más eficiente porque la subconsulta se ejecuta una sola vez y su resultado se reutiliza para todos los `JOIN`.

---

## 5. Resumen completo de tipos de JOIN

| Tipo | Filas que devuelve | NULL aparece en |
|---|---|---|
| `INNER JOIN` | Solo filas con coincidencia en **ambas** tablas | — |
| `LEFT JOIN` | **Todas** las filas de la izquierda + coincidencias de la derecha | Columnas de la tabla derecha |
| `RIGHT JOIN` | Coincidencias de la izquierda + **todas** las filas de la derecha | Columnas de la tabla izquierda |
| `FULL OUTER JOIN` | **Todas** las filas de **ambas** tablas | Ambos lados donde no hay coincidencia |
| `CROSS JOIN` | Producto cartesiano (N × M filas) — sin condición `ON` | — |

```
Diagrama conceptual:

  INNER JOIN      LEFT JOIN      RIGHT JOIN    FULL OUTER     CROSS JOIN
  ┌──┬──┐          ┌──┬──┐         ┌──┬──┐      ┌──┬──┐       ┌──────┐
  │  │██│          │██│██│         │  │██│      │██│██│       │ A×B  │
  │  │██│          │██│██│         │  │██│      │██│██│       │todos │
  └──┴──┘          └──┴──┘         └──┴──┘      └──┴──┘       └──────┘
  (intersección)  (todo A)      (todo B)     (todo A+B)    (sin condición)
```

---

## 6. COALESCE — manejo de NULL en resultados de JOIN

`COALESCE` es una función que recibe varios argumentos y devuelve el **primero que no sea NULL**:

```sql
COALESCE(expr1, expr2, ..., exprN)
-- devuelve expr1 si no es NULL
-- si expr1 es NULL, devuelve expr2
-- y así sucesivamente
```

**Uso típico con LEFT JOIN:**

```sql
-- Sin COALESCE: el médico sin turnos muestra NULL
SELECT m.nombre_medico, totales.total_recaudado    -- NULL si no hay turnos
FROM medico m
LEFT JOIN (...) AS totales ON ...;

-- Con COALESCE: muestra 0 en lugar de NULL
SELECT m.nombre_medico, COALESCE(totales.total_recaudado, 0) AS total_recaudado
FROM medico m
LEFT JOIN (...) AS totales ON ...;
```

---

## Referencia rápida

```sql
-- RIGHT JOIN (= LEFT JOIN con tablas invertidas)
SELECT m.nombre_medico, t.tipo_consulta
FROM turno t
RIGHT JOIN medico m ON t.id_medico = m.id_medico;

-- FULL OUTER JOIN
SELECT p.nombre_paciente, t.tipo_consulta
FROM paciente p
FULL OUTER JOIN turno t ON p.id_paciente = t.id_paciente;

-- CROSS JOIN (sin ON)
SELECT p.nombre_paciente, e.nombre_especialidad
FROM paciente p
CROSS JOIN especialidad e;
-- N filas × M filas = N×M filas

-- Tabla derivada básica (INNER JOIN)
SELECT t_princ.col, derivada.col_calc
FROM tabla_principal t_princ
INNER JOIN (
    SELECT fk_col, COUNT(*) AS col_calc
    FROM tabla_detalle
    GROUP BY fk_col
) AS derivada ON t_princ.pk = derivada.fk_col;

-- Tabla derivada con LEFT JOIN y COALESCE
SELECT t_princ.col, COALESCE(derivada.col_calc, 0) AS col_calc
FROM tabla_principal t_princ
LEFT JOIN (
    SELECT fk_col, SUM(num) AS col_calc
    FROM tabla_detalle
    GROUP BY fk_col
) AS derivada ON t_princ.pk = derivada.fk_col;

-- Top-N con tabla derivada
SELECT t_princ.col, top_n.total
FROM tabla_principal t_princ
INNER JOIN (
    SELECT fk_col, SUM(num) AS total
    FROM tabla_detalle
    GROUP BY fk_col
    ORDER BY total DESC
    LIMIT 3
) AS top_n ON t_princ.pk = top_n.fk_col;
```

---

## Vocabulario esencial

| Término | Definición |
|---|---|
| **RIGHT JOIN** | JOIN que devuelve todas las filas de la tabla derecha + coincidencias de la izquierda |
| **FULL OUTER JOIN** | JOIN que devuelve todas las filas de ambas tablas, con NULL donde no hay coincidencia |
| **CROSS JOIN** | Producto cartesiano: cada fila de A combinada con cada fila de B, sin condición ON |
| **Producto cartesiano** | Combinación de todas las filas de A con todas las de B → N × M filas |
| **Tabla derivada** | Subconsulta en la cláusula FROM que actúa como tabla temporal; requiere alias |
| **Alias de tabla derivada** | Nombre obligatorio asignado a la subconsulta en FROM (`AS nombre`) |
| **COALESCE** | Función que devuelve el primer valor no-NULL de una lista de expresiones |
| **Anti-join** | Técnica con LEFT JOIN + IS NULL para encontrar filas sin coincidencia |
| **Top-N** | Patrón de tabla derivada que usa ORDER BY + LIMIT para obtener los N mejores resultados |
| **Cortocircuito** | Optimización de EXISTS: para en cuanto encuentra la primera coincidencia |

---

## Errores frecuentes

| Error | Causa | Solución |
|---|---|---|
| Tabla derivada sin alias | PostgreSQL exige alias en toda subconsulta en FROM | Agregar `AS nombre_alias` |
| `CROSS JOIN` accidental | Olvidar la condición `ON` en un JOIN | Verificar que todo JOIN tiene su `ON` |
| `COUNT(*)` con LEFT JOIN da 1 en lugar de 0 | `COUNT(*)` cuenta la fila aunque el lado derecho sea NULL | Usar `COUNT(columna_tabla_derecha)` |
| FULL OUTER JOIN retorna igual que INNER | No hay filas sin coincidencia en los datos (FKs garantizan integridad) | Es correcto; el resultado sería diferente con datos huérfanos |
| RIGHT JOIN confuso de leer | Rompe la convención de "tabla principal a la izquierda" | Reescribir como LEFT JOIN invirtiendo el orden de tablas |
| NULL en resultado de LEFT JOIN + tabla derivada | El LEFT JOIN produce NULL cuando no hay coincidencia; la columna calculada también es NULL | Envolver con `COALESCE(col, 0)` |

---

## Preguntas de autoevaluación

1. ¿Cuál es la diferencia entre `RIGHT JOIN` y `LEFT JOIN`? ¿En qué situación usarías uno en lugar del otro?

2. Tienes una tabla `departamento` y una tabla `empleado`. Escribe con `FULL OUTER JOIN` una consulta que muestre todos los departamentos (aunque no tengan empleados) y todos los empleados (aunque no tengan departamento asignado).

3. ¿Por qué `CROSS JOIN` no lleva condición `ON`? ¿Qué ocurre si a una tabla de 1 000 filas le haces `CROSS JOIN` con otra de 500 filas?

4. Explica el concepto de "tabla derivada". ¿Qué ventaja tiene sobre una subconsulta correlacionada cuando se necesita calcular un total por grupo?

5. ¿Por qué PostgreSQL exige que toda tabla derivada tenga un alias? ¿Qué pasaría si no lo tuviera?

6. Tienes la tabla `medico` y quieres mostrar cada médico con el número de turnos que ha atendido, incluyendo médicos con 0 turnos. Escribe la consulta usando tabla derivada + `LEFT JOIN` + `COALESCE`.

7. ¿Para qué sirve `COALESCE`? Da un ejemplo de cómo `LEFT JOIN` produce `NULL` y cómo `COALESCE` lo convierte en un valor útil.

8. ¿En qué se parecen y en qué se diferencian una tabla derivada y una subconsulta correlacionada? ¿Cuántas veces ejecuta cada una su subconsulta?

---

## Para recordar

```
RIGHT JOIN    →  espejo de LEFT JOIN; convención: usar LEFT JOIN invirtiendo el orden
FULL OUTER    →  todo A + todo B + NULL en ambos lados donde no hay match
CROSS JOIN    →  producto cartesiano sin ON → N×M filas; cuidado con tablas grandes

Tabla derivada  →  subconsulta en FROM con alias obligatorio, ejecuta una sola vez
                   útil para pre-agregar, top-N, transformaciones complejas
COALESCE(x, 0)  →  reemplaza NULL por un valor por defecto en resultados de LEFT JOIN

Subconsulta correlacionada  →  en SELECT o WHERE, ejecuta N veces (una por fila)
Tabla derivada              →  en FROM, ejecuta 1 vez como tabla temporal

CROSS JOIN sin control   →  puede colapsar el servidor (N × M puede ser enorme)
LEFT JOIN + IS NULL      →  anti-join: filas sin coincidencia
COUNT(col_derecha)       →  correcto con LEFT JOIN (ignora NULL = 0 cuando no hay match)
COUNT(*)                 →  incorrecto con LEFT JOIN (cuenta 1 aunque no haya match)
```

---

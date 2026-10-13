# Clase 19 — JOINs avanzados: Self-JOIN · JOIN + CTE · Optimización · Índices
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**
**Herramienta:** PostgreSQL + pgAdmin


---

## Base de datos de la clase — ShopEasy

```
CATEGORIA     (id_categoria, nombre, id_padre → FK a id_categoria)
PRODUCTO      (id_producto, nombre, precio_cop, stock, id_categoria FK)
CLIENTE       (id_cliente, nombre, email, ciudad, plan)
               plan: 'regular' | 'vip'
PEDIDO        (id_pedido, id_cliente FK, fecha, estado)
               estado: 'entregado' | 'cancelado' | 'pendiente'
DETALLE_PEDIDO(id_detalle SERIAL PK, id_pedido FK, id_producto FK,
               cantidad, precio_unitario)
```

Datos relevantes para entender los ejemplos:
- **8 categorías**: 4 raíces (Electrónica, Ropa, Hogar, Deportes) + 4 hijas (Smartphones, Laptops, Camisetas, Pantalones). Hogar y Deportes **no tienen productos asignados**.
- **14 productos**: 12 con categoría (ninguno apunta directamente a las raíces, todos van a subcategorías) + 2 sin categoría (`PRD-13` Zapatillas, `PRD-14` Botella Deportiva). Estos 2 también son los únicos **nunca pedidos**.
- **10 clientes**: 8 con pedidos, 2 sin ningún pedido (`CLI-09` Juliana Soto y `CLI-10` Kevin Álvarez).
- **18 pedidos** (entregados, cancelados y pendientes) con **30 líneas de detalle** en total.

---

## Mapa completo de JOINs

Antes de ver el Self-JOIN conviene tener el cuadro completo de todos los JOINs vistos:

```
Tabla A (izquierda)          Tabla B (derecha)
┌──────────────────┐         ┌──────────────────┐
│  A1  ●──────────────────►  B1  │  ← coincidencia
│  A2  ●──────────────────►  B2  │  ← coincidencia
│  A3  │                   │  B3  │  ← solo en B
│  A4  │                              ← solo en A
└──────────────────┘         └──────────────────┘

INNER JOIN   → A1+B1, A2+B2                       (solo la intersección)
LEFT  JOIN   → A1+B1, A2+B2, A4+NULL             (todo A + intersección)
RIGHT JOIN   → A1+B1, A2+B2, NULL+B3             (intersección + todo B)
FULL OUTER   → A1+B1, A2+B2, A4+NULL, NULL+B3   (todo de ambos lados)
CROSS JOIN   → A×B (producto cartesiano — todas las combinaciones posibles)
Self-JOIN    → la misma tabla en A y en B (con alias distintos)
```

| JOIN | Pregunta que responde |
|------|-----------------------|
| INNER | ¿Qué tienen en común las dos tablas? |
| LEFT  | Dame todo de A, y lo que puedas de B |
| RIGHT | Dame todo de B, y lo que puedas de A |
| FULL OUTER | Dame todo de A y todo de B, coincidan o no |
| CROSS | Dame todas las combinaciones posibles |
| Self  | ¿Qué relación existe entre filas de la misma tabla? |

---

## 1. Self-JOIN

### 1.1 ¿Qué es?

Un **Self-JOIN** no es un tipo de JOIN distinto — es una técnica: hacer un JOIN de una tabla **con una copia de sí misma**. Se usa cuando una tabla tiene una **relación interna** entre sus propias filas.

Casos típicos en bases de datos reales:
- **Jerarquías**: categorías padre/hijo, territorios/subterritories, organigramas.
- **Comparaciones**: encontrar pares de filas que cumplan alguna condición entre sí.
- **Grafos**: rutas, conexiones entre nodos de la misma entidad.

### 1.2 El patrón: alias obligatorios

```sql
-- Estructura general de un Self-JOIN
SELECT alias1.col, alias2.col
FROM tabla alias1
[INNER | LEFT] JOIN tabla alias2 ON alias1.col_relacion = alias2.col_clave;
```

Los **dos alias son obligatorios** — sin ellos PostgreSQL no sabe a cuál "copia" de la tabla te referís en cada columna.

### 1.3 Self-JOIN en ShopEasy — categorías padre/hijo

La tabla `categoria` tiene la columna `id_padre` que apunta a otra fila de la misma tabla:

```
CATEGORIA
┌──────────────┬─────────────┬──────────┐
│ id_categoria │ nombre      │ id_padre │
├──────────────┼─────────────┼──────────┤
│      1       │ Electrónica │   NULL   │  ← raíz
│      2       │ Ropa        │   NULL   │  ← raíz
│      3       │ Hogar       │   NULL   │  ← raíz
│      4       │ Deportes    │   NULL   │  ← raíz
│      5       │ Smartphones │    1     │  ← hija de Electrónica
│      6       │ Laptops     │    1     │  ← hija de Electrónica
│      7       │ Camisetas   │    2     │  ← hija de Ropa
│      8       │ Pantalones  │    2     │  ← hija de Ropa
└──────────────┴─────────────┴──────────┘
```

**Ejemplo 1 — Solo subcategorías (INNER JOIN):**

```sql
-- h = hijo (la subcategoría), p = padre (la categoría raíz)
SELECT h.nombre AS subcategoria,
       p.nombre AS categoria_padre
FROM categoria h
INNER JOIN categoria p ON h.id_padre = p.id_categoria;
```

```
subcategoria  | categoria_padre
──────────────┼────────────────
Smartphones   | Electrónica
Laptops       | Electrónica
Camisetas     | Ropa
Pantalones    | Ropa
```

Con `INNER JOIN` las categorías raíz (`id_padre IS NULL`) no aparecen porque no tienen coincidencia en el lado derecho del JOIN.

**Ejemplo 2 — Todas las categorías (LEFT JOIN + COALESCE):**

```sql
SELECT h.nombre                         AS categoria,
       COALESCE(p.nombre, '— raíz —')  AS padre
FROM categoria h
LEFT JOIN categoria p ON h.id_padre = p.id_categoria
ORDER BY COALESCE(p.nombre, h.nombre), h.nombre;
```

```
categoria    | padre
─────────────┼─────────────
Deportes     | — raíz —
Electrónica  | — raíz —
Hogar        | — raíz —
Ropa         | — raíz —
Laptops      | Electrónica
Smartphones  | Electrónica
Camisetas    | Roba
Pantalones   | Ropa
```

Con `LEFT JOIN` las raíces aparecen en el resultado; `COALESCE` reemplaza el NULL por el texto `'— raíz —'`.

### 1.4 Self-JOIN para comparar filas entre sí

Además de jerarquías, el Self-JOIN sirve para comparar filas de la misma tabla entre sí:

```sql
-- Pares de productos en la misma subcategoría con sus precios
SELECT a.nombre                        AS producto_a,
       b.nombre                        AS producto_b,
       a.precio_cop                    AS precio_a,
       b.precio_cop                    AS precio_b,
       ABS(a.precio_cop - b.precio_cop) AS diferencia_cop
FROM producto a
JOIN producto b ON  a.id_categoria = b.id_categoria
               AND  a.id_producto  < b.id_producto   -- ← truco clave
WHERE a.id_categoria IS NOT NULL
ORDER BY a.id_categoria, diferencia_cop DESC;
```

La condición `a.id_producto < b.id_producto` hace dos cosas:
1. **Evita duplicados**: sin ella obtendrías el par (iPhone, Galaxy) Y también (Galaxy, iPhone).
2. **Evita la auto-comparación**: sin ella cada producto se compararía consigo mismo.

---

## 2. JOIN + CTE

### 2.1 ¿Por qué combinarlos?

Las CTEs permiten **nombrar una consulta** y referenciarse a ella como si fuera una tabla. Al combinarlas con JOINs, puedes:

- Pre-calcular agregados (totales, promedios, conteos) y luego unirlos con tablas detalladas.
- Separar lógica compleja en bloques legibles.
- Reusar el mismo cálculo en múltiples partes de la consulta principal.

**Alternativa sin CTE (más difícil de leer):**
```sql
SELECT c.nombre, p.id_pedido, sub.total_cop
FROM cliente c
JOIN pedido p ON c.id_cliente = p.id_cliente
JOIN (
    SELECT id_pedido, SUM(cantidad * precio_unitario) AS total_cop
    FROM detalle_pedido GROUP BY id_pedido
) sub ON p.id_pedido = sub.id_pedido;
```

**Con CTE (más legible):**
```sql
WITH total_por_pedido AS (
    SELECT id_pedido,
           SUM(cantidad * precio_unitario) AS total_cop
    FROM detalle_pedido
    GROUP BY id_pedido
)
SELECT c.nombre, p.id_pedido, tp.total_cop
FROM cliente c
JOIN pedido           p  ON c.id_cliente = p.id_cliente
JOIN total_por_pedido tp ON p.id_pedido  = tp.id_pedido;
```

El resultado es idéntico — la diferencia es legibilidad y mantenibilidad.

### 2.2 Ejemplo completo — gasto total por cliente

```sql
WITH gasto_cliente AS (
    SELECT p.id_cliente,
           COUNT(DISTINCT p.id_pedido)           AS total_pedidos,
           SUM(dp.cantidad * dp.precio_unitario) AS gasto_total
    FROM pedido p
    JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
    WHERE p.estado = 'entregado'           -- solo pedidos entregados
    GROUP BY p.id_cliente
)
SELECT c.nombre,
       c.plan,
       c.ciudad,
       COALESCE(g.total_pedidos, 0) AS pedidos_entregados,
       COALESCE(g.gasto_total,   0) AS gasto_total_cop
FROM cliente c
LEFT JOIN gasto_cliente g ON c.id_cliente = g.id_cliente
ORDER BY gasto_total_cop DESC;
```

Puntos clave:
- El CTE `gasto_cliente` solo tiene filas de clientes que han hecho pedidos entregados.
- El `LEFT JOIN` garantiza que **todos los clientes aparezcan**, incluidos `CLI-09` y `CLI-10`.
- `COALESCE` convierte el `NULL` de los clientes sin resultados en el CTE en `0`.

### 2.3 Ejemplo — ventas por categoría con CTE encadenado

```sql
WITH ventas AS (
    SELECT dp.id_producto,
           SUM(dp.cantidad * dp.precio_unitario) AS ingreso
    FROM detalle_pedido dp
    JOIN pedido p ON dp.id_pedido = p.id_pedido
    WHERE p.estado = 'entregado'
    GROUP BY dp.id_producto
),
ventas_categoria AS (
    SELECT pr.id_categoria,
           SUM(v.ingreso) AS ingreso_categoria
    FROM producto pr
    JOIN ventas v ON pr.id_producto = v.id_producto
    GROUP BY pr.id_categoria
)
SELECT cat.nombre                              AS categoria,
       COALESCE(vc.ingreso_categoria, 0)      AS ingreso_cop
FROM categoria cat
LEFT JOIN ventas_categoria vc ON cat.id_categoria = vc.id_categoria
WHERE cat.id_padre IS NOT NULL                -- solo subcategorías
ORDER BY ingreso_cop DESC;
```

---

## 3. EXPLAIN ANALYZE — leer el plan de ejecución

### 3.1 ¿Para qué sirve?

`EXPLAIN ANALYZE` revela cómo PostgreSQL ejecuta internamente una consulta:
- Qué **algoritmo de JOIN** usa.
- Si lee la tabla entera (**Seq Scan**) o va directo a las filas por un índice (**Index Scan**).
- Cuántas filas procesa cada paso y cuánto tiempo tarda.

```sql
-- Solo planea (no ejecuta la consulta)
EXPLAIN        SELECT ...;

-- Planea Y ejecuta — muestra tiempos reales
EXPLAIN ANALYZE SELECT ...;
```

### 3.2 Cómo leer el resultado

```sql
EXPLAIN ANALYZE
SELECT c.nombre, p.id_pedido, p.fecha
FROM cliente c
JOIN pedido p ON c.id_cliente = p.id_cliente
WHERE c.plan = 'vip';
```

Resultado típico:
```
Hash Join  (cost=1.23..2.45 rows=8 width=52) (actual time=0.05..0.12 rows=8 loops=1)
  Hash Cond: (p.id_cliente = c.id_cliente)
  ->  Seq Scan on pedido p  (actual rows=18 loops=1)
  ->  Hash  (actual rows=4 loops=1)
        ->  Seq Scan on cliente c
              Filter: (plan = 'vip')
              Rows Removed by Filter: 6
Planning Time: 0.3 ms
Execution Time: 0.5 ms
```

| Término | Qué significa |
|---------|---------------|
| `Hash Join` | El algoritmo de JOIN: crea una tabla hash de la tabla más pequeña y busca en ella |
| `Seq Scan` | Escaneo secuencial: lee la tabla entera fila por fila |
| `Index Scan` | Accede directamente a las filas usando un índice (más rápido en tablas grandes) |
| `cost=A..B` | Estimación del planner: A = costo de obtener la primera fila, B = costo total |
| `actual rows` | Cuántas filas produjo ese nodo realmente |
| `Rows Removed by Filter` | Cuántas filas descartó el filtro `WHERE` |
| `Planning Time` | Tiempo que tardó PostgreSQL en decidir el plan |
| `Execution Time` | Tiempo real de ejecución de la consulta |

### 3.3 Algoritmos de JOIN en PostgreSQL

PostgreSQL elige automáticamente el algoritmo más eficiente según el tamaño de las tablas y si hay índices:

| Algoritmo | Cuándo lo usa | Señal en EXPLAIN |
|-----------|---------------|------------------|
| **Nested Loop** | Tablas pequeñas o cuando hay un índice útil | `Nested Loop` |
| **Hash Join** | Tablas medianas/grandes sin índice en la columna de join | `Hash Join` |
| **Merge Join** | Datos ya ordenados o cuando se puede ordenar eficientemente | `Merge Join` |

### 3.4 La señal de alerta: Seq Scan en tablas grandes

Un `Seq Scan` en una tabla pequeña es completamente normal y puede ser la opción más eficiente. El problema aparece cuando ves `Seq Scan` en tablas con **miles o millones de filas** en una columna usada para JOIN o filtro — ahí conviene considerar un índice.

---

## 4. Índices

### 4.1 ¿Qué es un índice?

Un índice es una **estructura auxiliar** que PostgreSQL mantiene junto a la tabla para poder encontrar filas rápidamente sin recorrerla entera.

**Analogía:** el índice al final de un libro. Sin él deberías leer todo el libro para encontrar un tema. Con él vas directamente a la página correcta.

El costo: los índices **ocupan espacio en disco** y **se actualizan automáticamente** cada vez que se inserta, modifica o elimina una fila. Por eso no conviene indexar todo — solo las columnas que realmente se consultan frecuentemente.

### 4.2 ¿PostgreSQL no indexa las foreign keys automáticamente?

**No.** PostgreSQL solo crea índices automáticos en las **claves primarias** (PK) y en las columnas declaradas como `UNIQUE`. Las **foreign keys (FK) no se indexan automáticamente**, aunque se usan constantemente en JOINs.

Esto es una fuente común de problemas de rendimiento en aplicaciones reales.

```sql
-- pedido.id_cliente es FK → NO tiene índice automático
-- Si haces frecuentemente:
SELECT * FROM pedido WHERE id_cliente = 'CLI-01';
-- o:
SELECT * FROM cliente c JOIN pedido p ON c.id_cliente = p.id_cliente;
-- → conviene crear el índice manualmente:
CREATE INDEX idx_pedido_cliente ON pedido(id_cliente);
```

### 4.3 Tipos de índices

| Tipo | Descripción | Cuándo usarlo |
|------|-------------|---------------|
| **B-tree** | Árbol balanceado. Soporta =, <, >, BETWEEN, LIKE 'abc%', ORDER BY | Es el tipo por defecto — el 95% de los casos |
| **Hash** | Solo soporta igualdad exacta (=). Raramente más rápido que B-tree | Prácticamente nunca en PostgreSQL moderno |
| **GIN** | Para tipos complejos: arrays, texto completo, JSONB | Búsqueda en arrays, JSONB, texto con `@@` |
| **GiST** | Datos geométricos, rangos | Geografía, tipos de rango |
| **BRIN** | Índice muy compacto para datos correlacionados con su posición física | Tablas enormes con datos ordenados por tiempo |

Para este curso: **siempre usar B-tree** (el valor por defecto).

### 4.4 Sintaxis

```sql
-- Índice simple en una columna (B-tree por defecto)
CREATE INDEX idx_pedido_cliente ON pedido(id_cliente);

-- Índice en otra columna
CREATE INDEX idx_pedido_estado ON pedido(estado);

-- Índice compuesto en dos columnas
-- Útil cuando las consultas filtran por AMBAS columnas a la vez
-- También cubre consultas que solo filtran por la primera columna
CREATE INDEX idx_detalle_pedido_prod ON detalle_pedido(id_pedido, id_producto);

-- Índice UNIQUE (además de acelerar, garantiza unicidad)
CREATE UNIQUE INDEX idx_cliente_email ON cliente(email);

-- Ver todos los índices de una tabla
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'pedido'
ORDER BY indexname;

-- Eliminar un índice
DROP INDEX idx_pedido_cliente;
DROP INDEX IF EXISTS idx_pedido_cliente;  -- no falla si no existe
```

### 4.5 Cuándo crear un índice — reglas prácticas

| Situación | ¿Indexar? | Por qué |
|-----------|-----------|---------|
| Foreign key usada en JOINs frecuentes | ✅ Sí | PostgreSQL no la crea automáticamente |
| Columna en `WHERE` con muchos valores distintos (`id_cliente`, `email`) | ✅ Sí | Alta selectividad → el índice elimina muchas filas |
| Columna en `ORDER BY` de consultas lentas | ✅ Sí | Evita ordenamiento extra |
| Columna en `WHERE` con pocos valores distintos (`estado`, `plan`) | ⚠️ Con cuidado | Baja selectividad → puede no valer la pena |
| Tabla con menos de ~1000 filas | ❌ No | Seq Scan es más rápido — overhead innecesario |
| Columna que se modifica millones de veces por día | ⚠️ Evaluar | El índice se actualiza con cada modificación |

### 4.6 Demostración: impacto del índice

```sql
-- Sin índice en detalle_pedido(id_producto):
EXPLAIN ANALYZE
SELECT p.nombre, SUM(dp.cantidad)
FROM producto p
JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
GROUP BY p.nombre;
-- → Seq Scan on detalle_pedido (30 filas — muy pequeña, no se nota)

-- Crear el índice
CREATE INDEX idx_detalle_producto ON detalle_pedido(id_producto);

-- Con índice (con datos pequeños el planner puede ignorarlo todavía)
EXPLAIN ANALYZE
SELECT p.nombre, SUM(dp.cantidad)
FROM producto p
JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
GROUP BY p.nombre;
```

> **Nota importante:** con tablas pequeñas como la del dataset, PostgreSQL frecuentemente decide **no usar el índice** y hace Seq Scan de todas formas. No es un error — con pocos registros, un Seq Scan puede ser más rápido que buscar en el índice. El impacto real se ve en producción con cientos de miles o millones de filas.

### 4.7 Índices recomendados para ShopEasy

```sql
-- FKs que se usan en JOINs frecuentes
CREATE INDEX idx_pedido_cliente      ON pedido(id_cliente);
CREATE INDEX idx_detalle_pedido      ON detalle_pedido(id_pedido);
CREATE INDEX idx_detalle_producto    ON detalle_pedido(id_producto);
CREATE INDEX idx_producto_categoria  ON producto(id_categoria);

-- Columnas usadas frecuentemente en filtros
CREATE INDEX idx_pedido_estado       ON pedido(estado);
CREATE INDEX idx_pedido_fecha        ON pedido(fecha);
CREATE INDEX idx_cliente_plan        ON cliente(plan);
```

---

## 5. Referencia rápida — todos los JOINs

```sql
-- INNER JOIN: solo coincidencias
SELECT c.nombre, p.id_pedido
FROM cliente c
INNER JOIN pedido p ON c.id_cliente = p.id_cliente;

-- LEFT JOIN: todos los clientes, con o sin pedido
SELECT c.nombre, p.id_pedido
FROM cliente c
LEFT JOIN pedido p ON c.id_cliente = p.id_cliente;

-- RIGHT JOIN: todos los pedidos (y los clientes si los hay)
-- equivale a: FROM pedido LEFT JOIN cliente
SELECT c.nombre, p.id_pedido
FROM cliente c
RIGHT JOIN pedido p ON c.id_cliente = p.id_cliente;

-- FULL OUTER JOIN: todos de ambas tablas
SELECT c.nombre, p.id_pedido
FROM cliente c
FULL OUTER JOIN pedido p ON c.id_cliente = p.id_cliente;

-- CROSS JOIN: todas las combinaciones posibles (sin condición de unión)
SELECT c.nombre, pr.nombre
FROM cliente c
CROSS JOIN producto pr;
-- Resultado: 10 clientes × 14 productos = 140 filas

-- Self-JOIN: tabla unida consigo misma
SELECT h.nombre AS subcategoria, p.nombre AS padre
FROM categoria h
JOIN categoria p ON h.id_padre = p.id_categoria;
```

---

## 6. Errores frecuentes

### En Self-JOIN

```sql
-- ❌ Error: ambigüedad — ¿de cuál instancia de categoria es 'nombre'?
SELECT nombre, id_padre
FROM categoria
JOIN categoria ON id_padre = id_categoria;
-- → ERROR: ambiguous column name "nombre"

-- ✅ Correcto: alias obligatorios
SELECT h.nombre, p.nombre
FROM categoria h
JOIN categoria p ON h.id_padre = p.id_categoria;
```

### En JOIN + CTE

```sql
-- ❌ Error: CTE definido pero no incluido en el JOIN
WITH totales AS (
    SELECT id_pedido, SUM(cantidad * precio_unitario) AS total
    FROM detalle_pedido GROUP BY id_pedido
)
SELECT c.nombre, p.id_pedido   -- falta el JOIN con 'totales'
FROM cliente c
JOIN pedido p ON c.id_cliente = p.id_cliente;
-- Compila, pero los totales no aparecen — el CTE se definió y no se usó

-- ✅ Correcto
WITH totales AS (
    SELECT id_pedido, SUM(cantidad * precio_unitario) AS total
    FROM detalle_pedido GROUP BY id_pedido
)
SELECT c.nombre, p.id_pedido, t.total
FROM cliente c
JOIN pedido  p ON c.id_cliente = p.id_cliente
JOIN totales t ON p.id_pedido  = t.id_pedido;
```

### En LEFT JOIN con filtro en WHERE

```sql
-- ❌ El filtro en WHERE cancela el efecto del LEFT JOIN
SELECT c.nombre, p.id_pedido
FROM cliente c
LEFT JOIN pedido p ON c.id_cliente = p.id_cliente
WHERE p.estado = 'entregado';
-- → CLI-09 y CLI-10 desaparecen: el WHERE elimina las filas con p.estado = NULL

-- ✅ El filtro en el ON mantiene el LEFT JOIN intacto
SELECT c.nombre, p.id_pedido
FROM cliente c
LEFT JOIN pedido p ON c.id_cliente = p.id_cliente
                  AND p.estado     = 'entregado';
-- → CLI-09 y CLI-10 aparecen con NULL en id_pedido
```

### En índices

```sql
-- ❌ Indexar la PK — PostgreSQL ya lo hace automáticamente
CREATE INDEX idx_cliente_pk ON cliente(id_cliente);
-- Inútil: las PKs siempre tienen índice automático

-- ❌ Indexar la columna equivocada (la PK del padre en lugar de la FK del hijo)
CREATE INDEX idx_cliente ON cliente(id_cliente);  -- PK de cliente → ya existe
-- Lo que falta es el índice en la FK:
CREATE INDEX idx_pedido_cliente ON pedido(id_cliente);  -- ✅ esto sí falta
```

---

## 7. Para el Evento V

El Evento V evalúa **JOINs completos + optimización + índices**. Asegúrate de poder:

- Escribir INNER, LEFT, RIGHT, FULL OUTER, CROSS y Self-JOIN sin mirar referencias.
- Usar JOIN con múltiples tablas (3 o más) en la misma consulta.
- Combinar un CTE con un JOIN para pre-calcular agregados.
- Leer un resultado de `EXPLAIN ANALYZE` e identificar el tipo de escaneo.
- Crear un índice en una FK y en una columna de filtro.
- Evitar el error de LEFT JOIN + filtro en WHERE que convierte el resultado en INNER JOIN.

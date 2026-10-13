# Taller independiente
**JOINs avanzados, optimización e índices | Base de datos: ShopEasy**

---

> Ejecuta `shopeasy_setup.sql` antes de comenzar.  

---

## Esquema de referencia

```
CATEGORIA     (id_categoria, nombre, id_padre → FK a id_categoria)
               id_padre es NULL en las categorías raíz (Electrónica, Ropa, Hogar, Deportes)
               Las subcategorías (Smartphones, Laptops, Camisetas, Pantalones) tienen id_padre

PRODUCTO      (id_producto, nombre, precio_cop, stock, id_categoria FK)
               PRD-13 y PRD-14 tienen id_categoria = NULL (sin categoría asignada)

CLIENTE       (id_cliente, nombre, email, ciudad, plan)
               plan: 'regular' | 'vip'
               CLI-09 y CLI-10 no tienen ningún pedido

PEDIDO        (id_pedido, id_cliente FK, fecha, estado)
               estado: 'entregado' | 'cancelado' | 'pendiente'

DETALLE_PEDIDO(id_detalle SERIAL, id_pedido FK, id_producto FK,
               cantidad, precio_unitario)
               El ingreso de una línea = cantidad × precio_unitario
```

---

## Bloque A — LEFT JOIN con datos faltantes

**1. Clientes y sus pedidos entregados**

El área comercial quiere saber cuántos pedidos entregados tiene cada cliente para identificar a los más activos. Quieren ver **todos los clientes**, incluso los que aún no han comprado.

Muestra: `nombre`, `plan` y una columna `pedidos_entregados` con el conteo. Los clientes sin pedidos deben aparecer con `0` (no con `NULL`). Ordena de mayor a menor.

> **Pista — el truco del filtro en LEFT JOIN:** Si pones `WHERE estado = 'entregado'` al final, los clientes sin pedidos desaparecerán del resultado porque sus filas tienen `estado = NULL`. El filtro de estado debe ir en la condición `ON` del JOIN, no en el `WHERE`.
>
> ```sql
> LEFT JOIN pedido p ON c.id_cliente = p.id_cliente
>                   AND p.estado     = 'entregado'   -- ← correcto
> ```
>
> ¿Cuántas filas esperas? **10** (todos los clientes). CLI-09 y CLI-10 deben aparecer con `0`.

---

**2. Productos y su ingreso total**

El equipo de inventario quiere un reporte de ingresos por producto, incluyendo los que todavía no se han vendido (para identificar stock sin movimiento).

Muestra: `nombre` del producto y una columna `ingreso_total_cop` con la suma de `cantidad × precio_unitario` de todas las líneas de detalle, **sin importar el estado del pedido**. Los productos sin ventas deben aparecer con `0`. Ordena por ingreso de mayor a menor.

> **Pista — LEFT JOIN y COALESCE sobre SUM:** Cuando un producto no tiene filas en `detalle_pedido`, el `LEFT JOIN` produce `NULL` en todas las columnas del lado derecho. `SUM(NULL)` devuelve `NULL`, no `0`. Usa `COALESCE(SUM(...), 0)` para convertirlo.
>
> ¿Cuántas filas esperas? **14** (todos los productos). PRD-13 (Zapatillas Running) y PRD-14 (Botella Deportiva) deben aparecer con `0`.

---

## Bloque B — Self-JOIN y JOIN + CTE

**3. Categorías raíz y la cantidad de productos asignados directamente**

La base de datos organiza las categorías en dos niveles: raíces (Electrónica, Ropa, Hogar, Deportes) y subcategorías (Smartphones, Laptops, etc.). Los productos se asignan a las **subcategorías**, no a las raíces.

Para cada categoría raíz (`id_padre IS NULL`), muestra su nombre y cuántos productos tienen asignada **exactamente esa categoría** (es decir, `producto.id_categoria` apunta directamente a la raíz). Incluye las raíces sin productos.

> **Pista — leer el resultado:** En este dataset todos los productos van a subcategorías, no a raíces. El resultado esperado es `0` para las cuatro raíces — eso no es un error, es la prueba de que la jerarquía está bien diseñada.
>
> ¿Cuántas filas esperas? **4** (las cuatro categorías raíz, todas con `0` en la columna de conteo).

---

**4. Valor total de cada pedido con datos del cliente** *(JOIN + CTE)*

El equipo financiero necesita un listado de pedidos de alto valor. Como el valor de cada pedido está distribuido en múltiples filas de `detalle_pedido`, primero hay que calcularlo y luego filtrarlo.

Pasos:
1. Crea un CTE llamado `pedido_total` que calcule, para cada pedido, la suma de `cantidad × precio_unitario`.
2. Une ese CTE con `pedido` y `cliente` para obtener: `nombre` del cliente, `plan`, `id_pedido`, `fecha`, `estado` y `total_cop`.
3. Muestra solo los pedidos cuyo `total_cop` supere **$5.000.000**. Ordena por `total_cop` de mayor a menor.

> **Pista — estructura del CTE:**
> ```sql
> WITH pedido_total AS (
>     SELECT id_pedido, SUM(cantidad * precio_unitario) AS total_cop
>     FROM detalle_pedido
>     GROUP BY id_pedido
> )
> SELECT c.nombre, ...
> FROM cliente c
> JOIN pedido        p  ON ...
> JOIN pedido_total  pt ON ...
> WHERE pt.total_cop > 5000000;
> ```
>
> ¿Cuántas filas esperas? **7 pedidos** superan ese umbral. El más alto involucra un MacBook y un iPhone en el mismo pedido.

---

## Bloque C — Self-JOIN con jerarquía y optimización

**5. ★ Subcategorías con su padre y precio promedio** *(Self-JOIN)*

La gerencia quiere comparar el rango de precios entre las subcategorías de la tienda. Para esto necesitas unir la tabla `categoria` consigo misma: una instancia representa la subcategoría (el "hijo") y la otra su categoría raíz (el "padre").

Muestra: nombre de la subcategoría, nombre de su categoría padre y el precio promedio (`AVG`) de los productos de esa subcategoría redondeado al entero más cercano. Ordena primero por categoría padre y luego por precio promedio de mayor a menor.

> **Pista — los dos alias son obligatorios:**
> ```sql
> FROM categoria hijo
> JOIN categoria padre ON hijo.id_padre = padre.id_categoria
> JOIN producto   pr   ON pr.id_categoria = hijo.id_categoria
> ```
> Necesitas tres tablas en el FROM: `categoria` dos veces (con alias distintos) y `producto`.
>
> ¿Cuántas filas esperas? **4** (una por subcategoría: Smartphones, Laptops, Camisetas, Pantalones). Las raíces Hogar y Deportes no aparecen porque no tienen subcategorías con productos.

---

**6. ★ Crear un índice y observar el plan de ejecución** *(EXPLAIN ANALYZE)*

Sigue estos pasos en orden:

**Paso 1 — ejecuta `EXPLAIN ANALYZE` antes del índice:**
```sql
EXPLAIN ANALYZE
SELECT cat.nombre AS categoria, pr.nombre AS producto, pr.precio_cop
FROM categoria cat
JOIN producto pr ON cat.id_categoria = pr.id_categoria
WHERE cat.id_categoria IN (5, 6);
```
Anota el tipo de escaneo que usa PostgreSQL sobre `producto` (¿Seq Scan o Index Scan?).

**Paso 2 — crea el índice:**
```sql
CREATE INDEX idx_producto_categoria ON producto(id_categoria);
```

**Paso 3 — vuelve a ejecutar exactamente la misma consulta del paso 1 con `EXPLAIN ANALYZE`.**

Compara los dos planes y agrega un comentario en tu SQL explicando:
- ¿Cambió el tipo de escaneo?
- Si no cambió, ¿por qué crees que PostgreSQL decidió ignorar el índice?

> **Pista — respuesta esperada:** Con solo 14 productos es probable que PostgreSQL siga usando `Seq Scan` después de crear el índice. Leer 14 filas completas es más rápido que ir al índice, buscar la posición y luego ir a la tabla. El planificador de PostgreSQL toma esa decisión automáticamente. Esto **no es un error** — es el comportamiento correcto para tablas pequeñas. En producción, con cientos de miles de productos, el índice sería fundamental.

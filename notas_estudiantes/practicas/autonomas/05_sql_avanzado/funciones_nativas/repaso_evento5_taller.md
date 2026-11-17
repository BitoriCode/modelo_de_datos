# Repaso Evento V — Taller de JOINs
**Todos los tipos de JOIN | Base de datos: ShopEasy**

---

> Ejecuta `shopeasy_setup.sql` (de la clase 22) antes de comenzar.  
> Trabaja de forma **individual**. Tienes **30 minutos**.  
> Cada ejercicio cubre un tipo de JOIN diferente — están indicados en el encabezado.

---

## Esquema de referencia

```
CATEGORIA     (id_categoria, nombre, id_padre → FK a id_categoria)
               Raíces (id_padre IS NULL): Electrónica, Ropa, Hogar, Deportes
               Subcategorías (id_padre NOT NULL): Smartphones, Laptops, Camisetas, Pantalones

PRODUCTO      (id_producto, nombre, precio_cop, stock, id_categoria FK)
               PRD-13 y PRD-14 no tienen categoría (id_categoria = NULL)
               PRD-13 y PRD-14 nunca han sido pedidos

CLIENTE       (id_cliente, nombre, email, ciudad, plan: 'regular' | 'vip')
               CLI-09 Juliana Soto y CLI-10 Kevin Álvarez no tienen ningún pedido

PEDIDO        (id_pedido, id_cliente FK, fecha, estado: 'entregado' | 'cancelado' | 'pendiente')

DETALLE_PEDIDO(id_detalle, id_pedido FK, id_producto FK, cantidad, precio_unitario)
               Ingreso de una línea = cantidad × precio_unitario
```

---

## Ejercicio 1 — INNER JOIN

El área de atención al cliente necesita el detalle completo de todas las ventas **entregadas**: qué cliente compró, qué producto, en qué cantidad y a qué precio.

Muestra: `nombre` del cliente, `nombre` del producto, `cantidad`, `precio_unitario` y una columna `subtotal` calculada como `cantidad × precio_unitario`. Filtra solo los pedidos con estado `'entregado'`. Ordena por nombre del cliente y luego por nombre del producto.

> **Tablas que necesitas unir:** `cliente` → `pedido` → `detalle_pedido` → `producto` (4 tablas, 3 JOINs).  
> **¿Cuántas filas esperas?** 26 líneas de detalle de pedidos entregados.

---

## Ejercicio 2 — LEFT JOIN

El equipo comercial quiere revisar la actividad de **todos los clientes**, incluidos los que aún no han realizado ningún pedido.

Muestra: `nombre`, `plan` del cliente y el total de pedidos que tiene en cualquier estado (`total_pedidos`). Los clientes sin pedidos deben aparecer con `0`, no con `NULL`. Ordena de mayor a menor por `total_pedidos`.

> **¿Cuántas filas esperas?** 10 (todos los clientes). CLI-09 y CLI-10 deben aparecer con `0`.  
> **Pista clave:** `COUNT(p.id_pedido)` cuenta solo las filas no-NULL del lado derecho, así que con LEFT JOIN los clientes sin pedidos ya obtendrán `0` automáticamente — no necesitas `COALESCE` para el conteo. Sí necesitas agrupar por `c.id_cliente, c.nombre, c.plan`.

---

## Ejercicio 3 — RIGHT JOIN

El equipo de inventario quiere saber cuántas unidades se han vendido de **cada producto**, incluyendo los que todavía no tienen ninguna venta registrada.

Muestra: `nombre` del producto, `precio_cop` y `unidades_vendidas` (suma de `cantidad` de todas sus líneas de detalle, sin filtrar por estado de pedido). Los productos sin ventas deben aparecer con `0`. Ordena por `unidades_vendidas` de mayor a menor.

> **¿Cuántas filas esperas?** 14 (todos los productos). PRD-13 y PRD-14 aparecen con `0`.  
> **Pista clave:** `detalle_pedido` está a la **izquierda**, `producto` a la **derecha** del RIGHT JOIN — así aparecen todos los productos aunque no tengan líneas de detalle. Usa `COALESCE(SUM(dp.cantidad), 0)` para convertir el NULL en 0.

---

## Ejercicio 4 — FULL OUTER JOIN

El equipo de catálogo quiere una vista completa de la relación entre categorías y productos, identificando tanto las categorías sin productos como los productos sin categoría asignada.

Muestra: `nombre` de la categoría y `nombre` del producto. Donde no haya relación en alguno de los dos lados, debe aparecer el texto `'— sin asignar —'` en lugar de NULL. Ordena por nombre de categoría (nulls al final) y luego por nombre de producto.

> **¿Cuántas filas esperas?** 18 filas en total:
> - 12 productos que sí tienen categoría asignada (subcategorías 5–8).
> - 4 categorías raíz (1–4) que no tienen productos apuntando directamente a ellas.
> - 2 productos sin categoría (PRD-13 y PRD-14).  
>
> **Pista clave:** Usa `COALESCE(cat.nombre, '— sin asignar —')` y `COALESCE(pr.nombre, '— sin asignar —')` en el SELECT.

---

## Ejercicio 5 — CROSS JOIN

El área de estrategia quiere generar una tabla con **todas las combinaciones posibles** de clientes VIP y categorías raíz, como punto de partida para un análisis de potencial de mercado por segmento.

Muestra: `nombre` del cliente VIP y `nombre` de la categoría raíz. Ordena por nombre de cliente y luego por nombre de categoría.

> **¿Cuántas filas esperas?** 4 clientes VIP × 4 categorías raíz = **16 combinaciones**.  
> **Pista clave:** En CROSS JOIN no hay condición `ON`. Filtra los clientes VIP con `WHERE c.plan = 'vip'` y las categorías raíz con `WHERE cat.id_padre IS NULL`. Si filtras en el `WHERE`, puedes escribirlos en la misma cláusula con `AND`.

---

## Ejercicio 6 — Self-JOIN

La gerencia quiere ver el catálogo organizado jerárquicamente: cada subcategoría con el nombre de su categoría padre y el precio promedio de sus productos.

Muestra: `subcategoria` (nombre de la categoría hija), `categoria_padre` (nombre de la raíz) y `precio_promedio_cop` redondeado al entero más cercano. Ordena por nombre de categoría padre y luego por precio promedio de mayor a menor.

> **¿Cuántas filas esperas?** 4 (una por subcategoría: Smartphones, Laptops, Camisetas, Pantalones). Las raíces Hogar y Deportes no aparecen porque no tienen subcategorías con productos.  
> **Pista clave:** Necesitas la tabla `categoria` **dos veces** con alias distintos (`hijo` y `padre`) y un tercer JOIN con `producto`. El patrón es:
> ```
> FROM categoria hijo
> JOIN categoria padre ON hijo.id_padre   = padre.id_categoria
> JOIN producto   pr   ON pr.id_categoria = hijo.id_categoria
> ```

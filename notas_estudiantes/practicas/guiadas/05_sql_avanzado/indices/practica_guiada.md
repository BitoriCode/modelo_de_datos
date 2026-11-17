# Práctica guiada — Clase 22
**JOINs avanzados, optimización e índices | Base de datos: ShopEasy**

---

> Ejecuta [shopeasy_setup.sql](../../../../recursos/datasets/shopeasy_setup.sql) antes de comenzar.

---

## Esquema de referencia

```
CATEGORIA     (id_categoria, nombre, id_padre → FK a id_categoria)
PRODUCTO      (id_producto, nombre, precio_cop, stock, id_categoria FK)
CLIENTE       (id_cliente, nombre, email, ciudad, plan)
               plan: 'regular' | 'vip'
PEDIDO        (id_pedido, id_cliente FK, fecha, estado)
               estado: 'entregado' | 'cancelado' | 'pendiente'
DETALLE_PEDIDO(id_detalle SERIAL, id_pedido FK, id_producto FK,
               cantidad, precio_unitario)
```

**Datos clave:**
- `CLI-09` y `CLI-10` no tienen pedidos.
- `PRD-13` (Zapatillas Running) y `PRD-14` (Botella Deportiva) nunca fueron pedidos y no tienen categoría.
- Categorías `3` (Hogar) y `4` (Deportes) no tienen productos asignados.

---

## Bloque A — Self-JOIN

**1.** Lista cada categoría junto con el nombre de su categoría padre. Las categorías raíz (sin padre) deben aparecer con el texto `'— raíz —'` en la columna padre. Ordena por padre y luego por nombre de categoría.

**2.** Muestra todos los pares de productos dentro de la misma categoría (categoría hija) junto con la diferencia de precio entre ellos. Evita que el par `(A, B)` aparezca también como `(B, A)` y descarta los productos sin categoría.

---

## Bloque B — JOIN + CTE

**3.** Usa un CTE llamado `ventas_producto` que calcule, para cada producto, la cantidad total vendida (`SUM(cantidad)`) y el ingreso total (`SUM(cantidad * precio_unitario)`) considerando **solo pedidos entregados**. Luego une ese CTE con `producto` y `categoria` para mostrar: nombre del producto, nombre de la categoría, cantidad vendida e ingreso total. Incluye los productos que nunca se han vendido (con 0 en lugar de NULL).

---

## Bloque C — EXPLAIN ANALYZE e índices

**4.** Ejecuta `EXPLAIN ANALYZE` sobre la siguiente consulta y anota:
- ¿Qué tipo de nodo usa PostgreSQL para el JOIN? (Hash Join, Nested Loop, etc.)
- ¿Qué tipo de escaneo usa sobre `detalle_pedido`? (Seq Scan o Index Scan)

```sql
SELECT p.nombre, SUM(dp.cantidad) AS unidades_vendidas
FROM producto p
JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
GROUP BY p.nombre
ORDER BY unidades_vendidas DESC;
```

Luego crea un índice sobre `detalle_pedido(id_producto)`, vuelve a ejecutar `EXPLAIN ANALYZE` y observa si el plan cambia.

**5.** Crea los siguientes índices y justifica brevemente (en un comentario SQL) por qué cada uno puede ser útil:
- Índice en `pedido(id_cliente)`
- Índice en `pedido(estado)`
- Índice compuesto en `detalle_pedido(id_pedido, id_producto)`

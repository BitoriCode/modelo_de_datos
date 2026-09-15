# Clase 15 — Subconsultas avanzadas y JOINs
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**
**Herramienta:** PostgreSQL + pgAdmin
---

## ¿Por qué existen los JOINs?

Cuando normalizamos una base de datos separamos la información en múltiples tablas para eliminar redundancia. En AeroPass, en lugar de repetir el nombre del pasajero en cada reserva, lo almacenamos una sola vez en `pasajero` y lo referenciamos con `id_pasajero`.

Eso es eficiente para almacenar, pero crea un problema para consultar: **la información útil está repartida en varias tablas**.

```
Sin normalización (redundante):
┌──────────────┬──────────┬────────────┐
nom_pasajero  │ id_vuelo   │ aerolinea  │
Carlos Ruiz   │ VUE-101    │ Avianca    │  ← “Carlos Ruiz” repetido
Carlos Ruiz   │ VUE-205    │ LATAM      │  ← “Carlos Ruiz” repetido
Laura Mesa    │ VUE-101    │ Avianca    │
└──────────────┴──────────┴────────────┘

Con normalización (sin redundancia):
PASAJERO: PAS-001 │ Carlos Ruiz │ ...
RESERVA:  PAS-001 │ VUE-101     │ Económica
          PAS-001 │ VUE-205     │ Ejecutiva

JOIN reconstituye la vista combinada usando la FK como puente.
```

> **JOIN es el inverso de la normalización:** la normalización separa datos para almacenarlos sin redundancia; JOIN los vuelve a combinar para consultarlos con sentido. La FK es el hilo que los une.

### El producto cartesiano — por qué siempre se escribe ON

Sin una condición `ON`, un JOIN combina **cada fila de A con cada fila de B**. Eso se llama **producto cartesiano** y casi nunca es lo que se quiere:

```sql
-- ⚠️ Producto cartesiano: 8 pasajeros × 20 reservas = 160 filas sin sentido
SELECT * FROM pasajero CROSS JOIN reserva;
-- (o sin ON: SELECT * FROM pasajero, reserva)
```

La condición `ON` filtra solo las combinaciones válidas, reduciendo de 160 a 20:

```sql
-- Con ON: solo las 20 filas que tienen sentido real
SELECT * FROM pasajero p
INNER JOIN reserva r ON p.id_pasajero = r.id_pasajero;
```

---

## 1. Subconsulta correlacionada

Una **subconsulta correlacionada** es una subconsulta que hace referencia a una columna de la consulta exterior. A diferencia de una subconsulta normal (que se ejecuta una sola vez), una subconsulta correlacionada se ejecuta **una vez por cada fila** de la consulta exterior.

```
Subconsulta normal        → se ejecuta 1 vez, resultado fijo para toda la consulta
Subconsulta correlacionada → se ejecuta N veces, una por cada fila exterior
```

### 1.1 Subconsulta correlacionada en el SELECT

Permite calcular un valor asociado a cada fila del resultado:

```sql
-- Para cada pasajero, cuántas reservas tiene
SELECT
    p.nombre_pasajero,
    (SELECT COUNT(*) FROM reserva r WHERE r.id_pasajero = p.id_pasajero) AS num_reservas
FROM pasajero p;
```

La subconsulta referencia `p.id_pasajero` — es decir, para la fila de pasajero que PostgreSQL está procesando en ese momento. Cuando cambia la fila exterior, la subconsulta se vuelve a ejecutar con el nuevo valor.

### 1.2 Subconsulta correlacionada en el WHERE

```sql
-- Pasajeros con más de 2 reservas
SELECT nombre_pasajero
FROM pasajero p
WHERE (SELECT COUNT(*) FROM reserva r WHERE r.id_pasajero = p.id_pasajero) > 2;
```

> Este resultado es equivalente a `GROUP BY id_pasajero HAVING COUNT(*) > 2`, pero la subconsulta correlacionada es más flexible — no requiere GROUP BY y puede referenciarse en cualquier parte de la consulta.

---

## 2. EXISTS y NOT EXISTS

`EXISTS` es un operador que devuelve `TRUE` si la subconsulta retorna **al menos una fila**, y `FALSE` si no retorna ninguna. Es más eficiente que `IN` para verificar existencia porque detiene la búsqueda en cuanto encuentra la primera coincidencia.

### 2.1 EXISTS

```sql
-- Pasajeros que tienen al menos una reserva
SELECT * FROM pasajero p
WHERE EXISTS (
    SELECT 1 FROM reserva r WHERE r.id_pasajero = p.id_pasajero
);
```

> El `SELECT 1` es convención: a `EXISTS` no le importa qué columnas devuelve la subconsulta, solo si devuelve filas o no. Podría escribirse `SELECT *`, `SELECT 42`, o cualquier cosa — el resultado es idéntico. Se usa `SELECT 1` por claridad y eficiencia.

El motor de PostgreSQL aplica **evaluación en cortocircuito**: en cuanto encuentra la primera fila que cumple la condición, devuelve `TRUE` y deja de buscar. Esto lo hace más eficiente que `IN` cuando la tabla interna es grande.

### 2.2 NOT EXISTS

```sql
-- Pasajeros que no tienen ninguna reserva
SELECT * FROM pasajero p
WHERE NOT EXISTS (
    SELECT 1 FROM reserva r WHERE r.id_pasajero = p.id_pasajero
);

-- Vuelos con al menos una reserva en clase 'Primera'
SELECT id_vuelo, origen_vuelo, destino_vuelo FROM vuelo v
WHERE EXISTS (
    SELECT 1 FROM reserva r
    WHERE r.id_vuelo = v.id_vuelo AND r.clase = 'Primera'
);
```

### 2.3 EXISTS vs IN — comparación

Las tres formas siguientes producen el mismo resultado:

```sql
-- Con IN
SELECT * FROM pasajero
WHERE id_pasajero IN (SELECT id_pasajero FROM reserva);

-- Con EXISTS
SELECT * FROM pasajero p
WHERE EXISTS (SELECT 1 FROM reserva r WHERE r.id_pasajero = p.id_pasajero);

-- Con INNER JOIN (ver sección 3)
SELECT DISTINCT p.*
FROM pasajero p
INNER JOIN reserva r ON p.id_pasajero = r.id_pasajero;
```

| | `IN` | `EXISTS` | `INNER JOIN` |
|---|---|---|---|
| Detectar existencia | ✓ | ✓ | ✓ |
| Traer columnas de ambas tablas | ✗ | ✗ | ✓ |
| Eficiencia en tablas grandes | Media | Alta | Alta |
| Legibilidad | Alta | Media | Alta |

---

## 3. INNER JOIN

`JOIN` conecta dos tablas produciendo una **tabla combinada** con columnas de ambas. Es la herramienta que permite mostrar datos de múltiples tablas en una sola consulta.

### 3.1 Sintaxis

```sql
SELECT tabla_a.col1, tabla_b.col2
FROM tabla_a
INNER JOIN tabla_b ON tabla_a.pk = tabla_b.fk;
```

La condición `ON` especifica cómo se relacionan las tablas — normalmente una PK con su FK correspondiente.

### 3.2 Cómo funciona INNER JOIN — diagrama

```
PASAJERO (8 filas)              RESERVA (20 filas)
┌─────────┬──────────────┐     ┌─────────┬─────────┬───────────┐
│PAS-001  │Carlos Ruiz    │ ◄── │PAS-001  │VUE-101  │Económica  │
│         │               │ ◄── │PAS-001  │VUE-205  │Ejecutiva │
│         │               │ ◄── │PAS-001  │VUE-408  │Primera   │
│PAS-002  │Laura Mesa     │ ◄── │PAS-002  │VUE-101  │Económica  │
│...      │...            │     │...      │...      │...       │
└─────────┴──────────────┘     └─────────┴─────────┴───────────┘
                                        ↓ ON id_pasajero = id_pasajero

RESULTADO: 20 filas (una por reserva, con el nombre del pasajero incorporado)
┌────────────────┬─────────┬──────────┐
│nombre_pasajero │id_vuelo │clase     │
│Carlos Ruiz     │VUE-101  │Económica  │
│Carlos Ruiz     │VUE-205  │Ejecutiva │
│Carlos Ruiz     │VUE-408  │Primera   │
│Laura Mesa      │VUE-101  │Económica  │
│...             │...      │...       │
└────────────────┴─────────┴──────────┘
Nota: los pasajeros sin reservas no aparecen.
```

### 3.3 Ejemplo básico — 2 tablas

```sql
-- Nombre del pasajero junto con su clase de reserva y precio
SELECT p.nombre_pasajero, r.clase, r.precio_cop
FROM pasajero p
INNER JOIN reserva r ON p.id_pasajero = r.id_pasajero;
```

`INNER JOIN` devuelve **solo** las filas que tienen coincidencia en ambas tablas. Un pasajero sin reservas **no aparece** en el resultado.

### 3.4 Alias de tabla — obligatorio con JOIN

Cuando dos tablas tienen columnas con el mismo nombre, hay que calificar con el alias de tabla:

```sql
-- ERROR: columna ambigua
SELECT id_pasajero FROM pasajero JOIN reserva ON ...;

-- Correcto: alias p y r para calificar
SELECT p.id_pasajero, p.nombre_pasajero, r.clase
FROM pasajero p
INNER JOIN reserva r ON p.id_pasajero = r.id_pasajero;
```

### 3.5 JOIN con filtro y agregación

```sql
-- Reservas en clase 'Primera' con nombre del pasajero y ruta
SELECT p.nombre_pasajero, v.origen_vuelo, v.destino_vuelo, r.precio_cop
FROM pasajero p
INNER JOIN reserva  r ON p.id_pasajero = r.id_pasajero
INNER JOIN vuelo    v ON r.id_vuelo    = v.id_vuelo
WHERE r.clase = 'Primera';

-- Total pagado por cada pasajero
SELECT p.nombre_pasajero, COUNT(*) AS num_reservas, SUM(r.precio_cop) AS total_pagado
FROM pasajero p
INNER JOIN reserva r ON p.id_pasajero = r.id_pasajero
GROUP BY p.id_pasajero, p.nombre_pasajero
ORDER BY total_pagado DESC;
```

---

## 4. LEFT JOIN

`LEFT JOIN` devuelve **todas** las filas de la tabla de la izquierda (la que está en `FROM`), más las coincidencias de la tabla de la derecha. Cuando no hay coincidencia, las columnas de la derecha aparecen como `NULL`.

### 4.1 Cómo funciona LEFT JOIN — diagrama

La diferencia clave respecto a INNER JOIN: las filas de la izquierda que no tienen coincidencia **sí aparecen**, pero con `NULL` en las columnas del lado derecho.

```
PASAJERO (8 filas)              RESERVA (20 filas)
┌─────────┬──────────────┐     ┌─────────┬─────────┬───────────┐
│PAS-001  │Carlos Ruiz    │ ◄── │PAS-001  │VUE-101  │Económica  │
│PAS-002  │Laura Mesa     │ ◄── │PAS-002  │VUE-101  │Económica  │
│...      │...            │     │...      │...      │...       │
│PAS-SIN  │Sin Reservas   │ ✕   (sin coincidencia en RESERVA)        
└─────────┴──────────────┘     └─────────┴─────────┴───────────┘
                                        ↓ LEFT JOIN

RESULTADO: todas las filas de PASAJERO + coincidencias de RESERVA
┌────────────────┬─────────┬──────────┐
│nombre_pasajero │id_vuelo │clase     │
│Carlos Ruiz     │VUE-101  │Económica  │
│Carlos Ruiz     │VUE-205  │Ejecutiva │
│...             │...      │...       │
│Sin Reservas    │NULL     │NULL      │  ← aparece con NULL
└────────────────┴─────────┴──────────┘
```

### 4.2 Ejemplo básico

```sql
-- TODOS los pasajeros, con o sin reservas
SELECT p.nombre_pasajero, r.id_vuelo, r.clase
FROM pasajero p
LEFT JOIN reserva r ON p.id_pasajero = r.id_pasajero;
-- Los pasajeros sin reservas aparecen con NULL en las columnas de reserva
```

### 4.3 Encontrar filas sin coincidencia (anti-join)

```sql
-- Pasajeros que NO tienen ninguna reserva
SELECT p.nombre_pasajero
FROM pasajero p
LEFT JOIN reserva r ON p.id_pasajero = r.id_pasajero
WHERE r.id_pasajero IS NULL;
```

> Truco: después de un `LEFT JOIN`, las filas sin coincidencia tienen `NULL` en todas las columnas de la tabla derecha. Filtrando por `WHERE columna_derecha IS NULL` se obtienen exactamente las filas sin coincidencia.

### 4.4 LEFT JOIN con GROUP BY

```sql
-- Todos los vuelos con su cantidad de reservas (incluye vuelos con 0)
SELECT
    v.id_vuelo,
    v.origen_vuelo || ' → ' || v.destino_vuelo AS ruta,
    COUNT(r.id_pasajero) AS num_reservas       -- COUNT(col) ignora NULL
FROM vuelo v
LEFT JOIN reserva r ON v.id_vuelo = r.id_vuelo
GROUP BY v.id_vuelo, v.origen_vuelo, v.destino_vuelo
ORDER BY num_reservas DESC;
```

> **Atención:** usar `COUNT(r.id_pasajero)` y no `COUNT(*)`. Con `COUNT(*)`, las filas sin coincidencia contarían como 1 en lugar de 0.

---

## 5. JOIN con múltiples tablas

Se encadenan tantos `JOIN` como tablas se necesiten. Cada `JOIN` agrega una tabla al resultado:

```sql
-- 4 tablas: pasajero + reserva + vuelo + aerolinea
SELECT
    p.nombre_pasajero,
    a.nombre_aerolinea,
    v.origen_vuelo,
    v.destino_vuelo,
    r.clase,
    r.precio_cop
FROM pasajero p
INNER JOIN reserva   r ON p.id_pasajero  = r.id_pasajero
INNER JOIN vuelo     v ON r.id_vuelo     = v.id_vuelo
INNER JOIN aerolinea a ON v.id_aerolinea = a.id_aerolinea
ORDER BY p.nombre_pasajero;
```

**Regla:** cada `JOIN` necesita su propio `ON` con la condición de unión correspondiente.

---

## 6. INNER vs LEFT vs RIGHT — resumen

| Tipo | Filas que devuelve |
|---|---|
| `INNER JOIN` | Solo las filas con coincidencia en **ambas** tablas |
| `LEFT JOIN` | **Todas** las filas de la izquierda + coincidencias de la derecha |
| `RIGHT JOIN` | Coincidencias de la izquierda + **todas** las filas de la derecha |
| `FULL JOIN` | Todas las filas de ambas tablas, con NULL donde no haya coincidencia |

> `RIGHT JOIN` es equivalente a un `LEFT JOIN` con las tablas en orden invertido — en la práctica casi siempre se usa `LEFT JOIN`.

---

## 7. Errores frecuentes

| Error | Causa | Solución |
|---|---|---|
| `column "col" is ambiguous` | Dos tablas tienen la misma columna sin calificar | Usar `alias.columna` |
| `COUNT(*)` da 1 en lugar de 0 | Usar `COUNT(*)` con LEFT JOIN | Usar `COUNT(col_tabla_derecha)` |
| Resultado con más filas de lo esperado | Relación N:M sin `DISTINCT` | Agregar `DISTINCT` o revisar la lógica |
| `ON` mal escrito | Condición incorrecta genera producto cartesiano | Verificar las columnas FK/PK |

---

## Referencia rápida

```sql
-- Subconsulta correlacionada escalar
SELECT col, (SELECT f(x) FROM t2 WHERE t2.fk = t1.pk) AS val FROM t1;

-- EXISTS
SELECT * FROM t1 WHERE EXISTS (SELECT 1 FROM t2 WHERE t2.fk = t1.pk);

-- NOT EXISTS
SELECT * FROM t1 WHERE NOT EXISTS (SELECT 1 FROM t2 WHERE t2.fk = t1.pk);

-- INNER JOIN
SELECT a.c1, b.c2 FROM t1 a INNER JOIN t2 b ON a.pk = b.fk;

-- LEFT JOIN
SELECT a.c1, b.c2 FROM t1 a LEFT JOIN t2 b ON a.pk = b.fk;

-- Anti-join (filas sin coincidencia)
SELECT a.c1 FROM t1 a LEFT JOIN t2 b ON a.pk = b.fk WHERE b.fk IS NULL;

-- JOIN encadenado
SELECT ... FROM t1 a JOIN t2 b ON a.pk=b.fk JOIN t3 c ON b.pk=c.fk;
```

---

## Vocabulario esencial

| Término | Definición |
|---|---|
| **Subconsulta correlacionada** | Subconsulta que referencia una columna de la consulta exterior; se ejecuta una vez por fila |
| **EXISTS** | Operador que devuelve TRUE si la subconsulta retorna al menos una fila |
| **NOT EXISTS** | Operador que devuelve TRUE si la subconsulta no retorna ninguna fila |
| **Cortocircuito** | Optimización de EXISTS: para en cuanto encuentra la primera coincidencia |
| **JOIN** | Operación que combina filas de dos tablas según una condición de emparejamiento |
| **INNER JOIN** | JOIN que devuelve solo las filas con coincidencia en ambas tablas |
| **LEFT JOIN** | JOIN que devuelve todas las filas de la tabla izquierda + coincidencias de la derecha |
| **Producto cartesiano** | Combinación de cada fila de A con cada fila de B, sin condición (resultado sin sentido) |
| **Anti-join** | Técnica con LEFT JOIN + IS NULL para encontrar filas sin coincidencia |
| **Alias de tabla** | Nombre corto asignado a una tabla en la consulta (`FROM pasajero p`) |
| **ON** | Cláusula que define la condición de emparejamiento en un JOIN |

---

## Preguntas de autoevaluación

1. Explica con tus palabras por qué existen los JOINs. ¿Qué relación tienen con la normalización?
2. ¿Qué es un producto cartesiano y en qué situación ocurre en SQL?
3. Tienes una tabla `empleado` y una tabla `departamento`. Escribe un `INNER JOIN` que muestre el nombre de cada empleado y el nombre de su departamento.
4. ¿Cuál es la diferencia entre `INNER JOIN` y `LEFT JOIN`? Da un ejemplo de cuándo usar cada uno.
5. ¿Por qué `COUNT(*)` puede dar resultados incorrectos con `LEFT JOIN`? ¿Qué se debe usar en su lugar?
6. Una subconsulta con `IN` y una con `EXISTS` pueden dar el mismo resultado. ¿Cuándo preferirías `EXISTS` y por qué?
7. ¿Cuál es la diferencia entre una subconsulta normal y una correlacionada? ¿Cuántas veces se ejecuta cada una?
8. Escribe la consulta para encontrar todos los clientes que **no** han realizado ningún pedido, usando: (a) `NOT EXISTS`, (b) `LEFT JOIN + IS NULL`. ¿Dan el mismo resultado?

---

## Para recordar

```
Normalización separa datos  →  JOIN los reconstituye para consultar

Producto cartesiano         →  A × B sin ON  =  caos (evitar)
INNER JOIN                  →  solo filas con coincidencia en ambas tablas
LEFT JOIN                   →  todas las filas de la izquierda + NULL si no hay match

Subconsulta correlacionada  →  referencia la fila exterior, corre N veces
EXISTS / NOT EXISTS         →  pregunta sí/no sobre existencia (cortocircuito)

Anti-join                   →  LEFT JOIN ... WHERE columna_derecha IS NULL
COUNT con LEFT JOIN         →  COUNT(col_derecha), no COUNT(*)
```

---

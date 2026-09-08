# Clase 14 — DML: SELECT, filtros y funciones de agregación.

---

A partir de aquí el enfoque cambia: ya no definimos estructuras, sino que **consultamos y manipulamos los datos** que viven dentro de ellas.

---

## 1. ¿Qué es DML?

**DML** = *Data Manipulation Language* — el subconjunto de SQL que opera sobre los datos almacenados.

| Comando | Operación CRUD | Qué hace |
|---|---|---|
| `SELECT` | **R**ead | Consulta datos (no los modifica) |
| `INSERT` | **C**reate | Inserta nuevas filas |
| `UPDATE` | **U**pdate | Modifica filas existentes |
| `DELETE` | **D**elete | Elimina filas |

Esta clase cubre exclusivamente `SELECT` — el comando más frecuente en SQL y el más expresivo.

> **Diferencia clave con DDL:** DDL define el *contenedor* (tablas y columnas). DML trabaja con el *contenido* (filas y valores). Un `SELECT` nunca modifica nada en la base de datos.

---

## 2. Tablas de ejemplo

Los ejemplos de esta clase usan el esquema **AeroPass** trabajado en clase 13.

```
AEROLINEA (id_aerolinea, nombre_aerolinea)
PASAJERO  (id_pasajero, nombre_pasajero, email_pasajero)
VUELO     (id_vuelo, origen_vuelo, destino_vuelo, id_aerolinea)
RESERVA   (id_pasajero, id_vuelo, fecha_reserva, num_asiento, clase, precio_cop)
            PK compuesta: (id_pasajero, id_vuelo)
```

**Muestra de datos — tabla `reserva`:**

| id_pasajero | id_vuelo | fecha_reserva | clase | precio_cop |
|---|---|---|---|---|
| PAS-001 | VUE-101 | 2024-08-10 | Económica | 280 000 |
| PAS-001 | VUE-205 | 2024-08-16 | Ejecutiva | 720 000 |
| PAS-001 | VUE-408 | 2024-09-02 | Primera | 1 500 000 |
| PAS-002 | VUE-101 | 2024-08-10 | Económica | 220 000 |
| PAS-004 | VUE-613 | 2024-08-28 | Primera | 1 350 000 |
| PAS-006 | VUE-815 | 2024-08-30 | Económica | 290 000 |
| … | … | … | … | … |

*(20 reservas en total, 3 aerolíneas, 8 pasajeros, 8 vuelos)*

---

## 3. SELECT básico

La estructura mínima de toda consulta SQL:

```sql
SELECT columnas
FROM tabla;
```

### 3.1 Seleccionar columnas

```sql
-- Todas las columnas (útil para explorar, evitar en producción)
SELECT * FROM pasajero;

-- Columnas específicas
SELECT nombre_pasajero, email_pasajero FROM pasajero;
```

> **Buena práctica:** en sistemas reales se prefiere listar las columnas explícitamente en lugar de `SELECT *`. Es más claro y más eficiente porque el motor no necesita resolver el esquema completo.

### 3.2 Alias con AS

`AS` renombra una columna **solo en el resultado** — no modifica la tabla.

```sql
SELECT nombre_pasajero AS nombre, email_pasajero AS correo
FROM pasajero;
```

`AS` es opcional pero se recomienda escribirlo:

```sql
-- Con AS (recomendado)
SELECT nombre_pasajero AS nombre FROM pasajero;

-- Sin AS (válido pero menos legible)
SELECT nombre_pasajero nombre FROM pasajero;
```

### 3.3 Expresiones calculadas

Se pueden incluir operaciones matemáticas y concatenaciones directamente en el `SELECT`:

```sql
-- Precio con IVA del 19%
SELECT id_vuelo, precio_cop, ROUND(precio_cop * 1.19, 0) AS precio_con_iva
FROM reserva;

-- Concatenar texto con ||
SELECT id_vuelo, origen_vuelo || ' → ' || destino_vuelo AS ruta
FROM vuelo;
```

### 3.4 DISTINCT — eliminar duplicados

`DISTINCT` devuelve solo los valores únicos de las columnas indicadas:

```sql
-- ¿Qué clases de reserva existen?
SELECT DISTINCT clase FROM reserva;
-- Resultado: Económica | Ejecutiva | Primera

-- ¿Qué destinos hay?
SELECT DISTINCT destino_vuelo FROM vuelo;
```

---

## 4. WHERE — filtrar filas

`WHERE` establece la condición que cada fila debe cumplir para aparecer en el resultado:

```sql
SELECT columnas
FROM tabla
WHERE condición;
```

### 4.1 Comparadores básicos

| Operador | Significado | Ejemplo |
|---|---|---|
| `=` | Igual | `clase = 'Ejecutiva'` |
| `<>` ó `!=` | Distinto | `clase <> 'Económica'` |
| `>` | Mayor que | `precio_cop > 500000` |
| `<` | Menor que | `precio_cop < 300000` |
| `>=` | Mayor o igual | `precio_cop >= 700000` |
| `<=` | Menor o igual | `precio_cop <= 200000` |

```sql
SELECT * FROM reserva WHERE clase = 'Primera';
SELECT * FROM reserva WHERE precio_cop > 1000000;
SELECT * FROM pasajero WHERE id_pasajero = 'PAS-003';
```

### 4.2 AND, OR, NOT

```sql
-- AND: ambas condiciones deben cumplirse
SELECT * FROM reserva
WHERE clase = 'Ejecutiva' AND precio_cop < 800000;

-- OR: basta con que una condición se cumpla
SELECT * FROM reserva
WHERE clase = 'Ejecutiva' OR clase = 'Primera';

-- NOT: niega la condición
SELECT * FROM reserva
WHERE NOT clase = 'Económica';
```

> **Precedencia:** `AND` se evalúa antes que `OR`. Cuando los mezcles, usa paréntesis para dejar clara la intención:
> ```sql
> -- ¿qué agrupa este AND/OR?
> WHERE clase = 'Primera' OR clase = 'Ejecutiva' AND precio_cop > 700000
> -- equivale a:
> WHERE clase = 'Primera' OR (clase = 'Ejecutiva' AND precio_cop > 700000)
> -- si quieres otra cosa:
> WHERE (clase = 'Primera' OR clase = 'Ejecutiva') AND precio_cop > 700000
> ```

### 4.3 BETWEEN — rangos

`BETWEEN` verifica si un valor está dentro de un rango. **Los extremos están incluidos.**

```sql
SELECT * FROM reserva WHERE precio_cop BETWEEN 600000 AND 900000;

-- Equivalente exacto:
SELECT * FROM reserva WHERE precio_cop >= 600000 AND precio_cop <= 900000;

-- Funciona también con fechas
SELECT * FROM reserva WHERE fecha_reserva BETWEEN '2024-08-01' AND '2024-08-31';
```

### 4.4 IN — lista de valores

`IN` comprueba si el valor está en una lista. Es equivalente a encadenar varios `OR`, pero más legible:

```sql
-- Con IN
SELECT * FROM reserva WHERE clase IN ('Ejecutiva', 'Primera');

-- NOT IN: excluir valores
SELECT * FROM vuelo WHERE id_aerolinea NOT IN ('AER-1', 'AER-3');
```

### 4.5 LIKE / ILIKE — búsqueda de patrones

`LIKE` busca coincidencias parciales en texto usando dos comodines:

| Comodín | Representa |
|---|---|
| `%` | Cero o más caracteres cualquiera |
| `_` | Exactamente un carácter |

```sql
-- Pasajeros cuyo nombre empiece con 'A'
SELECT * FROM pasajero WHERE nombre_pasajero LIKE 'A%';

-- Pasajeros cuyo nombre contenga 'ar' en cualquier posición
SELECT * FROM pasajero WHERE nombre_pasajero LIKE '%ar%';

-- Vuelos con destino de exactamente 4 letras
SELECT * FROM vuelo WHERE destino_vuelo LIKE '____';
```

**`LIKE` vs `ILIKE`:**

| | Sensible a mayúsculas | Ejemplo |
|---|---|---|
| `LIKE` | Sí | `'ana%'` no encuentra `'Ana Torres'` |
| `ILIKE` | No | `'ana%'` sí encuentra `'Ana Torres'` |

```sql
-- ILIKE: no importa si es mayúscula o minúscula
SELECT * FROM pasajero WHERE nombre_pasajero ILIKE 'a%';
-- Devuelve: Ana Torres, Andrés Morales
```

### 4.6 IS NULL / IS NOT NULL

`NULL` representa la **ausencia de valor** — no es cero, no es un texto vacío. Por esta razón, no se puede comparar con `=`:

```sql
-- ✅ Correcto: pasajeros sin email registrado
SELECT * FROM pasajero WHERE email_pasajero IS NULL;

-- ✅ Correcto: pasajeros con email registrado
SELECT * FROM pasajero WHERE email_pasajero IS NOT NULL;
```

```sql
-- ❌ Incorrecto: siempre devuelve 0 filas
SELECT * FROM pasajero WHERE email_pasajero = NULL;
```

> `NULL = NULL` no es verdadero en SQL. `NULL` no es igual a nada, ni siquiera a sí mismo. La única forma de detectar un nulo es con `IS NULL`.

---

## 5. ORDER BY y LIMIT

### 5.1 ORDER BY — ordenar resultados

`ORDER BY` ordena las filas del resultado. No afecta los datos almacenados.

```sql
-- De mayor a menor precio
SELECT * FROM reserva ORDER BY precio_cop DESC;

-- De menor a mayor (por defecto si se omite ASC/DESC)
SELECT * FROM reserva ORDER BY fecha_reserva ASC;

-- Múltiples criterios: primero por clase (A→Z), luego por precio (mayor→menor)
SELECT * FROM reserva ORDER BY clase ASC, precio_cop DESC;
```

### 5.2 LIMIT y OFFSET

```sql
-- Las 3 reservas más caras
SELECT * FROM reserva ORDER BY precio_cop DESC LIMIT 3;

-- Paginación: saltar las primeras 5, mostrar las siguientes 5
SELECT * FROM reserva ORDER BY id_pasajero LIMIT 5 OFFSET 5;
```

---

## 6. Funciones de agregación

Las funciones de agregación **calculan un resultado sobre un conjunto de filas** y devuelven un único valor.

| Función | Qué calcula | Ignora NULLs |
|---|---|---|
| `COUNT(*)` | Cantidad de filas | No |
| `COUNT(col)` | Cantidad de valores no nulos en `col` | **Sí** |
| `SUM(col)` | Suma de los valores | Sí |
| `AVG(col)` | Promedio de los valores | Sí |
| `MAX(col)` | Valor máximo | Sí |
| `MIN(col)` | Valor mínimo | Sí |

### 6.1 COUNT

```sql
-- Total de reservas (todas las filas)
SELECT COUNT(*) AS total_reservas FROM reserva;
-- Resultado: 20

-- Pasajeros con email registrado (ignora los NULL)
SELECT COUNT(*) AS total, COUNT(email_pasajero) AS con_email
FROM pasajero;
-- Resultado: total = 8, con_email = 6
```

> La diferencia entre `COUNT(*)` y `COUNT(columna)` es la forma más común de detectar cuántos NULLs hay en una columna.

### 6.2 SUM y AVG

```sql
-- Total recaudado en todas las reservas
SELECT SUM(precio_cop) AS total_recaudado FROM reserva;
-- Resultado: 11 835 000

-- Precio promedio (con redondeo a 0 decimales)
SELECT ROUND(AVG(precio_cop), 0) AS precio_promedio FROM reserva;
-- Resultado: 591 750
```

### 6.3 MAX y MIN

```sql
SELECT MAX(precio_cop) AS mas_cara, MIN(precio_cop) AS mas_barata
FROM reserva;
-- Resultado: 1 650 000 | 175 000

-- Fecha de reserva más reciente y más antigua
SELECT MAX(fecha_reserva) AS mas_reciente, MIN(fecha_reserva) AS mas_antigua
FROM reserva;
```

### 6.4 Combinadas en una sola consulta

```sql
SELECT
    COUNT(*)                  AS total_reservas,
    SUM(precio_cop)           AS total_recaudado,
    ROUND(AVG(precio_cop), 0) AS precio_promedio,
    MAX(precio_cop)           AS precio_maximo,
    MIN(precio_cop)           AS precio_minimo
FROM reserva;
```

> **Importante:** cuando se usa una función de agregación sin `GROUP BY`, la consulta colapsa todas las filas en **una sola fila**. No se pueden mezclar columnas normales con funciones de agregación sin agrupar:
> ```sql
> -- ❌ Error: clase no está en GROUP BY
> SELECT clase, COUNT(*) FROM reserva;
>
> -- ✅ Correcto: solo agregación
> SELECT COUNT(*) FROM reserva;
>
> -- ✅ Correcto: con GROUP BY (ver sección 7)
> SELECT clase, COUNT(*) FROM reserva GROUP BY clase;
> ```

---

## 7. GROUP BY — agrupar resultados

`GROUP BY` divide las filas en grupos según los valores de una o más columnas, y aplica las funciones de agregación a cada grupo por separado.

```sql
SELECT columna_grupo, funcion(col)
FROM tabla
GROUP BY columna_grupo;
```

```sql
-- Cuántas reservas hay en cada clase
SELECT clase, COUNT(*) AS num_reservas
FROM reserva
GROUP BY clase
ORDER BY num_reservas DESC;
```

| clase | num_reservas |
|---|---|
| Económica | 11 |
| Ejecutiva | 6 |
| Primera | 3 |

```sql
-- Total recaudado y precio promedio por clase
SELECT
    clase,
    SUM(precio_cop)           AS total_recaudado,
    ROUND(AVG(precio_cop), 0) AS precio_promedio
FROM reserva
GROUP BY clase
ORDER BY total_recaudado DESC;

-- Cuántas reservas hizo cada pasajero
SELECT id_pasajero, COUNT(*) AS num_reservas
FROM reserva
GROUP BY id_pasajero
ORDER BY num_reservas DESC;
```

### Regla fundamental de GROUP BY

> **Toda columna en `SELECT` que NO sea una función de agregación, DEBE aparecer en `GROUP BY`.**

```sql
-- ❌ Error: nombre_pasajero no está en GROUP BY ni es una agregación
SELECT nombre_pasajero, COUNT(*) FROM reserva GROUP BY id_pasajero;

-- ✅ Correcto
SELECT id_pasajero, COUNT(*) FROM reserva GROUP BY id_pasajero;
```

---

## 8. HAVING — filtrar grupos

`HAVING` funciona como un `WHERE` pero actúa **después de que se formaron los grupos**. Permite filtrar con base en el resultado de una función de agregación.

```sql
-- Solo pasajeros con más de 2 reservas
SELECT id_pasajero, COUNT(*) AS num_reservas
FROM reserva
GROUP BY id_pasajero
HAVING COUNT(*) > 2;
```

| id_pasajero | num_reservas |
|---|---|
| PAS-001 | 3 |
| PAS-002 | 3 |
| PAS-003 | 3 |
| PAS-007 | 3 |

```sql
-- Clases con precio promedio superior a $500.000
SELECT clase, ROUND(AVG(precio_cop), 0) AS precio_promedio
FROM reserva
GROUP BY clase
HAVING AVG(precio_cop) > 500000;
```

### WHERE vs HAVING

| | `WHERE` | `HAVING` |
|---|---|---|
| **Filtra** | Filas individuales | Grupos (resultado de GROUP BY) |
| **Se ejecuta** | Antes de GROUP BY | Después de GROUP BY |
| **Puede usar** | Columnas de la tabla | Funciones de agregación |

**Ejemplo combinado** — reservas de agosto, solo clases con promedio mayor a $500.000 ese mes:

```sql
SELECT clase, ROUND(AVG(precio_cop), 0) AS promedio_agosto
FROM reserva
WHERE fecha_reserva BETWEEN '2024-08-01' AND '2024-08-31'  -- filtra filas primero
GROUP BY clase
HAVING AVG(precio_cop) > 500000;                           -- filtra grupos después
-- Resultado: Ejecutiva (≈733 000) y Primera (1 350 000)
```

---

## 9. Orden de ejecución del SELECT

El orden en que **se escribe** un SELECT no es el orden en que **se ejecuta**:

```
Orden de escritura:   SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT
Orden de ejecución:   FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
```

Esto explica restricciones importantes:

```sql
-- ❌ Error: el alias no existe aún cuando WHERE se evalúa
SELECT precio_cop * 1.19 AS precio_iva
FROM reserva
WHERE precio_iva > 800000;

-- ✅ Correcto: repetir la expresión en WHERE
SELECT precio_cop * 1.19 AS precio_iva
FROM reserva
WHERE precio_cop * 1.19 > 800000;
```

```sql
-- ❌ Error: función de agregación no se puede usar en WHERE
SELECT clase FROM reserva WHERE COUNT(*) > 3 GROUP BY clase;

-- ✅ Correcto: usar HAVING para filtrar después de agrupar
SELECT clase FROM reserva GROUP BY clase HAVING COUNT(*) > 3;
```

---

## 10. Errores frecuentes

| Error | ¿Por qué falla? | Solución |
|---|---|---|
| `WHERE col = NULL` | NULL no es un valor comparable con `=` | Usar `IS NULL` |
| `SELECT col, COUNT(*) FROM t` sin GROUP BY | Mezcla columna normal con agregación | Agregar `GROUP BY col` |
| Alias en WHERE | WHERE se ejecuta antes que SELECT | Repetir la expresión |
| `WHERE COUNT(*) > n` | Función de agregación en WHERE | Mover a HAVING |
| `BETWEEN 500000 AND 200000` | Extremo menor debe ir primero | `BETWEEN 200000 AND 500000` |

---

## 11. Anatomía completa del SELECT

Todas las cláusulas son opcionales excepto `SELECT` y `FROM`:

```sql
SELECT   columnas, funciones_de_agregacion    -- ¿qué mostrar?
FROM     tabla                                -- ¿de dónde?
WHERE    condición_sobre_filas               -- ¿qué filas incluir?
GROUP BY columna(s)                          -- ¿cómo agrupar?
HAVING   condición_sobre_grupos             -- ¿qué grupos incluir?
ORDER BY columna ASC|DESC                   -- ¿en qué orden?
LIMIT    n  OFFSET  m;                      -- ¿cuántos resultados?
```

**Ejemplo integrador** — vendedores que hayan facturado más de $2.000.000 en reservas de agosto, ordenados de mayor a menor:

```sql
SELECT
    id_pasajero,
    COUNT(*)              AS num_reservas,
    SUM(precio_cop)       AS total_facturado
FROM reserva
WHERE fecha_reserva BETWEEN '2024-08-01' AND '2024-08-31'
GROUP BY id_pasajero
HAVING SUM(precio_cop) > 2000000
ORDER BY total_facturado DESC
LIMIT 5;
```

---

## Referencia rápida — operadores WHERE

| Operador | Sintaxis | Ejemplo |
|---|---|---|
| Igual | `col = valor` | `clase = 'Ejecutiva'` |
| Distinto | `col <> valor` | `clase <> 'Económica'` |
| Rango | `col BETWEEN a AND b` | `precio_cop BETWEEN 500000 AND 1000000` |
| Lista | `col IN (v1, v2)` | `clase IN ('Ejecutiva', 'Primera')` |
| Patrón (sensible) | `col LIKE 'patrón'` | `nombre LIKE 'Ana%'` |
| Patrón (insensible) | `col ILIKE 'patrón'` | `nombre ILIKE 'ana%'` |
| Nulo | `col IS NULL` | `email_pasajero IS NULL` |
| No nulo | `col IS NOT NULL` | `email_pasajero IS NOT NULL` |
| Y lógico | `c1 AND c2` | `Ejecutiva AND precio > 700000` |
| O lógico | `c1 OR c2` | `Ejecutiva OR Primera` |
| Negación | `NOT condición` | `NOT clase = 'Económica'` |

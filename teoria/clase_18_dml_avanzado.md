# Clase 18 — DML avanzado: INSERT...SELECT · UPDATE...FROM · DELETE USING · CTE + DML
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**
**Herramienta:** PostgreSQL + pgAdmin

---

## Base de datos de la clase — UrbanBike

```
ESTACION  (id_estacion, nombre, barrio, capacidad)
BICICLETA (id_bici, modelo, estado, id_estacion FK — NULL si en tránsito)
           estado: 'disponible' | 'en_uso' | 'mantenimiento'
CLIENTE   (id_cliente, nombre, email, plan)
           plan: 'básico' | 'premium'
VIAJE     (id_viaje SERIAL PK, id_cliente FK, id_bici FK,
           id_origen FK, id_destino FK — NULL si en curso,
           fecha, duracion_min — NULL si en curso,
           tarifa_cop — NULL si en curso)
```

Datos clave:
- **6 estaciones**, **10 bicicletas** (4 disponibles · 2 en uso · 2 en mantenimiento), **8 clientes** (4 básico · 4 premium).
- **21 viajes** en total: **16 completados** (tienen `tarifa_cop`) · **2 en curso recientes** · **3 abandonados** (fecha < 2024-02-01, sin tarifa).
- Los viajes "en curso" y los "abandonados" se distinguen por fecha: los abandonados son de enero 2024.

---

## ¿Por qué hace falta algo más que lo básico?

En la clase 17 aprendieron las formas fundamentales de INSERT, UPDATE y DELETE. Esas formas funcionan para operaciones fila a fila o con subconsultas simples en `WHERE`. Las formas avanzadas de hoy resuelven tres problemas que aparecen en aplicaciones reales:

| Problema | Solución avanzada |
|----------|-------------------|
| Insertar el resultado de una consulta compleja en otra tabla | `INSERT ... SELECT` |
| Actualizar filas usando columnas de otra tabla (no solo su ID) | `UPDATE ... FROM` |
| Eliminar filas basándose en datos de otra tabla | `DELETE USING` |
| Identificar qué modificar con lógica compleja antes de actuar | `WITH ... UPDATE/DELETE` |

---

## 1. INSERT ... SELECT

`INSERT ... SELECT` inserta directamente el resultado de una consulta `SELECT` en una tabla. **No hay cláusula `VALUES`** — la consulta reemplaza esa parte.

### 1.1 Estructura

```
INSERT INTO tabla_destino (col1, col2, ...)
SELECT expr1, expr2, ...
FROM   origen
WHERE  condición;
```

Las columnas del `SELECT` deben corresponder en **orden y tipo** con las columnas del `INSERT`.

### 1.2 Comparación con INSERT básico

```
INSERT básico (clase 17):       INSERT ... SELECT (hoy):
────────────────────────        ──────────────────────────────────
INSERT INTO t (a, b)            INSERT INTO t (a, b)
VALUES (1, 'x'),                SELECT col_a, col_b
       (2, 'y');                FROM   otra_tabla
                                WHERE  condición
                                GROUP BY ...;

→ Datos que escribes tú         → Datos que ya existen en la BD,
  en el momento                   transformados o filtrados
```

### 1.3 Casos de uso típicos

- **Poblar una tabla de resumen o historial** a partir de datos de transacciones.
- **Copiar un subconjunto de datos** a una tabla de archivo o auditoría.
- **Crear datos derivados** (totales, promedios) que se van a consultar frecuentemente.

### 1.4 Ejemplos con UrbanBike

**Ejemplo 1 — crear y poblar una tabla de historial:**

```sql
CREATE TABLE historial_cliente (
    id_cliente   VARCHAR(10) PRIMARY KEY REFERENCES cliente(id_cliente),
    total_viajes INT NOT NULL DEFAULT 0,
    gasto_total  INT NOT NULL DEFAULT 0
);

INSERT INTO historial_cliente (id_cliente, total_viajes, gasto_total)
SELECT id_cliente,
       COUNT(*)        AS total_viajes,
       SUM(tarifa_cop) AS gasto_total
FROM viaje
WHERE tarifa_cop IS NOT NULL      -- solo viajes completados
GROUP BY id_cliente;
-- Se insertan 8 filas (una por cada cliente con al menos un viaje completado)
```

**Ejemplo 2 — copiar un subconjunto a otra tabla:**

```sql
CREATE TABLE clientes_vip (
    id_cliente VARCHAR(10) PRIMARY KEY,
    nombre     VARCHAR(100),
    plan       VARCHAR(10)
);

INSERT INTO clientes_vip
SELECT c.id_cliente, c.nombre, c.plan
FROM cliente c
WHERE c.plan = 'premium'
  AND c.id_cliente IN (
      SELECT DISTINCT id_cliente FROM viaje WHERE tarifa_cop IS NOT NULL
  );
-- Inserta los 4 clientes premium que ya han hecho al menos un viaje:
-- CLI-001 Andrés Morales · CLI-003 Carlos Leal
-- CLI-006 Fernanda Mora  · CLI-008 Helena Ríos
```

> Nota importante: el `SELECT` puede ser tan complejo como sea necesario — con `JOIN`, `GROUP BY`, `HAVING`, subconsultas, CTEs, etc. Si el `SELECT` devuelve 0 filas, el `INSERT` inserta 0 filas (sin error).

---

## 2. UPDATE ... FROM

En la clase 17 actualizaron filas usando subconsultas en `WHERE`:

```sql
-- Clase 17: subconsulta en WHERE
UPDATE viaje
SET tarifa_cop = ROUND(tarifa_cop * 0.85)
WHERE id_cliente IN (
    SELECT id_cliente FROM cliente WHERE plan = 'básico'
);
```

`UPDATE ... FROM` hace lo mismo pero mediante un **JOIN real** con la otra tabla, lo que permite leer **cualquier columna** de esa tabla en el `SET` o en el `WHERE`.

### 2.1 Estructura

```
UPDATE tabla_a  a
SET    a.columna = expresión_que_puede_usar_b.cualquier_col
FROM   tabla_b  b
WHERE  a.clave = b.clave
  AND  condición_extra;
```

### 2.2 Comparación directa

```sql
-- Descuento del 15% a viajes de clientes básico

-- Con subconsulta (clase 17): solo podemos usar el id del cliente
UPDATE viaje
SET tarifa_cop = ROUND(tarifa_cop * 0.85)
WHERE tarifa_cop IS NOT NULL
  AND id_cliente IN (
      SELECT id_cliente FROM cliente WHERE plan = 'básico'
  );

-- Con UPDATE...FROM: podemos usar cualquier columna de 'cliente' en el SET
UPDATE viaje v
SET tarifa_cop = ROUND(tarifa_cop * 0.85)
FROM cliente c
WHERE v.id_cliente  = c.id_cliente
  AND c.plan        = 'básico'
  AND v.tarifa_cop IS NOT NULL;
-- Resultado idéntico: 6 filas actualizadas
```

### 2.3 Cuándo UPDATE...FROM es indispensable

El caso donde la subconsulta no alcanza: necesitas **una columna de la tabla unida en el SET**:

```sql
-- Ajustar tarifa según la capacidad de la estación de origen
-- (estaciones con menos capacidad = más exclusivas = tarifa más alta)
UPDATE viaje v
SET tarifa_cop = ROUND(v.tarifa_cop * 1.10)
FROM estacion e
WHERE v.id_origen   = e.id_estacion
  AND e.capacidad  <= 8               -- columna de estacion
  AND v.tarifa_cop IS NOT NULL;
-- Estaciones afectadas: EST-2 (cap=8) y EST-5 (cap=6)
-- Con IN solo podríamos filtrar por id_estacion, no usar e.capacidad en el SET
```

```sql
-- Otro ejemplo: actualizar la estación actual de cada bici a su último destino
UPDATE bicicleta b
SET id_estacion = v.id_destino         -- ← columna de viaje usada en el SET
FROM viaje v
WHERE b.id_bici  = v.id_bici
  AND v.id_viaje = (
      SELECT MAX(v2.id_viaje) FROM viaje v2
      WHERE v2.id_bici = b.id_bici AND v2.tarifa_cop IS NOT NULL
  );
```

### 2.4 Cláusula RETURNING (bonus)

PostgreSQL permite agregar `RETURNING` al final de un `UPDATE` o `DELETE` para ver qué filas se modificaron, sin necesidad de un `SELECT` aparte:

```sql
UPDATE bicicleta
SET estado = 'mantenimiento'
WHERE id_bici = 'BIC-01'
RETURNING id_bici, modelo, estado;
-- Resultado inmediato:
-- BIC-01 | Trek 3 | mantenimiento
```

---

## 3. DELETE USING

`DELETE USING` elimina filas usando un **JOIN** con otra tabla, igual que `UPDATE ... FROM` pero para borrar.

### 3.1 Estructura

```
DELETE FROM tabla_a  a
USING  tabla_b  b
WHERE  a.clave = b.clave
  AND  condición;
```

### 3.2 Comparación con DELETE básico

```sql
-- DELETE con subconsulta (clase 17):
DELETE FROM viaje
WHERE id_cliente IN (
    SELECT id_cliente FROM cliente WHERE plan = 'básico'
)
AND tarifa_cop IS NULL
AND fecha < '2024-02-01';

-- DELETE USING: mismo resultado, forma más directa
DELETE FROM viaje v
USING cliente c
WHERE v.id_cliente = c.id_cliente
  AND c.plan       = 'básico'
  AND v.tarifa_cop IS NULL
  AND v.fecha      < '2024-02-01';
```

### 3.3 Ejemplo — eliminar viajes abandonados de clientes básico

```sql
-- Política: viajes sin cerrar de más de 60 días de clientes básico se eliminan
DELETE FROM viaje v
USING cliente c
WHERE v.id_cliente = c.id_cliente
  AND c.plan       = 'básico'
  AND v.tarifa_cop IS NULL
  AND v.fecha      < '2024-02-01';
```

¿Qué se elimina y qué no?

```
VIAJES SIN TARIFA (en curso o abandonados):
┌──────────┬───────────────┬────────────┬────────────┬────────────┐
│ id_viaje │ cliente       │ plan       │ fecha      │ ¿Eliminar? │
├──────────┼───────────────┼────────────┼────────────┼────────────┤
│ 17       │CLI-001 Andrés │ premium    │ 2024-03-24 │ NO (premium)│
│ 18       │CLI-006 Fernanda│premium   │ 2024-03-24 │ NO (premium)│
│ 19       │CLI-007 Gastón │ básico     │ 2024-01-10 │ SÍ ✓       │
│ 20       │CLI-003 Carlos │ premium    │ 2024-01-15 │ NO (premium)│
│ 21       │CLI-004 Diana  │ básico     │ 2024-01-20 │ SÍ ✓       │
└──────────┴───────────────┴────────────┴────────────┴────────────┘
Resultado: 2 filas eliminadas
```

### 3.4 Cuándo usar DELETE USING en lugar de DELETE con IN

Al igual que `UPDATE ... FROM`, `DELETE USING` es preferible cuando:
- La condición involucra **múltiples columnas** de la tabla unida.
- La lógica de unión es compleja y una subconsulta en `IN` sería difícil de leer.
- Quieres agregar `RETURNING` para registrar qué se eliminó.

---

## 4. CTE + DML — `WITH` antes de UPDATE o DELETE

Un CTE puede preceder a un `UPDATE` o `DELETE` igual que a un `SELECT`. Esto permite separar la **lógica de identificación** (qué filas afectar) de la **acción** (qué hacer con ellas).

### 4.1 Estructura — CTE + UPDATE

```
WITH identificados AS (
    SELECT id FROM tabla WHERE condición_compleja
)
UPDATE otra_tabla t
SET    col = nuevo_valor
FROM   identificados i
WHERE  t.id = i.id;
```

### 4.2 Estructura — CTE + DELETE

```
WITH identificados AS (
    SELECT id FROM tabla WHERE condición_compleja
)
DELETE FROM tabla
WHERE id IN (SELECT id FROM identificados);
```

### 4.3 Ejemplo — marcar bicicletas desgastadas como mantenimiento

```sql
-- Identificar bicicletas con 3 o más viajes completados
-- y marcarlas para mantenimiento en una sola operación
WITH mas_usadas AS (
    SELECT id_bici, COUNT(*) AS usos
    FROM viaje
    WHERE tarifa_cop IS NOT NULL
    GROUP BY id_bici
    HAVING COUNT(*) >= 3
)
UPDATE bicicleta b
SET estado = 'mantenimiento'
FROM mas_usadas mu
WHERE b.id_bici  = mu.id_bici
  AND b.estado  <> 'mantenimiento';
-- Resultado: BIC-01, BIC-03, BIC-05, BIC-08 → estado = 'mantenimiento'
-- (cada una tiene exactamente 3 viajes completados)
```

### 4.4 Ejemplo — CTE + DELETE

```sql
-- Eliminar viajes completados de bicicletas que acaban de ser retiradas
WITH retiradas AS (
    SELECT id_bici FROM bicicleta WHERE estado = 'mantenimiento'
)
DELETE FROM viaje
WHERE id_bici    IN (SELECT id_bici FROM retiradas)
  AND tarifa_cop IS NOT NULL;
```

### 4.5 ¿Por qué CTE y no una subconsulta directa?

```sql
-- Estas dos consultas producen el mismo resultado:

-- Con subconsulta directa:
UPDATE bicicleta
SET estado = 'mantenimiento'
WHERE id_bici IN (
    SELECT id_bici FROM viaje
    WHERE tarifa_cop IS NOT NULL
    GROUP BY id_bici HAVING COUNT(*) >= 3
)
AND estado <> 'mantenimiento';

-- Con CTE:
WITH mas_usadas AS (
    SELECT id_bici FROM viaje
    WHERE tarifa_cop IS NOT NULL
    GROUP BY id_bici HAVING COUNT(*) >= 3
)
UPDATE bicicleta
SET estado = 'mantenimiento'
WHERE id_bici IN (SELECT id_bici FROM mas_usadas)
  AND estado  <> 'mantenimiento';
```

La diferencia es de **legibilidad**: el CTE nombra el concepto `mas_usadas`. En producción, donde las condiciones pueden ser mucho más complejas, ese nombre puede hacer la diferencia entre entender el código en 10 segundos o en 10 minutos.

---

## 5. Resumen comparativo — formas básicas vs avanzadas

| Operación | Forma básica (clase 17) | Forma avanzada (clase 21) |
|-----------|------------------------|--------------------------|
| Insertar | `INSERT INTO t VALUES (...)` | `INSERT INTO t SELECT ...` |
| Actualizar usando otra tabla | `UPDATE t SET ... WHERE col IN (SELECT ...)` | `UPDATE t SET ... FROM otra WHERE ...` |
| Eliminar usando otra tabla | `DELETE FROM t WHERE col IN (SELECT ...)` | `DELETE FROM t USING otra WHERE ...` |
| Lógica de identificación compleja | Subconsulta anidada en `WHERE` | `WITH cte AS (...) UPDATE/DELETE` |

---

## 6. Errores frecuentes

```sql
-- ❌ En UPDATE...FROM, olvidar el alias y mezclar columnas de ambas tablas
UPDATE viaje
SET tarifa_cop = ROUND(tarifa_cop * 0.85)  -- ¿de qué tabla es tarifa_cop?
FROM cliente
WHERE id_cliente = id_cliente;             -- ¿cuál id_cliente es de cuál tabla?

-- ✓ Siempre usar alias para claridad
UPDATE viaje v
SET v.tarifa_cop = ROUND(v.tarifa_cop * 0.85)
FROM cliente c
WHERE v.id_cliente = c.id_cliente
  AND c.plan = 'básico';
```

```sql
-- ❌ En DELETE USING, poner la condición de unión en USING en vez de WHERE
DELETE FROM viaje
USING cliente c ON viaje.id_cliente = c.id_cliente;  -- ON no se usa en USING
-- ERROR: syntax error at or near "ON"

-- ✓ La condición de unión va en WHERE
DELETE FROM viaje v
USING cliente c
WHERE v.id_cliente = c.id_cliente  -- ← condición de unión va aquí
  AND c.plan = 'básico';
```

---

## Para recordar

```sql
-- INSERT desde una consulta
INSERT INTO resumen (col1, col2)
SELECT expr1, expr2 FROM origen WHERE ...;

-- UPDATE con JOIN real
UPDATE tabla_a a
SET a.col = valor
FROM tabla_b b
WHERE a.id = b.id AND b.condicion;

-- DELETE con JOIN
DELETE FROM tabla_a a
USING tabla_b b
WHERE a.id = b.id AND b.condicion;

-- CTE antes de modificación
WITH ids AS (SELECT id FROM tabla WHERE ...)
UPDATE tabla SET col = val FROM ids WHERE tabla.id = ids.id;
```

> **Regla de oro:** si necesitas datos de otra tabla en el `SET` de un `UPDATE`, usa `UPDATE ... FROM`. Si la lógica para identificar qué filas modificar es compleja, nómbrala con un CTE antes de actuar.

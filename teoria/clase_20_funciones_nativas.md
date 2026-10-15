# Clase 20 — Funciones nativas de PostgreSQL: texto, numéricas y fecha/hora
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**
**Herramienta:** PostgreSQL + pgAdmin

---


## Base de datos de la clase — StaffHub

```
DEPARTAMENTO (id_departamento, nombre, ciudad, presupuesto_anual)
EMPLEADO     (id_empleado, nombre, email, fecha_ingreso, salario_cop,
              calificacion NUMERIC(3,1), id_departamento FK)
CARGO        (id_empleado FK, titulo, nivel: 'junior' | 'senior' | 'lead')
```

Datos relevantes:
- **4 departamentos**: Tecnología (Bogotá), Marketing (Medellín), Finanzas (Bogotá), Operaciones (Cali).
- **12 empleados**: 10 con departamento asignado, 2 sin departamento (`EMP-11` Laura Medina y `EMP-12` Manuel Torres).
- Fechas de ingreso desde 2017 hasta 2024 — ideal para funciones de fecha.
- Calificaciones de desempeño entre 3.2 y 4.8 — ideal para ROUND, CEIL, FLOOR.

---

## ¿Dónde se usan las funciones nativas?

Las funciones nativas se pueden usar **en cualquier cláusula** de un SELECT:

```sql
SELECT UPPER(nombre)                    -- en la lista de columnas
FROM empleado
WHERE LENGTH(nombre) > 10              -- en el WHERE
ORDER BY LOWER(nombre)                 -- en el ORDER BY
```

```sql
SELECT nivel, ROUND(AVG(salario_cop))
FROM empleado JOIN cargo USING (id_empleado)
GROUP BY nivel
HAVING ROUND(AVG(salario_cop)) > 3000000  -- en el HAVING
ORDER BY 2 DESC;
```

---

## 1. Funciones de texto

### 1.1 Cambiar mayúsculas/minúsculas

```sql
SELECT UPPER('Ana Torres');    -- 'ANA TORRES'
SELECT LOWER('ANA TORRES');    -- 'ana torres'
SELECT INITCAP('ana torres');  -- 'Ana Torres' (primera letra de cada palabra en mayúscula)
```

```sql
SELECT nombre,
       UPPER(nombre)   AS mayusculas,
       LOWER(nombre)   AS minusculas,
       INITCAP(nombre) AS titulo
FROM empleado LIMIT 3;
```

### 1.2 Longitud de texto

```sql
SELECT LENGTH('Ana Torres');   -- 10 (cuenta espacios)
SELECT CHAR_LENGTH('Ana');     -- 3 (equivalente a LENGTH para texto UTF-8)
```

```sql
SELECT nombre, LENGTH(nombre) AS caracteres
FROM empleado
ORDER BY caracteres DESC;
-- 'Fernanda Castro' → 15 caracteres (la más larga)
```

### 1.3 Concatenar texto: `CONCAT` y `||`

Ambas formas producen el mismo resultado:

```sql
-- Con CONCAT
SELECT CONCAT(nombre, ' (', nivel, ')') AS etiqueta
FROM empleado JOIN cargo USING (id_empleado);

-- Con ||
SELECT nombre || ' (' || nivel || ')' AS etiqueta
FROM empleado JOIN cargo USING (id_empleado);

-- Resultado: 'Ana Torres (senior)', 'Carlos Ruiz (junior)', ...
```

> **Diferencia importante:** `||` con un `NULL` produce `NULL`. `CONCAT` ignora los NULL.
> ```sql
> SELECT 'hola' || NULL;      -- NULL
> SELECT CONCAT('hola', NULL); -- 'hola'
> ```

### 1.4 Extraer partes de texto: SPLIT_PART y SUBSTRING

**`SPLIT_PART(texto, delimitador, parte)`** — divide el texto por el delimitador y devuelve la parte indicada:

```sql
-- Extraer usuario y dominio del email
SELECT email,
       SPLIT_PART(email, '@', 1) AS usuario,  -- 'ana.torres'
       SPLIT_PART(email, '@', 2) AS dominio    -- 'staffhub.com'
FROM empleado LIMIT 3;

-- Extraer primer nombre (antes del espacio)
SELECT nombre, SPLIT_PART(nombre, ' ', 1) AS primer_nombre
FROM empleado;
-- 'Ana Torres' → 'Ana'
```

**`SUBSTRING(texto FROM inicio FOR longitud)`** — extrae una porción del texto:

```sql
SELECT SUBSTRING('EMP-01' FROM 5);          -- '01' (desde posición 5 hasta el final)
SELECT SUBSTRING('EMP-01' FROM 1 FOR 3);    -- 'EMP' (3 caracteres desde posición 1)
```

### 1.5 Reemplazar texto: REPLACE

```sql
SELECT REPLACE('ana.torres@staffhub.com', '@staffhub.com', '@empresa.co');
-- → 'ana.torres@empresa.co'
```

```sql
SELECT email, REPLACE(email, '@staffhub.com', '@empresa.co') AS email_nuevo
FROM empleado;
```

### 1.6 Eliminar espacios: TRIM

```sql
SELECT TRIM('  Ana Torres  ');    -- 'Ana Torres'   (elimina espacios de ambos lados)
SELECT LTRIM('  Ana Torres  ');   -- 'Ana Torres  ' (solo lado izquierdo)
SELECT RTRIM('  Ana Torres  ');   -- '  Ana Torres' (solo lado derecho)
```

`TRIM` es especialmente útil cuando los datos vienen de importaciones con espacios accidentales.

### 1.7 Buscar texto: POSITION e ILIKE

```sql
SELECT POSITION('@' IN 'ana.torres@staffhub.com');   -- 11 (posición del @)
```

```sql
-- ILIKE: LIKE sin distinguir mayúsculas/minúsculas
SELECT nombre FROM empleado WHERE nombre ILIKE '%torres%';
-- Encuentra 'Ana Torres' Y 'Manuel Torres'

SELECT nombre FROM empleado WHERE nombre LIKE '%Torres%';
-- Solo funciona si la capitalización coincide exactamente
```

### 1.8 Resumen de funciones de texto

| Función | Qué hace | Ejemplo |
|---------|----------|---------|
| `UPPER(t)` | Todo en mayúsculas | `UPPER('ana')` → `'ANA'` |
| `LOWER(t)` | Todo en minúsculas | `LOWER('ANA')` → `'ana'` |
| `INITCAP(t)` | Primera letra de cada palabra en mayúscula | `INITCAP('ana torres')` → `'Ana Torres'` |
| `LENGTH(t)` | Cantidad de caracteres | `LENGTH('Ana')` → `3` |
| `CONCAT(t1,t2,...)` | Concatenar (ignora NULL) | `CONCAT('a','b')` → `'ab'` |
| `t1 \|\| t2` | Concatenar (NULL propaga) | `'a' \|\| 'b'` → `'ab'` |
| `SPLIT_PART(t,d,n)` | Parte N al dividir por delimitador | `SPLIT_PART('a@b','@',2)` → `'b'` |
| `SUBSTRING(t FROM n)` | Texto desde posición N | `SUBSTRING('abc' FROM 2)` → `'bc'` |
| `REPLACE(t,old,new)` | Reemplazar texto | `REPLACE('ab','a','x')` → `'xb'` |
| `TRIM(t)` | Elimina espacios de los extremos | `TRIM(' ab ')` → `'ab'` |
| `POSITION(s IN t)` | Posición de s dentro de t | `POSITION('@' IN 'a@b')` → `2` |
| `ILIKE` | Búsqueda sin distinguir mayúsculas | `nombre ILIKE '%ana%'` |

---

## 2. Funciones numéricas

### 2.1 Redondeo: ROUND, CEIL, FLOOR, TRUNC

```sql
SELECT ROUND(4.567, 2);    -- 4.57  (redondea al 2.º decimal)
SELECT ROUND(4.567, 0);    -- 5.00  (al entero más cercano)
SELECT ROUND(4.567);       -- 5     (sin decimales)

-- Con dígitos negativos: redondea a la izquierda del punto decimal
SELECT ROUND(4750000, -3); -- 5000000  (al millar más cercano)
SELECT ROUND(4350000, -3); -- 4000000
SELECT ROUND(4750000, -5); -- 5000000  (a la centena de millar)
```

```sql
SELECT CEIL(4.1);    -- 5   (siempre hacia arriba)
SELECT CEIL(4.9);    -- 5
SELECT CEIL(-4.1);   -- -4  (hacia arriba = menos negativo)

SELECT FLOOR(4.9);   -- 4   (siempre hacia abajo)
SELECT FLOOR(4.1);   -- 4
SELECT FLOOR(-4.1);  -- -5  (hacia abajo = más negativo)

SELECT TRUNC(4.9);   -- 4   (trunca sin redondear — equivale a FLOOR para positivos)
SELECT TRUNC(-4.9);  -- -4  (diferente de FLOOR para negativos)
```

> **Diferencia ROUND vs TRUNC:** `ROUND(4.5)` → `5`, `TRUNC(4.5)` → `4`. TRUNC nunca redondea hacia arriba.

### 2.2 Valor absoluto: ABS

```sql
SELECT ABS(-4200000);    -- 4200000
SELECT ABS(4200000);     -- 4200000
```

Útil para calcular diferencias sin importar el signo:
```sql
SELECT ABS(salario_cop - 3000000) AS diferencia_del_medio
FROM empleado;
```

### 2.3 Residuo de la división: MOD

`MOD(dividendo, divisor)` devuelve el **residuo** (lo que sobra) de la división entera:

```sql
SELECT MOD(10, 3);    -- 1   (10 = 3×3 + 1)
SELECT MOD(12, 3);    -- 0   (12 es múltiplo exacto de 3)
SELECT MOD(7, 2);     -- 1   (7 = 2×3 + 1 → impar)
```

Aplicación práctica:
```sql
-- Identificar salarios que son múltiplos exactos de $500.000
SELECT nombre, salario_cop
FROM empleado
WHERE MOD(salario_cop, 500000) = 0;

-- Identificar filas pares e impares
SELECT id_empleado, nombre,
       CASE WHEN MOD(ROW_NUMBER() OVER(), 2) = 0 THEN 'par' ELSE 'impar' END AS fila
FROM empleado;
```

### 2.4 Otras funciones numéricas

```sql
SELECT POWER(2, 10);    -- 1024   (2 elevado a la 10)
SELECT SQRT(144);       -- 12     (raíz cuadrada)
SELECT PI();            -- 3.14159...
```

### 2.5 Resumen de funciones numéricas

| Función | Qué hace | Ejemplo |
|---------|----------|---------|
| `ROUND(n, d)` | Redondea al d-ésimo decimal | `ROUND(4.567, 1)` → `4.6` |
| `ROUND(n, -d)` | Redondea a la izquierda del punto | `ROUND(4750, -3)` → `5000` |
| `CEIL(n)` | Redondea siempre hacia arriba | `CEIL(4.1)` → `5` |
| `FLOOR(n)` | Redondea siempre hacia abajo | `FLOOR(4.9)` → `4` |
| `TRUNC(n)` | Trunca (descarta decimales) | `TRUNC(4.9)` → `4` |
| `ABS(n)` | Valor absoluto | `ABS(-5)` → `5` |
| `MOD(n, m)` | Residuo de n ÷ m | `MOD(10, 3)` → `1` |
| `POWER(b, e)` | b elevado a e | `POWER(2, 8)` → `256` |
| `SQRT(n)` | Raíz cuadrada | `SQRT(25)` → `5` |

---

## 3. Funciones de fecha y hora

### 3.1 Obtener la fecha/hora actual

```sql
SELECT NOW();            -- 2026-10-20 09:15:32.123456 (timestamp completo)
SELECT CURRENT_DATE;     -- 2026-10-20 (solo la fecha)
SELECT CURRENT_TIME;     -- 09:15:32 (solo la hora)
SELECT CURRENT_TIMESTAMP; -- igual que NOW()
```

### 3.2 EXTRACT y DATE_PART — extraer componentes

```sql
-- EXTRACT
SELECT EXTRACT(YEAR  FROM CURRENT_DATE);   -- 2026
SELECT EXTRACT(MONTH FROM CURRENT_DATE);   -- 10
SELECT EXTRACT(DAY   FROM CURRENT_DATE);   -- 20
SELECT EXTRACT(DOW   FROM CURRENT_DATE);   -- 1 (0=domingo, 1=lunes, ..., 6=sábado)
SELECT EXTRACT(QUARTER FROM CURRENT_DATE); -- 4 (cuarto trimestre)
```

```sql
-- Aplicado a datos reales
SELECT nombre, fecha_ingreso,
       EXTRACT(YEAR  FROM fecha_ingreso)::INT AS año_ingreso,
       EXTRACT(MONTH FROM fecha_ingreso)::INT AS mes_ingreso
FROM empleado
ORDER BY fecha_ingreso;
```

> `DATE_PART('year', fecha)` hace lo mismo que `EXTRACT(YEAR FROM fecha)` — son equivalentes en PostgreSQL.

### 3.3 AGE — calcular la diferencia entre fechas

`AGE(fecha_fin, fecha_inicio)` devuelve un **intervalo** con la diferencia exacta:

```sql
SELECT AGE('2026-10-20', '2019-03-15');
-- → 7 years 7 mons 5 days
```

Para obtener solo los años completos como número:
```sql
SELECT DATE_PART('year', AGE(CURRENT_DATE, fecha_ingreso))::INT AS anos
FROM empleado;
```

```sql
-- Empleados con más de 5 años de antigüedad
SELECT nombre, fecha_ingreso,
       DATE_PART('year', AGE(CURRENT_DATE, fecha_ingreso))::INT AS anos
FROM empleado
WHERE DATE_PART('year', AGE(CURRENT_DATE, fecha_ingreso)) > 5
ORDER BY fecha_ingreso;
```

### 3.4 TO_CHAR — formatear fecha como texto

`TO_CHAR(fecha, 'formato')` convierte una fecha en texto con el formato que definas:

```sql
SELECT TO_CHAR(CURRENT_DATE, 'DD/MM/YYYY');           -- '20/10/2026'
SELECT TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD');           -- '2026-10-20'
SELECT TO_CHAR(CURRENT_DATE, 'DD "de" Month "de" YYYY'); -- '20 de October     de 2026'
SELECT TO_CHAR(CURRENT_DATE, 'DD "de" FMMonth "de" YYYY'); -- '20 de October de 2026'
```

> El prefijo `FM` (Fill Mode) elimina los espacios de relleno en nombres de meses y días. Úsalo para texto limpio.

Códigos de formato más usados:

| Código | Qué representa | Ejemplo |
|--------|----------------|---------|
| `YYYY` | Año con 4 dígitos | `2026` |
| `MM` | Mes (01-12) | `10` |
| `DD` | Día del mes (01-31) | `20` |
| `Month` | Nombre completo del mes | `October` |
| `Mon` | Nombre abreviado | `Oct` |
| `Day` | Nombre del día | `Tuesday` |
| `HH24` | Hora en formato 24h | `09` |
| `MI` | Minutos | `15` |
| `SS` | Segundos | `32` |

> **Nota:** PostgreSQL genera los nombres de mes/día en inglés por defecto. Para español se puede configurar el locale, pero en este curso usaremos el texto en español de forma manual con `"de"`.

### 3.5 DATE_TRUNC — truncar al inicio del período

```sql
SELECT DATE_TRUNC('year',  CURRENT_DATE);  -- 2026-01-01
SELECT DATE_TRUNC('month', CURRENT_DATE);  -- 2026-10-01
SELECT DATE_TRUNC('week',  CURRENT_DATE);  -- 2026-10-19 (lunes de la semana)
```

Útil para agrupar por mes o año sin perder precisión:
```sql
SELECT DATE_TRUNC('year', fecha_ingreso) AS año_ingreso,
       COUNT(*) AS empleados_ingresados
FROM empleado
GROUP BY DATE_TRUNC('year', fecha_ingreso)
ORDER BY año_ingreso;
```

### 3.6 INTERVAL — sumar y restar tiempo

```sql
SELECT CURRENT_DATE + INTERVAL '1 year';    -- un año en el futuro
SELECT CURRENT_DATE - INTERVAL '6 months';  -- hace 6 meses
SELECT CURRENT_DATE + INTERVAL '30 days';   -- 30 días en el futuro
SELECT CURRENT_DATE + INTERVAL '1 year 3 months 10 days'; -- combinado
```

```sql
-- Fecha del décimo aniversario de cada empleado
SELECT nombre, fecha_ingreso,
       fecha_ingreso + INTERVAL '10 years' AS decimo_aniversario
FROM empleado
ORDER BY decimo_aniversario;
```

### 3.7 Resumen de funciones de fecha/hora

| Función | Qué hace | Ejemplo |
|---------|----------|---------|
| `NOW()` / `CURRENT_TIMESTAMP` | Fecha y hora actual | `2026-10-20 09:15:32` |
| `CURRENT_DATE` | Solo la fecha actual | `2026-10-20` |
| `EXTRACT(parte FROM f)` | Extrae un componente numérico | `EXTRACT(YEAR FROM fecha)` → `2026` |
| `DATE_PART('parte', f)` | Igual que EXTRACT | `DATE_PART('year', fecha)` → `2026` |
| `AGE(f2, f1)` | Intervalo entre dos fechas | `AGE(hoy, ingreso)` → `7 years 5 mons` |
| `TO_CHAR(f, 'fmt')` | Fecha formateada como texto | `TO_CHAR(f, 'DD/MM/YYYY')` |
| `DATE_TRUNC('parte', f)` | Trunca al inicio del período | `DATE_TRUNC('month', f)` → primer día del mes |
| `f + INTERVAL 'n unit'` | Suma un intervalo a una fecha | `fecha + INTERVAL '1 year'` |
| `f - INTERVAL 'n unit'` | Resta un intervalo | `fecha - INTERVAL '6 months'` |

---

## 4. Combinar funciones con JOINs y GROUP BY

Las funciones nativas se potencian cuando se combinan con JOINs y agregación:

```sql
-- Reporte por departamento: nombre, empleados, salario promedio formateado,
-- nombre del empleado más antiguo y su antigüedad
SELECT d.nombre                                              AS departamento,
       COUNT(e.id_empleado)                                  AS empleados,
       ROUND(AVG(e.salario_cop), -3)                         AS salario_promedio,
       MIN(TO_CHAR(e.fecha_ingreso, 'DD/MM/YYYY'))           AS ingreso_mas_antiguo
FROM departamento d
JOIN empleado e ON d.id_departamento = e.id_departamento
GROUP BY d.id_departamento, d.nombre
ORDER BY empleados DESC;
```

```sql
-- Etiqueta completa usando funciones de texto + fecha + JOIN
SELECT e.id_empleado
    || ' | '
    || UPPER(SPLIT_PART(e.nombre, ' ', 1))
    || ' — '
    || c.titulo
    || ' | '
    || DATE_PART('year', AGE(CURRENT_DATE, e.fecha_ingreso))::INT::TEXT
    || ' años'
    AS resumen
FROM empleado e
JOIN cargo c ON e.id_empleado = c.id_empleado
ORDER BY e.id_empleado;
```

---

## 5. Errores frecuentes

### Mezclar tipos en `||`

```sql
-- ❌ Error: no se puede concatenar INT directamente con texto
SELECT nombre || ' lleva ' || DATE_PART('year', AGE(fecha_ingreso)) || ' años'
FROM empleado;
-- → ERROR: operator || does not exist: text || double precision

-- ✅ Convertir el número a texto primero
SELECT nombre || ' lleva ' || DATE_PART('year', AGE(CURRENT_DATE, fecha_ingreso))::TEXT || ' años'
FROM empleado;
-- O con CONCAT (que convierte automáticamente):
SELECT CONCAT(nombre, ' lleva ', DATE_PART('year', AGE(CURRENT_DATE, fecha_ingreso)), ' años')
FROM empleado;
```

### ROUND sobre INTEGER

```sql
-- ❌ ROUND sobre INT con decimales no hace lo que esperas
SELECT ROUND(salario_cop / 1000000, 2) FROM empleado;
-- Si salario_cop es INT, la división INT/INT trunca → 4200000/1000000 = 4, luego ROUND(4,2) = 4.00

-- ✅ Forzar división decimal con .0
SELECT ROUND(salario_cop / 1000000.0, 2) FROM empleado;
-- 4200000 / 1000000.0 = 4.2 → ROUND(4.2, 2) = 4.20
```

### AGE sin el segundo argumento

```sql
-- ❌ AGE con un solo argumento calcula la diferencia desde CURRENT_DATE automáticamente
-- (funciona, pero puede confundir si no se sabe que el argumento omitido = CURRENT_DATE)
SELECT AGE(fecha_ingreso) FROM empleado;

-- ✅ Más explícito:
SELECT AGE(CURRENT_DATE, fecha_ingreso) FROM empleado;
```

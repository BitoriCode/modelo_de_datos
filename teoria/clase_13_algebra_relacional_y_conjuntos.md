# Clase 13 — Álgebra Relacional y Operaciones de Conjuntos
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**

---

## 1. Contexto: ¿dónde estamos?

Hasta ahora el curso ha cubierto cómo **diseñar** una base de datos (E-R → Relacional → Normalización → DDL). A partir de aquí entramos en la etapa de **manipulación de datos**: cómo consultar y transformar la información almacenada.

```
DDL  (Data Definition Language)  →  define ESTRUCTURAS
                                     CREATE TABLE, ALTER TABLE, DROP TABLE

DML  (Data Manipulation Language)  →  manipula DATOS
                                       Álgebra Relacional, SELECT, INSERT, UPDATE, DELETE
```

El **Álgebra Relacional** es el fundamento matemático de las consultas en bases de datos relacionales. Las operaciones de SQL (especialmente `SELECT`) son implementaciones de estas operaciones algebraicas.

### CRUD

Toda operación sobre datos corresponde a uno de cuatro tipos:

| Letra | Operación | Descripción | SQL |
|---|---|---|---|
| **C** | Create | Insertar nuevos datos | `INSERT` |
| **R** | Read | Consultar datos | `SELECT` |
| **U** | Update | Modificar datos existentes | `UPDATE` |
| **D** | Delete | Eliminar datos | `DELETE` |

El Álgebra Relacional se ocupa principalmente del **Read (R)** — cómo formular consultas.

---

## 2. Conceptos fundamentales

### Tupla

Una **tupla** es una fila de una tabla: una secuencia ordenada y finita de valores, donde cada valor corresponde a un atributo específico.

```
Tupla ejemplo de la tabla CLIENTE:
('CLI-001', 'Ana Torres', 'Medellín', 'ana@mail.co')
   ↑            ↑           ↑             ↑
id_cliente  nombre     ciudad        email
```

### Relación

Una **relación** es la tabla completa: un conjunto de tuplas que comparten el mismo esquema (mismo número y tipo de atributos). El término "relación" en el contexto matemático equivale a lo que en la práctica llamamos "tabla".

```
Relación = tabla = conjunto de tuplas
Tupla    = fila  = un registro
Atributo = columna = un campo
```

### Compatibilidad de unión

Dos relaciones son **compatibles para unión** si:
- Tienen el **mismo número de atributos**
- Los atributos en posiciones equivalentes tienen **dominios compatibles** (tipos de dato compatibles)

Esta condición es necesaria para las operaciones ∪, −, ∩.

---

## 3. Tablas de ejemplo

Los ejemplos de esta clase usan dos relaciones: `people` y `products`.

**people** (8 tuplas):

| id | first_name | last_name | birth_date | genre | company |
|---|---|---|---|---|---|
| 1 | BILL | GATES | 1955-10-28 | M | MICROSOFT |
| 2 | STEVE | JOBS | 1955-02-24 | M | APPLE |
| 3 | ELON | MUSK | 1971-06-28 | M | TESLA |
| 4 | SERGEI | BRIN | 1973-08-21 | M | GOOGLE |
| 5 | LARRY | PAGE | 1973-03-26 | M | GOOGLE |
| 6 | MICHELLE | ZATLYN | NULL | F | CLOUDFLARE |
| 7 | MELANIE | PERKINS | 1987-05-13 | F | CANVA |
| 8 | MIKE | WONG | NULL | M | SUNFOUNDER |

**products** (7 tuplas):

| id | name | brand | inventory |
|---|---|---|---|
| A1 | ARDUINO UNO | ARDUINO | 750 |
| AM | ARDUINO MINI | ARDUINO | 50 |
| WD1M | WEMOS D1 MINI | LOLIN | 1500 |
| WD1P | WEMOS D1 MINI PRO | LOLIN | 100 |
| BME280 | SENSOR BME 280 | SUNFOUNDER | 50 |
| PIR-01 | SENSOR DE MOVIMIENTO | SUNFOUNDER | 430 |
| ROT01 | SENSOR ROTATORIO | SUNFOUNDER | 500 |

---

## 4. Clasificación de las operaciones

```
Operaciones básicas
├── Unarias (operan sobre 1 tabla)
│   ├── π  Proyección
│   └── σ  Selección
└── Binarias (operan sobre 2 tablas)
    ├── ∪  Unión
    ├── −  Diferencia
    └── ×  Producto cartesiano

Operaciones derivadas (no básicas — se pueden expresar con las básicas)
├── ∩  Intersección
├── ⋈  Unión natural (Natural Join)
├── /  División
└── ←  Asignación
```

---

## 5. Operaciones básicas unarias

### 5.1 Proyección — π (pi)

**Notación:** $\pi_{a_1, a_2, \ldots, a_k}(R)$

**Definición:** devuelve solo las columnas especificadas de la relación R. Los duplicados de tuplas resultantes se eliminan automáticamente.

**Equivalente SQL:** `SELECT DISTINCT a1, a2, ..., ak FROM R`

**Ejemplo 1 — proyección simple:**
```
π id, first_name, birth_date (people)
```
Resultado: 8 tuplas con solo esas 3 columnas.

**Ejemplo 2 — proyección con eliminación de duplicados:**
```
π brand (products)
```
La tabla tiene 7 filas pero las marcas son ARDUINO×2, LOLIN×2, SUNFOUNDER×3.
Resultado: 3 tuplas → ARDUINO, LOLIN, SUNFOUNDER

**Ejemplo 3:**
```
π genre, company (people)
```
Las 8 filas originales incluyen (M, GOOGLE) dos veces (SERGEI BRIN y LARRY PAGE).
Resultado: 7 tuplas (el duplicado se elimina).

**Propiedades:**
- La proyección es **conmutativa** si los atributos se incluyen: π_A(π_B(R)) = π_A(R) si A ⊆ B
- No modifica las tuplas, solo selecciona columnas
- El resultado nunca tiene más filas que la tabla original (puede tener menos por duplicados)

---

### 5.2 Selección — σ (sigma)

**Notación:** $\sigma_{condición}(R)$

**Definición:** devuelve todas las tuplas de R que satisfacen la condición. Conserva todas las columnas.

**Equivalente SQL:** `SELECT * FROM R WHERE condición`

**Operadores de condición:**
| Símbolo | Significado |
|---|---|
| = | igual |
| ≠ | distinto |
| < | menor que |
| > | mayor que |
| ≤ | menor o igual |
| ≥ | mayor o igual |
| ∧ | Y (AND) |
| ∨ | O (OR) |
| ¬ | NO (NOT) |

**Ejemplo 1:**
```
σ genre = 'F' (people)
```
Resultado: 2 tuplas → filas de MICHELLE ZATLYN y MELANIE PERKINS

**Ejemplo 2:**
```
σ id > 3 (people)
```
Resultado: 5 tuplas → filas 4, 5, 6, 7, 8

**Ejemplo 3:**
```
σ brand = 'SUNFOUNDER' (products)
```
Resultado: 3 tuplas → BME280, PIR-01, ROT01

**Ejemplo 4 — condición compuesta con ∧:**
```
σ brand = 'SUNFOUNDER' ∧ inventory > 100 (products)
```
Resultado: 2 tuplas → PIR-01 (430) y ROT01 (500)
BME280 queda excluido porque inventory = 50 ≤ 100

**Propiedades:**
- La selección es **conmutativa**: σ_c1(σ_c2(R)) = σ_c2(σ_c1(R))
- Equivalencia: σ_c1∧c2(R) = σ_c1(σ_c2(R))
- El resultado nunca tiene más filas que la tabla original
- El resultado tiene exactamente las mismas columnas que la tabla original

**Composición de π y σ — muy frecuente:**
```
π first_name, company (σ genre = 'F' (people))
```
Se lee de adentro hacia afuera: primero σ filtra filas, luego π selecciona columnas.
Resultado: 2 tuplas → (MICHELLE, CLOUDFLARE) y (MELANIE, CANVA)

Equivalente SQL:
```sql
SELECT first_name, company
FROM people
WHERE genre = 'F';
```

---

## 6. Operaciones básicas binarias

### 6.1 Unión — ∪

**Notación:** $R \cup S$

**Requisito:** R y S deben ser **compatibles para unión**.

**Definición:** devuelve todas las tuplas que están en R, en S, o en ambas. Los duplicados se eliminan.

**Equivalente SQL:** `SELECT ... FROM R UNION SELECT ... FROM S`

**Ejemplo:**
```
π company (people)  ∪  π brand (products)
```

| π company (people) | π brand (products) | Resultado R ∪ S |
|---|---|---|
| MICROSOFT | ARDUINO | MICROSOFT |
| APPLE | LOLIN | APPLE |
| TESLA | SUNFOUNDER | TESLA |
| GOOGLE | | GOOGLE |
| SUNFOUNDER | | SUNFOUNDER |
| CANVA | | CANVA |
| CLOUDFLARE | | CLOUDFLARE |
| | | ARDUINO |
| | | LOLIN |

SUNFOUNDER aparece en ambas → aparece una sola vez en el resultado.
Resultado: 9 tuplas.

**Propiedades:**
- Conmutativa: R ∪ S = S ∪ R
- Asociativa: (R ∪ S) ∪ T = R ∪ (S ∪ T)

---

### 6.2 Diferencia — −

**Notación:** $R - S$

**Requisito:** R y S deben ser **compatibles para unión**.

**Definición:** devuelve las tuplas que están en R pero NO están en S.

**Equivalente SQL:** `SELECT ... FROM R EXCEPT SELECT ... FROM S`

**Ejemplo:**
```
π company (people)  −  π brand (products)
```

| π company (people) | π brand (products) | Resultado R − S |
|---|---|---|
| MICROSOFT | ARDUINO | MICROSOFT |
| APPLE | LOLIN | APPLE |
| TESLA | SUNFOUNDER | TESLA |
| GOOGLE | | GOOGLE |
| SUNFOUNDER | | CANVA |
| CANVA | | CLOUDFLARE |
| CLOUDFLARE | | |

SUNFOUNDER está en ambas → se elimina del resultado.
Resultado: 6 tuplas (las empresas de `people` que NO son marcas de `products`).

> **¡La diferencia NO es conmutativa!** R − S ≠ S − R
> `π brand (products) − π company (people)` = ARDUINO, LOLIN (marcas que no son empresas de nadie en `people`).

**Propiedades:**
- NO es conmutativa: R − S ≠ S − R en general
- R − R = ∅ (resultado vacío)
- R − ∅ = R

---

### 6.3 Producto Cartesiano — ×

**Notación:** $R \times S$

**Definición:** devuelve TODAS las combinaciones posibles de una tupla de R con una tupla de S.

Si R tiene $m$ tuplas y $p$ atributos, y S tiene $n$ tuplas y $q$ atributos:
- Resultado: $m \times n$ tuplas
- Resultado: $p + q$ atributos

**No requiere compatibilidad de unión.**

**Equivalente SQL:** `SELECT * FROM R CROSS JOIN S` o `SELECT * FROM R, S`

**Ejemplo:**
```
π genre (people)  ×  π brand (products)
```

| π genre (people) | π brand (products) |
|---|---|
| F | ARDUINO |
| M | LOLIN |
| | SUNFOUNDER |

Valores únicos: genre = {F, M} → 2 valores; brand = {ARDUINO, LOLIN, SUNFOUNDER} → 3 valores
Resultado: 2 × 3 = **6 tuplas**

| genre | brand |
|---|---|
| F | ARDUINO |
| F | LOLIN |
| F | SUNFOUNDER |
| M | ARDUINO |
| M | LOLIN |
| M | SUNFOUNDER |

**Uso principal:** el producto cartesiano por sí solo rara vez es útil. Se combina con σ para filtrar solo las combinaciones válidas — esa es la base de la Unión Natural y del JOIN.

**Propiedades:**
- Conmutativo en contenido: R × S produce las mismas tuplas que S × R (pero en orden de columnas diferente)
- Asociativo: (R × S) × T = R × (S × T)

---

## 7. Operaciones derivadas

### 7.1 Intersección — ∩

**Notación:** $R \cap S$

**Requisito:** R y S deben ser **compatibles para unión**.

**Definición:** devuelve las tuplas que están tanto en R como en S.

**Equivalente con operaciones básicas:** $R \cap S = R - (R - S)$

**Equivalente SQL:** `SELECT ... FROM R INTERSECT SELECT ... FROM S`

**Ejemplo:**
```
π company (people)  ∩  π brand (products)
```

| π company (people) | π brand (products) | Resultado R ∩ S |
|---|---|---|
| MICROSOFT | ARDUINO | SUNFOUNDER |
| APPLE | LOLIN | |
| TESLA | SUNFOUNDER | |
| GOOGLE | | |
| SUNFOUNDER | | |
| CANVA | | |
| CLOUDFLARE | | |

Solo SUNFOUNDER aparece en ambas listas.
Resultado: 1 tupla → SUNFOUNDER

**Propiedades:**
- Conmutativa: R ∩ S = S ∩ R
- Asociativa: (R ∩ S) ∩ T = R ∩ (S ∩ T)
- R ∩ R = R
- R ∩ ∅ = ∅

---

### 7.2 Unión Natural — ⋈ (Natural Join)

**Notación:** $R \bowtie S$

**Definición:** combina tuplas de R y S que tienen el **mismo valor en los atributos que tienen el mismo nombre**. En el resultado, la columna compartida aparece una sola vez.

**Equivalente con operaciones básicas:**

$R \bowtie S = \pi_{atributos\_sin\_duplicar}(\sigma_{R.col\_comun = S.col\_comun}(R \times S))$

Es decir: producto cartesiano → selección por igualdad en la columna común → proyección para eliminar la columna duplicada.

**Equivalente SQL:** `SELECT * FROM R NATURAL JOIN S` o `SELECT ... FROM R JOIN S ON R.col = S.col`

**Ejemplo:**

Para hacer la unión natural entre `people` y `products`, necesitamos una columna en común. En el ejemplo de la presentación, se equipara `company` (de people) con `brand` (de products), aunque no tienen el mismo nombre — en ese caso hay que especificar la condición manualmente:

```
σ company = brand (people × products)
```

| Resultado |
|---|
| MIKE WONG (company=SUNFOUNDER) se une con BME280, PIR-01, ROT01 (brand=SUNFOUNDER) |

Solo hay coincidencia cuando company = brand = SUNFOUNDER → 3 tuplas en el resultado.

**Propiedad clave:** La Unión Natural es el fundamento del **JOIN** en SQL. Cuando en el futuro usen `INNER JOIN`, estarán aplicando esta misma operación.

**Propiedades:**
- Conmutativa: R ⋈ S = S ⋈ R
- Asociativa: (R ⋈ S) ⋈ T = R ⋈ (S ⋈ T)
- Si R y S no tienen atributos en común: R ⋈ S = R × S (equivale al producto cartesiano)

---

### 7.3 División — ÷

**Notación:** $R \div S$

**Definición:** dada una relación R con atributos (A, B) y una relación S con atributo (B), la división R ÷ S devuelve todos los valores de A que están emparejados en R con **todos** los valores de B en S.

**Pregunta que responde:** *"¿Qué A se relaciona con TODOS los B?"*

**Equivalente con operaciones básicas:**

$R \div S = \pi_A(R) - \pi_A((\pi_A(R) \times S) - R)$

**Ejemplo conceptual:**

Supón que tienes:
- R: (estudiante, materia) — qué materias ha cursado cada estudiante
- S: (materia) — lista de materias requeridas = {BASES DE DATOS, CÁLCULO}

R ÷ S devuelve los estudiantes que han cursado **todas** las materias de S.

```
R:
Ana    | BASES DE DATOS
Ana    | CÁLCULO
Luis   | BASES DE DATOS
Carlos | BASES DE DATOS
Carlos | CÁLCULO

S:
BASES DE DATOS
CÁLCULO

R ÷ S = {Ana, Carlos}  (Luis solo cursó BASES DE DATOS, no cumple el requisito)
```

**Uso típico:** preguntas del tipo "todos", "siempre", "en cada". En SQL se suele implementar con subconsultas correlacionadas o con `NOT EXISTS`.

---

### 7.4 Asignación — ←

**Notación:** $t \leftarrow expresión$

**Definición:** asigna el resultado de una expresión de álgebra relacional a una variable temporal llamada `t`. No es considerada una operación en sí, sino un mecanismo para simplificar expresiones largas.

**Ejemplo — sin asignación:**
```
π first_name, company (σ genre = 'F' ∧ company ≠ 'CLOUDFLARE' (people))
```

**Con asignación:**
```
mujeres ← σ genre = 'F' (people)
no_cloudflare ← σ company ≠ 'CLOUDFLARE' (mujeres)
resultado ← π first_name, company (no_cloudflare)
```

La asignación es equivalente a los **CTE** (Common Table Expressions) o subconsultas con alias en SQL.

---

## 8. Operaciones de conjuntos en SQL

Las operaciones de conjuntos de álgebra relacional tienen equivalentes directos en SQL:

| Álgebra Relacional | SQL | Descripción |
|---|---|---|
| R ∪ S | `UNION` | Une dos consultas, elimina duplicados |
| R ∪ S (con dup.) | `UNION ALL` | Une dos consultas, **conserva** duplicados |
| R ∩ S | `INTERSECT` | Solo lo que aparece en ambas |
| R − S | `EXCEPT` o `MINUS` | Lo que está en R pero no en S |

### Requisitos en SQL

Para usar estas operaciones en SQL, las dos consultas deben ser **compatibles**:
1. Mismo **número de columnas**
2. Columnas en el **mismo orden** con **tipos de dato compatibles**

**Ejemplo UNION:**
```sql
SELECT company AS nombre FROM people
UNION
SELECT brand   AS nombre FROM products;
-- Resultado: todas las empresas/marcas sin duplicados
```

**Ejemplo UNION ALL:**
```sql
SELECT company AS nombre FROM people
UNION ALL
SELECT brand   AS nombre FROM products;
-- Resultado: 8 + 7 = 15 filas (con duplicados)
```

**Ejemplo INTERSECT:**
```sql
SELECT company AS nombre FROM people
INTERSECT
SELECT brand   AS nombre FROM products;
-- Resultado: SUNFOUNDER
```

**Ejemplo EXCEPT:**
```sql
SELECT company AS nombre FROM people
EXCEPT
SELECT brand   AS nombre FROM products;
-- Resultado: MICROSOFT, APPLE, TESLA, GOOGLE, CANVA, CLOUDFLARE
```

---

## 9. Correspondencia completa Álgebra Relacional → SQL

| Operación | Símbolo | Equivalente SQL | Descripción |
|---|---|---|---|
| Proyección | π | `SELECT col1, col2` | Seleccionar columnas |
| Selección | σ | `WHERE condición` | Filtrar filas |
| Producto cartesiano | × | `CROSS JOIN` / `FROM A, B` | Todas las combinaciones |
| Unión natural | ⋈ | `INNER JOIN ... ON` | Combinar por columna común |
| Unión | ∪ | `UNION` | Unir resultados |
| Diferencia | − | `EXCEPT` | Restar resultados |
| Intersección | ∩ | `INTERSECT` | Elemento común |
| División | ÷ | Subconsulta con `NOT EXISTS` | "Para todos" |
| Asignación | ← | `WITH nombre AS (...)` (CTE) | Variable temporal |

---

## 10. Resumen de propiedades

| Propiedad | Unión ∪ | Diferencia − | Intersección ∩ | Producto × |
|---|---|---|---|---|
| Conmutativa | ✅ | ❌ | ✅ | ✅ (col. distintas) |
| Asociativa | ✅ | ❌ | ✅ | ✅ |
| Requiere compatibilidad | ✅ | ✅ | ✅ | ❌ |

**Reglas de simplificación útiles:**
- `σ_c1(σ_c2(R))` = `σ_c1 ∧ c2(R)` — selecciones anidadas se unen con AND
- `π_A(π_B(R))` = `π_A(R)` si A ⊆ B — proyecciones se pueden reducir
- `R ∩ S` = `R − (R − S)` — intersección expresada con diferencias
- `σ_cond(R × S)` → base del JOIN

---

## 11. DML — SELECT: del álgebra a SQL

El Álgebra Relacional es el **fundamento teórico**; el comando `SELECT` de SQL es su **implementación práctica**.

### Equivalencias directas

| Álgebra Relacional | SQL equivalente |
|---|---|
| `π col1, col2 (R)` | `SELECT col1, col2 FROM R` |
| `σ cond (R)` | `SELECT * FROM R WHERE cond` |
| `π cols (σ cond (R))` | `SELECT cols FROM R WHERE cond` |
| `R ∪ S` | `... UNION ...` |
| `R − S` | `... EXCEPT ...` |
| `R ∩ S` | `... INTERSECT ...` |
| `R × S` | `SELECT * FROM R CROSS JOIN S` |
| `R ⋈ S` | `SELECT * FROM R JOIN S ON ...` |

### Sintaxis completa de SELECT

```sql
SELECT [DISTINCT] columnas        -- π  (proyección; DISTINCT elimina duplicados)
FROM   tabla                      -- relación de la que se consulta
WHERE  condición                  -- σ  (selección)
ORDER BY columna [ASC | DESC]     -- (no tiene equivalente en AR puro)
LIMIT  n;                         -- (no tiene equivalente en AR puro)
```

### Ejemplos progresivos con las tablas de clase

**1 — Traer todo:**
```sql
SELECT * FROM people;
```

**2 — Proyección π:**
```sql
SELECT first_name, company FROM people;
-- equivale a: π first_name, company (people)
```

**3 — DISTINCT (proyección que elimina duplicados):**
```sql
SELECT DISTINCT brand FROM products;
-- equivale a: π brand (products)  →  ARDUINO, LOLIN, SUNFOUNDER
```

**4 — Selección σ:**
```sql
SELECT * FROM people WHERE genre = 'F';
-- equivale a: σ genre = 'F' (people)
```

**5 — Condición compuesta (∧ = AND, ∨ = OR):**
```sql
SELECT * FROM products WHERE brand = 'SUNFOUNDER' AND inventory > 100;
-- equivale a: σ brand='SUNFOUNDER' ∧ inventory>100 (products)
-- → PIR-01 y ROT01
```

**6 — Proyección + selección combinadas:**
```sql
SELECT first_name, company
FROM   people
WHERE  genre = 'F';
-- equivale a: π first_name,company (σ genre='F' (people))
-- → (MICHELLE, CLOUDFLARE) y (MELANIE, CANVA)
```

**7 — ORDER BY y LIMIT:**
```sql
SELECT first_name, birth_date
FROM   people
WHERE  birth_date IS NOT NULL
ORDER BY birth_date ASC
LIMIT  3;
-- Las 3 personas con fechas de nacimiento más antiguas
```

**8 — Operaciones de conjuntos en SQL:**
```sql
-- Unión ∪
SELECT company AS nombre FROM people
UNION
SELECT brand   AS nombre FROM products;

-- Diferencia −
SELECT company AS nombre FROM people
EXCEPT
SELECT brand   AS nombre FROM products;

-- Intersección ∩
SELECT company AS nombre FROM people
INTERSECT
SELECT brand   AS nombre FROM products;
-- → SUNFOUNDER
```

> **Nota:** `UNION` elimina duplicados automáticamente. Si se quiere conservarlos, usar `UNION ALL`.

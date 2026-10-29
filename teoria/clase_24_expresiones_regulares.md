# Clase 24 — Expresiones Regulares en PostgreSQL
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**
**Herramienta:** PostgreSQL + pgAdmin

---

## Cadena de aprendizaje — dónde estamos

```
Funciones nativas de texto (UPPER, LOWER, SPLIT_PART...)  ← Clase 20
    ↓
PL/pgSQL: funciones, procedimientos y triggers            ← Clases 22–23
    ↓
Expresiones regulares en PostgreSQL                       ← Clase 24 (aquí)
```

---

## Base de datos de referencia — StaffHub

```
DEPARTAMENTO (id_departamento, nombre, ciudad, presupuesto_anual)
EMPLEADO     (id_empleado, nombre, email, fecha_ingreso, salario_cop,
              calificacion NUMERIC(3,1), id_departamento FK)
CARGO        (id_empleado FK, titulo, nivel: 'junior' | 'senior' | 'lead')
```

Los datos de texto de esta tabla (nombres, emails, IDs) son perfectos para practicar patrones.

---

## 1. ¿Qué es una expresión regular? — El concepto desde cero

### 1.1 El problema que resuelven

Imagina que tienes una tabla con 50.000 emails y necesitas encontrar los que tienen un formato inválido. Con lo que sabes de SQL puedes hacer:

```sql
WHERE email LIKE '%@%'
```

Eso encuentra cualquier texto que tenga un `@` en algún lugar. Pero pasaría:
- `"@@@@"` ✓ (falso positivo)
- `"sin arroba"` ✗ (correcto)
- `"dos@@arrobas.com"` ✓ (falso positivo)

El problema es que `LIKE` solo tiene dos comodines (`%` y `_`) y no hay forma de decirle: *"quiero un `@`, pero exactamente uno, y debe estar precedido de al menos una letra, y seguido de al menos un punto y luego letras"*.

Las **expresiones regulares** (regex) son un mini-lenguaje que permite describir patrones de texto con precisión quirúrgica. En lugar de *"contiene algo"*, puedes decir exactamente *qué forma* debe tener el texto.

### 1.2 La idea central: un patrón es una descripción

Una expresión regular es una **descripción** de cómo debe verse un texto. Se construye combinando:

- Caracteres literales: la letra `a`, el dígito `5`, el símbolo `@`
- Metacaracteres: símbolos con significado especial (`.`, `*`, `+`, `?`, `^`, `$`, `[`, `]`, `(`, `)`)

Cuando se aplica un patrón a un texto, el motor de regex recorre el texto y pregunta: *"¿este texto cumple la descripción?"*

```
Texto:    "ana.torres@staffhub.com"
Patrón:   "^[^@]+@[^@]+\.[a-z]{2,}$"

¿Cómo se lee ese patrón mentalmente?
  ^        → desde el inicio
  [^@]+    → uno o más caracteres que NO sean @
  @        → exactamente un @
  [^@]+    → uno o más caracteres que NO sean @
  \.       → un punto literal
  [a-z]{2,}→ dos o más letras minúsculas
  $        → hasta el final

Traducción: "empieza, tiene texto sin @, luego exactamente un @,
             luego texto sin @, luego un punto, luego al menos dos letras, termina"
```

### 1.3 Los caracteres especiales y los literales

En una regex, la mayoría de los caracteres se representan a sí mismos. Estos son **literales**:

```
a  b  c  1  2  3  @  #  %  -  _  /  :
```

Pero algunos caracteres tienen un **significado especial** (son metacaracteres):

```
.  *  +  ?  ^  $  [  ]  (  )  {  }  |  \
```

Si quieres usar uno de estos como literal (por ejemplo, un punto real), hay que **escaparlo** con `\`:

```
\.   → un punto literal (no "cualquier carácter")
\*   → un asterisco literal (no "cero o más repeticiones")
\(   → un paréntesis literal (no "inicio de grupo")
```

---

## 2. Construyendo patrones: los bloques fundamentales

Esta sección explica cada componente desde cero, con ejemplos mentales antes de SQL.

### 2.1 El punto — el comodín de un carácter

El punto `.` coincide con **cualquier carácter excepto salto de línea**. Es como el comodín `_` de LIKE pero para regex.

```
Patrón: a.c
¿Qué acepta? → 'a' + CUALQUIER carácter + 'c'

"abc" → ✓ (a, b, c)
"a1c" → ✓ (a, 1, c)
"a-c" → ✓ (a, -, c)
"ac"  → ✗ (no hay un carácter entre a y c)
"abbc"→ ✗ (hay DOS caracteres entre a y c, el punto solo acepta UNO)
```

```sql
SELECT 'abc' ~ 'a.c';   -- true
SELECT 'a1c' ~ 'a.c';   -- true
SELECT 'ac'  ~ 'a.c';   -- false: falta el carácter del medio
SELECT 'a.c' ~ 'a.c';   -- true: el punto de regex coincide con el punto literal
SELECT 'a.c' ~ 'a\.c';  -- true: \. significa punto LITERAL
SELECT 'abc' ~ 'a\.c';  -- false: 'b' no es un punto literal
```

> **La trampa más común:** `'a.c'` como patrón acepta `'abc'`, `'a1c'`, `'axc'`, etc. Si quieres validar que hay un punto literal (como en un email), debes escribir `'a\.c'`.

### 2.2 Clases de caracteres `[...]` — el menú de opciones

Una clase de caracteres define un **conjunto de opciones** para una sola posición. Se escribe entre corchetes.

```
[abc]     → exactamente uno de: a, b o c
[0-9]     → cualquier dígito del 0 al 9 (rango)
[a-z]     → cualquier letra minúscula (rango)
[A-Z]     → cualquier letra mayúscula (rango)
[a-zA-Z]  → cualquier letra (minúscula o mayúscula)
[^abc]    → cualquier carácter EXCEPTO a, b, c (la ^ dentro de [] niega)
[^0-9]    → cualquier cosa que NO sea un dígito
```

**Leyéndolo mentalmente:**
```
Patrón: [AEIOU]
"¿el carácter es A, E, I, O o U?"

Patrón: [^0-9]
"¿el carácter es cualquier cosa excepto un dígito?"
```

```sql
-- Nombres que empiezan con vocal mayúscula
SELECT nombre FROM empleado WHERE nombre ~ '^[AEIOU]';
-- Ana Torres, Eduardo Mora, Ignacio Peña

-- IDs que empiezan con EMP- seguido de exactamente dos dígitos
SELECT id_empleado FROM empleado WHERE id_empleado ~ '^EMP-[0-9][0-9]$';
-- EMP-01, EMP-02, ..., EMP-12

-- Emails que contienen caracteres inválidos (ni letras, ni dígitos, ni . @ _ -)
SELECT nombre, email FROM empleado WHERE email ~ '[^a-zA-Z0-9.@_-]';
-- Sin resultados: todos los emails de StaffHub son válidos
```

### 2.3 Clases predefinidas — atajos para conjuntos comunes

En lugar de escribir `[0-9]` cada vez, existen atajos:

| Atajo | Equivale a | Qué representa |
|-------|-----------|----------------|
| `\d` | `[0-9]` | Un dígito (del inglés **d**igit) |
| `\D` | `[^0-9]` | Cualquier cosa que NO sea dígito |
| `\w` | `[a-zA-Z0-9_]` | Letra, dígito o guión bajo (**w**ord character) |
| `\W` | `[^a-zA-Z0-9_]` | Todo lo contrario a \w |
| `\s` | `[ \t\n\r]` | Espacio en blanco (**s**pace) |
| `\S` | `[^ \t\n\r]` | Cualquier cosa que no sea espacio |

```sql
-- \d es lo mismo que [0-9]
SELECT 'EMP-01' ~ '\d';   -- true: contiene al menos un dígito
SELECT 'abc'    ~ '\d';   -- false: no hay dígitos

-- \s es el espacio y sus variantes
SELECT 'Ana Torres' ~ '\s';   -- true: hay un espacio
SELECT 'AnaT'       ~ '\s';   -- false: sin espacios
```

> **Nota sobre PostgreSQL:** PostgreSQL soporta `\d`, `\w`, `\s` aunque su estándar base es POSIX. Son atajos muy prácticos — úsalos.

### 2.4 Cuantificadores — ¿cuántas veces se repite?

Un cuantificador se pega **inmediatamente después** del elemento que modifica (un carácter, una clase `[...]` o un grupo `(...)`) e indica cuántas veces debe aparecer:

| Cuantificador | Significado | Ejemplo mental |
|---------------|-------------|----------------|
| `*` | 0 o más veces | "puede no estar, puede estar muchas veces" |
| `+` | 1 o más veces | "debe estar al menos una vez" |
| `?` | 0 o 1 vez | "es opcional" |
| `{n}` | exactamente n veces | "debe estar exactamente n veces" |
| `{n,}` | n o más veces | "debe estar al menos n veces" |
| `{n,m}` | entre n y m veces | "debe estar entre n y m veces" |

**Leyendo cuantificadores mentalmente:**

```
\d+     → "uno o más dígitos"
[a-z]*  → "cero o más letras minúsculas"
\.?     → "un punto, que es opcional"
\d{4}   → "exactamente cuatro dígitos"
[A-Z]{2,3} → "entre dos y tres letras mayúsculas"
```

```sql
-- \d+ : uno o más dígitos
SELECT '123'  ~ '^\d+$';   -- true: es solo dígitos
SELECT ''     ~ '^\d+$';   -- false: no hay ningún dígito (+ exige al menos uno)
SELECT 'abc'  ~ '^\d+$';   -- false: no hay dígitos

-- \d* : cero o más dígitos (acepta cadena vacía)
SELECT ''     ~ '^\d*$';   -- true: cero dígitos también cumple
SELECT '123'  ~ '^\d*$';   -- true

-- colour/color: la 'u' es opcional con ?
SELECT 'colour' ~ 'colo(u)?r';   -- true
SELECT 'color'  ~ 'colo(u)?r';   -- true

-- EMP- seguido de exactamente 2 dígitos
SELECT 'EMP-01'  ~ '^EMP-\d{2}$';   -- true
SELECT 'EMP-123' ~ '^EMP-\d{2}$';   -- false: 3 dígitos, no 2
SELECT 'EMP-1'   ~ '^EMP-\d{2}$';   -- false: 1 dígito, no 2
```

### 2.5 Anclas — el inicio y el final

Las anclas no coinciden con caracteres sino con **posiciones** en el texto:

| Ancla | Posición que marca |
|-------|-------------------|
| `^` | El inicio del texto |
| `$` | El final del texto |

**Sin anclas, el patrón busca en cualquier lugar del texto:**

```
Texto:   "abc123"
Patrón:  "\d+"       (uno o más dígitos)

Sin anclas: busca dígitos EN ALGÚN LUGAR → TRUE (encontró "123")

Patrón: "^\d+$"      (solo dígitos, de inicio a fin)

Con anclas: el texto COMPLETO debe ser dígitos → FALSE (tiene "abc" al inicio)
```

```sql
-- Sin anclas: ¿hay dígitos en algún lugar?
SELECT 'abc123' ~ '\d+';    -- true: hay dígitos (en "123")
SELECT 'abc'    ~ '\d+';    -- false: no hay ningún dígito

-- Con anclas: ¿el texto COMPLETO es solo dígitos?
SELECT '123'    ~ '^\d+$';  -- true
SELECT 'abc123' ~ '^\d+$';  -- false: tiene letras al inicio
SELECT '123abc' ~ '^\d+$';  -- false: tiene letras al final

-- ^ solo: ¿empieza con algo específico?
SELECT 'EMP-01' ~ '^EMP';   -- true: empieza con "EMP"
SELECT 'TEMP-01'~ '^EMP';   -- false: empieza con "TEMP"

-- $ solo: ¿termina con algo específico?
SELECT 'staffhub.com' ~ '\.com$';   -- true: termina con ".com"
SELECT 'staffhub.org' ~ '\.com$';   -- false: termina con ".org"
```

> **Regla práctica:** usa `^` y `$` siempre que quieras **validar** el formato completo de un texto. Sin anclas, el patrón es una **búsqueda** (¿contiene esto?), no una **validación** (¿tiene exactamente este formato?).

### 2.6 Alternancia y grupos

La barra vertical `|` significa "o". Los paréntesis `()` agrupan partes del patrón como una unidad:

```
gato|perro       → "gato" o "perro"
(gato|perro)s    → "gatos" o "perros" (el grupo recibe el 's')
col(o|ou)r       → "color" o "colour"
(jpg|png|gif)$   → termina en "jpg" o "png" o "gif"
```

```sql
-- Nivel de cargo: junior, senior o lead
SELECT titulo FROM cargo WHERE nivel ~ '^(junior|senior|lead)$';
-- todos los cargos (todos cumplen)

-- Nombres que contienen Torres o Leal o Ríos
SELECT nombre FROM empleado WHERE nombre ~ '(Torres|Leal|Ríos)';
-- Ana Torres, Diana Leal, Gabriel Ríos, Manuel Torres

-- Emails de dominio .com o .co
SELECT email FROM empleado WHERE email ~ '\.(com|co)$';
```

---

## 3. Cómo leer una regex de corrido

Antes de escribir una regex en SQL, el truco es **leerla en voz alta**, de izquierda a derecha, traduciendo cada símbolo:

```
Regex:   ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$

Lectura:
  ^              → "empieza aquí"
  [a-zA-Z0-9._%+-]+ → "uno o más caracteres que sean: letra, dígito, punto, guión bajo, %, + o -"
  @              → "literalmente un @"
  [a-zA-Z0-9.-]+ → "uno o más caracteres que sean: letra, dígito, punto o guión"
  \.             → "literalmente un punto"
  [a-zA-Z]{2,}   → "dos o más letras"
  $              → "termina aquí"

Traducción humana: "un email con usuario válido, arroba, dominio válido, punto, extensión de al menos 2 letras"
```

**Ejercicio de lectura — ¿qué describe esta regex?**

```
^\d{3}-\d{3}-\d{4}$
```
- `^` inicio
- `\d{3}` exactamente 3 dígitos
- `-` un guión literal
- `\d{3}` exactamente 3 dígitos
- `-` un guión literal
- `\d{4}` exactamente 4 dígitos
- `$` fin

Respuesta: un número de teléfono en formato `555-123-4567`.

---

## 4. Operadores de PostgreSQL para regex

PostgreSQL tiene 4 operadores que aplican una regex a un texto y devuelven `TRUE` o `FALSE`:

| Operador | Descripción | Sensible a mayúsculas |
|----------|-------------|----------------------|
| `~` | Coincide con el patrón | Sí |
| `~*` | Coincide con el patrón | No (insensible) |
| `!~` | **No** coincide con el patrón | Sí |
| `!~*` | **No** coincide con el patrón | No (insensible) |

```sql
-- Probar directamente (sin tabla)
SELECT 'Ana Torres' ~ 'torres';    -- false: sensible, 't' minúscula no coincide con 'T'
SELECT 'Ana Torres' ~* 'torres';   -- true: insensible

-- En WHERE — buscar nombres que empiezan con vocal
SELECT nombre FROM empleado WHERE nombre ~ '^[AEIOU]';

-- En WHERE — excluir emails de staffhub.com
SELECT nombre, email FROM empleado WHERE email !~ '@staffhub\.com$';
-- Sin resultados (todos son @staffhub.com en este dataset)

-- Validar formato de id_empleado
SELECT id_empleado, (id_empleado ~ '^EMP-\d{2}$') AS formato_valido
FROM empleado;
-- Todos deben mostrar: true
```

### 4.1 Diferencia con LIKE — cuándo usar cada uno

| Necesidad | Herramienta | Por qué |
|-----------|-------------|---------|
| Buscar texto que contenga "Torres" | `LIKE '%Torres%'` | Más simple, más rápido |
| Buscar texto que empiece con vocal | `~ '^[AEIOU]'` | LIKE no puede hacer esto |
| Validar formato completo de email | `~ '^...$'` | LIKE no tiene la precisión necesaria |
| Buscar texto sin distinción de mayúsculas | `ILIKE '%torres%'` | Más simple que `~*` |
| Validar que un campo es solo dígitos | `~ '^\d+$'` | LIKE no puede garantizar "solo dígitos" |

```sql
-- Las tres formas de buscar "Torres" — equivalentes para este caso simple
WHERE nombre LIKE '%Torres%'
WHERE nombre SIMILAR TO '%Torres%'
WHERE nombre ~ 'Torres'

-- Solo ~ puede hacer esto:
WHERE email ~ '^[a-z.]+@[a-z]+\.[a-z]{2,4}$'   -- validación de formato completo
WHERE nombre ~ '^[^0-9]+$'                        -- que no contenga dígitos
WHERE id_empleado ~ '^EMP-\d{2}$'                 -- formato exacto del ID
```

---

## 5. Funciones de PostgreSQL para regex

Además de los operadores (que solo dicen TRUE/FALSE), PostgreSQL tiene funciones que **extraen**, **reemplazan** o **dividen** texto usando regex.

### 5.1 REGEXP_REPLACE — reemplazar texto por patrón

Reemplaza las partes del texto que coinciden con el patrón por otro texto.

```sql
-- Sintaxis
REGEXP_REPLACE(texto, patron, reemplazo)           -- reemplaza la primera coincidencia
REGEXP_REPLACE(texto, patron, reemplazo, 'g')      -- 'g' = todas las coincidencias
REGEXP_REPLACE(texto, patron, reemplazo, 'gi')     -- 'g' + 'i' = todas, insensible
```

**Ejemplos paso a paso:**

```sql
-- Caso 1: cambiar el dominio de un email
SELECT REGEXP_REPLACE('ana@staffhub.com', '@staffhub\.com$', '@empresa.co');
-- Patrón: @staffhub\.com$ → literal @ + staffhub + punto literal + com + fin
-- Resultado: 'ana@empresa.co'

-- Caso 2: eliminar todos los dígitos de una cadena
SELECT REGEXP_REPLACE('EMP-01-2024', '\d', '', 'g');
-- \d = cualquier dígito, '' = reemplazar por nada, 'g' = todas las ocurrencias
-- Resultado: 'EMP--'

-- Caso 3: limpiar espacios múltiples
SELECT TRIM(REGEXP_REPLACE('  Ana   Torres  ', '\s+', ' ', 'g'));
-- \s+ = uno o más espacios, ' ' = un espacio, 'g' = todas las ocurrencias
-- Resultado: 'Ana Torres'

-- Caso 4: enmascarar el usuario de un email
SELECT REGEXP_REPLACE('ana.torres@staffhub.com', '^[^@]+', '***');
-- ^[^@]+ = desde el inicio, uno o más caracteres que no sean @
-- Resultado: '***@staffhub.com'
```

Aplicado a la tabla:

```sql
SELECT nombre,
       REGEXP_REPLACE(email, '@staffhub\.com$', '@empresa.co') AS email_nuevo
FROM empleado;
-- ana.torres@empresa.co  |  carlos.ruiz@empresa.co  | ...
```

### 5.2 REGEXP_MATCH — extraer la primera coincidencia

Devuelve la primera parte del texto que coincide con el patrón, como un array de texto.

```sql
-- Sintaxis
REGEXP_MATCH(texto, patron)       -- devuelve array con la primera coincidencia
(REGEXP_MATCH(texto, patron))[1]  -- accede al primer elemento del array
```

```sql
-- Extraer el primer número de un texto
SELECT REGEXP_MATCH('EMP-07 tiene 5 años', '\d+');
-- {'07'}  ← solo la primera coincidencia

SELECT (REGEXP_MATCH('EMP-07 tiene 5 años', '\d+'))[1];
-- '07'  ← el valor directamente (sin los corchetes del array)
```

**Grupos de captura `()` — extraer partes específicas:**

Los paréntesis dentro de la regex crean **grupos de captura**. Cada grupo capturado se guarda en una posición del array resultado:

```sql
-- Separar usuario y dominio de un email usando grupos
SELECT REGEXP_MATCH('ana.torres@staffhub.com', '^([^@]+)@(.+)$');
-- {'ana.torres','staffhub.com'}
-- [1] = lo que capturó el primer grupo: ([^@]+) = "ana.torres"
-- [2] = lo que capturó el segundo grupo: (.+) = "staffhub.com"

SELECT (REGEXP_MATCH('ana.torres@staffhub.com', '^([^@]+)@(.+)$'))[1] AS usuario;
-- 'ana.torres'

SELECT (REGEXP_MATCH('ana.torres@staffhub.com', '^([^@]+)@(.+)$'))[2] AS dominio;
-- 'staffhub.com'
```

Aplicado a la tabla:

```sql
SELECT nombre,
       (REGEXP_MATCH(email, '^([^@]+)@(.+)$'))[1] AS usuario,
       (REGEXP_MATCH(email, '^([^@]+)@(.+)$'))[2] AS dominio
FROM empleado;
```

### 5.3 REGEXP_MATCHES — todas las coincidencias

A diferencia de `REGEXP_MATCH` (solo la primera), `REGEXP_MATCHES` con el flag `'g'` devuelve **una fila por cada coincidencia**:

```sql
-- Extraer TODOS los números de un texto
SELECT REGEXP_MATCHES('EMP-07 tiene 5 años y ganó $4200000', '\d+', 'g');
-- {'07'}
-- {'5'}
-- {'4200000'}
-- (tres filas, una por cada número encontrado)
```

> **¿Cuándo usar REGEXP_MATCH vs REGEXP_MATCHES?**
> - `REGEXP_MATCH` → cuando sabes que solo hay una coincidencia y quieres el valor directamente
> - `REGEXP_MATCHES` con `'g'` → cuando puede haber múltiples coincidencias y quieres todas

### 5.4 REGEXP_SPLIT_TO_TABLE — dividir texto en filas

Divide un texto usando el patrón como **separador** y devuelve una fila por cada parte:

```sql
-- Dividir un nombre completo por espacios
SELECT REGEXP_SPLIT_TO_TABLE('Ana María Torres Ruiz', '\s+') AS parte;
-- Ana
-- María
-- Torres
-- Ruiz

-- Dividir una lista separada por comas (con espacios opcionales)
SELECT REGEXP_SPLIT_TO_TABLE('lunes, martes,  miércoles', ',\s*') AS dia;
-- lunes
-- martes
-- miércoles
-- \s* = cero o más espacios después de la coma (opcionales)
```

### 5.5 REGEXP_SPLIT_TO_ARRAY — dividir texto en array

Igual que `REGEXP_SPLIT_TO_TABLE` pero devuelve un array en lugar de filas (útil dentro de consultas):

```sql
SELECT REGEXP_SPLIT_TO_ARRAY('Ana Torres', '\s+');
-- {Ana,Torres}   ← un array con dos elementos

-- Acceder a elementos individuales
SELECT (REGEXP_SPLIT_TO_ARRAY('Ana Torres', '\s+'))[1] AS primer_nombre;  -- 'Ana'
SELECT (REGEXP_SPLIT_TO_ARRAY('Ana Torres', '\s+'))[2] AS apellido;        -- 'Torres'

-- Aplicado a la tabla: extraer primer nombre y apellido
SELECT nombre,
       (REGEXP_SPLIT_TO_ARRAY(nombre, '\s+'))[1] AS primer_nombre,
       (REGEXP_SPLIT_TO_ARRAY(nombre, '\s+'))[2] AS apellido
FROM empleado
ORDER BY apellido;
```

---

## 6. Casos de uso reales en PostgreSQL

### 6.1 Validación de datos

```sql
-- Verificar que todos los IDs tienen el formato correcto (EMP-XX)
SELECT id_empleado,
       nombre,
       (id_empleado ~ '^EMP-\d{2}$') AS id_valido
FROM empleado
WHERE NOT (id_empleado ~ '^EMP-\d{2}$');
-- Sin resultados: todos son válidos en StaffHub
-- En producción: esta consulta detecta registros con formato incorrecto

-- Verificar formato de email
SELECT nombre, email,
       (email ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') AS email_valido
FROM empleado;

-- Verificar que el nombre no contiene dígitos
SELECT nombre,
       (nombre ~ '\d') AS contiene_digitos
FROM empleado
WHERE nombre ~ '\d';
-- Sin resultados: ningún nombre tiene dígitos
```

### 6.2 Extracción de información

```sql
-- Extraer el usuario (antes del @) de cada email
SELECT nombre,
       (REGEXP_MATCH(email, '^([^@]+)@'))[1] AS usuario_email
FROM empleado;

-- Extraer la extensión del dominio (.com, .co, etc.)
SELECT nombre,
       (REGEXP_MATCH(email, '\.([a-z]+)$'))[1] AS extension
FROM empleado;
-- todos: 'com'

-- Extraer el número del ID de empleado como texto
SELECT id_empleado,
       (REGEXP_MATCH(id_empleado, '\d+'))[1] AS numero
FROM empleado
ORDER BY numero;
-- '01', '02', ..., '12'
```

### 6.3 Limpieza y transformación

```sql
-- Normalizar el dominio del email (cambiar @staffhub.com por @empresa.co)
SELECT nombre,
       REGEXP_REPLACE(email, '@staffhub\.com$', '@empresa.co') AS email_normalizado
FROM empleado;

-- Limpiar espacios múltiples en cualquier campo de texto
SELECT TRIM(REGEXP_REPLACE('  Ana    Torres  ', '\s+', ' ', 'g')) AS nombre_limpio;
-- 'Ana Torres'

-- Generar tarjeta de presentación
SELECT id_empleado || ' | ' ||
       UPPER((REGEXP_SPLIT_TO_ARRAY(nombre, '\s+'))[2]) || ', ' ||
       (REGEXP_SPLIT_TO_ARRAY(nombre, '\s+'))[1]
       AS tarjeta
FROM empleado
ORDER BY (REGEXP_SPLIT_TO_ARRAY(nombre, '\s+'))[2];
-- EMP-06 | RÍOS, Gabriel
-- EMP-01 | TORRES, Ana
-- EMP-07 | VARGAS, Helena
-- ...
```

### 6.4 Uso dentro de PL/pgSQL

Las regex funcionan exactamente igual dentro de funciones y triggers:

```sql
-- Función que valida el email antes de insertar
CREATE OR REPLACE FUNCTION crear_empleado_validado(
    p_id     VARCHAR,
    p_nombre VARCHAR,
    p_email  VARCHAR,
    p_fecha  DATE,
    p_sal    INT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar ID con regex
    IF p_id !~ '^EMP-\d{2}$' THEN
        RAISE EXCEPTION 'ID inválido: %. Formato esperado: EMP-XX', p_id;
    END IF;

    -- Validar email con regex
    IF p_email IS NOT NULL AND p_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' THEN
        RAISE EXCEPTION 'Email inválido: %', p_email;
    END IF;

    -- Limpiar nombre con regex antes de insertar
    INSERT INTO empleado (id_empleado, nombre, email, fecha_ingreso, salario_cop)
    VALUES (p_id,
            INITCAP(TRIM(REGEXP_REPLACE(p_nombre, '\s+', ' ', 'g'))),
            LOWER(p_email),
            p_fecha, p_sal);

    RETURN 'Empleado ' || p_id || ' creado correctamente.';
END;
$$;
```

---

## 7. Comparativa completa: LIKE vs SIMILAR TO vs `~`

| Característica | `LIKE` / `ILIKE` | `SIMILAR TO` | `~` / `~*` (POSIX) |
|----------------|------------------|--------------|---------------------|
| Wildcard "cualquier cosa" | `%` | `%` | No — usa `.*` o `\w+` |
| Wildcard "un carácter" | `_` | `_` | No — usa `.` |
| Clases de caracteres | No | `[a-z]`, `[abc]` | `[a-z]`, `\d`, `\w`... |
| Cuantificadores | No | `*`, `+`, `?` | `*`, `+`, `?`, `{n}`, `{n,m}` |
| Alternancia | No | `(a\|b)` | `a\|b`, `(a\|b)` |
| Anclas explícitas | No — `%` actúa como comodín | El patrón ancla implícitamente todo | `^` y `$` explícitos |
| Grupos de captura | No | No | Sí — para usar con REGEXP_MATCH |
| Sensible a mayúsculas | `LIKE` sí / `ILIKE` no | Sí | `~` sí / `~*` no |
| Funciones de extracción | No | No | `REGEXP_REPLACE`, `REGEXP_MATCH`... |
| Velocidad | ⚡ Más rápido | Intermedio | Más lento (más potente) |
| **Cuándo usar** | Búsquedas simples con `%` | Patrones con clases básicas | Validación precisa, extracción, limpieza |

---

## 8. Patrones de referencia rápida

Estos son los patrones más usados en bases de datos reales:

| Propósito | Patrón | Notas |
|-----------|--------|-------|
| Email básico | `'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'` | No cubre todos los casos edge pero es práctico |
| Solo dígitos | `'^\d+$'` | Equivale a `'^[0-9]+$'` |
| Solo letras (sin tildes) | `'^[a-zA-Z]+$'` | |
| Solo letras y espacios | `'^[a-zA-Z ]+$'` | |
| Letras con tildes y ñ | `'^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$'` | |
| ID formato EMP-XX | `'^EMP-\d{2}$'` | Exactamente 2 dígitos |
| Fecha YYYY-MM-DD | `'^\d{4}-\d{2}-\d{2}$'` | No valida que los valores sean fechas reales |
| URL básica | `'^https?://.+\..+'` | `?` hace la 's' opcional |
| Teléfono colombiano (10 dígitos) | `'^\d{10}$'` | |
| Código postal Colombia | `'^\d{6}$'` | |
| Sin dígitos en el texto | `'^[^\d]+$'` o `'^\D+$'` | |
| Empieza con mayúscula | `'^[A-ZÁÉÍÓÚ]'` | Solo valida el primer carácter |

---

## 9. Errores frecuentes

### Olvidar escapar el punto en patrones de email/dominio

```sql
-- ❌ El punto sin escapar acepta cualquier carácter
SELECT 'axbxc' ~ 'a.b.c';   -- true: los puntos son comodines
SELECT 'axbxc' ~ 'a\.b\.c'; -- false: puntos literales — correcto

-- En emails: staffhub.com vs staffhubXcom
SELECT 'staffhubXcom' ~ 'staffhub.com';    -- true (¡MAL! el punto acepta 'X')
SELECT 'staffhubXcom' ~ 'staffhub\.com';   -- false (bien: exige punto literal)
```

### Olvidar las anclas en validaciones

```sql
-- ❌ Sin anclas, solo busca si el patrón APARECE en algún lugar
SELECT 'abc123xyz' ~ '\d+';    -- true: hay dígitos en algún lugar
-- No valida que TODA la cadena sea dígitos

-- ✅ Con anclas, valida el formato completo
SELECT 'abc123xyz' ~ '^\d+$';  -- false: correcto
SELECT '123'       ~ '^\d+$';  -- true: correcto
```

### Confundir `~` (sensible) con `~*` (insensible)

```sql
SELECT 'Ana Torres' ~ 'ana';    -- false: 'A' mayúscula no coincide con 'a'
SELECT 'Ana Torres' ~* 'ana';   -- true: insensible a mayúsculas
```

### `REGEXP_MATCHES` sin flag `'g'` no devuelve todas las coincidencias

```sql
-- Sin 'g': solo la primera coincidencia
SELECT REGEXP_MATCHES('abc123def456', '\d+');
-- {'123'}   ← solo la primera

-- Con 'g': todas las coincidencias (una fila por cada una)
SELECT REGEXP_MATCHES('abc123def456', '\d+', 'g');
-- {'123'}
-- {'456'}
```

### Intentar extraer texto con `~` (que solo devuelve TRUE/FALSE)

```sql
-- ❌ ~ solo dice si coincide, no extrae el texto coincidente
SELECT nombre ~ '([A-Z][a-z]+)' FROM empleado;
-- Devuelve: true/false — no el texto capturado

-- ✅ Para extraer, usar REGEXP_MATCH
SELECT (REGEXP_MATCH(nombre, '([A-Z][a-z]+)'))[1] FROM empleado;
-- 'Ana', 'Carlos', 'Diana', ...
```

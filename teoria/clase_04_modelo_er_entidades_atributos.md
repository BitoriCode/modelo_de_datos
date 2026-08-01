# Clase 4 — Modelo Entidad-Relación: Entidades y Atributos
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**

---

## Repaso rápido — Clases 1-3

- **Modelo de datos:** estructura + restricciones + operaciones
- **3 niveles:** conceptual → lógico → físico
- **4 usuarios:** DBA, Diseñador, Desarrollador, Usuario final
- **Pregunta de esta clase:** ¿cómo construyo el **nivel conceptual**?

---

## 1. ¿Por qué necesitamos un método para diseñar?

Imagina este escenario: un cliente te dice *"quiero una base de datos para gestionar mi tienda — tengo productos, proveedores, clientes y pedidos"*. ¿Por dónde empiezas?

Sin un método formal, el diseñador puede:
- Olvidar información importante
- Crear tablas redundantes o mal estructuradas
- Descubrir problemas graves cuando ya hay miles de líneas de código escritas

> **El Modelo Entidad-Relación** es ese método.

---

## 2. ¿Qué es el Modelo Entidad-Relación (E-R)?

> El **Modelo Entidad-Relación** (E-R) es un lenguaje gráfico para representar la estructura de los datos a nivel conceptual, **independiente de cualquier DBMS**.

Fue propuesto por **Peter Chen** en **1976** y sigue siendo el estándar para diseño conceptual de bases de datos relacionales.

### 2.1 Características clave

1. **Visual:** se dibuja en papel, pizarrón o herramientas como draw.io — antes de tocar SQL
2. **Independiente del DBMS:** no importa si usarás PostgreSQL, MySQL, Oracle u otro
3. **Lenguaje común:** permite que diseñadores, programadores y clientes hablen el mismo idioma sobre los datos

### 2.2 Posición del E-R en el proceso de diseño

El E-R vive en el **nivel conceptual**. Es el primer paso antes de cualquier implementación:

```
Mundo real
    ↓  (análisis de requisitos: entrevistas, documentos, casos de uso)
Diagrama E-R              ← Clases 4 y 5 (estamos aquí)
    ↓  (transformación al modelo relacional)
Tablas y columnas         ← Semana 6
    ↓  (implementación)
SQL en PostgreSQL         ← Semanas 7-8
```

---

## 3. Entidades

### 3.1 Definición

> Una **entidad** es cualquier cosa del mundo real que tiene existencia independiente y sobre la cual queremos guardar información.

**Regla práctica para identificar entidades:** si puedes hacerle preguntas como *"¿cuántos hay?"*, *"¿cuáles son sus características?"* o *"¿tiene nombre, código o identificador propio?"*, probablemente es una entidad.

### 3.2 Ejemplos: qué es y qué NO es una entidad

| ¿Es entidad? | Caso | Razonamiento |
|---|---|---|
| ✅ Sí | `ESTUDIANTE` | Tiene cédula, nombre, carrera. Existen muchos, cada uno identificable |
| ✅ Sí | `CURSO` | Tiene código, nombre, créditos |
| ✅ Sí | `PROFESOR` | Tiene nombre, departamento, título |
| ❌ No | `"aprobado"` | Es un estado de un estudiante, no una cosa en sí misma |
| ❌ No | `"nombre"` | Es un dato (atributo) de un estudiante, no una entidad |
| ⚠️ Depende | `MATRÍCULA` | Puede ser entidad si se quieren guardar datos propios de la inscripción (fecha, nota) |

### 3.3 Tipo de entidad vs. Ocurrencia

Son dos conceptos distintos que se suelen confundir:

| Concepto | También llamado | Descripción | Ejemplo |
|---|---|---|---|
| **Tipo de entidad** | Clase | La definición abstracta | `ESTUDIANTE` |
| **Ocurrencia** | Instancia | Un caso concreto | *Ana García, cod. 2021-001* |

> Es como la diferencia entre la clase `Estudiante` en Java (tipo) y un objeto `new Estudiante("Ana")` (ocurrencia).

### 3.4 Notación de Chen — Entidades

En el diagrama de Chen, las entidades se representan con **rectángulos**. El nombre va en **MAYÚSCULAS** dentro del rectángulo.

```
┌─────────────┐     ┌────────┐     ┌──────────┐
│  ESTUDIANTE │     │ CURSO  │     │ PROFESOR │
└─────────────┘     └────────┘     └──────────┘
```

### 3.5 Entidades fuertes vs. Débiles (introducción)

| Tipo | Descripción | Notación Chen |
|---|---|---|
| **Entidad fuerte** | Existe por sí sola. Tiene su propia clave que la identifica unívocamente | Rectángulo simple `┌───┐` |
| **Entidad débil** | Su existencia depende de otra entidad. No tiene clave propia completa | Rectángulo doble `╔═══╗` |

**Ejemplo de entidad débil:** `DEPENDIENTE` (familiar de un empleado). Un dependiente no existe en la BD si no existe el empleado al que pertenece.

> En la clase 4 solo trabajamos con **entidades fuertes**. Las débiles se verán en la clase siguiente.

---

## 4. Atributos

### 4.1 Definición

> Un **atributo** es una propiedad o característica de una entidad que queremos almacenar.

Los atributos responden a la pregunta: ¿qué información quiero guardar sobre esta entidad?

En la notación de Chen, los atributos se dibujan como **óvalos** conectados al rectángulo de la entidad.

```
    (id_est)   (nombre)   (fecha_nac)
         \         |          /
       ┌──────────────────────┐
       │      ESTUDIANTE      │
       └──────────────────────┘
            /         \
       (carrera)    (correo)
```

### 4.2 Los 5 tipos de atributos

Conocer los tipos de atributos es fundamental porque cada uno se **implementa de manera diferente** en SQL.

---

#### Tipo 1: Atributo simple (o atómico)

No se puede descomponer en partes más pequeñas. Es el tipo más común.

- **Notación:** óvalo normal `( )`
- **En SQL:** se convierte directamente en una columna

| Atributo | Columna SQL |
|---|---|
| `(id_estudiante)` | `id_estudiante INT` |
| `(nombre)` | `nombre VARCHAR(100)` |
| `(creditos)` | `creditos INT` |
| `(correo)` | `correo VARCHAR(150)` |

---

#### Tipo 2: Atributo compuesto

Se puede descomponer en **sub-atributos** más simples. La decisión de si un atributo es simple o compuesto depende de si el sistema necesita operar sobre sus partes.

- **Notación:** óvalo con sub-óvalos conectados

```
         ( dirección )
        /      |      \
  (calle)  (ciudad)  (código_postal)
```

- **En SQL:** cada sub-atributo se convierte en una columna separada

```sql
-- Si dirección es compuesta:
calle          VARCHAR(100),
ciudad         VARCHAR(50),
codigo_postal  VARCHAR(10)
```

> **¿Cuándo hacerla compuesta?** Si el sistema necesita buscar, filtrar u ordenar por ciudad o código postal por separado, debe ser compuesta. Si solo se muestra como texto completo, puede ser simple.

---

#### Tipo 3: Atributo multivaluado

Puede tener **más de un valor** para la misma ocurrencia de la entidad.

- **Notación:** óvalo doble `(( ))`

```
     (( teléfono ))
           |
   ┌──────────────┐
   │  ESTUDIANTE  │
   └──────────────┘
```

**Ejemplos:**
- `teléfono`: un estudiante puede tener celular y fijo
- `correo`: puede tener correo institucional y personal
- `idioma`: un candidato puede hablar varios idiomas

**Implementación en SQL:** un atributo multivaluado **siempre** se convierte en una **tabla separada**. Nunca se almacena como `tel1, tel2, tel3` en columnas separadas — eso viola las reglas de normalización.

```sql
-- INCORRECTO (columnas separadas para valores múltiples)
CREATE TABLE estudiantes (
    id       SERIAL PRIMARY KEY,
    nombre   VARCHAR(100),
    telefono1 VARCHAR(20),    -- ❌ ¿y si tiene un 4to teléfono?
    telefono2 VARCHAR(20)     -- ❌ columnas vacías si solo tiene uno
);

-- CORRECTO (tabla separada para el atributo multivaluado)
CREATE TABLE estudiantes (
    id     SERIAL PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE telefonos_estudiante (
    estudiante_id INT REFERENCES estudiantes(id),
    telefono      VARCHAR(20),
    tipo          VARCHAR(20)  -- 'celular', 'fijo', 'trabajo'
);
```

---

#### Tipo 4: Atributo derivado

Su valor se puede **calcular** a partir de otros datos ya almacenados. No es necesario guardarlo.

- **Notación:** óvalo punteado `(- -)`

```
  (- edad -)     (nombre)   (fecha_nacimiento)
       |              |            |
   ┌──────────────────────────────────────┐
   │              ESTUDIANTE              │
   └──────────────────────────────────────┘
```

**Ejemplos:**
- `edad` — calculada a partir de `fecha_nacimiento` y la fecha actual
- `total_créditos` — calculado sumando los créditos de las materias aprobadas
- `promedio` — calculado a partir de las notas

**Implementación en SQL:** los atributos derivados generalmente **no se almacenan** en la BD. Se calculan en el momento de la consulta.

```sql
-- edad se calcula al consultar, no se guarda
SELECT nombre,
       EXTRACT(YEAR FROM AGE(fecha_nacimiento)) AS edad
FROM estudiantes;
```

> **¿Por qué no guardar la edad?** Porque tendría que actualizarse cada año para cada estudiante. Si se guarda, habrá inconsistencias. Si se calcula, siempre es correcta.

---

#### Tipo 5: Atributo nulo (NULL)

No es un tipo de atributo aparte — es una **propiedad** que puede tener cualquier atributo. Indica que en ciertas ocurrencias ese atributo puede no tener valor.

**Ejemplos:**
- `segundo_apellido` — no todos tienen segundo apellido
- `número_extensión` — solo para empleados que tienen oficina
- `fecha_graduación` — no aplica para estudiantes activos

> **Importante:** `NULL` no es `0` ni es cadena vacía `''`. `NULL` significa **"valor desconocido o no aplicable"**. En SQL, las operaciones con `NULL` tienen comportamiento especial.

```sql
-- En SQL, NULL no es igual a nada, ni siquiera a sí mismo
SELECT * FROM estudiantes WHERE fecha_graduacion = NULL;  -- ❌ no funciona
SELECT * FROM estudiantes WHERE fecha_graduacion IS NULL; -- ✅ correcto
```

---

### 4.3 Resumen visual de los 5 tipos

| Tipo | Notación Chen | Ejemplo | Implementación SQL |
|---|---|---|---|
| Simple | `( nombre )` | `(nombre)` | Columna directa |
| Compuesto | sub-óvalos | `(dirección)` → `calle, ciudad` | Columnas separadas |
| Multivaluado | `(( teléfono ))` | `((teléfono))` | Tabla separada |
| Derivado | `(- edad -)` | `(- promedio -)` | No se almacena, se calcula |
| Nulo | cualquier tipo + puede ser `NULL` | `(segundo_apellido)` | Columna sin `NOT NULL` |

---

## 5. Claves — Cómo identificar cada ocurrencia

### 5.1 El problema de la identificación

Si hay 500 estudiantes llamados *"María García"*, ¿cómo distinguimos cuál es cuál? Necesitamos un atributo (o conjunto de atributos) que identifique de forma **única e inequívoca** cada ocurrencia de la entidad.

### 5.2 Tipos de claves

#### Superclave

> Cualquier conjunto de atributos que identifique de forma única una ocurrencia. **Puede tener atributos redundantes.**

Ejemplo en `ESTUDIANTE`: `{id, nombre}` es superclave — pero `id` solo ya identifica, así que `nombre` sobra.

#### Clave candidata

> Superclave **mínima** — no tiene atributos redundantes. Si se quita cualquier atributo, ya no identifica unívocamente.

Ejemplo en `ESTUDIANTE`:
- `id_estudiante` — identifica unívocamente, no se puede reducir más ✅
- `número_documento` — también identifica unívocamente ✅
- `{id_estudiante, nombre}` — no es candidata porque `nombre` sobra ❌

Puede haber **varias claves candidatas** en una entidad.

#### Clave primaria (PK)

> La clave candidata que el **diseñador elige** para identificar la entidad en el modelo. Solo puede haber **una** por entidad.

- En la notación de Chen: el atributo PK se **subraya**

```
  ( id_estudiante )   ← atributo subrayado = PK
   ──────────────
```

#### Clave foránea (FK)

> Atributo de una tabla que **referencia** la clave primaria de otra tabla. Establece la relación entre tablas.

```sql
CREATE TABLE matriculas (
    estudiante_id INT REFERENCES estudiantes(id),  -- FK → PK de estudiantes
    curso_id      INT REFERENCES cursos(id),        -- FK → PK de cursos
    ...
);
```

### 5.3 Reglas de una buena clave primaria

| Regla | Descripción | Contraejemplo |
|---|---|---|
| **Unicidad** | No puede repetirse entre ocurrencias | Dos estudiantes con el mismo id |
| **No nula** | Nunca puede ser `NULL` | Un estudiante sin id |
| **Estabilidad** | No debe cambiar con el tiempo | El nombre puede cambiar (apellido por matrimonio) |
| **Minimalidad** | Usar el menor número de atributos posible | No usar `{id, nombre}` si `id` solo alcanza |

### 5.4 Claves naturales vs. Artificiales

| Tipo | Descripción | Ejemplo | ¿Cuándo usarla? |
|---|---|---|---|
| **Natural** | Existe en el mundo real y es única | Número de cédula, ISBN de un libro | Cuando es estable y siempre existe |
| **Artificial (surrogate)** | Generada por el sistema, sin significado de negocio | `SERIAL`, UUID | La mayoría de los casos |

> **¿Por qué casi siempre se prefiere la clave artificial?**
> - El número de documento puede cambiar (pasaporte vencido, cambio de país)
> - El correo puede cambiar
> - El número de documento puede ser incorrecto o estar pendiente de asignar
> - El `SERIAL` nunca cambia — es interno al sistema

---

## 6. Notación de Chen — Resumen completo

| Símbolo | Representa | Ejemplo |
|---|---|---|
| `┌───┐` Rectángulo | Entidad fuerte | `ESTUDIANTE`, `CURSO` |
| `╔═══╗` Rectángulo doble | Entidad débil | `DEPENDIENTE` (de `EMPLEADO`) |
| `( )` Óvalo | Atributo simple | `(nombre)`, `(edad)` |
| Sub-óvalos conectados | Atributo compuesto | `(dirección)` → `(calle)`, `(ciudad)` |
| `(( ))` Óvalo doble | Atributo multivaluado | `((teléfono))`, `((correo))` |
| `(- -)` Óvalo punteado | Atributo derivado | `(-edad-)`, `(-promedio-)` |
| Atributo subrayado | Clave primaria | `(id_estudiante)` subrayado |
| `◇` Rombo | Relación (se verá próxima clase) | `◇ INSCRIBE ◇` |

---

## 7. Ejercicio guiado — Primer diagrama E-R

### Enunciado

> *Una universidad quiere registrar la información básica de sus estudiantes. De cada estudiante se sabe: número de documento (único), nombre completo, fecha de nacimiento, carrera, semestre actual. Además pueden tener entre 1 y 3 correos electrónicos registrados.*

### Solución paso a paso

**Paso 1 — Identificar la entidad:**
→ `ESTUDIANTE` (tiene existencia propia, podemos hacer preguntas sobre sus características)

**Paso 2 — Listar los atributos:**
→ número_documento, nombre, fecha_nacimiento, carrera, semestre, correos, edad

**Paso 3 — Clasificar cada atributo:**

| Atributo | Tipo | Razonamiento |
|---|---|---|
| `número_documento` | Simple, **PK** | Único, no se puede descomponer, identifica el estudiante |
| `nombre` | Simple (o compuesto) | Simple si no se necesita separar nombre/apellido; compuesto si sí |
| `fecha_nacimiento` | Simple | Un solo valor, no se descompone para operar |
| `carrera` | Simple | Un solo valor de texto |
| `semestre` | Simple | Número entero |
| `correo` | **Multivaluado** | Puede tener 1 a 3 correos → óvalo doble |
| `edad` | **Derivado** | Se calcula de `fecha_nacimiento` → no se almacena |

**Paso 4 — Diagrama resultante:**

```
 (- edad -)   (número_doc)   (nombre)   (fecha_nacimiento)
                ─────────
                    |            |              |
              ┌─────────────────────────────────────┐
              │             ESTUDIANTE              │
              └─────────────────────────────────────┘
                     |              |           |
                (carrera)      (semestre)   ((correo))
```

> La línea bajo `(número_doc)` indica que es la **clave primaria**.

---

## 8. Errores comunes al diseñar entidades y atributos

| Error | Descripción | Corrección |
|---|---|---|
| Guardar atributos derivados | Almacenar `edad` en lugar de `fecha_nacimiento` | Solo guardar `fecha_nacimiento` y calcular la edad al consultar |
| Atributos multivaluados en columnas separadas | `tel1, tel2, tel3` en la misma tabla | Crear tabla `telefonos` con FK |
| Entidad sin clave primaria | No definir qué atributo identifica unívocamente | Siempre definir un PK |
| Usar datos variables como PK | Usar `correo` o `nombre` como PK | Preferir clave artificial (`SERIAL`) |
| Una entidad para todo | Meter todos los datos del sistema en una tabla | Una tabla por concepto del mundo real |

---

## Vocabulario esencial de la Clase 4

| Término | Definición |
|---|---|
| **Modelo E-R** | Lenguaje gráfico para diseñar la BD a nivel conceptual, creado por Peter Chen (1976) |
| **Entidad** | Cosa del mundo real con existencia independiente sobre la que queremos guardar datos |
| **Tipo de entidad** | La definición abstracta de una entidad (ej: `ESTUDIANTE`) |
| **Ocurrencia** | Un caso concreto de una entidad (ej: *Ana García*) |
| **Entidad fuerte** | Existe por sí sola; tiene su propia clave |
| **Entidad débil** | Depende de otra entidad para existir |
| **Atributo** | Propiedad de una entidad que se quiere almacenar |
| **Atributo compuesto** | Se puede descomponer en sub-atributos |
| **Atributo multivaluado** | Puede tener múltiples valores para la misma ocurrencia |
| **Atributo derivado** | Se calcula a partir de otros datos; no se almacena |
| **Superclave** | Conjunto de atributos que identifica unívocamente (puede tener redundancias) |
| **Clave candidata** | Superclave mínima; sin atributos redundantes |
| **Clave primaria (PK)** | Clave candidata elegida por el diseñador; se subraya en Chen |
| **Clave foránea (FK)** | Atributo que referencia la PK de otra tabla |
| **Clave natural** | Identificador que existe en el mundo real (cédula, ISBN) |
| **Clave artificial** | Identificador generado por el sistema (`SERIAL`, UUID) |

---

## Preguntas de autoevaluación

1. ¿Cuál es la diferencia entre un **tipo de entidad** y una **ocurrencia**? Da un ejemplo de cada uno para la entidad `PRODUCTO`.
2. Identifica si cada uno de los siguientes es entidad, atributo o relación: `FACTURA`, `precio`, `nombre_cliente`, `EMPLEADO`, `trabaja_en`, `fecha_contrato`.
3. Clasifica cada atributo de la entidad `EMPLEADO` (id, nombre, dirección completa, teléfonos posibles, salario_mensual, salario_anual, extensión de oficina si tiene). Justifica cada clasificación.
4. ¿Por qué un atributo multivaluado **nunca** debe implementarse como columnas separadas (`tel1, tel2, tel3`) en SQL?
5. ¿Cuál es la diferencia entre **superclave** y **clave candidata**? Da un ejemplo.
6. ¿Por qué se prefiere una **clave artificial** (`SERIAL`) sobre usar el número de cédula como clave primaria?
7. Dado el enunciado: *"Una biblioteca quiere registrar sus libros. Cada libro tiene ISBN, título, año de publicación y puede pertenecer a varios géneros."* — Dibuja el diagrama E-R con la notación de Chen e identifica el tipo de cada atributo.

---

## Para recordar

```
E-R: diseño conceptual antes de escribir SQL
Entidad → RECTÁNGULO | Atributo → óvalo | PK → subrayado
5 tipos de atributos:
  simple      → ( )         → columna directa
  compuesto   → sub-óvalos  → columnas separadas
  multivaluado→ (( ))       → tabla separada ← ¡importante!
  derivado    → (- -)       → no se almacena, se calcula
  nulo        → cualquiera  → sin NOT NULL
Clave primaria: única, no nula, estable, mínima
Preferir clave artificial (SERIAL) sobre clave natural
```

---

*Siguiente clase: Relaciones y cardinalidades en el Modelo E-R — cómo conectar entidades entre sí.*

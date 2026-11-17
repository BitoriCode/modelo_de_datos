# Práctica: Normalización
**Dominio:** sistema de matrículas universitarias

**Objetivo:** llevar la tabla `INSCRIPCION` desde su forma original (no normalizada) hasta **3FN**,
paso a paso, siguiendo el proceso visto en clase.

---

## La tabla de partida

El sistema de información de una universidad almacena todo en una sola tabla plana:

```
INSCRIPCION
┌──────────────────┬───────────────────┬─────────┬──────────────────┬──────────────────┬──────────────┬─────────────────┬──────────────────┬───────────────────┬─────────┬──────────────────┬───────────────────┬────────────┬────────────────────────────────┐
│ cod_estudiante   │ cod_asignatura    │ periodo │ nombre_estudiante │ email_estudiante  │ cod_programa │ nombre_programa │ decano_programa   │ nombre_asignatura │ creditos│ cod_departamento │ nombre_departamento│ nota_final │ telefonos_emergencia           │
├──────────────────┼───────────────────┼─────────┼──────────────────┼──────────────────┼──────────────┼─────────────────┼──────────────────┼───────────────────┼─────────┼──────────────────┼───────────────────┼────────────┼────────────────────────────────┤
│ EST-001          │ MAT-101           │ 2024-1  │ Sofía Herrera    │ sofia@uni.edu    │ PROG-IS      │ Ing. Sistemas   │ Dr. Mora          │ Cálculo I         │ 4       │ DEP-MAT          │ Matemáticas        │ 3.8        │ "312-000-0001, 317-000-0002"   │
│ EST-001          │ BD-201            │ 2024-1  │ Sofía Herrera    │ sofia@uni.edu    │ PROG-IS      │ Ing. Sistemas   │ Dr. Mora          │ Bases de Datos    │ 3       │ DEP-SIS          │ Sistemas           │ 4.2        │ "312-000-0001, 317-000-0002"   │
│ EST-002          │ MAT-101           │ 2024-1  │ Carlos López     │ carlos@uni.edu   │ PROG-IS      │ Ing. Sistemas   │ Dr. Mora          │ Cálculo I         │ 4       │ DEP-MAT          │ Matemáticas        │ 2.9        │ "300-111-2233"                 │
│ EST-003          │ BD-201            │ 2024-1  │ Laura Ríos       │ laura@uni.edu    │ PROG-CC      │ Ciencias Comp.  │ Dra. Salazar      │ Bases de Datos    │ 3       │ DEP-SIS          │ Sistemas           │ 3.5        │ "316-444-5566, 304-777-8899"   │
└──────────────────┴───────────────────┴─────────┴──────────────────┴──────────────────┴──────────────┴─────────────────┴──────────────────┴───────────────────┴─────────┴──────────────────┴───────────────────┴────────────┴────────────────────────────────┘
```

**PK actual:** (`cod_estudiante`, `cod_asignatura`, `periodo`)

---

## Paso 1 — Verificar la Primera Forma Normal (1FN)

Una tabla está en 1FN si **cada celda contiene un único valor atómico** (sin listas ni grupos repetidos).

**Pregunta:** ¿alguna columna de `INSCRIPCION` viola la 1FN? Justifica tu respuesta.

```
Respuesta:



```

**Corrección:** escribe a continuación cómo quedaría la tabla separada que resuelve la violación de 1FN.
Usa la notación del curso: `TABLA(col1 [PK], col2, col3 [FK → OTRA])`.

```
Tabla nueva:



Tabla modificada:


```

---

## Paso 2 — Identificar las dependencias funcionales

Completa la tabla de dependencias funcionales (DF) que existen en `INSCRIPCION`.
Usa la notación `X → Y`.

| Atributo / conjunto que determina | Atributos que determina | ¿De qué parte de la PK depende? |
|---|---|---|
| `cod_estudiante` | | |
| `cod_asignatura` | | |
| `(cod_estudiante, cod_asignatura, periodo)` — PK completa | | |
| `cod_programa` | | |
| `cod_departamento` | | |

---

## Paso 3 — Verificar la Segunda Forma Normal (2FN)

Una tabla está en 2FN si está en 1FN **y ningún atributo no-clave depende de solo una parte de la PK compuesta**.

Para cada columna no-clave de `INSCRIPCION`, marca de qué depende:

| Columna | Solo de `cod_estudiante` | Solo de `cod_asignatura` | De la PK completa |
|---|---|---|---|
| `nombre_estudiante` | | | |
| `email_estudiante` | | | |
| `cod_programa` | | | |
| `nombre_programa` | | | |
| `decano_programa` | | | |
| `nombre_asignatura` | | | |
| `creditos` | | | |
| `cod_departamento` | | | |
| `nombre_departamento` | | | |
| `nota_final` | | | |

**¿La tabla está en 2FN?**

```
No / Sí — porque:



```

**Corrección 2FN:** escribe las tablas resultantes de eliminar las dependencias parciales.

```
Tabla 1:


Tabla 2:


Tabla 3:


```

---

## Paso 4 — Verificar la Tercera Forma Normal (3FN)

Una tabla está en 3FN si está en 2FN **y ningún atributo no-clave depende de otro atributo no-clave**
(no hay dependencias transitivas: `PK → A → B` donde `A` no es clave).

Revisa **cada tabla** que obtuviste en el Paso 3.

**Tabla ESTUDIANTE** (o como la hayas llamado):

| ¿Hay algún atributo no-clave que determine a otro? | Sí / No |
|---|---|
| Describe la dependencia transitiva (si existe): | |

**Tabla ASIGNATURA** (o como la hayas llamado):

| ¿Hay algún atributo no-clave que determine a otro? | Sí / No |
|---|---|
| Describe la dependencia transitiva (si existe): | |

**Corrección 3FN:** escribe las tablas nuevas que resultan de eliminar las dependencias transitivas.

```
Tabla nueva 1:


Tabla nueva 2:


Tablas que se modifican y cómo quedan:



```

---

## Paso 5 — Esquema final en 3FN

Escribe el esquema relacional completo (todas las tablas) usando la notación del curso.
Indica las PK con `[PK]` y las FK con `[FK → TABLA(columna)]`.

```
1.


2.


3.


4.


5.


6.

```

**¿Cuántas tablas produjo la normalización?** ______

---

## Paso 6 — Preguntas de análisis

Responde después de completar los pasos anteriores.

**a)** La tabla original tenía 14 columnas y todo en un solo lugar. El esquema en 3FN tiene varias tablas.
¿Qué se gana con tener más tablas? ¿Qué se complica?

```
Respuesta:



```

**b)** En la tabla original, si el decano del programa "Ing. Sistemas" cambia, ¿cuántas filas habría
que actualizar? ¿Y con el esquema en 3FN?

```
Con la tabla original:


Con el esquema 3FN:


```

**c)** `nota_final` quedó en la tabla `INSCRIPCION` (o como la hayas llamado).
¿Por qué no la moviste a `ESTUDIANTE` o a `ASIGNATURA`?

```
Respuesta:



```

**d)** Si quisieras implementar este esquema en PostgreSQL con `CREATE TABLE`,
¿en qué orden deberías crear las tablas? ¿Por qué ese orden importa?

```
Orden de creación:
1.
2.
3.
4.
5.
6.

Razón:


```

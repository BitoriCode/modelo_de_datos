# Clase 2 — DBMS, Tablas, Tipos de Datos, SQL y Arquitectura ANSI/SPARC
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**

---

## Repaso rápido — Clase 1

- Una **base de datos** es una colección organizada de datos relacionados
- El problema de los **archivos planos**: redundancia, inconsistencia, sin control de acceso, sin concurrencia
- **DBMS** = software que actúa de intermediario entre los usuarios y los datos

---

## 1. ¿Qué es un DBMS?

> Un **DBMS** (Database Management System / Sistema Gestor de Bases de Datos) es el **software** que actúa como intermediario entre los usuarios y los datos almacenados en disco.

**Analogía:** la base de datos es el archivo físico en el cajón. El DBMS es quien controla quién puede abrirlo, qué puede leer, y garantiza que nadie lo deje en desorden.

### 1.1 Componentes principales de un DBMS

| Componente | ¿Qué hace? |
|---|---|
| **Motor de consultas** | Recibe el SQL, lo analiza, lo optimiza y devuelve resultados |
| **Diccionario de datos** | Almacena la "descripción" de la BD: nombres de tablas, tipos, restricciones, permisos |
| **Gestor de transacciones** | Garantiza que las operaciones sean completas o no ocurran (todo o nada) |
| **Gestor de almacenamiento** | Controla cómo se escriben y leen los datos físicamente en disco |
| **Gestor de usuarios y seguridad** | Controla quién puede hacer qué sobre qué datos |

### 1.2 Ventajas del DBMS sobre archivos planos

| Problema con archivos | Solución del DBMS |
|---|---|
| Datos duplicados | Control de integridad y claves únicas |
| Cualquiera puede modificar | Sistema de usuarios y permisos |
| Dos personas no pueden editar a la vez | Control de concurrencia |
| Corte de luz a mitad de operación = datos corruptos | Transacciones ACID |
| Difícil cruzar datos entre archivos | Relaciones y JOINs entre tablas |

### 1.3 ¿Qué es ACID?

Las transacciones en un DBMS deben cumplir las propiedades ACID:

| Propiedad | Nombre | Qué garantiza |
|---|---|---|
| **A** | Atomicidad | Una transacción es "todo o nada" — si falla a mitad, se revierte completa |
| **C** | Consistencia | La BD pasa de un estado válido a otro estado válido |
| **I** | Aislamiento | Las transacciones simultáneas no se afectan entre sí |
| **D** | Durabilidad | Una vez confirmada una transacción, sus cambios persisten aunque haya un fallo |

> **Ejemplo:** transferencia bancaria — debitar cuenta A y acreditar cuenta B son dos operaciones. Si la luz se va después del débito pero antes del crédito, el DBMS revierte el débito. Nadie pierde dinero.

### 1.4 DBMS más usados en la industria

**Relacionales (SQL):**
- **PostgreSQL** ← el de este curso
- MySQL / MariaDB
- Oracle Database
- Microsoft SQL Server
- SQLite

**No relacionales (NoSQL):**
- MongoDB (documentos)
- Redis (clave-valor)
- Cassandra (columnar, Big Data)

---

## 2. Tablas: la unidad básica del modelo relacional

> Una **tabla** es la unidad básica de almacenamiento en una base de datos relacional. Organiza los datos en **filas** y **columnas**.

### 2.1 Terminología

| Término técnico | Sinónimos | Descripción |
|---|---|---|
| **Tabla** | Relación | El contenedor de un tipo de datos |
| **Columna** | Campo, atributo | Una característica de cada registro (nombre, edad, carrera…) |
| **Fila** | Registro, tupla | Un dato concreto (una persona, un pedido, un producto…) |

### 2.2 Ejemplo de tabla

| id | nombre | edad | carrera | activo |
|----|--------|------|---------|--------|
| 1 | Ana García | 22 | Ingeniería de Sistemas | TRUE |
| 2 | Luis Martínez | 25 | Ciencias de la Computación | TRUE |
| 3 | María Pérez | 21 | Ingeniería de Sistemas | FALSE |

### 2.3 Reglas fundamentales de las tablas

1. Cada columna tiene un **nombre único** y un **tipo de dato fijo** — no se mezclan texto y números en la misma columna
2. El **orden de las filas no importa** — no hay "primera fila" como en Excel
3. Cada fila suele tener una columna **clave primaria** (`id`) que la identifica de forma única
4. Cada tabla representa **un solo concepto** del mundo real (estudiantes, cursos, productos)

---

## 3. Tipos de datos en PostgreSQL

Declarar el tipo correcto en cada columna es fundamental porque el DBMS:
- **Rechaza datos incorrectos** (no puedes escribir "hola" en una columna de edad)
- **Optimiza el almacenamiento** en disco
- **Habilita operaciones correctas** (sumar números, comparar fechas)

### 3.1 Tipos más usados

| Tipo | ¿Qué guarda? | Columna típica | Ejemplo de valor |
|---|---|---|---|
| `INT` | Número entero | edad, cantidad, créditos | `22`, `3`, `2025` |
| `SERIAL` | Entero auto-incremental (lo asigna PostgreSQL) | id | `1`, `2`, `3`… |
| `BIGINT` | Entero grande | id de tablas muy grandes | `9000000000` |
| `VARCHAR(n)` | Texto de hasta *n* caracteres | nombre, carrera, email | `'Ana García'` |
| `TEXT` | Texto sin límite | descripción, observaciones | `'Texto muy largo...'` |
| `BOOLEAN` | Verdadero o falso | activo, pagado, aprobado | `TRUE` o `FALSE` |
| `DATE` | Fecha (sin hora) | fecha_nacimiento | `'2025-07-21'` |
| `TIMESTAMP` | Fecha y hora | fecha_registro | `'2025-07-21 10:30:00'` |
| `NUMERIC(p,s)` | Decimal exacto | precio, nota, salario | `19.99`, `4.5` |

> **`NUMERIC(8,2)`** = hasta 8 dígitos en total, con 2 decimales. Siempre usa `NUMERIC` para precios y notas — nunca `FLOAT`, que puede introducir errores de redondeo.

### 3.2 Ejemplo de definición de tabla con tipos

```sql
CREATE TABLE estudiantes (
    id              SERIAL        PRIMARY KEY,   -- PostgreSQL asigna el id solo
    nombre          VARCHAR(100)  NOT NULL,       -- texto, max 100 chars, obligatorio
    edad            INT,                          -- número entero
    carrera         VARCHAR(80),                  -- texto, max 80 chars
    activo          BOOLEAN       DEFAULT TRUE,   -- por defecto activo
    fecha_inicio    DATE,                         -- fecha
    promedio        NUMERIC(4,2)                  -- ej: 3.85
);
```

```sql
CREATE TABLE cursos (
    id           SERIAL        PRIMARY KEY,
    nombre       VARCHAR(100)  NOT NULL,
    creditos     INT           NOT NULL,
    fecha_inicio DATE,
    costo        NUMERIC(8,2)
);
```

---

## 4. SQL — El lenguaje de las bases de datos relacionales

> **SQL** (Structured Query Language) es el lenguaje estándar para comunicarse con un DBMS relacional.

SQL tiene **cuatro categorías**. Es fundamental conocerlas porque organizan todo lo que harás en el semestre:

| Categoría | Nombre completo | Para qué sirve | Comandos principales |
|---|---|---|---|
| **DDL** | Data Definition Language | Crear y modificar la **estructura** | `CREATE`, `ALTER`, `DROP` |
| **DML** | Data Manipulation Language | Manipular los **datos** | `SELECT`, `INSERT`, `UPDATE`, `DELETE` |
| **DCL** | Data Control Language | Controlar **permisos** de acceso | `GRANT`, `REVOKE` |
| **TCL** | Transaction Control Language | Gestionar **transacciones** | `COMMIT`, `ROLLBACK` |

### 4.1 Ejemplos de cada categoría

**DDL — crear una tabla y modificarla:**
```sql
-- Crear tabla (DDL)
CREATE TABLE productos (
    id      SERIAL PRIMARY KEY,
    nombre  VARCHAR(80) NOT NULL,
    precio  NUMERIC(8,2)
);

-- Agregar una columna (DDL)
ALTER TABLE productos ADD COLUMN stock INT DEFAULT 0;

-- Eliminar tabla (DDL) — ¡cuidado, borra todo!
DROP TABLE productos;
```

**DML — insertar y consultar datos:**
```sql
-- Insertar un registro (DML)
INSERT INTO estudiantes (nombre, edad, carrera) VALUES ('Carlos Ruiz', 23, 'Matemáticas');

-- Consultar todos los registros (DML)
SELECT * FROM estudiantes;

-- Consultar con filtro (DML)
SELECT nombre, carrera FROM estudiantes WHERE activo = TRUE;

-- Actualizar un registro (DML)
UPDATE estudiantes SET edad = 24 WHERE id = 4;

-- Eliminar un registro (DML)
DELETE FROM estudiantes WHERE id = 4;
```

**DCL — dar y quitar permisos:**
```sql
-- Dar permiso de solo lectura (DCL)
GRANT SELECT ON estudiantes TO consultor_notas;

-- Quitar el permiso (DCL)
REVOKE SELECT ON estudiantes FROM consultor_notas;
```

**TCL — confirmar o revertir transacciones:**
```sql
-- Iniciar una transacción
BEGIN;
  UPDATE cuentas SET saldo = saldo - 100 WHERE id = 1;
  UPDATE cuentas SET saldo = saldo + 100 WHERE id = 2;
COMMIT;   -- confirmar ambas operaciones

-- Si algo falla:
ROLLBACK; -- revertir todo
```

---

## 5. Arquitectura ANSI/SPARC — Los 3 niveles de abstracción

La arquitectura ANSI/SPARC (1975) define **tres niveles** que separan cómo los usuarios ven los datos de cómo estos se almacenan físicamente. Es uno de los conceptos más importantes del curso.

```
┌─────────────────────────────────────────────────┐
│            NIVEL EXTERNO (Vistas)               │
│  Vista del app web  │  Vista del contador       │
│  "Dame los activos" │  "Dame las facturas"      │
└──────────────────────┬──────────────────────────┘
                       │  ← Independencia LÓGICA
┌──────────────────────▼──────────────────────────┐
│            NIVEL CONCEPTUAL (Tablas)            │
│  estudiantes(id, nombre, edad, carrera, activo) │
│  cursos(id, nombre, creditos, fecha_inicio)     │
└──────────────────────┬──────────────────────────┘
                       │  ← Independencia FÍSICA
┌──────────────────────▼──────────────────────────┐
│            NIVEL INTERNO (Almacenamiento)       │
│  Archivos en disco, índices, páginas de datos   │
└─────────────────────────────────────────────────┘
```

### 5.1 Descripción de cada nivel

| Nivel | ¿Qué describe? | ¿Quién lo ve? | Ejemplo |
|---|---|---|---|
| **Externo** | Lo que cada usuario o aplicación ve | Usuarios finales, aplicaciones | Una consulta `SELECT` devuelve solo nombre y carrera |
| **Conceptual** | La estructura completa de la BD: tablas, columnas, tipos, relaciones | Diseñadores, desarrolladores | La tabla `estudiantes` con todas sus columnas |
| **Interno** | Cómo se almacenan físicamente los datos en disco | DBA (administrador) | Archivos .db, índices B-Tree, páginas de 8KB |

### 5.2 Independencia de datos

La separación en niveles permite que los cambios en un nivel **no afecten** a los otros. Esto se llama **independencia de datos** y es una de las grandes ventajas del modelo relacional.

#### Independencia Física

> **Definición:** Puedes cambiar cómo se almacenan físicamente los datos **sin modificar tablas ni consultas**.

**Ejemplo:** el DBA agrega un índice para acelerar búsquedas por carrera:
```sql
CREATE INDEX idx_carrera ON estudiantes (carrera);
```
La tabla `estudiantes` no cambia. Las consultas existentes no cambian. La búsqueda es más rápida. Eso es independencia física.

#### Independencia Lógica

> **Definición:** Puedes cambiar la estructura de las tablas **sin romper las consultas existentes**.

**Ejemplo:** se agrega la columna `email` a `estudiantes`:
```sql
ALTER TABLE estudiantes ADD COLUMN email VARCHAR(150);
```
Las consultas que usaban `nombre` y `carrera` siguen funcionando exactamente igual. Eso es independencia lógica.

> **Regla práctica:** la independencia física es más fácil de lograr que la independencia lógica. Agregar o eliminar columnas puede romper consultas si no se planifica bien.

---

## 6. Resumen visual del nivel conceptual en la práctica

La tabla que creas con `CREATE TABLE` **es** el nivel conceptual:

```sql
-- Esto es el nivel conceptual en acción:
CREATE TABLE estudiantes (
    id      SERIAL        PRIMARY KEY,
    nombre  VARCHAR(100)  NOT NULL,
    edad    INT,
    carrera VARCHAR(80),
    activo  BOOLEAN       DEFAULT TRUE
);
```

Cada `SELECT` que haces es el nivel externo — una vista de esos datos:

```sql
-- Vista para la secretaría: solo activos
SELECT nombre, carrera FROM estudiantes WHERE activo = TRUE;

-- Vista para el bienestar: todos con edad
SELECT nombre, edad FROM estudiantes;
```

El archivo `.db` en disco que PostgreSQL crea internamente es el nivel interno — no lo ves directamente.

---

## 7. Cheat Sheet SQL para la práctica

```sql
-- CREAR TABLA
CREATE TABLE tabla (
    columna1  TIPO  RESTRICCION,
    columna2  TIPO
);

-- RESTRICCIONES MÁS USADAS
--   PRIMARY KEY   → identificador único de la fila
--   NOT NULL      → el campo no puede quedar vacío
--   DEFAULT valor → valor automático si no se especifica
--   REFERENCES    → clave foránea (apunta a otra tabla)

-- INSERTAR
INSERT INTO tabla (col1, col2) VALUES ('valor1', 42);

-- CONSULTAR
SELECT *           FROM tabla;                      -- todo
SELECT col1, col2  FROM tabla;                      -- columnas específicas
SELECT *           FROM tabla WHERE col2 > 20;      -- con filtro
SELECT col1, COUNT(*) FROM tabla GROUP BY col1;     -- agrupar

-- MODIFICAR ESTRUCTURA
ALTER TABLE tabla ADD COLUMN nueva_col VARCHAR(50);
ALTER TABLE tabla DROP COLUMN columna_vieja;

-- AGREGAR ÍNDICE (mejora rendimiento)
CREATE INDEX nombre_idx ON tabla (columna);

-- ELIMINAR TABLA
DROP TABLE tabla;
```

---

## Vocabulario esencial de la Clase 2

| Término | Definición |
|---|---|
| **DBMS** | Software que gestiona la base de datos (PostgreSQL, MySQL…) |
| **Tabla** | Estructura de filas y columnas que almacena un tipo de datos |
| **Fila / Tupla** | Un registro concreto en la tabla |
| **Columna / Atributo** | Una propiedad de cada registro |
| **Tipo de dato** | Define qué clase de valor puede tener una columna |
| **ACID** | Propiedades que garantizan la fiabilidad de las transacciones |
| **DDL** | Comandos para definir la estructura (CREATE, ALTER, DROP) |
| **DML** | Comandos para manipular datos (SELECT, INSERT, UPDATE, DELETE) |
| **DCL** | Comandos para gestionar permisos (GRANT, REVOKE) |
| **TCL** | Comandos para gestionar transacciones (COMMIT, ROLLBACK) |
| **ANSI/SPARC** | Arquitectura de 3 niveles: externo, conceptual, interno |
| **Independencia física** | Cambiar el almacenamiento sin afectar tablas ni consultas |
| **Independencia lógica** | Cambiar la estructura de tablas sin romper consultas existentes |

---

## Preguntas de autoevaluación

1. Dibuja el diagrama de los 3 niveles ANSI/SPARC. ¿Qué contiene cada nivel?
2. Explica con un ejemplo concreto la diferencia entre **independencia física** e **independencia lógica**.
3. ¿Cuál es la diferencia entre `VARCHAR(50)` y `TEXT`? ¿Cuándo usarías cada uno?
4. ¿Por qué se usa `NUMERIC(8,2)` para precios en lugar de `FLOAT`?
5. Clasifica cada uno de estos comandos en DDL, DML, DCL o TCL: `DROP TABLE`, `SELECT`, `GRANT`, `ROLLBACK`, `INSERT`, `ALTER TABLE`, `REVOKE`, `COMMIT`.
6. Una empresa agrega una nueva columna `fecha_contrato` a su tabla de empleados. Las consultas existentes que usan `nombre` y `salario` ¿siguen funcionando? ¿Qué principio aplica?

---

## Para recordar

```
DBMS = intermediario entre usuarios y datos
Tabla = filas (registros) + columnas (atributos)
SERIAL = el id lo asigna PostgreSQL automáticamente
NUMERIC(p,s) para precios — nunca FLOAT
DDL: estructura | DML: datos | DCL: permisos | TCL: transacciones
ANSI/SPARC: externo → conceptual → interno
Independencia física: cambiar disco sin cambiar tablas
Independencia lógica: cambiar tablas sin romper consultas
```

---

*Siguiente clase: ¿Qué es un modelo de datos? — 3 componentes, niveles de abstracción y tipos de usuarios.*

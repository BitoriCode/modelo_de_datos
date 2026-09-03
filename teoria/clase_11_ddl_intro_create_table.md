# Clase 11 — DDL: Introducción y primer CREATE TABLE
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**
**Herramienta:** PostgreSQL + pgAdmin

---

## Cadena de diseño — dónde estamos

```
Mundo real
    ↓  análisis de requisitos
Diagrama E-R (modelo conceptual)         ← Clases 4, 7, 8, 9
    ↓  transformación
Esquema relacional (modelo lógico)       ← Clase 10
    ↓  implementación  ← Estamos aquí
SQL en PostgreSQL
```

El esquema relacional describe las tablas en texto:
`CAMPAMENTO(cod_campamento [PK], nombre, ciudad, ...)`

El SQL es el código que PostgreSQL ejecuta para crear esa estructura en disco.

---

## 1. ¿Qué es DDL?

**DDL** = *Data Definition Language* — el subconjunto de SQL que define la **estructura** de la base de datos.

| Comando | Qué hace | Cuándo |
|---------|----------|--------|
| `CREATE` | Crea una tabla, base de datos, índice, vista... | Clase 11 |
| `ALTER` | Modifica una tabla existente (agrega/elimina columnas) | Clase 14 |
| `DROP` | Elimina una tabla permanentemente | Clase 14 |

> DDL define el *contenedor*. DML (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) manipula los *datos* dentro.

---

## 2. Tipos de dato esenciales en PostgreSQL

| Tipo | Descripción | Ejemplo de uso |
|------|-------------|----------------|
| `VARCHAR(n)` | Texto de hasta *n* caracteres | `nombre VARCHAR(100)` |
| `TEXT` | Texto sin límite de longitud | `descripcion TEXT` |
| `INT` | Número entero | `duracion_minutos INT` |
| `NUMERIC(p,s)` | Decimal exacto (*p* dígitos, *s* decimales) | `precio NUMERIC(10,2)` |
| `BOOLEAN` | Verdadero (`true`) o falso (`false`) | `activo BOOLEAN` |
| `DATE` | Solo fecha — formato `YYYY-MM-DD` | `fecha_nacimiento DATE` |
| `TIMESTAMP` | Fecha y hora | `created_at TIMESTAMP` |
| `SERIAL` | Entero auto-incremental generado por la BD | `id SERIAL` |

**¿`VARCHAR` o `TEXT`?**
- Usa `VARCHAR(n)` cuando quieras limitar la longitud (nombre: 100 chars).
- Usa `TEXT` cuando el contenido puede ser largo e impredecible (descripción, notas).

**¿`SERIAL` o `VARCHAR` para IDs?**
- `SERIAL` → el ID lo genera la BD automáticamente (1, 2, 3…). No tienes que pensarlo.
- `VARCHAR` → el ID lo decides tú ('CAMP01', 'CC-123456'). Útil para códigos con significado.

---

## 3. CREATE TABLE — PK simple (inline)

Cuando la clave primaria es **una sola columna**, se declara inline junto a la columna:

```sql
CREATE TABLE campamento (
    cod_campamento  VARCHAR(10)   PRIMARY KEY,   -- PK inline
    nombre          VARCHAR(100)  NOT NULL,
    ciudad          VARCHAR(50)   NOT NULL,
    calle           VARCHAR(100),                -- sin NOT NULL = opcional
    numero          VARCHAR(10),
    telefono        VARCHAR(15),
    email           VARCHAR(150)
);
```

**Reglas de sintaxis:**
- La **última columna no lleva coma**.
- `PRIMARY KEY` inline solo es válido para **una columna**.
- Sin `NOT NULL` → la columna acepta `NULL` (valor desconocido / no aplicable).

---

## 4. NOT NULL

`NOT NULL` es una restricción que impide que una columna quede vacía:

```sql
nombre  VARCHAR(100)  NOT NULL   -- obligatorio: no se puede insertar sin este valor
email   VARCHAR(150)             -- opcional: puede ser NULL (el campamento puede no tener email)
```

**¿Cuándo usar NOT NULL?**
- Campos que siempre deben tener valor: nombres, fechas de nacimiento, claves foráneas con participación total.
- Campos opcionales: teléfonos secundarios, correos de contacto, descripciones.

---

## 5. PRIMARY KEY: lo que garantiza

`PRIMARY KEY` equivale a aplicar dos restricciones al mismo tiempo:

| Restricción | Significado |
|-------------|-------------|
| `UNIQUE` | No pueden existir dos filas con el mismo valor en esta columna |
| `NOT NULL` | La columna nunca puede ser NULL |

```sql
-- Esto falla — duplicado de PK:
INSERT INTO campamento VALUES ('CAMP01', 'Otro campamento', 'Cali', ...);
-- ERROR: duplicate key value violates unique constraint

-- Esto falla — PK nula:
INSERT INTO campamento (nombre, ciudad) VALUES ('Sin código', 'Bogotá');
-- ERROR: null value in column "cod_campamento" violates not-null constraint
```

---

## 6. CREATE TABLE — PK compuesta (a nivel de tabla)

Cuando la clave primaria incluye **dos o más columnas**, se declara al final de la tabla:

```sql
CREATE TABLE cabana (
    cod_campamento  VARCHAR(10)  NOT NULL,
    num_cabana      INT          NOT NULL,
    nombre_cabana   VARCHAR(50),
    capacidad       INT,
    PRIMARY KEY (cod_campamento, num_cabana)   -- PK compuesta: al final
);
```

**¿Por qué es compuesta?**
La cabaña número 1 puede existir en muchos campamentos. Solo la **combinación** `(cod_campamento, num_cabana)` es única.

```sql
-- Estas tres filas son válidas — ninguna duplica la PK:
INSERT INTO cabana VALUES ('CAMP01', 1, 'El Roble', 8);
INSERT INTO cabana VALUES ('CAMP01', 2, 'El Pino',  6);   -- mismo campamento, diferente número
INSERT INTO cabana VALUES ('CAMP02', 1, 'La Ceiba', 10);   -- mismo número, diferente campamento

-- Esto falla — duplicado de PK compuesta:
INSERT INTO cabana VALUES ('CAMP01', 1, 'Repetida', 4);
-- ERROR: duplicate key value violates unique constraint "cabana_pkey"
```

**Regla:** si la PK tiene más de una columna → siempre `PRIMARY KEY (col1, col2)` al final.

---

## 7. DROP TABLE IF EXISTS

Antes de crear una tabla que ya existe, hay que eliminarla:

```sql
DROP TABLE IF EXISTS cabana;       -- elimina si existe, sin error si no existe
DROP TABLE IF EXISTS campamento;   -- ídem
```

**Buena práctica:** usa `IF EXISTS` para evitar errores al re-ejecutar el script.

**Orden de borrado:** cuando haya FK, hay que borrar primero las tablas que dependen de otras.
Aunque hoy no tenemos FK, ya ponemos el orden correcto:

```sql
DROP TABLE IF EXISTS actividad;
DROP TABLE IF EXISTS participante;
DROP TABLE IF EXISTS monitor;
DROP TABLE IF EXISTS cabana;
DROP TABLE IF EXISTS campamento;
```

---

## 8. Esquema completo — campamento (5 tablas)

Las 5 entidades fuertes del campamento implementadas en SQL:

```sql
CREATE TABLE campamento (
    cod_campamento  VARCHAR(10)   PRIMARY KEY,
    nombre          VARCHAR(100)  NOT NULL,
    ciudad          VARCHAR(50)   NOT NULL,
    calle           VARCHAR(100),
    numero          VARCHAR(10),
    telefono        VARCHAR(15),
    email           VARCHAR(150)
);

CREATE TABLE cabana (
    cod_campamento  VARCHAR(10)  NOT NULL,
    num_cabana      INT          NOT NULL,
    nombre_cabana   VARCHAR(50),
    capacidad       INT,
    PRIMARY KEY (cod_campamento, num_cabana)
);

CREATE TABLE monitor (
    cod_monitor     VARCHAR(10)   PRIMARY KEY,
    primer_nombre   VARCHAR(50)   NOT NULL,
    apellidos       VARCHAR(100)  NOT NULL,
    telefono        VARCHAR(15),
    cod_campamento  VARCHAR(10)   NOT NULL    -- FK → campamento (se añade en clase 13)
);

CREATE TABLE participante (
    num_participante  VARCHAR(20)   PRIMARY KEY,
    primer_nombre     VARCHAR(50)   NOT NULL,
    apellidos         VARCHAR(100)  NOT NULL,
    fecha_nacimiento  DATE          NOT NULL,
    email_tutor       VARCHAR(150),
    nombre_tutor      VARCHAR(100)  NOT NULL
);

CREATE TABLE actividad (
    cod_actividad     VARCHAR(10)   PRIMARY KEY,
    nombre            VARCHAR(100)  NOT NULL,
    descripcion       TEXT,
    duracion_minutos  INT,
    nivel             VARCHAR(20),
    cod_monitor       VARCHAR(10)   NOT NULL  -- FK → monitor (se añade en clase 13)
);
```

> **¿Por qué no hay FK todavía?**
> `cod_campamento` en MONITOR y `cod_monitor` en ACTIVIDAD son columnas normales por ahora.
> Sin `REFERENCES`, PostgreSQL acepta cualquier valor — no verifica que exista en la otra tabla.
> En clase 13 añadimos `REFERENCES` y PostgreSQL empieza a validar esa integridad.

---

## 9. Verificar en pgAdmin

```sql
-- Ver todos los registros de una tabla:
SELECT * FROM campamento;

-- Ver la estructura de columnas de una tabla:
SELECT column_name, data_type, is_nullable
  FROM information_schema.columns
 WHERE table_name = 'campamento'
 ORDER BY ordinal_position;

-- Contar filas en todas las tablas:
SELECT 'campamento'    AS tabla, COUNT(*) AS filas FROM campamento
UNION ALL SELECT 'cabana',       COUNT(*) FROM cabana
UNION ALL SELECT 'monitor',      COUNT(*) FROM monitor
UNION ALL SELECT 'participante', COUNT(*) FROM participante
UNION ALL SELECT 'actividad',    COUNT(*) FROM actividad;
```

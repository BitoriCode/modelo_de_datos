# Taller integrador — Del diseño al SQL
**Curso:** Modelo de Datos | **Dominio:** CanchaYa — sistema de reservas de canchas deportivas
**Herramienta:** pgAdmin + PostgreSQL

> Este taller une tres pasos del proceso completo:
> 1. **Normalizar** una tabla plana hasta 3FN
> 2. **Implementar** el esquema en pgAdmin con todas las restricciones
> 3. **Modificar** la base de datos con `ALTER TABLE`

---

## La tabla de partida

La empresa CanchaYa almacena todas sus reservas en una sola hoja de cálculo:

| id_reserva | id_cancha | fecha_reserva | id_cliente | nombre_cliente | email_cliente | telefonos_cliente | tipo_cancha | precio_hora | id_club | nombre_club | ciudad_club | num_horas |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| RES-001 | CAN-1 | 2024-06-10 | CLI-10 | Andrés Gil | andres@mail.co | "310-5550001, 315-4440002" | Fútbol 5 | 50000 | CLUB-1 | El Estadio | Medellín | 2 |
| RES-001 | CAN-2 | 2024-06-10 | CLI-10 | Andrés Gil | andres@mail.co | "310-5550001, 315-4440002" | Básquetbol | 40000 | CLUB-1 | El Estadio | Medellín | 2 |
| RES-002 | CAN-3 | 2024-06-11 | CLI-20 | Lucía Ramos | lucia@mail.co | "300-8889999" | Tenis | 60000 | CLUB-2 | SportCenter | Bogotá | 1 |
| RES-003 | CAN-1 | 2024-06-12 | CLI-30 | Miguel Parra | miguel@mail.co | "312-3334444" | Fútbol 5 | 50000 | CLUB-1 | El Estadio | Medellín | 3 |

**PK de esta tabla:** (`id_reserva`, `id_cancha`) — una reserva puede incluir varias canchas.

---

## PARTE 1 — Normalizar

### 1.1 — Violaciones de 1FN

¿Qué columna contiene una lista de valores en una sola celda?

```
Columna con violación de 1FN: ____________________________
```

Escribe la tabla nueva que resuelve esta violación. Usa la notación del curso:

```
TABLA(columna1 [marca], columna2, ...)

Tabla nueva:


Tabla modificada:

```

### 1.2 — Dependencias funcionales

Completa las dependencias funcionales de la tabla principal (después de corregir la 1FN).
La PK es (`id_reserva`, `id_cancha`).

| ¿Qué columna(s) determinan...? | ...a estos atributos | ¿Dep. parcial o completa? |
|---|---|---|
| `id_reserva` sola | | |
| `id_cancha` sola | | |
| (`id_reserva`, `id_cancha`) juntas | | |

### 1.3 — Aplicar 2FN

La tabla NO está en 2FN porque hay dependencias parciales. Escribe las tres tablas resultantes:

```
Tabla 1 (todo lo que depende solo de id_reserva):


Tabla 2 (todo lo que depende solo de id_cancha):


Tabla 3 (lo que depende de la PK completa):

```

### 1.4 — Verificar y aplicar 3FN

Revisa las tablas que obtuviste en 1.3. ¿Hay algún atributo no-clave que determine a otro atributo no-clave?

**En la tabla de reservas:** ¿`id_cliente` determina a `nombre_cliente` y `email_cliente`?

```
Sí / No. Si sí → cadena transitiva: ________________________________
Tabla nueva que resuelve esto:

Tabla modificada:

```

**En la tabla de canchas:** ¿`id_club` determina a `nombre_club` y `ciudad_club`?

```
Sí / No. Si sí → cadena transitiva: ________________________________
Tabla nueva que resuelve esto:

Tabla modificada:

```

### 1.5 — Esquema final en 3FN

Escribe el esquema completo con todas las tablas. Indica `[PK]`, `[FK → TABLA(col)]` y tipos de dato.

```
1.


2.


3.


4.


5.


6.

```

**¿En qué orden debes crear las tablas en SQL?** (recuerda: primero los padres, luego los hijos)

```
Orden: 1. _____ 2. _____ 3. _____ 4. _____ 5. _____ 6. _____
```

---

## PARTE 2 — Implementar en pgAdmin

Abre pgAdmin → `curso_bd` → Query Tool. Ejecuta primero el bloque de limpieza, luego crea cada tabla.

### Limpieza (ejecuta esto primero cada vez que quieras empezar de cero)

```sql
DROP TABLE IF EXISTS reserva_cancha CASCADE;
DROP TABLE IF EXISTS reserva CASCADE;
DROP TABLE IF EXISTS telefono_cliente CASCADE;
DROP TABLE IF EXISTS cancha CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;
DROP TABLE IF EXISTS club CASCADE;
```

### Tabla 1: CLUB

```sql
CREATE TABLE club (
    id_club      VARCHAR(10)  PRIMARY KEY,
    nombre_club  VARCHAR(100) NOT NULL,
    ciudad_club  VARCHAR(50)  NOT NULL
);
```

Verifica con:
```sql
INSERT INTO club VALUES ('CLUB-1', 'El Estadio', 'Medellín');
INSERT INTO club VALUES ('CLUB-2', 'SportCenter', 'Bogotá');
SELECT * FROM club;
```

### Tabla 2: CLIENTE

```sql
CREATE TABLE cliente (
    id_cliente      VARCHAR(10)  PRIMARY KEY,
    nombre_cliente  VARCHAR(100) NOT NULL,
    email_cliente   VARCHAR(150) -- TODO: agrega la restricción UNIQUE aquí
);
```

Verifica con:
```sql
INSERT INTO cliente VALUES ('CLI-10', 'Andrés Gil',   'andres@mail.co');
INSERT INTO cliente VALUES ('CLI-20', 'Lucía Ramos',  'lucia@mail.co');
INSERT INTO cliente VALUES ('CLI-30', 'Miguel Parra', 'miguel@mail.co');
SELECT * FROM cliente;
```

> **Prueba de restricción:** intenta insertar un segundo cliente con `email_cliente = 'andres@mail.co'`. ¿Qué error produce?

### Tabla 3: TELEFONO_CLIENTE

> PK compuesta. La FK apunta a `cliente`.

```sql
CREATE TABLE telefono_cliente (
    id_cliente  VARCHAR(10) NOT NULL REFERENCES -- TODO: completa la referencia,
    telefono    VARCHAR(15) NOT NULL,
    PRIMARY KEY (id_cliente, telefono)
);
```

Verifica con:
```sql
INSERT INTO telefono_cliente VALUES ('CLI-10', '310-5550001');
INSERT INTO telefono_cliente VALUES ('CLI-10', '315-4440002');
INSERT INTO telefono_cliente VALUES ('CLI-20', '300-8889999');
INSERT INTO telefono_cliente VALUES ('CLI-30', '312-3334444');
SELECT * FROM telefono_cliente;
```

### Tabla 4: CANCHA

> El tipo de cancha solo puede ser uno de los valores conocidos. El precio debe ser positivo.

```sql
CREATE TABLE cancha (
    id_cancha    VARCHAR(10)    PRIMARY KEY,
    tipo_cancha  VARCHAR(30)    NOT NULL
                                CHECK (tipo_cancha IN (
                                    'Fútbol 5', 'Fútbol 11',
                                    'Básquetbol', 'Tenis',
                                    'Voleibol', 'Pádel'
                                )),
    precio_hora  NUMERIC(10,2)  NOT NULL CHECK (precio_hora > 0),
    id_club      VARCHAR(10)    NOT NULL REFERENCES -- TODO: completa
);
```

Verifica con:
```sql
INSERT INTO cancha VALUES ('CAN-1', 'Fútbol 5',  50000, 'CLUB-1');
INSERT INTO cancha VALUES ('CAN-2', 'Básquetbol', 40000, 'CLUB-1');
INSERT INTO cancha VALUES ('CAN-3', 'Tenis',      60000, 'CLUB-2');
SELECT * FROM cancha;
```

> **Prueba de restricción:** intenta insertar una cancha con `tipo_cancha = 'Hockey'`. ¿Qué error produce?

### Tabla 5: RESERVA

```sql
CREATE TABLE reserva (
    id_reserva    VARCHAR(10) PRIMARY KEY,
    fecha_reserva DATE        NOT NULL,
    id_cliente    VARCHAR(10) NOT NULL REFERENCES -- TODO: completa
);
```

Verifica con:
```sql
INSERT INTO reserva VALUES ('RES-001', '2024-06-10', 'CLI-10');
INSERT INTO reserva VALUES ('RES-002', '2024-06-11', 'CLI-20');
INSERT INTO reserva VALUES ('RES-003', '2024-06-12', 'CLI-30');
SELECT * FROM reserva;
```

### Tabla 6: RESERVA_CANCHA

> PK compuesta. Dos FK. El número de horas debe estar entre 1 y 4.

```sql
CREATE TABLE reserva_cancha (
    id_reserva  VARCHAR(10) NOT NULL REFERENCES -- TODO: completa,
    id_cancha   VARCHAR(10) NOT NULL REFERENCES -- TODO: completa,
    num_horas   INT         NOT NULL CHECK (-- TODO: escribe la condición),
    PRIMARY KEY (id_reserva, id_cancha)
);
```

Verifica con:
```sql
INSERT INTO reserva_cancha VALUES ('RES-001', 'CAN-1', 2);
INSERT INTO reserva_cancha VALUES ('RES-001', 'CAN-2', 2);
INSERT INTO reserva_cancha VALUES ('RES-002', 'CAN-3', 1);
INSERT INTO reserva_cancha VALUES ('RES-003', 'CAN-1', 3);
SELECT * FROM reserva_cancha;
```

> **Prueba de restricción:** intenta insertar una fila con `num_horas = 5`. ¿Qué error produce?

### Verificación integral

Una vez creadas las 6 tablas y cargados los datos, ejecuta:

```sql
SELECT 'club'              AS tabla, COUNT(*) AS filas FROM club
UNION ALL SELECT 'cliente',           COUNT(*) FROM cliente
UNION ALL SELECT 'telefono_cliente',  COUNT(*) FROM telefono_cliente
UNION ALL SELECT 'cancha',            COUNT(*) FROM cancha
UNION ALL SELECT 'reserva',           COUNT(*) FROM reserva
UNION ALL SELECT 'reserva_cancha',    COUNT(*) FROM reserva_cancha;
```

Resultado esperado: 6 filas con `filas` = 2, 3, 4, 3, 3, 4 respectivamente.

> **Prueba de integridad referencial:** intenta insertar en `reserva_cancha` una fila con `id_cancha = 'CAN-99'` (que no existe en `cancha`). ¿Qué error produce? ¿Qué restricción viola?

---

## PARTE 3 — Modificar con ALTER TABLE

La empresa quiere agregar nuevas funcionalidades. Aplica cada cambio con `ALTER TABLE`.

### 3.1 — Agregar estado a la reserva

El área de operaciones necesita rastrear si una reserva está pendiente, confirmada o cancelada.

```sql
ALTER TABLE reserva
    ADD COLUMN estado VARCHAR(20) NOT NULL DEFAULT 'pendiente'
                      CONSTRAINT ck_estado_reserva
                      CHECK (estado IN ('pendiente', 'confirmada', 'cancelada'));
```

Verifica:
```sql
SELECT * FROM reserva;
-- ¿Qué valor tiene la columna estado en las filas existentes?
```

### 3.2 — Agregar capacidad a la cancha

El sistema necesita saber cuántas personas puede albergar cada cancha simultáneamente.

```sql
-- TODO: escribe el ALTER TABLE para agregar la columna capacidad INT NOT NULL DEFAULT 2
ALTER TABLE cancha
    -- completa aquí
```

### 3.3 — Marcar clientes activos / inactivos

El equipo de marketing pide poder desactivar clientes sin borrarlos.

```sql
-- TODO: escribe el ALTER TABLE para agregar columna activo BOOLEAN DEFAULT true
ALTER TABLE cliente
    -- completa aquí
```

### 3.4 — Agregar descripción a la cancha

Operaciones quiere incluir una descripción larga y libre para cada cancha (puede quedar vacía).

```sql
-- TODO: ¿qué tipo de dato usarías para un texto sin límite de longitud?
ALTER TABLE cancha
    ADD COLUMN descripcion -- completa el tipo
```

### 3.5 — Renombrar una columna

La empresa decide estandarizar: `ciudad_club` → `municipio_club`.

```sql
ALTER TABLE club
    RENAME COLUMN ciudad_club TO municipio_club;
```

Verifica:
```sql
SELECT * FROM club;
```

### 3.6 — Eliminar una tabla (DROP TABLE)

Durante pruebas se creó una tabla `club_temporal` por error. Elimínala de forma segura:

```sql
CREATE TABLE club_temporal (id INT);   -- simular el error
DROP TABLE IF EXISTS club_temporal;    -- eliminarla
```

> `IF EXISTS` evita el error si la tabla ya no existe. Úsalo siempre en scripts de limpieza.

---

## Preguntas de reflexión

**a)** ¿Por qué en la Parte 2 se crea primero `club` y `cliente` antes que `cancha` y `reserva`?

```
Respuesta:
```

**b)** En el paso 3.1 se usó `DEFAULT 'pendiente'`. ¿Qué pasaría si no se pusiera el `DEFAULT` y se intentara hacer un INSERT en `reserva` sin especificar el `estado`?

```
Respuesta:
```

**c)** ¿Qué diferencia hay entre borrar una tabla con `DROP TABLE` y borrar todos sus datos con `DELETE FROM`?

```
Respuesta:
```

**d)** Si quisieras eliminar la tabla `cancha` pero tiene filas referenciadas en `reserva_cancha`, ¿qué error produciría? ¿Cómo podrías solucionarlo sin perder datos?

```
Respuesta:
```

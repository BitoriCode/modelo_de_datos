# Clase 11 — Práctica:CAMPAMENTO DDL.
**Dominio:** sistema de campamento de verano (continuación clase 10)

**Objetivo:** implementar en SQL el esquema relacional que construiste la clase pasada. Hoy: las 5 tablas con `PRIMARY KEY`, `NOT NULL` y llaves foráneas (`REFERENCES`).

---

## Paso 0: Limpiar por si las tablas ya existen

> El orden importa: las tablas con FK deben eliminarse antes que las referenciadas.

```sql
DROP TABLE IF EXISTS actividad;
DROP TABLE IF EXISTS participante;
DROP TABLE IF EXISTS monitor;
DROP TABLE IF EXISTS cabana;
DROP TABLE IF EXISTS campamento;
```

---

## Parte 1 — Ejercicios guiados (lee, predice, ejecuta)

### Ejercicio 1-A: CAMPAMENTO (PK simple, inline)

**Antes de ejecutar, responde:**
- ¿Cuál columna es la clave primaria?
- ¿Cuáles columnas son obligatorias?
- ¿Qué tipo de dato tiene cada columna?

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

INSERT INTO campamento VALUES
    ('CAMP01', 'Campamento Sol',  'Medellín', 'Calle 10', '15A', '3001234567', 'sol@camp.co'),
    ('CAMP02', 'Campamento Luna', 'Bogotá',   'Carrera 5', '80', '3019876543', NULL);

SELECT * FROM campamento;
```

**Predice antes de ejecutar — ¿error o éxito?**

a) Insertar `cod_campamento = 'CAMP01'` de nuevo (duplicado de PK)  
b) Insertar un campamento sin nombre

Descomenta para verificar:

```sql
-- INSERT INTO campamento VALUES ('CAMP01', 'Duplicado', 'Cali', NULL, NULL, NULL, NULL);
-- INSERT INTO campamento (cod_campamento, ciudad) VALUES ('CAMP03', 'Cali');
```

---

### Ejercicio 1-B: CABANA (PK compuesta + FK)

> Observa:
> - La PK se declara **al final** cuando tiene más de una columna.
> - `REFERENCES` declara una llave foránea: PostgreSQL rechazará cualquier `cod_campamento` que no exista en `campamento`.

```sql
CREATE TABLE cabana (
    cod_campamento  VARCHAR(10)  NOT NULL  REFERENCES campamento(cod_campamento),
    num_cabana      INT          NOT NULL,
    nombre_cabana   VARCHAR(50),
    capacidad       INT,
    PRIMARY KEY (cod_campamento, num_cabana)
);

INSERT INTO cabana VALUES
    ('CAMP01', 1, 'El Roble', 8),
    ('CAMP01', 2, 'El Pino',  6),
    ('CAMP02', 1, 'La Ceiba', 10);

SELECT * FROM cabana;
```

**Analiza:**
- ¿Por qué `num_cabana = 1` aparece dos veces sin error?
- ¿Qué par de valores sería un duplicado de PK?
- ¿Qué error produce insertar un `cod_campamento` que no existe en `campamento`?

```sql
-- INSERT INTO cabana VALUES ('CAMP99', 1, 'Fantasma', 5);
```

---

## Parte 2 — Tablas restantes

### MONITOR

| Columna | Tipo | Restricción |
|---|---|---|
| `cod_monitor` | texto hasta 10 chars | clave primaria |
| `primer_nombre` | texto hasta 50 chars | obligatorio |
| `apellidos` | texto hasta 100 chars | obligatorio |
| `telefono` | texto hasta 15 chars | opcional |
| `cod_campamento` | texto hasta 10 chars | obligatorio · FK → `REFERENCES campamento(cod_campamento)` |

```sql
CREATE TABLE monitor (
    cod_monitor     VARCHAR(10)   PRIMARY KEY,
    primer_nombre   VARCHAR(50)   NOT NULL,
    apellidos       VARCHAR(100)  NOT NULL,
    telefono        VARCHAR(15),
    cod_campamento  VARCHAR(10)   NOT NULL  REFERENCES campamento(cod_campamento)
);
```

Verifica insertando:

```sql
INSERT INTO monitor VALUES ('MON001', 'Carlos', 'Gómez Pérez',    '3101112233', 'CAMP01');
INSERT INTO monitor VALUES ('MON002', 'Laura',  'Martínez Silva', '3204445566', 'CAMP01');
SELECT * FROM monitor;
```

---

### PARTICIPANTE

| Columna | Tipo | Restricción |
|---|---|---|
| `num_participante` | texto hasta 20 chars | clave primaria |
| `primer_nombre` | texto hasta 50 chars | obligatorio |
| `apellidos` | texto hasta 100 chars | obligatorio |
| `fecha_nacimiento` | fecha | obligatorio |
| `email_tutor` | texto hasta 150 chars | opcional |
| `nombre_tutor` | texto hasta 100 chars | obligatorio |

```sql
CREATE TABLE participante (
    num_participante  VARCHAR(20)   PRIMARY KEY,
    primer_nombre     VARCHAR(50)   NOT NULL,
    apellidos         VARCHAR(100)  NOT NULL,
    fecha_nacimiento  DATE          NOT NULL,
    email_tutor       VARCHAR(150),
    nombre_tutor      VARCHAR(100)  NOT NULL
);
```

Verifica insertando:

```sql
INSERT INTO participante VALUES ('CC-123456', 'Valentina', 'Ríos López',    '2015-03-14', 'padre@mail.co', 'Juan Ríos');
INSERT INTO participante VALUES ('CC-654321', 'Mateo',     'Vargas Torres', '2016-07-22', NULL,            'Ana Torres');
SELECT * FROM participante;
```

---

### ACTIVIDAD

| Columna | Tipo | Restricción |
|---|---|---|
| `cod_actividad` | texto hasta 10 chars | clave primaria |
| `nombre` | texto hasta 100 chars | obligatorio |
| `descripcion` | texto sin límite | opcional |
| `duracion_minutos` | número entero | opcional |
| `nivel` | texto hasta 20 chars | opcional |
| `cod_monitor` | texto hasta 10 chars | obligatorio · FK → `REFERENCES monitor(cod_monitor)` |

```sql
CREATE TABLE actividad (
    cod_actividad     VARCHAR(10)   PRIMARY KEY,
    nombre            VARCHAR(100)  NOT NULL,
    descripcion       TEXT,
    duracion_minutos  INT,
    nivel             VARCHAR(20),
    cod_monitor       VARCHAR(10)   NOT NULL  REFERENCES monitor(cod_monitor)
);
```

Verifica insertando:

```sql
INSERT INTO actividad VALUES ('ACT01', 'Natación',     'Natación en piscina olímpica',    90,  'basico',     'MON001');
INSERT INTO actividad VALUES ('ACT02', 'Senderismo',   'Caminata por senderos naturales', 120, 'intermedio', 'MON002');
INSERT INTO actividad VALUES ('ACT03', 'Manualidades', NULL,                              60,  'basico',     'MON001');
SELECT * FROM actividad;
```

---

## Verificación final

```sql
SELECT 'campamento'    AS tabla, COUNT(*) AS filas FROM campamento
UNION ALL SELECT 'cabana',       COUNT(*) FROM cabana
UNION ALL SELECT 'monitor',      COUNT(*) FROM monitor
UNION ALL SELECT 'participante', COUNT(*) FROM participante
UNION ALL SELECT 'actividad',    COUNT(*) FROM actividad;
```

---

### Reto 4 — Opcional (desafío)

Intenta violar las restricciones de las tablas que creaste:

a) Insertar un participante sin `nombre_tutor`  
b) Insertar una actividad con `cod_actividad` ya existente  
c) Insertar un monitor sin `cod_campamento`  
d) Insertar un monitor con `cod_campamento = 'CAMP99'` (que no existe)

¿Qué restricción viola cada caso? ¿PK, NOT NULL o FK?

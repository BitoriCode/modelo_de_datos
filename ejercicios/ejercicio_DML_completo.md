# Taller DML completo
**DML completo: SELECT · INSERT · UPDATE · DELETE · Subconsultas | Base de datos: AeroPass**

---

## Esquema de referencia

```
AEROLINEA (id_aerolinea, nombre_aerolinea)
PASAJERO  (id_pasajero, nombre_pasajero, email_pasajero)
VUELO     (id_vuelo, origen_vuelo, destino_vuelo, id_aerolinea)
RESERVA   (id_pasajero, id_vuelo, fecha_reserva, num_asiento, clase, precio_cop)
           PK: (id_pasajero, id_vuelo)
```

> Copia y ejecuta el bloque de preparación en pgAdmin antes de comenzar.

```sql
DROP TABLE IF EXISTS reserva   CASCADE;
DROP TABLE IF EXISTS vuelo     CASCADE;
DROP TABLE IF EXISTS pasajero  CASCADE;
DROP TABLE IF EXISTS aerolinea CASCADE;

CREATE TABLE aerolinea (
    id_aerolinea     VARCHAR(10)  PRIMARY KEY,
    nombre_aerolinea VARCHAR(50)  NOT NULL
);
CREATE TABLE pasajero (
    id_pasajero     VARCHAR(10)  PRIMARY KEY,
    nombre_pasajero VARCHAR(100) NOT NULL,
    email_pasajero  VARCHAR(150)
);
CREATE TABLE vuelo (
    id_vuelo      VARCHAR(10) PRIMARY KEY,
    origen_vuelo  VARCHAR(50) NOT NULL,
    destino_vuelo VARCHAR(50) NOT NULL,
    id_aerolinea  VARCHAR(10) NOT NULL REFERENCES aerolinea(id_aerolinea)
);
CREATE TABLE reserva (
    id_pasajero   VARCHAR(10)  NOT NULL REFERENCES pasajero(id_pasajero),
    id_vuelo      VARCHAR(10)  NOT NULL REFERENCES vuelo(id_vuelo),
    fecha_reserva DATE         NOT NULL,
    num_asiento   VARCHAR(5)   NOT NULL,
    clase         VARCHAR(20)  NOT NULL,
    precio_cop    INT          NOT NULL CHECK (precio_cop > 0),
    PRIMARY KEY (id_pasajero, id_vuelo)
);

INSERT INTO aerolinea VALUES
    ('AER-1', 'Avianca'), ('AER-2', 'LATAM'), ('AER-3', 'Wingo');

INSERT INTO pasajero VALUES
    ('PAS-001', 'Carlos Ruiz',    'carlos@mail.co'),
    ('PAS-002', 'Laura Mesa',     'laura@mail.co'),
    ('PAS-003', 'Jorge Vega',     'jorge@mail.co'),
    ('PAS-004', 'Ana Torres',      NULL),
    ('PAS-005', 'Sofía Herrera',  'sofia@mail.co'),
    ('PAS-006', 'Miguel Castro',   NULL),
    ('PAS-007', 'Patricia Leal',  'patricia@mail.co'),
    ('PAS-008', 'Andrés Morales', 'andres@mail.co');

INSERT INTO vuelo VALUES
    ('VUE-101', 'Medellín',     'Bogotá',       'AER-1'),
    ('VUE-205', 'Bogotá',       'Cali',         'AER-2'),
    ('VUE-312', 'Cali',         'Barranquilla', 'AER-2'),
    ('VUE-408', 'Bogotá',       'Cartagena',    'AER-3'),
    ('VUE-510', 'Bogotá',       'Medellín',     'AER-1'),
    ('VUE-613', 'Pereira',      'Bogotá',       'AER-3'),
    ('VUE-720', 'Medellín',     'Cartagena',    'AER-1'),
    ('VUE-815', 'Barranquilla', 'Bogotá',       'AER-2');

INSERT INTO reserva VALUES
    ('PAS-001', 'VUE-101', '2024-08-10', '12A',  'Económica',   280000),
    ('PAS-001', 'VUE-205', '2024-08-16', '5C',   'Ejecutiva',   720000),
    ('PAS-001', 'VUE-408', '2024-09-02', '8D',   'Primera',    1500000),
    ('PAS-002', 'VUE-101', '2024-08-10', '12B',  'Económica',   220000),
    ('PAS-002', 'VUE-312', '2024-08-20', '7A',   'Económica',   310000),
    ('PAS-002', 'VUE-720', '2024-09-05', '2A',   'Ejecutiva',   840000),
    ('PAS-003', 'VUE-312', '2024-08-17', '3C',   'Económica',   195000),
    ('PAS-003', 'VUE-510', '2024-08-25', '9B',   'Económica',   340000),
    ('PAS-003', 'VUE-408', '2024-09-06', '10C',  'Económica',   260000),
    ('PAS-004', 'VUE-408', '2024-08-18', '3B',   'Ejecutiva',   650000),
    ('PAS-004', 'VUE-613', '2024-08-28', '1A',   'Primera',    1350000),
    ('PAS-005', 'VUE-101', '2024-08-22', '15A',  'Económica',   215000),
    ('PAS-005', 'VUE-205', '2024-09-01', '6C',   'Ejecutiva',   780000),
    ('PAS-006', 'VUE-815', '2024-08-30', '4D',   'Económica',   290000),
    ('PAS-006', 'VUE-510', '2024-09-03', '11A',  'Económica',   305000),
    ('PAS-007', 'VUE-720', '2024-08-12', '7C',   'Ejecutiva',   810000),
    ('PAS-007', 'VUE-613', '2024-09-01', '2B',   'Económica',   175000),
    ('PAS-007', 'VUE-815', '2024-09-04', '8A',   'Primera',    1650000),
    ('PAS-008', 'VUE-101', '2024-08-15', '14B',  'Económica',   250000),
    ('PAS-008', 'VUE-205', '2024-09-05', '3A',   'Ejecutiva',   695000);
```

---

## Bloque A — SELECT básico

**1.** Lista todos los pasajeros. Renombra las columnas como `codigo`, `nombre_completo` y `correo`.

**2.** Lista las rutas disponibles mostrando cada vuelo en el formato `"Medellín → Bogotá"` en una sola columna llamada `ruta`.

**3.** ¿Cuántos destinos distintos existen en la tabla `vuelo`?

---

## Bloque B — WHERE: filtros

**4.** Lista todas las reservas en clase `'Primera'`. Muestra: `id_pasajero`, `id_vuelo`, `fecha_reserva` y `precio_cop`.

**5.** ¿Qué pasajeros no tienen email registrado? Muestra su código y nombre.

**6.** Lista los vuelos cuyo destino sea `'Bogotá'` o `'Medellín'`.

**7.** Lista las reservas realizadas entre el 15 y el 31 de agosto de 2024 (incluyente).

**8.** Lista los pasajeros cuyo nombre empiece con `'A'`, sin importar mayúsculas.

**9.** Lista las reservas que **no** sean de clase `'Económica'`, ordenadas de mayor a menor precio.

**10.** Lista las reservas de la aerolínea `'AER-1'` en clase `'Económica'`.

**11.** Lista las reservas de septiembre de 2024 en clase `'Ejecutiva'` o `'Primera'`, ordenadas por fecha.

---

## Bloque C — ORDER BY y LIMIT

**12.** ¿Cuáles son las 3 reservas más caras? Muestra `id_pasajero`, `id_vuelo`, `clase` y `precio_cop`.

**13.** Lista todos los vuelos ordenados por `origen_vuelo` (A→Z) y, en empate, por `destino_vuelo` (A→Z).

---

## Bloque D — Funciones de agregación

**14.** En una sola consulta: ¿cuántos pasajeros hay en total y cuántos tienen email registrado?

**15.** En una sola consulta: precio total, precio promedio (sin decimales), máximo y mínimo de todas las reservas.

**16.** ¿Cuál fue la fecha de reserva más reciente y la más antigua?

---

## Bloque E — GROUP BY y HAVING

**17.** ¿Cuántas reservas hay en cada clase? Ordena de mayor a menor.

**18.** Por clase: total recaudado y precio promedio. Ordena por total recaudado de mayor a menor.

**19.** ¿Cuántas reservas ha hecho cada pasajero? Ordena de mayor a menor.

**20.** Lista solo los pasajeros con **más de 2 reservas**.

**21.** ¿Cuántos vuelos tiene cada aerolínea? Muestra solo las que tienen **más de 2 vuelos**.

**22.** ★ ¿Qué clases tienen precio promedio superior a $500.000 en las reservas de agosto de 2024?

---

## Bloque F — INSERT

**23.** Registra los siguientes tres pasajeros en un solo `INSERT`:

| id | nombre | email |
|---|---|---|
| PAS-012 | Diana Ospina | diana@mail.co |
| PAS-013 | Felipe Mora | NULL |
| PAS-014 | Isabel Reyes | isabel@mail.co |

**24.** Agrega un nuevo vuelo: `VUE-920`, de `Bogotá` a `Manizales`, operado por `AER-1`.

**25.** Registra una reserva para `PAS-012` en `VUE-920`, fecha `2024-10-15`, asiento `4B`, clase `Ejecutiva`, precio `680000`.

**26.** Intenta insertar esa misma reserva de `PAS-012` / `VUE-920` otra vez. ¿Qué error aparece y por qué?

---

## Bloque G — UPDATE

**27.** La aerolínea Wingo (`AER-3`) cambió su nombre a `"Wingo Airlines"`. Actualízalo.

**28.** El pasajero `PAS-013` proporcionó su email: `felipe@mail.co`. Actualízalo.

**29.** Todas las reservas en clase `'Económica'` de septiembre de 2024 subieron $30.000. Aplica el aumento.

**30.** El vuelo `VUE-613` fue reasignado a la aerolínea `AER-2`. Actualiza su `id_aerolinea`.

---

## Bloque H — DELETE

**31.** Elimina los pasajeros sin email que **además** no tienen ninguna reserva registrada.

**32.** Elimina las reservas en clase `'Económica'` con precio inferior al mínimo de clase `'Ejecutiva'`.

---

## Bloque I — Subconsultas

**33.** Lista las reservas con precio superior al promedio general de todas las reservas.

**34.** Lista los vuelos que tienen **más de 2 reservas** registradas.

**35.** Lista los pasajeros que hicieron reservas en **más de una clase distinta**.

**36.** ★ Aplica un aumento del 5% a las reservas de los pasajeros sin email registrado.

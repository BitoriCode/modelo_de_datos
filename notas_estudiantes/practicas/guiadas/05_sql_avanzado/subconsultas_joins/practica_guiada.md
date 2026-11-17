# Práctica guiada — Clase 18
**Subconsultas avanzadas + JOINs | Base de datos: AeroPass**

---

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
    id_pasajero   VARCHAR(10) NOT NULL REFERENCES pasajero(id_pasajero),
    id_vuelo      VARCHAR(10) NOT NULL REFERENCES vuelo(id_vuelo),
    fecha_reserva DATE        NOT NULL,
    num_asiento   VARCHAR(5)  NOT NULL,
    clase         VARCHAR(20) NOT NULL,
    precio_cop    INT         NOT NULL CHECK (precio_cop > 0),
    PRIMARY KEY (id_pasajero, id_vuelo)
);

INSERT INTO aerolinea VALUES
    ('AER-1','Avianca'), ('AER-2','LATAM'), ('AER-3','Wingo');

INSERT INTO pasajero VALUES
    ('PAS-001','Carlos Ruiz',   'carlos@mail.co'),
    ('PAS-002','Laura Mesa',    'laura@mail.co'),
    ('PAS-003','Jorge Vega',    'jorge@mail.co'),
    ('PAS-004','Ana Torres',     NULL),
    ('PAS-005','Sofía Herrera', 'sofia@mail.co'),
    ('PAS-006','Miguel Castro',  NULL),
    ('PAS-007','Patricia Leal', 'patricia@mail.co'),
    ('PAS-008','Andrés Morales','andres@mail.co');

INSERT INTO vuelo VALUES
    ('VUE-101','Medellín',    'Bogotá',       'AER-1'),
    ('VUE-205','Bogotá',      'Cali',         'AER-2'),
    ('VUE-312','Cali',        'Barranquilla', 'AER-2'),
    ('VUE-408','Bogotá',      'Cartagena',    'AER-3'),
    ('VUE-510','Bogotá',      'Medellín',     'AER-1'),
    ('VUE-613','Pereira',     'Bogotá',       'AER-3'),
    ('VUE-720','Medellín',    'Cartagena',    'AER-1'),
    ('VUE-815','Barranquilla','Bogotá',       'AER-2');

INSERT INTO reserva VALUES
    ('PAS-001','VUE-101','2024-08-10','12A','Económica',  280000),
    ('PAS-001','VUE-205','2024-08-16','5C', 'Ejecutiva',  720000),
    ('PAS-001','VUE-408','2024-09-02','8D', 'Primera',   1500000),
    ('PAS-002','VUE-101','2024-08-10','12B','Económica',  220000),
    ('PAS-002','VUE-312','2024-08-20','7A', 'Económica',  310000),
    ('PAS-002','VUE-720','2024-09-05','2A', 'Ejecutiva',  840000),
    ('PAS-003','VUE-312','2024-08-17','3C', 'Económica',  195000),
    ('PAS-003','VUE-510','2024-08-25','9B', 'Económica',  340000),
    ('PAS-003','VUE-408','2024-09-06','10C','Económica',  260000),
    ('PAS-004','VUE-408','2024-08-18','3B', 'Ejecutiva',  650000),
    ('PAS-004','VUE-613','2024-08-28','1A', 'Primera',   1350000),
    ('PAS-005','VUE-101','2024-08-22','15A','Económica',  215000),
    ('PAS-005','VUE-205','2024-09-01','6C', 'Ejecutiva',  780000),
    ('PAS-006','VUE-815','2024-08-30','4D', 'Económica',  290000),
    ('PAS-006','VUE-510','2024-09-03','11A','Económica',  305000),
    ('PAS-007','VUE-720','2024-08-12','7C', 'Ejecutiva',  810000),
    ('PAS-007','VUE-613','2024-09-01','2B', 'Económica',  175000),
    ('PAS-007','VUE-815','2024-09-04','8A', 'Primera',   1650000),
    ('PAS-008','VUE-101','2024-08-15','14B','Económica',  250000),
    ('PAS-008','VUE-205','2024-09-05','3A', 'Ejecutiva',  695000);

SELECT COUNT(*) AS pasajeros FROM pasajero;   -- 8
SELECT COUNT(*) AS reservas  FROM reserva;    -- 20
```

---

## Subconsultas correlacionadas

**1.** Para cada pasajero, muestra su nombre y cuántas reservas tiene.
*(subconsulta correlacionada escalar en el SELECT)*

**2.** Lista los pasajeros que tienen más de 2 reservas.
*(subconsulta correlacionada en el WHERE)*

**3.** Lista los vuelos que tienen al menos una reserva en clase `'Primera'`. *(EXISTS)*

**4.** Lista los pasajeros que **no** tienen ninguna reserva. *(NOT EXISTS)*

---

## Subconsulta vs JOIN — comparación

Observa el siguiente par de consultas. Las dos devuelven los pasajeros que tienen al menos una reserva:

```sql
-- Con subconsulta correlacionada (consulta la tabla reserva 8 veces: una por pasajero)
SELECT p.nombre_pasajero
FROM pasajero p
WHERE EXISTS (SELECT 1 FROM reserva r WHERE r.id_pasajero = p.id_pasajero);

-- Con INNER JOIN (una sola pasada sobre ambas tablas)
SELECT DISTINCT p.nombre_pasajero
FROM pasajero p
INNER JOIN reserva r ON p.id_pasajero = r.id_pasajero;
```

> Ambas dan el mismo resultado. La subconsulta consulta `reserva` **8 veces**; el JOIN la consulta **una vez**.
> Además, con JOIN puedes proyectar columnas de `reserva` directamente en el `SELECT`,
> algo que la subconsulta correlacionada no puede hacer sin trucos adicionales.

---

## INNER JOIN

**5.** Lista el nombre de cada pasajero junto a su clase de reserva y precio.

**6.** Lista nombre del pasajero, origen y destino del vuelo, y clase de la reserva.
*(3 tablas: pasajero + reserva + vuelo)*

**7.** Lista nombre del pasajero, nombre de la aerolínea, ruta y clase.
*(4 tablas)*

**8.** ¿Cuánto pagó en total cada pasajero? Muestra nombre y total.
*(INNER JOIN + GROUP BY)*

---

## LEFT JOIN

**9.** Lista todos los pasajeros con sus reservas. Los que no tienen reserva deben aparecer igualmente.

**10.** ¿Cuáles pasajeros no tienen ninguna reserva? *(LEFT JOIN + IS NULL)*

**11.** Para cada vuelo, muestra cuántas reservas tiene. Incluye los vuelos sin reservas.
*(LEFT JOIN + GROUP BY + COUNT)*

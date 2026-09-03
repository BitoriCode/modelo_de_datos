# Práctica DML — AeroPass

> Copia el bloque de preparación en pgAdmin, ejecútalo y luego escribe cada consulta.

---

## Preparación — crear tablas e insertar datos

```sql
-- Limpieza
DROP TABLE IF EXISTS reserva    CASCADE;
DROP TABLE IF EXISTS vuelo      CASCADE;
DROP TABLE IF EXISTS pasajero   CASCADE;
DROP TABLE IF EXISTS aerolinea  CASCADE;

-- Tablas
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
    PRIMARY KEY (id_pasajero, id_vuelo)
);

-- Datos
INSERT INTO aerolinea VALUES
    ('AER-1', 'Avianca'),
    ('AER-2', 'LATAM'),
    ('AER-3', 'Wingo');

INSERT INTO pasajero VALUES
    ('PAS-001', 'Carlos Ruiz', 'carlos@mail.co'),
    ('PAS-002', 'Laura Mesa',  'laura@mail.co'),
    ('PAS-003', 'Jorge Vega',  'jorge@mail.co'),
    ('PAS-004', 'Ana Torres',  NULL);

INSERT INTO vuelo VALUES
    ('VUE-101', 'Medellín', 'Bogotá',        'AER-1'),
    ('VUE-205', 'Bogotá',   'Cali',          'AER-2'),
    ('VUE-312', 'Cali',     'Barranquilla',  'AER-2'),
    ('VUE-408', 'Bogotá',   'Cartagena',     'AER-3');

INSERT INTO reserva VALUES
    ('PAS-001', 'VUE-101', '2024-08-15', '12A', 'Económica'),
    ('PAS-001', 'VUE-205', '2024-08-16', '5C',  'Ejecutiva'),
    ('PAS-002', 'VUE-101', '2024-08-15', '12B', 'Económica'),
    ('PAS-003', 'VUE-312', '2024-08-17', '7A',  'Económica'),
    ('PAS-004', 'VUE-408', '2024-08-18', '3B',  'Ejecutiva');
```

---

## Esquema de referencia

```
AEROLINEA(id_aerolinea, nombre_aerolinea)
PASAJERO (id_pasajero, nombre_pasajero, email_pasajero)
VUELO    (id_vuelo, origen_vuelo, destino_vuelo, id_aerolinea)
RESERVA  (id_pasajero, id_vuelo, fecha_reserva, num_asiento, clase)
```

---

## Consultas

**1.** Trae todos los pasajeros.


---

**2.** Trae solo el nombre y el email de los pasajeros.


---

**3.** Trae todos los vuelos.



---

**4.** Trae los vuelos que salen de Bogotá.


---

**5.** Trae las reservas en clase Ejecutiva.


---

**6.** Trae todas las reservas del pasajero `PAS-001`.



---

**7.** Trae todas las reservas ordenadas por fecha, de la más reciente a la más antigua.



---

**8.** Trae las reservas del pasajero `PAS-001` que sean en clase Ejecutiva.



---

**9.** Trae los vuelos que salen de Medellín **o** de Cali.




---

**10.** Trae las reservas que **no** son en clase Económica.




---

**11.** Trae los vuelos operados por `AER-2` (LATAM) que van a Barranquilla.




---

**12.** Trae los pasajeros que no tienen email registrado.


---


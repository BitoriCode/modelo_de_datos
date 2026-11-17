# Práctica guiada — Clase 19
**JOINs avanzados + Tablas derivadas | Base de datos: MediCare**

---

```sql
DROP TABLE IF EXISTS turno        CASCADE;
DROP TABLE IF EXISTS medico       CASCADE;
DROP TABLE IF EXISTS paciente     CASCADE;
DROP TABLE IF EXISTS especialidad CASCADE;

CREATE TABLE especialidad (
    id_especialidad     VARCHAR(10)  PRIMARY KEY,
    nombre_especialidad VARCHAR(60)  NOT NULL
);
CREATE TABLE medico (
    id_medico       VARCHAR(10)  PRIMARY KEY,
    nombre_medico   VARCHAR(100) NOT NULL,
    id_especialidad VARCHAR(10)  NOT NULL REFERENCES especialidad(id_especialidad)
);
CREATE TABLE paciente (
    id_paciente     VARCHAR(10)  PRIMARY KEY,
    nombre_paciente VARCHAR(100) NOT NULL,
    email_paciente  VARCHAR(150)
);
CREATE TABLE turno (
    id_paciente   VARCHAR(10) NOT NULL REFERENCES paciente(id_paciente),
    id_medico     VARCHAR(10) NOT NULL REFERENCES medico(id_medico),
    fecha_turno   DATE        NOT NULL,
    tipo_consulta VARCHAR(20) NOT NULL,
    costo_cop     INT         NOT NULL CHECK (costo_cop > 0),
    PRIMARY KEY (id_paciente, id_medico)
);

INSERT INTO especialidad VALUES
    ('ESP-1', 'Medicina General'),
    ('ESP-2', 'Pediatría'),
    ('ESP-3', 'Cardiología');

INSERT INTO medico VALUES
    ('MED-001', 'Dr. Carlos Torres',  'ESP-1'),
    ('MED-002', 'Dra. Laura Sánchez', 'ESP-2'),
    ('MED-003', 'Dr. Jorge Vargas',   'ESP-3'),
    ('MED-004', 'Dra. Ana Ríos',      'ESP-1'),
    ('MED-005', 'Dra. Sofía Herrera', 'ESP-3'),  -- sin turnos
    ('MED-006', 'Dr. Miguel Castro',  'ESP-2');   -- sin turnos

INSERT INTO paciente VALUES
    ('PAC-001', 'Carlos Ruiz',    'carlos@mail.co'),
    ('PAC-002', 'Laura Mesa',     'laura@mail.co'),
    ('PAC-003', 'Jorge Vega',     'jorge@mail.co'),
    ('PAC-004', 'Ana Torres',      NULL),
    ('PAC-005', 'Sofía Herrera',  'sofia@mail.co'),
    ('PAC-006', 'Miguel Castro',   NULL),
    ('PAC-007', 'Patricia Leal',  'patricia@mail.co'),  -- sin turnos
    ('PAC-008', 'Andrés Morales', 'andres@mail.co');    -- sin turnos

INSERT INTO turno VALUES
    ('PAC-001', 'MED-001', '2024-08-10', 'Primera vez',  50000),
    ('PAC-001', 'MED-002', '2024-08-16', 'Control',      65000),
    ('PAC-001', 'MED-003', '2024-09-02', 'Urgencia',    120000),
    ('PAC-002', 'MED-001', '2024-08-10', 'Primera vez',  50000),
    ('PAC-002', 'MED-002', '2024-08-20', 'Control',      65000),
    ('PAC-002', 'MED-004', '2024-09-05', 'Primera vez',  50000),
    ('PAC-003', 'MED-003', '2024-08-17', 'Urgencia',    120000),
    ('PAC-003', 'MED-004', '2024-08-25', 'Control',      50000),
    ('PAC-003', 'MED-001', '2024-09-06', 'Control',      50000),
    ('PAC-004', 'MED-002', '2024-08-18', 'Primera vez',  65000),
    ('PAC-004', 'MED-004', '2024-08-28', 'Urgencia',     50000),
    ('PAC-005', 'MED-001', '2024-08-22', 'Primera vez',  50000),
    ('PAC-005', 'MED-002', '2024-09-01', 'Control',      65000),
    ('PAC-005', 'MED-003', '2024-09-04', 'Control',     120000),
    ('PAC-006', 'MED-004', '2024-08-30', 'Primera vez',  50000),
    ('PAC-006', 'MED-003', '2024-09-03', 'Control',     120000);

SELECT COUNT(*) AS especialidades FROM especialidad;  -- 3
SELECT COUNT(*) AS medicos         FROM medico;        -- 6
SELECT COUNT(*) AS pacientes       FROM paciente;      -- 8
SELECT COUNT(*) AS turnos          FROM turno;         -- 16
```

---

## Esquema de referencia

```
ESPECIALIDAD  (id_especialidad, nombre_especialidad)
MEDICO        (id_medico, nombre_medico, id_especialidad)
PACIENTE      (id_paciente, nombre_paciente, email_paciente)
TURNO         (id_paciente, id_medico, fecha_turno, tipo_consulta, costo_cop)
              PK: (id_paciente, id_medico)
```

---

## RIGHT JOIN

**1.** Muestra todos los médicos con sus turnos. Los médicos que no tienen ningún turno deben aparecer igualmente.  
*(RIGHT JOIN — escribe `turno` como tabla izquierda y `medico` como tabla derecha)*

**2.** Escribe la misma consulta del punto 1 usando LEFT JOIN, invirtiendo el orden de las tablas. Verifica que el resultado es idéntico.

---

## FULL OUTER JOIN

**3.** Muestra todos los pacientes con sus turnos. Los pacientes sin turno deben aparecer con NULL en las columnas del turno.

**4.** Muestra todos los médicos con sus turnos, incluyendo los que no tienen ningún turno registrado.

---

## CROSS JOIN

**5.** Genera todas las combinaciones posibles de pacientes y especialidades. ¿Cuántas filas resultan?

---

## Tabla derivada (subconsulta en FROM)

**6.** Muestra el nombre de cada médico y la cantidad de turnos que ha atendido.  
*(INNER JOIN con una subconsulta como tabla derivada)*

**7.** Muestra el nombre de cada paciente y su gasto total en turnos. Los pacientes sin turnos deben aparecer con `0`.  
*(LEFT JOIN + tabla derivada + COALESCE)*

**8.** Lista los 3 médicos con mayor recaudación total, mostrando su nombre y el monto.  
*(tabla derivada con ORDER BY + LIMIT)*

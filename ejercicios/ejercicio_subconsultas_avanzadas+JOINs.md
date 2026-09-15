# Taller Clase 15
**Subconsultas avanzadas + JOINs | Base de datos: LibroMundo**

---

## Preparación — ejecuta este bloque antes de comenzar

```sql
DROP TABLE IF EXISTS compra    CASCADE;
DROP TABLE IF EXISTS libro     CASCADE;
DROP TABLE IF EXISTS cliente   CASCADE;
DROP TABLE IF EXISTS editorial CASCADE;

CREATE TABLE editorial (
    id_editorial     SERIAL       PRIMARY KEY,
    nombre_editorial VARCHAR(60)  NOT NULL,
    pais_origen      VARCHAR(40)  NOT NULL,
    anio_fundacion   SMALLINT     NOT NULL
);
CREATE TABLE cliente (
    id_cliente     SERIAL        PRIMARY KEY,
    nombre_cliente VARCHAR(100)  NOT NULL,
    email_cliente  VARCHAR(150),
    fecha_registro DATE          NOT NULL DEFAULT CURRENT_DATE
);
CREATE TABLE libro (
    id_libro     SERIAL         PRIMARY KEY,
    titulo_libro VARCHAR(150)   NOT NULL,
    genero_libro VARCHAR(40)    NOT NULL,
    precio_cop   NUMERIC(10, 2) NOT NULL CHECK (precio_cop > 0),
    paginas      SMALLINT       NOT NULL CHECK (paginas > 0),
    disponible   BOOLEAN        NOT NULL DEFAULT TRUE,
    id_editorial INT            NOT NULL REFERENCES editorial(id_editorial)
);
CREATE TABLE compra (
    id_cliente   INT            NOT NULL REFERENCES cliente(id_cliente),
    id_libro     INT            NOT NULL REFERENCES libro(id_libro),
    fecha_compra DATE           NOT NULL,
    cantidad     SMALLINT       NOT NULL CHECK (cantidad > 0),
    total_cop    NUMERIC(10, 2) NOT NULL CHECK (total_cop > 0),
    PRIMARY KEY (id_cliente, id_libro)
);

-- id_editorial se asigna automáticamente: 1=Planeta, 2=Penguin, 3=Alfaguara
INSERT INTO editorial (nombre_editorial, pais_origen, anio_fundacion) VALUES
    ('Planeta',   'Colombia',  1949),
    ('Penguin',   'Argentina', 1935),
    ('Alfaguara', 'España',    1964);

-- id_cliente se asigna automáticamente: 1=Carlos Ruiz ... 8=Andrés Morales
INSERT INTO cliente (nombre_cliente, email_cliente, fecha_registro) VALUES
    ('Carlos Ruiz',    'carlos@mail.co',   '2023-01-15'),
    ('Laura Mesa',     'laura@mail.co',    '2023-03-22'),
    ('Jorge Vega',     'jorge@mail.co',    '2023-05-10'),
    ('Ana Torres',      NULL,              '2023-06-01'),
    ('Sofía Herrera',  'sofia@mail.co',    '2023-08-14'),
    ('Miguel Castro',   NULL,              '2023-09-30'),
    ('Patricia Leal',  'patricia@mail.co', '2024-01-07'),
    ('Andrés Morales', 'andres@mail.co',   '2024-02-18');

-- id_libro se asigna automáticamente: 1=Cien años ... 8=Atomic Habits
INSERT INTO libro (titulo_libro, genero_libro, precio_cop, paginas, disponible, id_editorial) VALUES
    ('Cien años de soledad', 'Novela',          45000.00, 432, TRUE,  1),
    ('El marciano',          'Ciencia Ficción', 38000.00, 369, TRUE,  2),
    ('El resplandor',        'Terror',          35000.00, 447, TRUE,  3),
    ('El poder del ahora',   'Autoayuda',       42000.00, 236, TRUE,  1),
    ('Sapiens',              'Historia',        52000.00, 513, TRUE,  2),
    ('Dune',                 'Ciencia Ficción', 48000.00, 688, TRUE,  3),
    ('La sombra del viento', 'Novela',          40000.00, 498, FALSE, 1),
    ('Atomic Habits',        'Autoayuda',       39000.00, 320, FALSE, 2);

-- id_cliente e id_libro son ahora enteros generados por SERIAL
INSERT INTO compra VALUES
    (1, 1, '2024-08-10', 1,  45000.00),
    (1, 2, '2024-08-16', 1,  38000.00),
    (1, 5, '2024-09-02', 2, 104000.00),
    (2, 1, '2024-08-10', 1,  45000.00),
    (2, 3, '2024-08-20', 1,  35000.00),
    (2, 6, '2024-09-05', 1,  48000.00),
    (3, 3, '2024-08-17', 2,  70000.00),
    (3, 4, '2024-08-25', 1,  42000.00),
    (3, 5, '2024-09-06', 1,  52000.00),
    (4, 2, '2024-08-18', 1,  38000.00),
    (4, 6, '2024-08-28', 2,  96000.00),
    (5, 1, '2024-08-22', 1,  45000.00),
    (5, 4, '2024-09-01', 1,  42000.00),
    (7, 2, '2024-08-12', 1,  38000.00),
    (7, 5, '2024-09-01', 1,  52000.00),
    (7, 6, '2024-09-04', 2,  96000.00);

SELECT COUNT(*) AS clientes FROM cliente;   -- 8
SELECT COUNT(*) AS libros   FROM libro;     -- 8
SELECT COUNT(*) AS compras  FROM compra;    -- 16
```

---

## Esquema de referencia

```
EDITORIAL  (id_editorial SERIAL PK, nombre_editorial, pais_origen, anio_fundacion)
LIBRO      (id_libro SERIAL PK, titulo_libro, genero_libro, precio_cop, paginas, disponible, id_editorial)
CLIENTE    (id_cliente SERIAL PK, nombre_cliente, email_cliente, fecha_registro)
COMPRA     (id_cliente, id_libro, fecha_compra, cantidad, total_cop)
           PK: (id_cliente, id_libro)
```

---

## Bloque A — Subconsultas correlacionadas y EXISTS

**1.** Para cada libro, muestra su título y cuántas veces ha sido comprado.
*(subconsulta correlacionada escalar)*

**2.** Lista los libros que **no** tienen ninguna compra registrada. *(NOT EXISTS)*

**3.** Lista las editoriales que tienen al menos un libro de género `'Ciencia Ficción'`. *(EXISTS)*

**4.** Lista los clientes cuyo número de compras es mayor al promedio de compras por cliente.

---

## Bloque B — INNER JOIN

**5.** Lista el nombre del cliente, la fecha de compra y el total pagado por cada compra.
*(2 tablas: cliente + compra)*

**6.** Lista nombre del cliente, título del libro, género y total pagado. Ordena por nombre del cliente.
*(3 tablas: + libro)*

**7.** Lista la información completa de cada compra: nombre del cliente, nombre de la editorial, título del libro, género y precio.
*(4 tablas)*

**8.** ¿Cuántas compras registró cada editorial y cuánto recaudó en total?
*(4 tablas + GROUP BY)*

**9.** Lista las compras de libros de género `'Terror'` mostrando nombre del cliente, título del libro y total pagado.

---

## Bloque C — LEFT JOIN

**10.** Lista todos los clientes con el total que han pagado en compras. Los que no han comprado nada deben aparecer igualmente.

**11.** Lista todas las editoriales con el número de libros que tienen y el total recaudado en compras. Incluye editoriales cuyos libros no hayan tenido ninguna compra.
*(LEFT JOIN encadenado + GROUP BY)*

**12.** ★ Lista los clientes que tienen compras registradas pero **ninguna** de género `'Autoayuda'`.
*(INNER JOIN + NOT EXISTS o NOT IN)*

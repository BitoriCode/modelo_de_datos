# DDL — Restricciones e integridad de los datos

[Índice de notas](../README.md) · [Ruta de estudio](../ruta_estudio_programacion.md)

## Antes de empezar

**Sesión de referencia:** S12, 100 minutos. Repasa [CREATE TABLE y tipos](ddl_inicial.md), PK, FK y normalización. Carga [StaffHub](../recursos/datasets/staffhub_setup.sql) en una base de práctica siguiendo las [instrucciones de preparación](../recursos/datasets/README.md).

**Al finalizar podrás:** convertir una regla de negocio en una restricción, modificar una tabla con `ALTER TABLE` y explicar por qué se rechaza un dato. Para esta práctica basta comprender que `BEGIN; ... ROLLBACK;` permite ejecutar cambios y revertirlos; no es un bloque PL/pgSQL.

## 1. Elegir la restricción

| Necesidad | Herramienta | Qué comprobar |
|---|---|---|
| Identificar una fila | `PRIMARY KEY` | No se repite ni admite nulos; puede incluir varias columnas. |
| Exigir un dato | `NOT NULL` | No admite `NULL`; una cadena vacía sigue siendo un valor. |
| Evitar repetición | `UNIQUE` | Por defecto puede haber varios nulos: no equivale a NOT NULL. |
| Referenciar una fila existente | `FOREIGN KEY` | La columna referenciada debe ser una clave válida; los tipos deben ser compatibles. |
| Validar un rango o relación entre columnas de la fila | `CHECK` | Solo rechaza FALSE; NULL no se rechaza por sí solo. |
| Dar un valor al omitir la columna | `DEFAULT` | No sustituye un NULL explícito ni es una restricción de integridad. |

`CHECK (nota BETWEEN 0 AND 5)` permite una nota sin registrar (`NULL`). Si la nota fuera obligatoria, se necesita también `NOT NULL`. Una FK opcional admite NULL; una relación obligatoria necesita FK y NOT NULL.

## 2. Práctica guiada — Formación del personal

Reglas: un curso tiene código único, nombre irrepetible y cupos positivos. Una persona puede inscribirse una vez por curso. La nota es opcional y, si se registra, debe estar entre 0 y 5.

Ejecuta el siguiente bloque completo sobre StaffHub. Las tablas nuevas se revierten al final:

```sql
BEGIN;
CREATE TABLE capacitacion (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    cupos INT NOT NULL DEFAULT 20 CHECK (cupos > 0)
);
CREATE TABLE inscripcion_capacitacion (
    codigo VARCHAR(10) REFERENCES capacitacion(codigo),
    id_empleado VARCHAR(10) REFERENCES empleado(id_empleado),
    nota NUMERIC(3,1) CHECK (nota BETWEEN 0 AND 5),
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (codigo, id_empleado)
);
INSERT INTO capacitacion (codigo, nombre) VALUES ('SQL-01', 'SQL inicial');
INSERT INTO inscripcion_capacitacion (codigo, id_empleado)
VALUES ('SQL-01', 'EMP-01');
SELECT c.codigo, c.cupos, i.id_empleado, i.nota
FROM capacitacion c JOIN inscripcion_capacitacion i USING (codigo);
ROLLBACK;
```

Esperado: una inscripción de EMP-01, 20 cupos y nota NULL. La PK compuesta hace obligatorias sus dos columnas. La FK no controla el aforo del curso: esa regla depende de otras filas y requeriría otro diseño o lógica adicional; no debe inventarse un CHECK con una subconsulta.

## 3. Modificar y eliminar objetos de práctica

`ALTER TABLE` permite añadir columnas y restricciones a datos existentes. Una restricción nueva falla si los datos actuales ya la incumplen. Este ejemplo es independiente del anterior:

```sql
BEGIN;
ALTER TABLE empleado ADD COLUMN telefono TEXT;
ALTER TABLE empleado ADD CONSTRAINT chk_salario_positivo CHECK (salario_cop > 0);
ALTER TABLE empleado RENAME COLUMN telefono TO telefono_contacto;
ALTER TABLE empleado DROP COLUMN telefono_contacto;
ROLLBACK;
```

Para retirar una tabla de ejercicios se usa `DROP TABLE nombre;`. Sin `CASCADE`, PostgreSQL impide eliminarla si hay objetos dependientes. En un reinicio, retirar primero la tabla hija permite evitar CASCADE. `IF EXISTS` evita el error de objeto inexistente; no convierte la eliminación en una operación inocua.

## 4. Práctica autónoma — 30 minutos

**Reto A.** Crea `curso_practica`: código PK, nombre obligatorio e irrepetible, cupos positivos con valor predeterminado 20 y activo obligatorio con valor predeterminado TRUE. Inserta una fila omitiendo cupos y activo. Explica qué ocurriría con cupos NULL, 0 y nombre repetido.

**Reto B.** Sobre StaffHub, añade una restricción de salario positivo y otra de calificación entre 1 y 5, permitiendo calificación NULL. Explica por qué no hace falta un trigger para esas reglas.

<details>
<summary>Soluciones razonadas — consultar después de intentar los retos</summary>

```sql
-- practica_ddl_a
BEGIN;
CREATE TABLE curso_practica (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre TEXT NOT NULL UNIQUE,
    cupos INT NOT NULL DEFAULT 20 CHECK (cupos > 0),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);
INSERT INTO curso_practica (codigo, nombre) VALUES ('C-01', 'Modelado');
SELECT cupos, activo FROM curso_practica WHERE codigo = 'C-01';
ROLLBACK;
```

Esperado: `20` y `true`. NOT NULL rechaza cupos NULL, CHECK rechaza 0 y UNIQUE rechaza un nombre repetido. DEFAULT solo actúa cuando se omite el valor o se escribe DEFAULT.

```sql
-- practica_ddl_b
BEGIN;
ALTER TABLE empleado ADD CONSTRAINT chk_salario_practica CHECK (salario_cop > 0);
ALTER TABLE empleado ADD CONSTRAINT chk_calificacion_practica
    CHECK (calificacion BETWEEN 1 AND 5);
UPDATE empleado SET calificacion = NULL WHERE id_empleado = 'EMP-01';
SELECT calificacion IS NULL AS sin_evaluar FROM empleado WHERE id_empleado = 'EMP-01';
ROLLBACK;
```

Esperado: TRUE. Los CHECK consultan solo la fila y expresan directamente las reglas. Para comprobar rechazos, modifica una copia del bloque con salario -1 o calificación 6. Ante el error, ejecuta ROLLBACK antes de continuar; no lo sustituyas por COMMIT.

</details>

## 5. Comprueba tu aprendizaje

1. ¿Por qué CHECK no reemplaza a NOT NULL? Porque una condición desconocida por NULL no se rechaza.
2. ¿Por qué dos FK no evitan inscribir dos veces al mismo empleado? Validan existencia, no la unicidad de la pareja; eso lo resuelve la PK compuesta.
3. ¿Qué diferencia hay entre omitir cupos y enviar NULL? La omisión usa DEFAULT; NULL explícito incumple NOT NULL.
4. ¿Cuándo preferirías una restricción a un trigger? Cuando la regla se expresa con PK, FK, UNIQUE, NOT NULL o CHECK sin lógica adicional.

Continúa con [DML básico](dml_basico.md). Referencia: [restricciones en PostgreSQL](https://www.postgresql.org/docs/18/ddl-constraints.html).

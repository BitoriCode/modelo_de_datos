# Clase 7 — Práctica: Relaciones, Cardinalidades, Entidades Débiles y Asociativas

**Curso:** Modelos de Datos  
**Fecha:** 11 de agosto  
**Herramienta:** [draw.io](https://app.diagrams.net) 

---

## Caso 1 — Biblioteca Universitaria

> Relaciones, cardinalidades y entidades débiles

**Para cada caso, lee el enunciado e identifica:**

a) Todas las entidades (indica si cada una es fuerte o débil)  
b) Las relaciones entre entidades y su nombre descriptivo  
c) La cardinalidad de cada relación (1:1, 1:N, M:N)  
d) La participación de cada entidad en cada relación (total o parcial)  
e) El discriminador de las entidades débiles

---

### Enunciado

La biblioteca tiene varias **sucursales** identificadas por un código único; cada sucursal tiene nombre y dirección.

Los **libros** se identifican por ISBN, y tienen título, año y género. Cada libro puede tener varios **autores**. De cada autor se guarda nombre y nacionalidad.

Cada sucursal posee **ejemplares** físicos de los libros. Un ejemplar se identifica por su número de ejemplar *dentro de la sucursal* (por ejemplo: Sucursal Norte / Ejemplar 3 del libro X). Los ejemplares tienen estado: disponible, prestado o dañado.

Los **socios** se identifican por número de carné y tienen nombre, correo y teléfono. Un socio puede tener múltiples **préstamos** activos o históricos. Cada préstamo registra fecha de préstamo, fecha de devolución esperada y fecha de devolución real (en blanco si aún no fue devuelto). Un préstamo corresponde exactamente a un ejemplar.

---

### Preguntas guía

1. ¿`EJEMPLAR` es fuerte o débil? ¿De qué entidad depende? ¿Cuál es su discriminador?
2. ¿`PRÉSTAMO` es fuerte, débil o asociativa? Justifica.
3. ¿Cuál es la cardinalidad entre `AUTOR` y `LIBRO`?
4. ¿La participación de `SOCIO` en `PRÉSTAMO` es total o parcial? ¿Por qué?
5. ¿La participación de `EJEMPLAR` en `PRÉSTAMO` es total o parcial?
6. Dibuja el diagrama E-R completo en draw.io con todas las cardinalidades y participaciones.

---

## Caso 2 — Recursos Humanos Corporativos

> Entidades débiles, relaciones reflexivas y entidades asociativas

**Para cada caso, lee el enunciado e identifica:**

a) Las entidades (fuertes o débiles) y sus atributos  
b) Las relaciones, cardinalidades y participaciones  
c) Si hay alguna relación M:N que deba convertirse en entidad asociativa

---

### Enunciado

Una empresa tiene **departamentos**, cada uno con nombre único y presupuesto asignado. Cada **empleado** tiene código interno, nombre, fecha de ingreso y salario base. Todo empleado pertenece exactamente a un departamento.

Algunos empleados **supervisan** a otros empleados dentro de su mismo departamento. Un supervisor puede tener varios supervisados, pero cada empleado tiene a lo sumo un supervisor. No todo empleado tiene supervisor (por ejemplo, los directores).

Los empleados pueden registrar **dependientes** familiares (hijos o cónyuge) para el seguro médico. De cada dependiente se guarda nombre y fecha de nacimiento. El nombre del dependiente es único dentro del grupo familiar del empleado, pero puede repetirse entre grupos de distintos empleados.

La empresa gestiona **proyectos** con código, nombre y presupuesto. Cada empleado puede trabajar en varios proyectos, y cada proyecto puede tener varios empleados. La empresa registra el número de **horas semanales** que cada empleado dedica a cada proyecto.

---

### Preguntas guía

1. ¿`DEPENDIENTE` es fuerte o débil? ¿Cuál es su discriminador?
2. La relación "EMPLEADO supervisa EMPLEADO" ¿es 1:N o M:N? ¿Por qué?  
   ¿La participación de `EMPLEADO` en "es supervisado" es total o parcial?
3. ¿La relación `EMPLEADO`—`PROYECTO` debe convertirse en entidad asociativa?  
   Justifica basándote en los atributos del vínculo.
4. ¿Puede existir un `DEPARTAMENTO` sin empleados? ¿Cómo se refleja eso en el diagrama?
5. Dibuja el diagrama E-R completo en draw.io.

---

## Caso 3 — Aerolínea Regional *(Escenario del Evento I)*

> Integración completa: atributos + relaciones + débiles + asociativas

Retoma el escenario del **Evento I** y complétalo agregando las relaciones. No necesitas reinventar las entidades; ya las identificaste antes.

---

### Enunciado

La aerolínea opera **vuelos** entre ciudades colombianas. Cada vuelo tiene número, fecha, hora de salida y hora de llegada; la duración se calcula automáticamente. Cada vuelo usa una **aeronave**; las aeronaves se identifican por matrícula y tienen modelo y capacidad.

Los **pasajeros** tienen nombre completo, número de pasaporte y correo. Cada pasajero puede registrar varios teléfonos de contacto. Un pasajero puede realizar múltiples **reservas**. Cada reserva registra número de asiento, clase (económica/business) y estado (confirmada/pendiente/cancelada).

> **Decisión de diseño a justificar:** ¿`RESERVA` debe ser entidad débil, entidad asociativa o entidad fuerte?

---

### Preguntas guía

1. Lista todas las entidades e indica si son fuertes o débiles.
2. Define una relación entre cada par de entidades que se vinculan.  
   Para cada una indica: nombre, cardinalidad y participación.
3. ¿`RESERVA` es débil (depende de pasajero) o asociativa (une pasajero con vuelo)?  
   Argumenta tu decisión. ¿Cambia algo en el diagrama según la elección?
4. El atributo `teléfonos` (multivaluado) de `PASAJERO`:  
   ¿cómo se representa en draw.io? ¿Afecta las relaciones del diagrama?
5. Dibuja el diagrama E-R completo en draw.io incluyendo cardinalidades, participaciones y la decisión sobre `RESERVA`.

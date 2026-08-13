#  Diagramas Entidad-Relación
---

## Instrucciones generales

1. Elige **uno** de los tres enunciados.
2. Construye el diagrama E-R completo en **[draw.io](https://app.diagrams.net)** usando **notación Chen**.
   - Usa la librería **Entity Relation** del panel de shapes.
3. El diagrama debe incluir:
   - Todas las entidades con sus atributos y el **tipo** de cada atributo
   - Todas las relaciones con **cardinalidades** (1:1, 1:N, M:N)
   - **Participación** total o parcial en cada relación (línea doble = total)
   - Al menos: una **entidad débil**, una relación **M:N** y una **entidad asociativa**
4. Exporta el archivo como `.drawio` y entrégalo según las indicaciones del profesor.

---

## Enunciado A — Sistema de cine 

Una cadena de cines gestiona sus salas y funciones. Cada cine tiene nombre y dirección.
Las salas se identifican por número dentro del cine y tienen capacidad y tipo (normal o VIP).

Las películas tienen título, año y una calificación promedio calculada a partir de las reseñas
registradas en el sistema. Un actor puede participar en muchas películas; de cada participación
se registra el personaje interpretado.

Cada función corresponde a una sala y una película, con fecha, hora y precio base.

### Preguntas de análisis

Antes de dibujar, responde:

1. ¿Qué entidades identificas? ¿Cuáles son fuertes y cuáles débiles?
2. ¿Qué atributos tiene cada entidad? ¿Alguno es derivado, multivaluado o compuesto?
3. ¿Qué relaciones existen? ¿Cuál es su cardinalidad?
4. ¿Existe alguna relación M:N que deba convertirse en entidad asociativa? ¿Por qué?

---

## Enunciado B — Sistema de pedidos de comida 

Una plataforma de delivery registra restaurantes y sus menús. Cada restaurante tiene nombre
y dirección. Los ítems del menú se identifican por un código dentro del restaurante y tienen
nombre, precio y categoría.

Los clientes tienen nombre, una dirección de entrega compuesta por calle y ciudad, y pueden
registrar varios teléfonos de contacto.

Un cliente hace pedidos; cada pedido tiene fecha, estado y un total que se calcula a partir
de sus líneas. Cada línea del pedido registra la cantidad y el precio unitario del ítem pedido,
y se identifica por su número dentro del pedido.

### Preguntas de análisis

Antes de dibujar, responde:

1. ¿Cuántas entidades débiles hay? ¿De qué entidades dependen?
2. ¿Qué atributo de CLIENTE es multivaluado? ¿Cómo se representa en Chen?
3. ¿Qué atributo es compuesto? ¿Qué sub-atributos tiene?
4. ¿Qué atributo es derivado? ¿De dónde se calcularía?
5. LÍNEA_PEDIDO tiene dos relaciones con otras entidades: ¿cuál es identificadora y cuál no?

---

## Enunciado C — Sistema universitario 

Una universidad organiza sus departamentos dentro de facultades. Cada departamento emplea
profesores y ofrece asignaturas.

Las secciones de una asignatura se identifican por número dentro de esa asignatura y tienen
horario y aula asignada. Un profesor puede dictar varias secciones.

Los estudiantes se inscriben en secciones; de cada inscripción se registra la fecha, la nota
final y el estado (activa, retirada o aprobada). El promedio académico del estudiante se
calcula automáticamente a partir de sus notas registradas.

### Preguntas de análisis

Antes de dibujar, responde:

1. ¿Qué cadena de relaciones 1:N existe entre FACULTAD, DEPARTAMENTO y PROFESOR?
2. ¿Por qué SECCIÓN es una entidad débil? ¿Cuál es su discriminador?
3. SECCIÓN tiene dos relaciones con otras entidades: ¿cuáles son y qué tipo es cada una?
4. ¿Qué relación M:N existe? ¿Qué entidad asociativa la resuelve?
5. ¿Qué atributo del estudiante es derivado? ¿De qué se calcularía?

---

## Referencia rápida — Shapes de draw.io (librería Entity Relation)

| Shape | Representa |
|-------|-----------|
| `Entity` | Entidad fuerte |
| `Weak Entity` | Entidad débil |
| `Relationship` | Relación (diamante) |
| `Identifying Relationship` | Relación identificadora (diamante doble) |
| `Attribute` | Atributo simple |
| `Key Attribute` | Clave primaria |
| `Partial Key` | Discriminador de entidad débil |
| `Derived Attribute` | Atributo derivado |
| `Multivalued Attribute` | Atributo multivaluado |

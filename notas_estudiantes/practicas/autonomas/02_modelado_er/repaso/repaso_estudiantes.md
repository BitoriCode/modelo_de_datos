# Repaso integrador — Modelo Entidad-Relación
**Curso:** Modelo de Datos &nbsp;|&nbsp; **Clase 9** &nbsp;|&nbsp; **18 de agosto de 2026**

> Esta clase tiene dos partes: primero un resumen de todos los conceptos del modelo E-R,
> y luego un simulacro en condiciones de examen. El Evento II es el jueves 20 de agosto.

---

## Parte 1 — Resumen de conceptos

### 1.1 Tipos de entidades

| Tipo | Descripción | Representación Chen | Identificador |
|------|-------------|---------------------|---------------|
| **Fuerte** | Existe de forma independiente; tiene clave propia | Rectángulo simple | Atributo clave propio |
| **Débil** | No puede identificarse sin otra entidad (la propietaria) | Rectángulo **doble** | Clave propietaria + discriminante (clave parcial) |

> Una entidad débil siempre tiene **participación total** en la relación identificadora con su propietaria.

---

### 1.2 Tipos de atributos

| Tipo | Descripción | Representación Chen |
|------|-------------|---------------------|
| **Simple** | Valor único, atómico | Óvalo simple |
| **Clave** | Identifica de forma única cada instancia | Óvalo con texto **subrayado** |
| **Discriminante** | Clave parcial de entidad débil | Óvalo con subrayado **discontinuo** |
| **Compuesto** | Formado por sub-atributos | Óvalo con sub-óvalos conectados |
| **Multivaluado** | Puede tener múltiples valores para la misma instancia | Óvalo **doble** |
| **Derivado** | Se calcula a partir de otros datos; no se almacena | Óvalo **discontinuo** (punteado) |
| **Opcional (nulo)** | Puede no tener valor | Óvalo simple (se puede anotar con "nullable") |

---

### 1.3 Tipos de relaciones

| Cardinalidad | Significado | Ejemplo |
|-------------|-------------|---------|
| **1:1** | Cada instancia de A se asocia con exactamente una de B | CIUDADANO — PASAPORTE |
| **1:N** | Una instancia de A se asocia con muchas de B; cada B con una sola A | DEPARTAMENTO — EMPLEADO |
| **M:N** | Muchas instancias de A con muchas de B | ESTUDIANTE — CURSO |

**Relación identificadora:** relación entre una entidad propietaria y su entidad débil.
Se representa con **rombo doble**.

---

### 1.4 Participación

| Tipo | Significado | Representación Chen |
|------|-------------|---------------------|
| **Total** | Toda instancia de la entidad participa en la relación | Línea **doble** |
| **Parcial** | Algunas instancias pueden no participar | Línea simple |

**Regla clave:** una entidad débil SIEMPRE tiene participación total en su relación identificadora.

---

### 1.5 Entidades asociativas

Cuando una relación **M:N tiene atributos propios**, o necesita participar en otras relaciones,
se convierte en una **entidad asociativa** (rectángulo que envuelve al rombo, o rectángulo
conectado al rombo de la relación).

**Señal para identificarlas:** si la pregunta *"¿de qué atributo es esto?"* no tiene una respuesta
clara (no pertenece ni a A ni a B, sino a la combinación A+B), ese atributo vive en una entidad
asociativa.

---

### 1.6 Errores frecuentes — lista de verificación antes de entregar

- [ ] ¿Cada entidad débil tiene rectángulo doble?
- [ ] ¿La relación identificadora tiene rombo doble?
- [ ] ¿El discriminante tiene subrayado discontinuo (Partial Key)?
- [ ] ¿Los atributos derivados tienen óvalo discontinuo?
- [ ] ¿Los atributos multivaluados tienen óvalo doble?
- [ ] ¿Los atributos compuestos tienen sub-óvalos conectados?
- [ ] ¿La participación total está marcada con línea doble?
- [ ] ¿Las entidades asociativas están representadas (no solo como relación M:N)?
- [ ] ¿Todos los atributos están conectados a su entidad o relación?
- [ ] ¿Las cardinalidades (1, N, M) están etiquetadas en cada extremo del rombo?

---

## Parte 2 — Simulacro

> **Condiciones de examen.** Trabaja de forma individual y sin consultar apuntes.
> Tienes **40 minutos** para construir el diagrama E-R completo en draw.io.
> No hay preguntas guía — el análisis depende completamente de ti.

---

### Enunciado — Sistema de gestión de la clínica dental DentPlus

DentPlus opera varias **clínicas** dentales en distintas ciudades. De cada clínica se registra
su nombre, una dirección compuesta por calle, número y ciudad, uno o más teléfonos de contacto
y un correo electrónico institucional.

Cada clínica cuenta con varios **consultorios** de atención. Un consultorio se identifica por
un número dentro de su clínica: el Consultorio 1 de la clínica Bogotá y el Consultorio 1 de
la clínica Cali son instancias distintas. De cada consultorio se registra una descripción, el
equipo disponible (sillón dental, rayos X, ultrasonido, láser — un consultorio puede tener
más de uno) y su estado (disponible, ocupado o en mantenimiento). Un consultorio no puede
existir en el sistema sin pertenecer a una clínica.

Los **dentistas** trabajan en una única clínica. De cada dentista se registra su nombre completo
(primer nombre y apellidos), teléfono, correo electrónico y las especialidades que ejerce:
ortodoncia, endodoncia, periodoncia, estética, entre otras. Un dentista puede tener más de una
especialidad. Puede haber dentistas registrados sin citas asignadas.

Los **pacientes** se registran con su nombre completo (primer nombre y apellidos), fecha de
nacimiento, teléfono y correo electrónico. La edad de cada paciente se calcula automáticamente
a partir de su fecha de nacimiento. Si el paciente tiene alergias conocidas (a anestésicos,
materiales o medicamentos), también se registran — puede tener varias o ninguna.

Cada vez que un paciente acude a la clínica se genera una **cita**, que registra la fecha, la
hora, el motivo de la consulta y el diagnóstico emitido por el dentista (puede no haberse
registrado aún si la cita es futura). Cada cita es atendida por un único dentista y se realiza
en un único consultorio. El costo total de la cita no se almacena: se calcula sumando los
costos de todos los tratamientos realizados.

Los **tratamientos** disponibles en la clínica (limpieza dental, extracción, blanqueamiento,
colocación de brackets, endodoncia, entre otros) tienen un nombre, una descripción, un costo
unitario de referencia y una duración estimada en minutos.

Durante una cita pueden realizarse uno o más tratamientos. Un mismo tratamiento puede
practicarse en muchas citas distintas a lo largo del tiempo. Cada vez que se realiza un
tratamiento dentro de una cita, se registra el precio que se cobró en esa ocasión —que puede
diferir del costo de referencia por descuentos o coberturas de seguro— y las observaciones
clínicas relevantes del dentista.

---

## Entregable del simulacro

Diagrama E-R completo en notación Chen, exportado como `.drawio`, con:
- Todas las entidades (tipo correcto)
- Todos los atributos (tipo correcto, conectados a su entidad)
- Todas las relaciones con cardinalidades y participaciones
- Entidades débiles con relación identificadora
- Entidades asociativas donde corresponda

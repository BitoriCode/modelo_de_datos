# Práctica integradora — Modelo Entidad-Relación
---

## Instrucciones generales

1. El trabajo es **individual o en parejas** (según indicación del profesor).
2. **Lee el escenario completo antes de comenzar a dibujar.**
3. Responde las **preguntas de análisis** en papel o en un documento aparte — son el paso previo obligatorio al diagrama.
4. Construye el diagrama E-R completo en [draw.io](https://app.diagrams.net) usando **notación Chen**.
   - Usa la librería **Entity Relation** del panel de shapes.
5. El diagrama debe incluir:
   - Todas las entidades con su tipo (rectángulo simple = fuerte; rectángulo doble = débil)
   - Todos los atributos con su tipo (óvalo simple, doble, discontinuo, con sub-atributos según corresponda)
   - Todas las relaciones (rombo) con cardinalidades (1:1, 1:N, M:N)
   - Relaciones identificadoras (rombo doble) para entidades débiles
   - Entidades asociativas donde corresponda

---

## Escenario — Sistema de gestión de la red de gimnasios FitLife S.A.

FitLife S.A. es una cadena de gimnasios con presencia en varias ciudades del país. La empresa
gestiona sus sedes de forma centralizada y necesita un sistema que registre toda su información
operativa: las sedes, sus salas, los instructores, las clases, los socios y los planes de membresía.

---

### Sedes

La empresa opera múltiples **sedes** distribuidas en distintas ciudades. De cada sede se
registra un nombre comercial, una dirección completa —formada por calle, número, ciudad y
país—, un teléfono y un correo electrónico de contacto. También se guarda la fecha en que
la sede fue inaugurada.

La **calificación promedio** de cada sede no se ingresa directamente: se obtiene calculando
el promedio de todas las encuestas de satisfacción que completan los socios. Cuando una sede
aún no ha recibido encuestas, este valor no existe.

---

### Salas

Dentro de cada sede hay una o más **salas** de entrenamiento. Cada sala se identifica
mediante un número dentro de su sede: la Sala 1 de la Sede Bogotá y la Sala 1 de la Sede
Medellín son instancias completamente distintas y ese número por sí solo no las diferencia.

De cada sala se registra: un nombre descriptivo (por ejemplo, *Sala de Spinning*), un tipo
de actividad (pesas, cardio, aeróbic, pilates, yoga o funcional), la capacidad máxima de
personas y el estado de operación (activa o en mantenimiento).

**Una sala no puede existir en el sistema sin pertenecer a una sede.**

---

### Instructores

Los **instructores** son el personal técnico del gimnasio. Cada instructor trabaja en una
única sede. De cada instructor se registra su nombre completo (primer nombre y apellidos),
correo electrónico, teléfono de contacto, fecha de contratación y salario.

Un instructor puede tener **varias especialidades** registradas en el sistema (por ejemplo:
yoga, pilates, crossfit, natación, nutrición). Una sede puede tener muchos instructores,
pero cada instructor pertenece a una sola sede. Puede haber instructores registrados que
aún no tengan clases asignadas.

---

### Clases

La sede organiza **clases** grupales: yoga, crossfit, pilates, funcional, stretching, entre
otras. De cada clase se registra: un nombre, una descripción, un nivel de dificultad
(básico, intermedio o avanzado), un horario —compuesto por el día de la semana y las horas
de inicio y fin— y una duración total en minutos.

El número de **cupos disponibles** no se ingresa: se calcula restando el total de inscritos
activos del cupo máximo de la clase.

Cada clase se desarrolla en una sala específica de la sede y es dictada por un único
instructor. Una sala puede no tener clases programadas en un momento dado. Cada clase tiene
exactamente un instructor asignado.

---

### Socios

Los **socios** son los clientes del gimnasio. De cada socio se registra: nombre completo
(primer nombre y apellidos), correo electrónico, uno o más teléfonos de contacto, fecha
de nacimiento y fecha de registro en el sistema.

La **edad** de cada socio se calcula automáticamente a partir de su fecha de nacimiento;
no se almacena como un valor fijo. Un socio puede registrar opcionalmente una foto de
perfil — si no la sube, el campo queda vacío.

---

### Planes de membresía

FitLife ofrece distintos **planes** de membresía. De cada plan se registra un nombre, una
descripción, el precio mensual y la duración en meses.

Según el plan, se registran los **beneficios adicionales incluidos**: un mismo plan puede
incluir varios beneficios (por ejemplo: "acceso_piscina", "entrenador_personal",
"nutricionista"), y un beneficio puede estar disponible en varios planes. El plan "Básico"
solo incluye "acceso_general". Un plan puede existir en el sistema aunque en ese momento
ningún socio lo haya contratado.

---

### Membresías

Cuando un socio contrata un plan, se genera una **membresía** que registra: la fecha de
inicio, el precio realmente pagado (puede diferir del precio base del plan por descuentos
o promociones), el método de pago y el estado actual (activa, vencida, suspendida o
cancelada).

La **fecha de vencimiento** se calcula automáticamente sumando la duración en meses del
plan a la fecha de inicio; no se almacena directamente.

Un mismo socio puede contratar el mismo plan en distintos momentos (por ejemplo, renovar
el plan mensual cada mes). Cada contratación es una instancia de membresía independiente.

---

### Inscripciones a clases

Los socios pueden inscribirse en las clases disponibles. De cada inscripción se registra:
la fecha en que se realizó, el número de asistencias confirmadas hasta ese momento y el
estado de la inscripción (activa, completada o cancelada).

Un socio puede estar inscrito en varias clases al mismo tiempo, y una clase puede tener
muchos socios inscritos.

---

## Datos de ejemplo

Las siguientes tablas muestran una muestra real del sistema. Úsalas para verificar que
tu modelo puede representar esta información sin perder datos ni crear ambigüedades.

### Sedes y salas

| cod_sede | nombre_sede | dirección (calle, número, ciudad, país) | inauguración |
|----------|--------------|-----------------------------------------|--------------|
| S01 | FitLife Centro | Cra. 7 #32-15, Bogotá, Colombia | 2019-03-01 |
| S02 | FitLife Norte | Av. El Poblado 45-80, Medellín, Colombia | 2021-07-15 |

| sed_sede | num_sala | nombre_sala | tipo | capacidad | estado |
|----------|----------|-------------|------|-----------|--------|
| S01 | 1 | Sala de Spinning | cardio | 25 | activa |
| S01 | 2 | Sala de Yoga | yoga | 20 | activa |
| S01 | 3 | Sala Funcional | funcional | 18 | en mantenimiento |
| S02 | 1 | Sala de Pesas | pesas | 30 | activa |
| S02 | 2 | Sala de Aeróbic | aeróbic | 22 | activa |

> La clave de una sala es la combinación **(cod_sede, num_sala)** — el número solo no es suficiente.

---

### Instructores

| cod_instructor | nombre | email | especialidades | cod_sede |
|----------------|--------|-------|----------------|----------|
| INS01 | Carlos Martínez | c.martinez@fitlife.co | yoga, pilates | S01 |
| INS02 | Laura Ramírez | l.ramirez@fitlife.co | crossfit, funcional | S01 |
| INS03 | Diego Herrera | d.herrera@fitlife.co | pesas, funcional, nutrición | S02 |

> INS01 tiene dos especialidades registradas; INS03 tiene tres.

---

### Socios y planes

| cod_socio | nombre | email | teléfonos | nacimiento |
|-----------|--------|-------|-----------|------------|
| SOC01 | Ana Torres | ana@email.com | 3001234567, 6011234567 | 1995-04-12 |
| SOC02 | Luis Gómez | luis@email.com | 3109876543 | 1988-11-30 |
| SOC03 | María Pinto | m.pinto@email.com | 3207654321, 3157891234 | 2001-06-08 |

> SOC01 tiene dos teléfonos registrados; SOC02 tiene uno.

| cod_plan | nombre | precio_mensual | duración | beneficios |
|----------|--------|----------------|----------|------------|
| P01 | Básico | $80.000 | 1 mes | acceso_general |
| P02 | Premium | $150.000 | 1 mes | acceso_general, acceso_piscina, nutricionista |
| P03 | Anual Plus | $90.000 | 12 meses | acceso_general, entrenador_personal |

---

### Membresías

| cod_membresia | socio | plan | fecha_inicio | precio_pagado | método_pago | estado |
|---------------|-------|------|--------------|---------------|-------------|--------|
| MB01 | SOC01 (Ana) | P01 (Básico) | 2026-07-01 | $80.000 | tarjeta | vencida |
| MB02 | SOC01 (Ana) | P02 (Premium) | 2026-08-01 | $130.000 | tarjeta | activa |
| MB03 | SOC02 (Luis) | P03 (Anual Plus) | 2026-01-15 | $90.000 | débito | activa |

> Ana (SOC01) contrató primero el Básico en julio y luego el Premium en agosto.
> Son **dos membresías independientes** del mismo socio — una ya venció y la otra está activa.
> El modelo debe poder representar esto sin perder ninguna de las dos.

---

### Clases e inscripciones

| cod_clase | nombre | nivel | horario | cupo_max | sala | instructor |
|-----------|--------|-------|---------|----------|------|------------|
| C01 | Yoga Matutino | básico | Lunes, 07:00–08:00 | 15 | (S01, 2) | INS01 |
| C02 | Crossfit Intensivo | avanzado | Martes, 06:00–07:00 | 12 | (S01, 1) | INS02 |
| C03 | Yoga Relajación | básico | Jueves, 18:00–19:00 | 15 | (S01, 2) | INS01 |

| cod_inscripcion | socio | clase | fecha_inscripcion | asistencias | estado |
|-----------------|-------|-------|-------------------|-------------|--------|
| I01 | SOC01 (Ana) | C01 (Yoga Mat.) | 2026-08-03 | 3 | activa |
| I02 | SOC02 (Luis) | C01 (Yoga Mat.) | 2026-08-05 | 2 | activa |
| I03 | SOC01 (Ana) | C02 (Crossfit) | 2026-08-03 | 1 | activa |
| I04 | SOC03 (María) | C01 (Yoga Mat.) | 2026-08-06 | 1 | activa |

> Ana (SOC01) está inscrita en **dos clases distintas** al mismo tiempo (C01 y C02).
> La clase C01 tiene **tres socios inscritos** (Ana, Luis y María).
> El instructor INS01 dicta **dos clases distintas** (C01 y C03).

---

## Preguntas de análisis

Responde estas preguntas **antes de abrir draw.io**. Son la base del diseño y representan
la mitad del trabajo intelectual de esta práctica.

---

### Bloque 1 — Entidades

1. Lista todas las entidades que identificas en el escenario. ¿Cuántas hay?
2. Para cada entidad, indica si es **fuerte** o **débil** y justifica tu respuesta.
   - Guía: una entidad es débil si su identificador **depende** del identificador de otra entidad.
3. ¿Qué entidad no puede ser identificada de forma independiente? ¿De cuál entidad depende para
   existir y para ser identificada?
4. En la tabla de salas, la columna `num_sala` tiene el valor `1` en dos filas diferentes.
   ¿Esto es un error o tiene sentido? ¿Cómo afecta el diseño?

---

### Bloque 2 — Atributos

5. Para cada entidad, lista sus atributos e indica el tipo de cada uno:
   - **Simple:** valor único, atómico (ej. email)
   - **Compuesto:** formado por sub-atributos (ej. nombre completo → primer_nombre + apellidos)
   - **Multivaluado:** puede tener varios valores para la misma instancia (ej. teléfonos)
   - **Derivado:** se calcula a partir de otros datos; no se almacena (ej. edad)
   - **Opcional:** puede estar vacío/nulo para algunas instancias

6. ¿Cuál es el atributo **clave** (identificador) de cada entidad fuerte?
7. Para la entidad débil: ¿cuál es el **discriminante** (atributo parcial)? ¿Cómo se forma la clave completa?
8. Los beneficios de PLAN ("acceso_piscina", "entrenador_personal"…) aparecen como una lista en
   la tabla. ¿Qué tipo de atributo es esto? ¿Cómo se representa en el diagrama Chen?

---

### Bloque 3 — Relaciones y cardinalidades

9. Lista todas las relaciones que existen entre entidades, con su cardinalidad (1:1, 1:N o M:N).
10. Para cada relación, indica si la participación de **cada** entidad es **total** o **parcial**
    y justifica. Usa los datos de ejemplo para apoyar tu razonamiento.
    - Guía: participación total = **toda** instancia de esa entidad debe participar en la relación.

11. Analiza la relación entre SEDE e INSTRUCTOR:
    - ¿Puede existir una sede sin instructores? ¿Puede existir un instructor sin sede?
    - ¿Qué cardinalidad y qué participación corresponden a cada lado?

12. Analiza la relación entre SALA y CLASE:
    - ¿Puede existir una sala sin clases? ¿Puede existir una clase sin sala?
    - ¿Qué dice el escenario exactamente sobre esto?

---

### Bloque 4 — Entidades asociativas

13. Identifica todas las relaciones **M:N** del modelo. ¿Cuántas hay?
14. Para cada relación M:N: ¿tiene atributos propios? ¿Esos atributos pertenecen a alguna de las
    entidades que conecta, o solo tienen sentido en el contexto de esa relación?
15. ¿Cuántas entidades asociativas debe tener el modelo? Nómbralas.
16. Para la entidad MEMBRESÍA:
    - ¿Por qué `fecha_vencimiento` es un atributo derivado dentro de MEMBRESÍA y no un atributo
      simple almacenado?
    - ¿Por qué `precio_pagado` no puede ser un atributo de SOCIO ni de PLAN?

---


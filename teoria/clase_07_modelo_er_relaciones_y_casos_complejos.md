# Clase 7 — Modelo E-R: Relaciones, Cardinalidades y Casos Complejos
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**
**Herramienta:** draw.io (app.diagrams.net) · Notación Chen

---

## Repaso — Lo que sabemos

De clase 4:
- **Entidad:** cosa del mundo real con existencia independiente sobre la que guardamos información
- **Atributos:** datos que describen una entidad (simple, compuesto, multivaluado, derivado, nulo)
- **Clave primaria:** atributo que identifica unívocamente a cada instancia

Pregunta que abre esta clase: *¿Cómo conectamos dos entidades entre sí en el diagrama?*

---

## 1. Relaciones

### 1.1 Definición

> Una **relación** es una asociación nombrada entre dos entidades que tiene significado en el dominio del problema.

**Notación Chen:** la relación se representa con un **diamante** (◇) con el nombre en el centro.

```
[ESTUDIANTE] ——◇ INSCRITO_EN ◇—— [CURSO]
```

**Convenciones:**
- Nombre en verbo (infinitivo o voz activa): TRABAJA_EN, TIENE, PERTENECE_A, ATIENDE
- El nombre describe el sentido del vínculo

### 1.2 Cardinalidad

La **cardinalidad** define cuántas instancias de una entidad pueden estar asociadas a instancias de otra.

| Tipo | Descripción | Ejemplo cotidiano |
|------|-------------|-------------------|
| **1:1** | Una instancia de A con exactamente una de B | CIUDADANO — PASAPORTE |
| **1:N** | Una instancia de A con muchas de B; cada B solo con una A | DEPARTAMENTO — EMPLEADO |
| **M:N** | Muchas de A con muchas de B | ESTUDIANTE — CURSO |

**Truco para determinar la cardinalidad:**
> Pregúntate en ambas direcciones:
> - *"¿Cuántos [B] puede tener un solo [A]?"*
> - *"¿Cuántos [A] puede tener un solo [B]?"*

**Diagramas Chen:**

```
1:1    [CIUDADANO] —1——◇ TIENE ◇——1— [PASAPORTE]

1:N    [DEPARTAMENTO] —1——◇ TIENE ◇——N— [EMPLEADO]

M:N    [ESTUDIANTE] —M——◇ INSCRITO_EN ◇——N— [CURSO]
```

### 1.3 Participación

La **participación** indica si **todas** las instancias de una entidad deben participar en la relación.

| Tipo | Cardinalidad mínima | Notación Chen | Significado |
|------|---------------------|---------------|-------------|
| **Total** (obligatoria) | 1 | Línea doble (══) | Toda instancia DEBE participar |
| **Parcial** (opcional) | 0 | Línea simple (——) | Algunas instancias pueden no participar |

**Ejemplo:**
```
[EMPLEADO] ════◇ PERTENECE_A ◇———— [DEPARTAMENTO]
  (total: todo empleado            (parcial: no todos los
   debe tener depto.)               deptos. tienen gerente)
```

**Regla práctica:**
> Si una instancia puede existir SIN participar en la relación → **parcial**.
> Si una instancia NO puede existir sin participar → **total**.

---

## 2. Entidades débiles

### 2.1 ¿Qué problema resuelven?

Imagina las habitaciones de un hotel. La habitación 101 existe en el Marriott, en el Hilton y en cualquier otro hotel. El número "101" por sí solo **no identifica** una habitación específica — necesita saber a qué hotel pertenece.

> Una **entidad débil** es aquella cuya identificación completa depende de otra entidad llamada **entidad propietaria** (o dueña).

### 2.2 Cuatro señales de una entidad débil

1. No puede existir sin estar asociada a otra entidad
2. Su identificación requiere la clave de la entidad propietaria
3. Pierde sentido si la entidad propietaria desaparece
4. Tiene un atributo que la distingue **dentro del grupo** de su propietaria (discriminador)

### 2.3 Componentes y notación

| Elemento | Descripción | Notación Chen |
|----------|-------------|---------------|
| **Entidad débil** | La que no puede identificarse sola | Rectángulo doble `[[NOMBRE]]` |
| **Entidad propietaria** | De quien depende | Rectángulo simple `[NOMBRE]` |
| **Relación identificadora** | Vínculo entre ambas | Diamante doble `◇◇` |
| **Discriminador** (clave parcial) | Atributo que distingue dentro del grupo | Óvalo de línea punteada |
| **Participación desde la débil** | Siempre total | Línea doble (══) |

### 2.4 Ejemplo 1 — HABITACIÓN débil de HOTEL

```
        id_hotel  nombre  dirección
           ⊙        ○        ○
           |        |        |
        [HOTEL] ════◇◇ CONTIENE ◇◇════ [[HABITACIÓN]]
                                            |        |
                                      num_hab ⊙⊙   tipo ○
                                      (discriminador)
```

- **Identificación completa:** `id_hotel + num_hab`
- Si el hotel se elimina del sistema, sus habitaciones también desaparecen

### 2.5 Ejemplo 2 — DEPENDIENTE débil de EMPLEADO

Contexto: una empresa registra familiares de empleados para el seguro médico.
El nombre "Ana García" puede repetirse en muchos grupos familiares.
Lo que identifica a un dependiente es: el empleado al que pertenece + su nombre.

```
[EMPLEADO] ════◇◇ TIENE ◇◇════ [[DEPENDIENTE]]
                                    |              |
                              nombre ⊙⊙     fecha_nacimiento ○
                              (discriminador)
```

- **Identificación completa:** `cod_empleado + nombre_dependiente`

---

## 3. Entidades asociativas

### 3.1 El problema: M:N con atributos propios

Tenemos ESTUDIANTE y CURSO (relación M:N). El sistema también debe guardar la fecha de inscripción y la nota final. Podemos poner esos atributos directamente en el diamante:

```
[ESTUDIANTE] —M——◇ INSCRITO_EN ◇——N— [CURSO]
                        |
                     fecha
                     nota
```

Esto funciona para atributos simples. El problema surge cuando:
- La relación necesita atributos más complejos o una clave propia
- La relación necesita **conectarse con otra entidad** (una relación no puede hacerlo)

> Una relación no puede participar en otra relación. Solo las entidades pueden relacionarse.

### 3.2 La solución: entidad asociativa

> Una **entidad asociativa** nace de promover una relación M:N a entidad. Tiene atributos propios y puede participar en otras relaciones.

**Notación Chen:** diamante dentro de rectángulo `◈`

**Antes (relación con atributos):**
```
[ESTUDIANTE] —M——◇ INSCRITO_EN ◇——N— [CURSO]
                        |
                     fecha, nota
```

**Después (entidad asociativa):**
```
[ESTUDIANTE] —1——◇ realiza ◇——N— [INSCRIPCIÓN] —N——◇ de ◇——1— [CURSO]
                                       |
                               id_inscripcion (PK)
                               fecha_inscripcion
                               nota_final
```

O con notación abreviada:

```
[ESTUDIANTE] ——M—— ◈ INSCRIPCIÓN ◈ ——N—— [CURSO]
                           |
                    id, fecha, nota
```

### 3.3 ¿Cuándo usar entidad asociativa?

| Situación | ¿Usar entidad asociativa? |
|-----------|--------------------------|
| M:N con atributos simples sin necesidad de referenciarlos | Opcional |
| M:N con atributos importantes y necesidad de identificarlos | **Sí** |
| M:N donde la relación debe conectarse con otras entidades | **Sí, obligatorio** |

---

## 4. draw.io — Herramienta para diagramar E-R

### 4.1 Acceso

URL: **app.diagrams.net** (web, sin instalación ni cuenta)

Pasos:
1. Clic en "Create New Diagram" → Blank → Create
2. En el panel izquierdo, buscar **"Entity"** en la barra de búsqueda
3. Aparece la librería **"Entity Relation"** con todas las figuras Chen

### 4.2 Figuras Chen en draw.io

| Concepto E-R | Shape en draw.io | Visual |
|---|---|---|
| Entidad fuerte | `Entity` | Rectángulo simple |
| Entidad débil | `Weak Entity` | Rectángulo de línea doble |
| Atributo | `Attribute` | Óvalo simple |
| Atributo clave (PK) | `Key Attribute` | Óvalo con texto subrayado |
| Discriminador | `Partial Key` | Óvalo de línea punteada |
| Relación | `Relationship` | Diamante simple |
| Relación identificadora | `Identifying Relationship` | Diamante de línea doble |

### 4.3 Participación en draw.io

- **Participación total:** usar conector de línea doble, o anotar `(1,N)` sobre la línea
- **Participación parcial:** conector de línea simple estándar

---

## Resumen visual: figuras Chen y cuándo usarlas

| Figura | Cuándo |
|--------|--------|
| Rectángulo simple | Entidad fuerte (tiene PK propia) |
| Rectángulo doble | Entidad débil (necesita propietaria para identificarse) |
| Óvalo simple | Atributo regular |
| Óvalo subrayado | Clave primaria |
| Óvalo punteado | Discriminador de entidad débil |
| Diamante simple | Relación regular |
| Diamante doble | Relación identificadora (débil ↔ propietaria) |
| Diamante en rectángulo | Entidad asociativa |
| Línea simple (——) | Participación parcial |
| Línea doble (══) | Participación total |

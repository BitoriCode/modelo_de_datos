# PRÁCTICA CLASE 5 — Repaso Evento I
**Materia:** Modelo de Datos | **Fecha:** 4 de agosto | **Modalidad:** Individual, en papel

> Responde con tus propias palabras. En el Evento I real se evalúa comprensión, no memorización literal.

---

## EJERCICIO 1 — Selección múltiple (8 preguntas)

Encierra en un círculo la letra de la respuesta correcta.

---

**1.** ¿Cuál de las siguientes situaciones describe mejor el problema de **inconsistencia** en un sistema de archivos planos?

- a) El archivo de Excel no puede ser abierto por dos personas al mismo tiempo
- b) El nombre del cliente se actualiza en el archivo de facturación pero no en el archivo de envíos
- c) El archivo .csv no tiene contraseña y cualquier empleado puede verlo
- d) El archivo de inventario tiene miles de filas y se vuelve lento de procesar

---

**2.** ¿Cuál de las siguientes afirmaciones sobre ACID es **incorrecta**?

- a) Atomicidad garantiza que una transacción se completa en su totalidad o no se ejecuta
- b) Consistencia significa que la BD pasa de un estado válido a otro estado válido
- c) Aislamiento asegura que múltiples transacciones simultáneas no interfieren entre sí
- d) Durabilidad garantiza que dos transacciones no pueden ejecutarse al mismo tiempo

---

**3.** En la arquitectura ANSI/SPARC, ¿en qué nivel se define la vista `mi_historial_academico` que solo muestra las notas del estudiante que inició sesión?

- a) Nivel interno
- b) Nivel conceptual
- c) Nivel externo
- d) Nivel físico

---

**4.** Un diseñador de bases de datos recibe el siguiente requerimiento: *"El sistema debe guardar las certificaciones de idioma de los candidatos; cada candidato puede tener entre 0 y 5 certificaciones"*. ¿Qué tipo de atributo es `certificaciones`?

- a) Simple
- b) Compuesto
- c) Derivado
- d) Multivaluado

---

**5.** ¿Cuál de las siguientes opciones describe mejor el **principio de mínimo privilegio**?

- a) El DBA debe conocer las contraseñas de todos los usuarios del sistema
- b) Los usuarios solo deben tener los permisos estrictamente necesarios para cumplir su función
- c) El acceso a la BD debe estar restringido únicamente al DBA y al desarrollador principal
- d) El sistema debe permitir que solo un usuario esté conectado a la vez

---

**6.** Una empresa de comercio electrónico necesita almacenar millones de sesiones de usuario activas con respuesta en menos de 1 milisegundo. ¿Qué tipo de base de datos es más adecuado?

- a) Base de datos relacional (PostgreSQL)
- b) Base de datos documental (MongoDB)
- c) Base de datos clave-valor (Redis)
- d) Base de datos de grafos (Neo4j)

---

**7.** ¿Cuál de las siguientes es la diferencia correcta entre **autenticación** y **autorización**?

- a) Autenticación define qué puede hacer el usuario; autorización verifica quién es
- b) Autenticación verifica la identidad del usuario; autorización define qué puede hacer
- c) Ambas son lo mismo; son sinónimos en seguridad de bases de datos
- d) Autenticación es responsabilidad del desarrollador; autorización es del DBA

---

**8.** Un arquitecto de datos afirma: *"Puedo cambiar el esquema de particionado de las tablas en disco sin modificar ninguna consulta SQL ni ninguna tabla"*. ¿A qué tipo de independencia se refiere?

- a) Independencia lógica
- b) Independencia conceptual
- c) Independencia física
- d) Independencia de datos externa

---

## EJERCICIO 2 — Clasifica los elementos (Nivel ANSI/SPARC)

Escribe el nivel ANSI/SPARC correcto en la columna derecha: **Externo**, **Conceptual** o **Interno**.

| Elemento del sistema | Nivel ANSI/SPARC |
|---------------------|-----------------|
| La restricción `NOT NULL` sobre la columna `nombre` en la tabla `ESTUDIANTE` | |
| El archivo físico `pg_data/base/16384/1247` en el servidor de PostgreSQL | |
| El índice B-Tree creado sobre la columna `correo` para acelerar búsquedas | |
| La vista `reporte_ventas_region` que consulta el gerente de ventas | |
| La definición de la clave foránea entre `MATRICULA` y `ESTUDIANTE` | |
| El formulario web que usa el estudiante para ver sus notas | |
| La estrategia de almacenamiento en páginas de 8KB del motor PostgreSQL | |
| La tabla `PRODUCTO` con sus columnas `id`, `nombre`, `precio`, `stock` | |

---

## EJERCICIO 3 — Clasifica los atributos

Dada la entidad `MÉDICO` de un sistema hospitalario, clasifica cada atributo según su tipo: **Simple**, **Compuesto**, **Multivaluado**, **Derivado** o **Nulo (opcional)**.

Además, para los atributos **multivaluados** indica cómo se implementarían en SQL (una oración).  
Para los atributos **derivados** indica por qué no se almacenan.

| Atributo | Tipo | Nota de implementación (solo para multivaluado y derivado) |
|----------|------|-----------------------------------------------------------|
| `id_medico` (único, no cambia) | | |
| `nombre_completo` (primer nombre + segundo nombre + apellido) | | |
| `especialidades` (un médico puede tener varias) | | |
| `años_de_experiencia` (calculado desde `fecha_de_grado`) | | |
| `numero_de_consultorio` (solo si tiene consultorio asignado) | | |
| `correos_electronicos` (puede tener correo personal e institucional) | | |
| `fecha_de_grado` | | |
| `tarifa_por_consulta` | | |

---

## EJERCICIO 4 — Caso de análisis (desarrollo)

**Escenario:** El Hospital Central necesita un sistema de información para gestionar sus operaciones. El gerente de IT te explica lo siguiente:

> "Tenemos médicos, cada uno con varias especialidades. Los pacientes llegan, se registran y se les asigna una cita con un médico disponible. Cada cita tiene fecha, hora y resultado (diagnóstico). Los pacientes pueden tener múltiples citas a lo largo del tiempo. Necesitamos también registrar los medicamentos recetados en cada cita — un médico puede recetar varios medicamentos en una misma cita."

Responde las siguientes preguntas:

**4.1** Identifica al menos **4 entidades** del sistema. Justifica brevemente por qué cada una es una entidad y no un atributo.

| Entidad | Justificación |
|---------|--------------|
| | |
| | |
| | |
| | |

**4.2** Para la entidad `PACIENTE`, propón al menos **5 atributos** y clasifica cada uno según su tipo (simple, compuesto, multivaluado, derivado, nulo).

| Atributo | Tipo |
|----------|------|
| | |
| | |
| | |
| | |
| | |

**4.3** ¿Cuál de las entidades identificadas podría ser una **entidad débil**? Explica por qué.

_Tu respuesta:_

---

**4.4** El hospital recibe 8.000 citas por día y al final de cada trimestre el departamento de análisis genera reportes de morbilidad (enfermedades más frecuentes, médicos con más citas, etc.). Responde:

- ¿Qué tipo de carga de trabajo es el registro diario de citas? ¿Por qué?
- ¿Qué tipo de carga de trabajo son los reportes trimestrales? ¿Por qué?
- ¿Qué tipo de BD (relacional, documental, clave-valor, columnar, grafos) recomendarías para cada carga? Justifica.

_Tu respuesta:_

---

## EJERCICIO 5 — Identifica errores de diseño

El siguiente fragmento describe un diseño propuesto por un estudiante para un sistema de biblioteca. Identifica **todos los errores** que encuentres y explica cómo corregirlos.

**Diseño propuesto:**

```
Entidad: LIBRO
Atributos:
  - id_libro (simple)
  - titulo (simple)
  - autor1 (simple)   ← el libro puede tener hasta 3 autores
  - autor2 (simple)
  - autor3 (simple)
  - generos (simple)  ← el libro puede pertenecer a varios géneros
  - edad_del_libro (simple) ← calculada desde año_publicacion
  - año_publicacion (simple)
  - resumen (simple)
  - disponible (simple) ← TRUE si hay al menos 1 ejemplar en stock
```

**Instrucciones:**  
a) Identifica cada error y el tipo de problema que representa.  
b) Propón el diseño corregido con los tipos de atributo correctos para cada caso.

| Atributo con error | Tipo de problema | Corrección |
|--------------------|-----------------|------------|
| | | |
| | | |
| | | |

---

## EJERCICIO 6 — Integrador (caso libre)

**Escenario:** Una plataforma de streaming de música (similar a Spotify) necesita gestionar artistas, álbumes, canciones y usuarios. Cada usuario puede tener varias listas de reproducción. Cada canción puede pertenecer a varios géneros. Los artistas pueden colaborar en canciones (una canción puede tener más de un artista).

**6.1** Lista al menos **5 entidades**. Para cada una, indica si es fuerte o débil y da un breve argumento.

| Entidad | ¿Fuerte o débil? | Argumento |
|---------|-----------------|-----------|
| | | |
| | | |
| | | |
| | | |
| | | |

**6.2** Para la entidad `CANCION`, propón los atributos e indica el tipo de cada uno. Incluye al menos un atributo de cada tipo (simple, compuesto, multivaluado, derivado).

| Atributo | Tipo | Nota |
|----------|------|------|
| | | |
| | | |
| | | |
| | | |

**6.3** El sistema necesita recomendar canciones a los usuarios en menos de 50 milisegundos, basándose en conexiones entre usuarios y géneros favoritos. ¿Qué tipo de base de datos elegirías para el **motor de recomendaciones**? Justifica en 2-3 oraciones.

_Tu respuesta:_

---

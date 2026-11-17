-- ============================================================
--  CURSO: MODELOS DE DATOS
--  Clase 4 — 30 de julio | CASOS DE ANÁLISIS (no hay SQL)
--  Tema: Modelo Entidad-Relación — introducción (entidades y atributos)
-- ============================================================


-- ============================================================
--  CASO 1 — IDENTIFICAR ENTIDADES Y ATRIBUTOS
--  Dado un enunciado, identificar las entidades y sus atributos.
-- ============================================================

/*
Lee cada enunciado e identifica:
  a) Las entidades presentes
  b) Los atributos de cada entidad
  c) El tipo de cada atributo (simple / compuesto / multivaluado / derivado)
  d) La clave primaria más adecuada

ENUNCIADO A — Sistema de biblioteca:
  Una biblioteca gestiona libros y socios. De cada libro se conoce
  su ISBN (único), título, año de publicación y número de páginas.
  Un libro puede tener varios autores. De cada socio se guarda
  número de carné (único), nombre completo, dirección (calle y ciudad),
  fecha de nacimiento y teléfonos de contacto (puede tener hasta 2).
  También se calcula automáticamente si el socio es mayor o menor de edad.

ENUNCIADO B — Sistema de empleados:
  Una empresa registra a sus empleados. Cada empleado tiene un código
  interno (único), nombre, apellido, fecha de ingreso y salario base.
  Los empleados pueden tener uno o más títulos académicos.
  También se quiere conocer los años de antigüedad en la empresa.
  Algunos empleados tienen número de extensión telefónica (no todos).

ENUNCIADO C — Sistema de reservas de hotel:
  Un hotel quiere registrar sus habitaciones y huéspedes.
  Cada habitación tiene un número (único dentro del hotel), tipo
  (sencilla, doble, suite) y tarifa por noche.
  De cada huésped se necesita: número de documento (único), nombre,
  nacionalidad, correo electrónico y teléfono.
  La tarifa total de la estadía se puede calcular a partir de la
  tarifa por noche y el número de noches.
*/

-- RESPUESTAS ESPERADAS — ENUNCIADO A:

-- Entidad: LIBRO
--   ISBN            → simple, PK
--   título          → simple
--   año_publicación → simple
--   num_páginas     → simple
--   autor           → MULTIVALUADO (varios autores) → ((autor))

-- Entidad: SOCIO
--   num_carné       → simple, PK
--   nombre_completo → simple (o compuesto si se separa nombre/apellido)
--   dirección       → COMPUESTO → calle + ciudad
--   fecha_nacimiento→ simple
--   teléfono        → MULTIVALUADO (hasta 2) → ((teléfono))
--   es_mayor_edad   → DERIVADO de fecha_nacimiento → (- es_mayor_edad -)


-- RESPUESTAS ESPERADAS — ENUNCIADO B:

-- Entidad: EMPLEADO
--   codigo_empleado    → simple, PK (artificial/surrogate)
--   nombre             → simple
--   apellido           → simple
--   fecha_ingreso      → simple
--   salario_base       → simple
--   titulo_academico   → MULTIVALUADO (uno o más) → ((titulo_academico))
--   años_antigüedad    → DERIVADO de fecha_ingreso → (- años_antigüedad -)
--   extension_telefono → simple, puede ser NULL (no todos lo tienen)


-- RESPUESTAS ESPERADAS — ENUNCIADO C:

-- Entidad: HABITACION
--   num_habitacion  → simple, PK
--   tipo            → simple
--   tarifa_noche    → simple

-- Entidad: HUESPED
--   num_documento   → simple, PK
--   nombre          → simple
--   nacionalidad    → simple
--   correo          → simple (o multivaluado si puede tener varios)
--   teléfono        → simple

-- NOTA: tarifa_total → es un atributo DERIVADO de RESERVA (no de las entidades base)
--   Se verá cuando modelemos relaciones en la próxima clase.


-- ============================================================
--  CASO 2 — ELEGIR LA CLAVE PRIMARIA CORRECTA
--  Para cada entidad, evalúa las opciones de clave primaria.
-- ============================================================

/*
Para cada entidad, indica cuál de las opciones es mejor clave primaria y por qué.
Considera: unicidad, estabilidad, nulabilidad y minimalidad.

ENTIDAD: ESTUDIANTE
  Opción 1: nombre_completo
  Opción 2: número_documento (cédula o pasaporte)
  Opción 3: correo_institucional
  Opción 4: id_estudiante (número generado por el sistema)

ENTIDAD: PRODUCTO
  Opción 1: nombre_producto
  Opción 2: código_barras
  Opción 3: id_producto (generado por el sistema)
  Opción 4: precio

ENTIDAD: EMPLEADO
  Opción 1: nombre + apellido (combinados)
  Opción 2: número_seguridad_social
  Opción 3: correo_corporativo
  Opción 4: codigo_empleado (generado por el sistema)
*/

-- ANÁLISIS ESPERADO — ESTUDIANTE:
--   nombre_completo       ❌ No es único (dos "Ana García"), no es estable (cambio de apellido)
--   número_documento      ⚠️  Candidata válida, pero puede cambiar (pasaporte vence, cambio de país)
--   correo_institucional  ⚠️  Candidata válida, pero cambia si se reasigna o caduca al graduarse
--   id_estudiante         ✅ Mejor opción: generado por el sistema, nunca cambia, siempre existe

-- ANÁLISIS ESPERADO — PRODUCTO:
--   nombre_producto  ❌ No es único (varios "Agua Mineral 500ml" de diferentes marcas)
--   código_barras    ⚠️  Candidata, pero puede cambiar si cambia el proveedor o el empaque
--   id_producto      ✅ Mejor opción: artificial, estable, único
--   precio           ❌ No es único, cambia constantemente

-- ANÁLISIS ESPERADO — EMPLEADO:
--   nombre + apellido        ❌ No es único, puede haber homónimos
--   número_seguridad_social  ⚠️  Natural, único, estable — pero solo aplica en algunos países
--   correo_corporativo       ⚠️  Cambia si el empleado cambia de área o es reasignado
--   codigo_empleado          ✅ Mejor opción: artificial, controlado, nunca cambia


-- ============================================================
--  CASO 3 — ATRIBUTO vs ENTIDAD
--  Decide si el concepto debe ser atributo o entidad independiente.
-- ============================================================

/*
Para cada situación, decide si el concepto destacado en MAYÚSCULAS
debe modelarse como un ATRIBUTO de la entidad indicada, o como una
ENTIDAD separada. Justifica tu respuesta.

Situación 1:
  Entidad: EMPLEADO
  Concepto: DEPARTAMENTO
  Contexto A: Solo necesitamos saber el nombre del departamento al que pertenece el empleado.
  Contexto B: El sistema también gestiona presupuesto, jefe y ubicación de cada departamento.

Situación 2:
  Entidad: LIBRO
  Concepto: AUTOR
  Contexto A: Solo registramos el nombre del autor como dato informativo.
  Contexto B: El sistema también gestiona la página web del autor, su biografía y sus otros libros.

Situación 3:
  Entidad: PEDIDO
  Concepto: DIRECCIÓN DE ENTREGA
  Contexto A: La dirección es un texto libre que solo se usa para este pedido.
  Contexto B: El cliente tiene múltiples direcciones guardadas y puede elegir una al hacer el pedido.
*/

-- RESPUESTAS ESPERADAS:

-- Situación 1:
--   Contexto A: DEPARTAMENTO = atributo simple de EMPLEADO (solo el nombre)
--   Contexto B: DEPARTAMENTO = entidad independiente (tiene sus propios datos)

-- Situación 2:
--   Contexto A: AUTOR = atributo (simple o multivaluado si hay varios)
--   Contexto B: AUTOR = entidad independiente (tiene datos propios y relaciones)

-- Situación 3:
--   Contexto A: DIRECCIÓN = atributo compuesto de PEDIDO
--   Contexto B: DIRECCIÓN = entidad independiente asociada al CLIENTE

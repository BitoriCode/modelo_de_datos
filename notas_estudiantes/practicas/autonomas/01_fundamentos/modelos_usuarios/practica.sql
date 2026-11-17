-- ============================================================
--  CURSO: MODELOS DE DATOS
--  Clase 3 — 18 de febrero | CASOS DE ANÁLISIS (no hay SQL)
--  Tema: Definición de modelo de datos + Usuarios de una BD
-- ============================================================

-- ============================================================
--  CASO 1 — DEFINICIÓN DE MODELO: SISTEMA DE PEDIDOS
--  Identificar los 3 componentes del modelo y detectar errores de diseño.
-- ============================================================

/*
Un estudiante diseñó el siguiente modelo para un sistema de pedidos:

  ESTRUCTURA:
    Producto (nombre, precio)
    Cliente  (nombre, dirección)
    Pedido   (producto, cliente, cantidad, fecha)

  RESTRICCIONES: ninguna definida

  OPERACIONES: crear pedido, ver pedidos del cliente
*/

-- PREGUNTA 1: ¿Qué restricciones críticas faltan?
-- Esperado:
--   · Un pedido sin producto o cliente debería ser imposible
--   · La cantidad debe ser mayor que 0
--   · El precio no puede ser negativo

-- PREGUNTA 2: ¿Hay un problema en la estructura?
-- Esperado:
--   · "producto" y "cliente" en Pedido guardan texto, no referencias.
--     Si cambia el nombre del producto, el pedido queda con datos incorrectos.
--     → Deben ser claves foráneas al id del producto/cliente.

-- PREGUNTA 3: ¿Qué nivel de abstracción muestra este modelo?
-- Esperado: es un modelo LÓGICO incompleto (habla de tablas pero sin tipos ni claves).

-- PREGUNTA 4: ¿Qué operaciones faltan para un sistema de pedidos real?
-- Esperado: actualizar estado (pendiente/enviado/entregado), cancelar pedido,
--           calcular total (precio × cantidad), listar pedidos por fecha.


-- ============================================================
--  CASO 2 — USUARIOS Y CONTROL DE ACCESO: CLÍNICA VETERINARIA
--  Identificar tipos de usuario y permisos.
-- ============================================================

/*
Una clínica veterinaria tiene estas tablas: mascotas, dueños, consultas, medicamentos.

Personas que interactúan con el sistema:

  A) Sofía — recepcionista. Registra nuevos dueños y mascotas. Agenda consultas.
     No toca diagnósticos ni facturación.

  B) Dr. Ramírez — veterinario. Registra diagnóstico y tratamiento de cada consulta.
     Consulta historial médico. No ve datos de facturación.

  C) Carlos — desarrollador TI. Construyó y mantiene la app web. Accede al
     esquema completo para ajustes y corrección de errores.

  D) Valentina — admin de sistemas. Se encarga del servidor PostgreSQL:
     backups nocturnos, crea usuarios, monitorea rendimiento.
*/

-- PREGUNTA 1: ¿A qué tipo de usuario corresponde cada persona?
-- (DBA / Diseñador / Desarrollador / Usuario final)
-- Esperado:
--   A) Sofía       → Usuario final (paramétrico)
--   B) Dr. Ramírez → Usuario final (especializado)
--   C) Carlos      → Desarrollador
--   D) Valentina   → DBA

-- PREGUNTA 2: ¿Qué permisos necesita cada persona sobre la tabla "consultas"?
-- (SELECT / INSERT / UPDATE / DELETE / ninguno)
-- Esperado:
--   A) Sofía:       SELECT, INSERT (agendar)
--   B) Dr. Ramírez: SELECT, UPDATE (agregar diagnóstico)
--   C) Carlos:      SELECT, INSERT, UPDATE, DELETE
--   D) Valentina:   ALL (o ninguno sobre datos — opera el servidor)

-- PREGUNTA 3: ¿Se viola el principio de mínimo privilegio en estos casos?
--   i)  Sofía tiene permiso DELETE sobre la tabla "consultas"
--   ii) El Dr. Ramírez puede modificar precios en la tabla "medicamentos"
-- Esperado: ambos violan el principio. Sofía podría borrar consultas accidentalmente;
--           el Dr. podría alterar precios, lo que está fuera de su responsabilidad.


-- ============================================================
--  CASO 3 — DEBATE RÁPIDO (5 minutos, para el cierre)
-- ============================================================

/*
Pedro (desarrollador): "Para simplificar, démosle acceso completo a todos.
Así nadie queda bloqueado cuando necesita algo urgente."

Laura (DBA): "No. Cada usuario solo debe tener los permisos que necesita."

¿Quién tiene razón? Argumenta con al menos 3 razones concretas.
*/

-- Esperado (el estudiante puede dar otras válidas):
--   1. Error accidental: con acceso total, un bug puede borrar datos críticos.
--   2. Seguridad externa: una cuenta hackeada expone todo el sistema.
--   3. Cumplimiento legal: GDPR / Ley 1581 exigen control de acceso por principio.

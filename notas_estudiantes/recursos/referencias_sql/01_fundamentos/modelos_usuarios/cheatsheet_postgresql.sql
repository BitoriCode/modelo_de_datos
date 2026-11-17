-- ============================================================
--  CLASE 3 — REFERENCIA CONCEPTUAL: Modelo de datos + Usuarios
-- ============================================================


-- ── MODELO DE DATOS ─────────────────────────────────────────

-- Representación abstracta que describe:
--   · Estructura   → qué datos existen y cómo se organizan
--   · Restricciones → qué reglas deben cumplir los datos
--   · Operaciones  → qué se puede hacer (SELECT, INSERT, UPDATE, DELETE)


-- ── 3 NIVELES DE ABSTRACCIÓN ────────────────────────────────

-- CONCEPTUAL → qué existe en el negocio
--   Herramienta: Diagrama E-R
--   No habla de tablas ni tipos de dato.
--   Lo entiende el cliente y el técnico.

-- LÓGICO → cómo se organiza
--   Herramienta: modelo relacional (tablas, columnas, claves)
--   Independiente del DBMS.

-- FÍSICO → cómo se implementa
--   Herramienta: SQL DDL en PostgreSQL
--   Específico del DBMS: tipos exactos, restricciones, índices.


-- ── 4 TIPOS DE USUARIO ──────────────────────────────────────

-- DBA (Administrador)
--   Gestiona el sistema completo: usuarios, backups, rendimiento, seguridad.
--   Accede a los 3 niveles ANSI/SPARC.

-- DISEÑADOR
--   Define la estructura (diagrama E-R → modelo relacional → normalización).
--   Trabaja principalmente en el nivel conceptual.

-- DESARROLLADOR
--   Construye la aplicación y escribe las consultas SQL.
--   Trabaja en el nivel conceptual y externo.

-- USUARIO FINAL
--   Usa la aplicación sin necesitar SQL.
--   Solo ve el nivel externo.
--   Paramétrico (cajero) / Especializado (analista) / Independiente.


-- ── CONTROL DE ACCESO ───────────────────────────────────────

-- AUTENTICACIÓN → ¿quién eres?        (usuario + contraseña)
-- AUTORIZACIÓN  → ¿qué puedes hacer?  (permisos sobre objetos)

-- PERMISOS BÁSICOS (DCL):
--   SELECT  → leer datos
--   INSERT  → agregar registros
--   UPDATE  → modificar registros
--   DELETE  → eliminar registros
--   ALL PRIVILEGES → todos los permisos

-- GRANT  nombre_permiso ON tabla TO usuario;  -- dar permiso
-- REVOKE nombre_permiso ON tabla FROM usuario; -- quitar permiso
-- (se estudian en detalle en semana 14)


-- ── ROLES ───────────────────────────────────────────────────

-- Conjunto de permisos agrupados con un nombre.
-- Se asigna a múltiples usuarios. Si cambia la política → modificar 1 rol.


-- ── PRINCIPIO DE MÍNIMO PRIVILEGIO ──────────────────────────

-- Cada usuario solo debe tener los permisos que necesita. Nada más.
-- Razones: limitar errores, contener hackeos, cumplir regulaciones, facilitar auditoría.


-- ── GLOSARIO ────────────────────────────────────────────────

-- Modelo         → representación abstracta de la realidad para un propósito
-- Abstracción    → ignorar detalles irrelevantes; quedarse con lo importante
-- Entidad        → objeto del mundo real sobre el que se guarda información
-- Restricción    → regla que los datos deben cumplir siempre
-- DBA            → Database Administrator. Gestiona el sistema completo.
-- Autenticación  → verificar quién es el usuario
-- Autorización   → verificar qué puede hacer el usuario
-- Rol            → conjunto de permisos agrupados con un nombre
-- GRANT          → comando SQL para otorgar permisos
-- REVOKE         → comando SQL para revocar permisos
-- RLS            → Row-Level Security: permisos a nivel de fila individual

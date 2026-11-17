-- ============================================================
--  CLASE 4 — REFERENCIA: Modelo Entidad-Relación — Notación y conceptos
-- ============================================================
--  NOTA: No hay SQL en esta clase. Este archivo documenta la
--  notación gráfica de Chen y los conceptos clave del Modelo E-R.
-- ============================================================


-- ── PROCESO DE DISEÑO ────────────────────────────────────────

--  Mundo real
--      ↓ (análisis de requisitos)
--  Diagrama E-R             ← Clase 4 y 5
--      ↓ (transformación)
--  Modelo Relacional (tablas)   ← Semana 6
--      ↓ (implementación)
--  SQL en PostgreSQL            ← Semanas 7-8


-- ── NOTACIÓN DE CHEN ─────────────────────────────────────────

--  SÍMBOLO              REPRESENTA           EJEMPLO
--  ─────────────────────────────────────────────────────────────
--  ┌─────────┐
--  │ ENTIDAD │          Entidad fuerte        ESTUDIANTE, CURSO
--  └─────────┘
--
--  ╔═════════╗
--  ║ ENTIDAD ║          Entidad débil         DEPENDIENTE (de EMPLEADO)
--  ╚═════════╝
--
--  ( atributo )         Atributo simple       ( nombre ), ( edad )
--
--  ( sub1 )─( compuesto )─( sub2 )
--                       Atributo compuesto    ( dirección ) → calle, ciudad
--
--  (( atributo ))       Atributo multivaluado (( teléfono )), (( correo ))
--
--  (- atributo -)       Atributo derivado     (- edad -), (- promedio -)
--
--  ( atributo )         Atributo clave (PK)   subrayado en el diagrama
--   ──────────
--
--  ◇ nombre ◇           Relación              ◇ INSCRIBE ◇
--
--  ◈ nombre ◈           Relación identificante (para entidad débil)


-- ── ENTIDADES ────────────────────────────────────────────────

--  Definición:
--    Cosa del mundo real con existencia independiente sobre la
--    cual queremos almacenar información.

--  Tipo vs. ocurrencia:
--    Tipo (clase):   ESTUDIANTE   — definición abstracta
--    Ocurrencia:     Ana García   — instancia concreta

--  Entidad fuerte:   tiene su propia clave. Ej: ESTUDIANTE, PRODUCTO
--  Entidad débil:    depende de otra para existir. Ej: DEPENDIENTE (de EMPLEADO)
--                    (se verá con detalle en clase 5)


-- ── TIPOS DE ATRIBUTOS ───────────────────────────────────────

--  TIPO              NOTACIÓN        EJEMPLO             NOTA SQL
--  ─────────────────────────────────────────────────────────────────
--  Simple            ( attr )        ( nombre )          Columna directa
--  Compuesto         sub-óvalos      ( dirección )       Columnas separadas
--  Multivaluado      (( attr ))      (( teléfono ))      → Tabla separada
--  Derivado          (- attr -)      (- edad -)          → No se almacena
--  Null              cualquiera      ( extensión )       NULL en SQL


-- ── CLAVES ───────────────────────────────────────────────────

--  TIPO                  DESCRIPCIÓN
--  ─────────────────────────────────────────────────────────────────
--  Superclave            Cualquier conjunto que identifica unívocamente
--                        Puede ser redundante. Ej: {id, nombre}
--
--  Clave candidata       Superclave mínima. Sin atributos redundantes.
--                        Ej en ESTUDIANTE: id_estudiante, número_documento
--
--  Clave primaria (PK)   Clave candidata elegida por el diseñador.
--                        Se subraya en la notación de Chen.
--                        Solo puede haber UNA por entidad.
--
--  Clave artificial      Generada por el sistema (SERIAL, UUID).
--  (surrogate key)       Sin significado en el mundo real. Preferida
--                        en la práctica por su estabilidad.
--
--  Clave natural         Existe en el mundo real y es única.
--                        Ej: ISBN de un libro, código de barras.


-- ── REGLAS DE UNA BUENA CLAVE PRIMARIA ──────────────────────

--  1. ÚNICA:       No puede repetirse entre ocurrencias de la entidad
--  2. NO NULA:     Nunca puede ser NULL
--  3. ESTABLE:     No debe cambiar con el tiempo
--  4. MÍNIMA:      Usar el menor número de atributos posible


-- ── ATRIBUTO vs. ENTIDAD — REGLA DE ORO ─────────────────────

--  ¿Cuándo un concepto debe ser ATRIBUTO?
--    · Solo lo usamos como dato informativo
--    · No tiene atributos propios relevantes para el sistema
--    · No se relaciona con otras entidades
--    Ej: carrera como string dentro de ESTUDIANTE
--
--  ¿Cuándo debe ser ENTIDAD independiente?
--    · Tiene sus propios atributos (código, nombre, descripción...)
--    · Se relaciona con múltiples entidades
--    · Puede tener muchas ocurrencias que se comparten
--    Ej: CARRERA si también gestiona pensum, créditos, facultad


-- ── EJEMPLO COMPLETO — ENTIDAD ESTUDIANTE ───────────────────

--  Atributos:
--    numero_documento  → simple, PK (subrayado)
--    nombre            → simple (o compuesto: primer_nombre + apellido)
--    fecha_nacimiento  → simple
--    carrera           → simple
--    semestre          → simple
--    correo            → multivaluado ((correo))
--    edad              → derivado (- edad -) = calculado de fecha_nacimiento

--  Diagrama textual:
--
--  (- edad -)  ( numero_doc )  ( nombre )  ( fecha_nac )
--                    |              |            |
--              ┌──────────────────────────────────────┐
--              │            ESTUDIANTE               │
--              └──────────────────────────────────────┘
--                    |          |           |
--               ( carrera ) ( semestre ) (( correo ))


-- ── PRÓXIMA CLASE (Clase 5) ──────────────────────────────────

--  Relaciones entre entidades
--  Cardinalidades: 1:1, 1:N, M:N
--  Participación: total vs parcial
--  Entidades débiles y relaciones identificantes
--  Entidades asociativas (relaciones con atributos)

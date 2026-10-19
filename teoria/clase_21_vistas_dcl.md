# Clase 21 — Vistas (`CREATE VIEW`) + Usuarios y privilegios (DCL)
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**
**Herramienta:** PostgreSQL + pgAdmin

---

## Base de datos de la clase — StaffHub

```
DEPARTAMENTO (id_departamento, nombre, ciudad, presupuesto_anual)
EMPLEADO     (id_empleado, nombre, email, fecha_ingreso, salario_cop,
              calificacion NUMERIC(3,1), id_departamento FK)
CARGO        (id_empleado FK, titulo, nivel: 'junior' | 'senior' | 'lead')
```

---

## 1. Vistas — `CREATE VIEW`

### 1.1 ¿Qué es una vista?

Una **vista** es una consulta `SELECT` guardada con un nombre en la base de datos. Se comporta exactamente como una tabla: se puede consultar, filtrar, ordenar y unir con otras tablas o vistas. La diferencia clave es que **no almacena datos** — cada vez que la consultas, PostgreSQL ejecuta la consulta interna y te devuelve el resultado actualizado.

```
Tabla física → almacena datos en disco
Vista        → almacena solo la definición (el SELECT)
               los datos vienen de las tablas base, siempre frescos
```

**Casos de uso principales:**

| Uso | Descripción |
|-----|-------------|
| **Reutilización** | Guardar consultas complejas (con JOINs, funciones) que se usan frecuentemente |
| **Seguridad** | Ocultar columnas sensibles (email, salario, contraseñas) exponiendo solo lo necesario |
| **Simplicidad** | Dar una interfaz simple sobre un esquema complejo |
| **Compatibilidad** | Mantener una "vista estable" aunque el esquema interno cambie |

### 1.2 Sintaxis básica

```sql
CREATE VIEW nombre_vista AS
SELECT col1, col2, ...
FROM   tabla
[JOIN  ...]
[WHERE condición];
```

```sql
-- Ejemplo: vista del directorio de empleados (sin datos sensibles)
CREATE VIEW v_directorio_publico AS
SELECT e.id_empleado,
       e.nombre,
       COALESCE(d.nombre, 'Sin departamento') AS departamento,
       d.ciudad,
       c.titulo,
       c.nivel
FROM empleado e
LEFT JOIN departamento d ON e.id_departamento = d.id_departamento
JOIN cargo c ON e.id_empleado = c.id_empleado;
```

### 1.3 Consultar una vista

Exactamente igual que una tabla:

```sql
-- Todos los registros
SELECT * FROM v_directorio_publico;

-- Con filtros
SELECT nombre, departamento, nivel
FROM v_directorio_publico
WHERE nivel = 'lead';

-- Con agregación
SELECT departamento, COUNT(*) AS empleados
FROM v_directorio_publico
GROUP BY departamento
ORDER BY empleados DESC;

-- JOINs con otras tablas o vistas
SELECT v.nombre, v.departamento, e.salario_cop
FROM v_directorio_publico v
JOIN empleado e ON v.id_empleado = e.id_empleado
ORDER BY e.salario_cop DESC;
```

### 1.4 Vistas con JOINs y funciones nativas

Las vistas pueden encapsular cualquier complejidad:

```sql
CREATE VIEW v_resumen_personal AS
SELECT e.id_empleado,
       UPPER(SPLIT_PART(e.nombre, ' ', 1))          AS primer_nombre,
       c.nivel,
       ROUND(e.salario_cop / 1000000.0, 2)          AS salario_millones,
       e.calificacion,
       TO_CHAR(e.fecha_ingreso, 'DD/MM/YYYY')        AS fecha_ingreso_fmt,
       DATE_PART('year', AGE(CURRENT_DATE, e.fecha_ingreso))::INT AS anos_empresa
FROM empleado e
JOIN cargo c ON e.id_empleado = c.id_empleado;
```

```sql
-- Usar la vista como si fuera una tabla
SELECT * FROM v_resumen_personal
WHERE anos_empresa > 5
ORDER BY salario_millones DESC;
```

```sql
-- Vista con estadísticas por departamento
CREATE VIEW v_stats_departamento AS
SELECT d.nombre                              AS departamento,
       d.ciudad,
       COUNT(e.id_empleado)                  AS total_empleados,
       ROUND(AVG(e.salario_cop), -3)         AS salario_promedio,
       MAX(e.calificacion)                   AS mejor_calificacion
FROM departamento d
LEFT JOIN empleado e ON d.id_departamento = e.id_departamento
GROUP BY d.id_departamento, d.nombre, d.ciudad;
```

### 1.5 Modificar y eliminar vistas

**`CREATE OR REPLACE VIEW`** — reemplaza la definición si la vista ya existe; si no existe, la crea:

```sql
CREATE OR REPLACE VIEW v_directorio_publico AS
SELECT e.id_empleado,
       e.nombre,
       COALESCE(d.nombre, 'Sin departamento') AS departamento,
       d.ciudad,
       c.titulo,
       c.nivel,
       e.fecha_ingreso                        -- columna nueva agregada al final
FROM empleado e
LEFT JOIN departamento d ON e.id_departamento = d.id_departamento
JOIN cargo c ON e.id_empleado = c.id_empleado;
```

> **Restricción importante:** `CREATE OR REPLACE` solo puede **agregar** columnas al final. No puede eliminar columnas, cambiar el tipo de columnas existentes ni cambiar el nombre de columnas que ya existen. Para esos cambios usa `DROP VIEW` + `CREATE VIEW`.

**`DROP VIEW`** — eliminar una vista:

```sql
DROP VIEW v_resumen_personal;
DROP VIEW IF EXISTS v_resumen_personal;   -- no falla si no existe
DROP VIEW IF EXISTS v1, v2, v3;           -- eliminar varias a la vez
```

### 1.6 Ver las vistas existentes

```sql
SELECT table_name AS vista,
       view_definition
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;
```

### 1.7 Vistas actualizables

Una vista que cumple estas condiciones permite `INSERT`, `UPDATE` y `DELETE` directamente:

| Condición requerida | Descripción |
|---------------------|-------------|
| ✅ Una sola tabla en el `FROM` | Sin JOINs |
| ✅ Sin `GROUP BY` ni `HAVING` | |
| ✅ Sin `DISTINCT` ni `LIMIT` | |
| ✅ Sin funciones de agregación | Sin `SUM`, `COUNT`, `AVG`, etc. |
| ✅ Sin subconsultas en el `SELECT` | |
| ✅ Sin operaciones de conjunto | Sin `UNION`, `INTERSECT`, `EXCEPT` |

```sql
-- Vista actualizable (cumple todos los criterios)
CREATE VIEW v_empleados_tecnologia AS
SELECT id_empleado, nombre, email, salario_cop
FROM empleado
WHERE id_departamento = 1;

-- UPDATE a través de la vista → modifica la tabla empleado
UPDATE v_empleados_tecnologia
SET salario_cop = ROUND(salario_cop * 1.05)
WHERE id_empleado = 'EMP-01';

-- La vista con JOINs NO es actualizable
CREATE VIEW v_con_join AS
SELECT e.nombre, d.nombre AS depto
FROM empleado e JOIN departamento d ON e.id_departamento = d.id_departamento;
-- → UPDATE sobre esta vista falla con error
```

### 1.8 WITH CHECK OPTION

`WITH CHECK OPTION` agrega una restricción: cualquier `INSERT` o `UPDATE` hecho a través de la vista debe seguir cumpliendo el `WHERE` de la vista. Si no lo cumple, PostgreSQL lo rechaza.

```sql
CREATE VIEW v_junior AS
SELECT e.id_empleado, e.nombre, c.nivel
FROM empleado e
JOIN cargo c ON e.id_empleado = c.id_empleado
WHERE c.nivel = 'junior'
WITH CHECK OPTION;

-- Esto falla — el resultado quedaría fuera del filtro de la vista
UPDATE v_junior
SET nivel = 'senior'
WHERE id_empleado = 'EMP-02';
-- → ERROR: new row violates check option for view "v_junior"
```

---

## 2. DCL — Control de acceso: usuarios, roles y privilegios

DCL (Data Control Language) es el subconjunto de SQL que controla quién puede hacer qué en la base de datos.

```
DDL → CREATE TABLE, DROP TABLE, ALTER TABLE (estructura)
DML → SELECT, INSERT, UPDATE, DELETE (datos)
DCL → GRANT, REVOKE, CREATE USER, CREATE ROLE (acceso)
```

### 2.1 ¿Por qué controlar el acceso?

**Principio de mínimo privilegio:** cada usuario o aplicación debe tener exactamente los permisos que necesita para su función — ni más ni menos.

```
Analista de datos     → solo SELECT en tablas/vistas que necesita
Aplicación web        → SELECT, INSERT, UPDATE (no DROP, no CREATE)
Área de RRHH          → SELECT y UPDATE sobre tablas de personal
DBA                   → ALL PRIVILEGES
```

Si todos tuvieran acceso total, cualquier error (accidental o malicioso) podría borrar o alterar datos críticos.

### 2.2 CREATE USER y CREATE ROLE

En PostgreSQL, `USER` y `ROLE` son prácticamente lo mismo. La diferencia principal: `CREATE USER` habilita el login por defecto; `CREATE ROLE` no.

```sql
-- CREATE USER (puede conectarse a la BD)
CREATE USER analista_rrhh WITH PASSWORD 'rrhh2024';

-- Equivalente con ROLE
CREATE ROLE analista_rrhh WITH LOGIN PASSWORD 'rrhh2024';

-- ROLE sin login (solo para agrupar permisos)
CREATE ROLE rol_solo_lectura;
CREATE ROLE rol_editor;
```

```sql
-- Ver todos los roles/usuarios
SELECT rolname         AS nombre,
       rolcanlogin     AS puede_conectarse,
       rolsuper        AS es_superusuario
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%'
ORDER BY rolcanlogin DESC, rolname;
```

### 2.3 GRANT — otorgar privilegios

**Sobre una tabla o vista:**

```sql
GRANT SELECT ON empleado TO analista_rrhh;
GRANT SELECT, INSERT ON departamento TO analista_rrhh;
GRANT ALL PRIVILEGES ON cargo TO analista_rrhh;

-- Sobre una vista (independiente de los permisos sobre las tablas base)
GRANT SELECT ON v_directorio_publico TO analista_rrhh;

-- Sobre todas las tablas del esquema actual
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analista_rrhh;
```

**Tipos de privilegios sobre tablas:**

| Privilegio | Permite |
|------------|---------|
| `SELECT` | Leer filas (`SELECT`) |
| `INSERT` | Insertar filas (`INSERT`) |
| `UPDATE` | Modificar filas (`UPDATE`) |
| `DELETE` | Eliminar filas (`DELETE`) |
| `TRUNCATE` | Vaciar la tabla completamente |
| `REFERENCES` | Crear claves foráneas que referencien la tabla |
| `ALL PRIVILEGES` | Todos los anteriores |

**Asignar un rol a un usuario:**

```sql
GRANT rol_solo_lectura TO analista_rrhh;
-- analista_rrhh hereda todos los permisos que tenga rol_solo_lectura
```

### 2.3.1 — Niveles de permisos: base de datos, esquema y objetos

En PostgreSQL los permisos existen en **tres niveles distintos** que van de mayor a menor alcance. Para poder acceder a una tabla, un usuario necesita permisos en los tres:

```
BASE DE DATOS  →  ¿puede conectarse?
     ↓
  ESQUEMA      →  ¿puede ver los objetos dentro del esquema?
     ↓
   OBJETO      →  ¿puede hacer SELECT/INSERT/UPDATE sobre esa tabla o vista?
```

Si falta el permiso en cualquier nivel, el acceso falla aunque los otros dos estén concedidos.

#### Nivel 1 — Base de datos (`ON DATABASE`)

```sql
-- Privilegios disponibles sobre una base de datos:
GRANT CONNECT ON DATABASE nombre_bd TO usuario;   -- permite conectarse
GRANT CREATE  ON DATABASE nombre_bd TO usuario;   -- permite crear esquemas
GRANT TEMP    ON DATABASE nombre_bd TO usuario;   -- permite crear tablas temporales

-- Quitar el acceso completo a la base de datos:
REVOKE CONNECT ON DATABASE nombre_bd FROM usuario;
-- A partir de ese momento el usuario no puede ni conectarse
```

| Privilegio BD | Permite |
|---------------|---------|
| `CONNECT` | Conectarse a la base de datos. Sin esto, todo lo demás es irrelevante |
| `CREATE` | Crear nuevos esquemas dentro de la BD |
| `TEMP` | Crear tablas temporales en cualquier esquema |

> **Nota:** `CONNECT` se otorga a `PUBLIC` por defecto al crear una BD. Para restringir quién puede conectarse, primero hay que revocárselo a PUBLIC: `REVOKE CONNECT ON DATABASE mi_bd FROM PUBLIC;`

#### Nivel 2 — Esquema (`ON SCHEMA`)

Un **esquema** es un espacio de nombres dentro de la base de datos (el esquema por defecto es `public`). Sin permiso sobre el esquema, el usuario no puede ver ni usar los objetos que contiene, aunque tenga SELECT sobre una tabla específica.

```sql
-- Permitir que el usuario pueda "ver" y usar los objetos del esquema
GRANT USAGE ON SCHEMA public TO analista_rrhh;

-- Permitir que el usuario cree objetos (tablas, vistas, etc.) en el esquema
GRANT CREATE ON SCHEMA public TO analista_rrhh;

-- Quitar el acceso al esquema
REVOKE USAGE ON SCHEMA public FROM analista_rrhh;
```

| Privilegio esquema | Permite |
|--------------------|---------|
| `USAGE` | Acceder a los objetos del esquema (necesario para hacer SELECT en sus tablas) |
| `CREATE` | Crear nuevas tablas, vistas, índices, etc. dentro del esquema |

#### Nivel 3 — Objetos específicos (tablas, vistas, funciones)

Es lo que ya vieron en la sección anterior: `GRANT SELECT ON tabla TO usuario`.

#### Otorgar acceso a todos los objetos actuales del esquema

```sql
-- SELECT sobre todas las tablas que existen HOY en el esquema public
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analista_rrhh;

-- Escritura sobre todas las tablas actuales
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO analista_rrhh;

-- Sobre todas las secuencias (necesario para INSERT en tablas con SERIAL)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO analista_rrhh;

-- Sobre todas las funciones actuales
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO analista_rrhh;
```

> **Limitación importante:** `ON ALL TABLES` aplica solo a las tablas que **existen en ese momento**. Las tablas creadas después **no heredan** este permiso automáticamente.

#### Permisos para tablas futuras — `ALTER DEFAULT PRIVILEGES`

```sql
-- A partir de ahora, cualquier tabla que cree el superusuario en 'public'
-- tendrá SELECT automáticamente para analista_rrhh
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO analista_rrhh;

-- Para secuencias (INSERT en tablas con SERIAL)
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO analista_rrhh;
```

#### Superusuario — acceso total sin restricciones

```sql
-- Convertir un usuario en superusuario (equivale a root en Linux)
ALTER USER analista_rrhh SUPERUSER;

-- Quitarle los privilegios de superusuario
ALTER USER analista_rrhh NOSUPERUSER;

-- Verificar quién es superusuario
SELECT rolname, rolsuper FROM pg_roles WHERE rolsuper = TRUE;
```

> ⚠️ **El superusuario ignora todas las restricciones de permisos** — puede leer, modificar y eliminar cualquier objeto de cualquier base de datos en el servidor. Nunca se debe usar para aplicaciones, reportes ni acceso cotidiano.

#### ¿Cuándo usar cada nivel de alcance?

| Situación | Solución recomendada |
|-----------|---------------------|
| Un analista nuevo necesita leer reportes | `GRANT USAGE ON SCHEMA` + `GRANT SELECT ON ALL TABLES` |
| Una aplicación web necesita operar | `GRANT USAGE ON SCHEMA` + GRANT tabla por tabla según lo que use |
| Un DBA junior necesita crear objetos | `GRANT CREATE ON SCHEMA` + roles específicos |
| Migración o mantenimiento puntual de un DBA | Superusuario temporal, revocar al terminar |
| Nunca | Dejar el superusuario como usuario por defecto de la aplicación |

#### Secuencia completa para dar acceso a un usuario nuevo

```sql
-- 1. Crear el usuario
CREATE USER nuevo_analista WITH PASSWORD 'segura2024';

-- 2. Permitir conexión a la base de datos
GRANT CONNECT ON DATABASE staffhub TO nuevo_analista;

-- 3. Permitir ver los objetos del esquema
GRANT USAGE ON SCHEMA public TO nuevo_analista;

-- 4. Otorgar permisos sobre los objetos que necesita
GRANT SELECT ON ALL TABLES IN SCHEMA public TO nuevo_analista;

-- 5. (Opcional) Permisos para tablas futuras
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO nuevo_analista;
```

> **Regla de oro:** siempre empieza con los permisos mínimos necesarios y agrega solo lo que se justifique. Es mucho más difícil restringir permisos mal otorgados que concederlos desde cero de forma controlada.

### 2.4 REVOKE — quitar privilegios

```sql
-- Quitar un privilegio específico
REVOKE INSERT ON departamento FROM analista_rrhh;

-- Quitar todos los privilegios sobre una tabla
REVOKE ALL PRIVILEGES ON empleado FROM analista_rrhh;

-- Quitar un rol
REVOKE rol_solo_lectura FROM analista_rrhh;
```

> **Importante:** `REVOKE` solo quita los permisos otorgados **directamente** al usuario. Los permisos heredados de un rol no se ven afectados a menos que se revoque el rol completo.

### 2.5 WITH GRANT OPTION

```sql
-- analista_rrhh puede a su vez otorgar este permiso a otros usuarios
GRANT SELECT ON v_directorio_publico TO analista_rrhh WITH GRANT OPTION;
```

Usar con cautela — crea una cadena de permisos difícil de auditar.

### 2.6 Patrón recomendado: roles → usuarios

En lugar de otorgar permisos directamente a cada usuario, se crean **roles** que representan funciones del negocio y luego se asignan esos roles a los usuarios.

```sql
-- PASO 1: crear roles por función
CREATE ROLE rol_rrhh_consulta;
CREATE ROLE rol_rrhh_editor;

-- PASO 2: asignar permisos a los roles
GRANT SELECT ON v_directorio_publico  TO rol_rrhh_consulta;
GRANT SELECT ON v_stats_departamento  TO rol_rrhh_consulta;

GRANT rol_rrhh_consulta               TO rol_rrhh_editor;   -- hereda
GRANT SELECT, UPDATE ON empleado      TO rol_rrhh_editor;
GRANT SELECT, UPDATE ON cargo         TO rol_rrhh_editor;

-- PASO 3: asignar roles a usuarios
CREATE USER ana_rrhh WITH PASSWORD 'ana2024';
CREATE USER carlos_editor WITH PASSWORD 'carlos2024';

GRANT rol_rrhh_consulta TO ana_rrhh;
GRANT rol_rrhh_editor   TO carlos_editor;
```

**Ventaja:** si se contrata un nuevo analista, solo hace falta `GRANT rol_rrhh_consulta TO nuevo_usuario`. Sin roles, habría que repetir todos los GRANT uno por uno.

### 2.7 Verificar privilegios

```sql
-- Ver qué privilegios tienen usuarios y roles sobre las tablas
SELECT grantee        AS usuario_o_rol,
       table_name     AS tabla,
       privilege_type AS privilegio
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
ORDER BY grantee, table_name, privilege_type;
```

```sql
-- Ver a qué roles pertenece un usuario
SELECT rolname AS rol
FROM pg_roles
WHERE pg_has_role('analista_rrhh', oid, 'member')
  AND rolname != 'analista_rrhh';
```

### 2.8 Eliminar usuarios y roles

```sql
-- Primero revocar todos sus permisos
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM analista_rrhh;

-- Luego eliminar
DROP USER analista_rrhh;
DROP ROLE rol_solo_lectura;

-- Con IF EXISTS para evitar error si no existe
DROP USER IF EXISTS analista_rrhh;
DROP ROLE IF EXISTS rol_solo_lectura;
```

> **Nota:** No se puede eliminar un usuario si todavía tiene objetos en la base de datos (tablas, secuencias, etc.) o si tiene privilegios activos sobre ellos. Hay que revocarlos o reasignarlos primero.

---

## 3. Relación entre vistas y DCL

La combinación de vistas + DCL es una estrategia poderosa de seguridad:

```
Tabla empleado
├── id_empleado
├── nombre
├── email          ← sensible
├── salario_cop    ← sensible
└── calificacion   ← sensible

        ↓ CREATE VIEW v_directorio_publico (oculta email, salario, calificación)
        ↓ GRANT SELECT ON v_directorio_publico TO rol_consulta

El usuario con rol_consulta puede consultar el directorio
sin acceder directamente a la tabla empleado ni ver los datos sensibles.
```

```sql
-- Patrón completo: vista de seguridad + permiso al rol
CREATE VIEW v_directorio_publico AS
SELECT id_empleado, nombre, id_departamento
FROM empleado;

GRANT SELECT ON v_directorio_publico TO rol_consulta;
-- rol_consulta NO tiene GRANT sobre la tabla empleado
-- → solo puede ver lo que la vista expone
```

---

## 4. Errores frecuentes

### Intentar modificar columnas existentes con OR REPLACE

```sql
-- ❌ No funciona — OR REPLACE no puede cambiar el tipo de una columna existente
CREATE OR REPLACE VIEW v_empleado AS
SELECT id_empleado::TEXT, nombre  -- cambiar tipo de id_empleado
FROM empleado;
-- → ERROR: cannot change data type of view column "id_empleado"

-- ✅ Solución: DROP + CREATE
DROP VIEW v_empleado;
CREATE VIEW v_empleado AS
SELECT id_empleado::TEXT, nombre
FROM empleado;
```

### GRANT sobre tabla base no equivale a GRANT sobre la vista

```sql
-- ❌ Error común: pensar que el permiso sobre la tabla incluye la vista
GRANT SELECT ON empleado TO analista;
-- analista NO puede consultar v_directorio_publico automáticamente

-- ✅ Hay que hacer GRANT sobre la vista explícitamente
GRANT SELECT ON v_directorio_publico TO analista;
```

### UPDATE a través de una vista con JOIN

```sql
-- ❌ Falla porque la vista tiene JOIN (no es actualizable)
CREATE VIEW v_emp_depto AS
SELECT e.nombre, d.nombre AS depto
FROM empleado e JOIN departamento d ON e.id_departamento = d.id_departamento;

UPDATE v_emp_depto SET nombre = 'Nuevo nombre' WHERE nombre = 'Ana Torres';
-- → ERROR: cannot update view "v_emp_depto" — views with JOIN are not updatable
```

### Eliminar un usuario sin revocar permisos primero

```sql
-- ❌ Puede fallar si el usuario tiene objetos o permisos activos
DROP USER analista_rrhh;
-- → ERROR: role "analista_rrhh" cannot be dropped because some objects depend on it

-- ✅ Revocar antes de eliminar
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM analista_rrhh;
REVOKE rol_solo_lectura FROM analista_rrhh;
DROP USER analista_rrhh;
```

---
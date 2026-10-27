# Clase 23 — PL/pgSQL: Triggers
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**
**Herramienta:** PostgreSQL + pgAdmin

---

## Cadena de aprendizaje — dónde estamos

```
SQL puro: SELECT, JOINs, funciones nativas        ← Clases 16–21
    ↓
Vistas + DCL (GRANT / REVOKE)                     ← Clase 21
    ↓
PL/pgSQL: DO, variables, IF, FOR                  ← Clase 22
CREATE FUNCTION · CREATE PROCEDURE
    ↓
PL/pgSQL: Triggers                                ← Clase 23 (aquí)
```

---

## Base de datos de referencia — StaffHub

```
DEPARTAMENTO   (id_departamento, nombre, ciudad, presupuesto_anual)
EMPLEADO       (id_empleado, nombre, email, fecha_ingreso, salario_cop,
                calificacion NUMERIC(3,1), id_departamento FK,
                ultima_modificacion TIMESTAMP)
CARGO          (id_empleado FK, titulo, nivel: 'junior' | 'senior' | 'lead')
LOG_AUDITORIA  (id_log SERIAL PK, tabla, operacion, id_registro,
                descripcion, fecha_hora, usuario_bd)
```

La tabla `log_auditoria` se crea en esta clase para los ejemplos de auditoría.

---

## 1. ¿Qué es un trigger?

Un **trigger** (disparador) es un bloque PL/pgSQL que PostgreSQL ejecuta **automáticamente** cuando ocurre un evento (INSERT, UPDATE, DELETE o TRUNCATE) sobre una tabla. No se invoca manualmente — se activa solo, sin importar desde dónde venga el cambio.

### 1.1 El problema que resuelven

Con funciones y procedimientos (clase anterior) el código se ejecuta **cuando alguien lo llama**. Pero hay situaciones donde se necesita que algo ocurra **siempre**, ante cualquier modificación de datos, sin depender de que la aplicación lo recuerde:

```
Sin trigger:                              Con trigger:
──────────────────────────────────        ──────────────────────────────────────
App actualiza salario                     App actualiza salario
  → a veces registra en el log              → el trigger registra SIEMPRE
  → a veces olvida hacerlo                  → sin importar qué sistema hizo el UPDATE
DBA actualiza desde pgAdmin               DBA actualiza desde pgAdmin
  → nadie registra nada                     → el trigger registra igual
Script de migración actualiza             Script de migración actualiza
  → nadie registra nada                     → el trigger registra igual
```

### 1.2 ¿Para qué se usan?

| Caso de uso | Descripción | Momento típico |
|-------------|-------------|----------------|
| **Auditoría** | Registrar quién cambió qué, desde qué valor y cuándo | AFTER |
| **Validación** | Imponer reglas de negocio que CHECK no puede expresar | BEFORE |
| **Cálculo automático** | Actualizar campos derivados o timestamps automáticamente | BEFORE |
| **Normalización** | Limpiar o estandarizar datos antes de guardarlos | BEFORE |
| **Integridad referencial** | Implementar cascadas personalizadas que FK ON CASCADE no permite | AFTER |
| **Notificaciones** | Avisar a otros sistemas cuando ocurre un evento importante | AFTER |

### 1.3 ¿Cuándo usar un trigger?

```
¿La acción debe ocurrir SIEMPRE que cambie la tabla,
sin importar desde dónde venga el cambio?
    SÍ → trigger

¿La acción debe ocurrir ANTES de guardar para validar o modificar datos?
    SÍ → trigger BEFORE

¿La acción modifica datos en OTRA tabla como consecuencia del cambio?
    SÍ → trigger AFTER

¿Puedo expresar la regla con CHECK, NOT NULL o FK?
    SÍ → usar esa restricción (más simple que un trigger)

¿La acción solo ocurre cuando alguien la pide explícitamente?
    SÍ → función o procedimiento (no un trigger)
```

---

## 2. Anatomía de un trigger: 5 componentes

Todo trigger se define por exactamente 5 decisiones:

### 2.1 Evento — ¿qué lo dispara?

| Evento | Cuándo se activa |
|--------|-----------------|
| `INSERT` | Al insertar una nueva fila |
| `UPDATE` | Al modificar una fila existente |
| `DELETE` | Al eliminar una fila |
| `TRUNCATE` | Al vaciar la tabla completa |

Se pueden combinar en un mismo trigger: `INSERT OR UPDATE OR DELETE`.

### 2.2 Tabla — ¿en qué tabla?

```sql
ON empleado
ON cargo
ON cualquier_tabla
```

### 2.3 Momento — ¿cuándo se ejecuta?

| Momento | Descripción | Puede modificar datos |
|---------|-------------|----------------------|
| `BEFORE` | **Antes** de que el cambio se aplique | **Sí** — puede cambiar `NEW` o cancelar la operación |
| `AFTER` | **Después** de que el cambio ya se aplicó | No — el cambio ya ocurrió |
| `INSTEAD OF` | **En lugar** del cambio (solo sobre vistas) | Sí |

### 2.4 Nivel — ¿cuántas veces se ejecuta?

| Nivel | ¿Cuántas veces? | ¿Tiene NEW/OLD? | Uso típico |
|-------|----------------|-----------------|------------|
| `FOR EACH ROW` | Una vez **por fila** afectada | Sí | La gran mayoría de los casos |
| `FOR EACH STATEMENT` | Una vez **por sentencia** SQL | No | Conteo de operaciones, alertas globales |

**Diferencia práctica:** si un solo UPDATE afecta 5 filas:
- `FOR EACH ROW` → el trigger se ejecuta **5 veces** (una por fila)
- `FOR EACH STATEMENT` → el trigger se ejecuta **1 vez** (por la sentencia completa)

### 2.5 Función — ¿qué hace?

Una función PL/pgSQL que retorna el tipo especial `TRIGGER`. Esta función es la que contiene toda la lógica y tiene dos características únicas frente a las funciones normales:
- **No recibe parámetros** en la firma — la información llega en variables especiales automáticas (`NEW`, `OLD`, `TG_OP`...)
- **Siempre retorna `TRIGGER`** en la declaración, aunque dentro retorna `NEW`, `OLD` o `NULL`

---

## 3. El proceso de creación: dos pasos obligatorios

Un trigger **siempre** requiere crear dos objetos separados en este orden:

```
┌─────────────────────────────────────────────────────────┐
│  PASO 1: La función trigger                             │
│  Define QUÉ hace cuando el trigger se activa            │
│  → CREATE FUNCTION ... RETURNS TRIGGER                  │
└─────────────────────────────────────────────────────────┘
                          ↓  (debe existir antes)
┌─────────────────────────────────────────────────────────┐
│  PASO 2: El trigger                                     │
│  Define CUÁNDO y DÓNDE se ejecuta esa función           │
│  → CREATE TRIGGER                                       │
└─────────────────────────────────────────────────────────┘
```

```sql
-- PASO 1: función trigger
-- · No lleva parámetros en la firma
-- · Siempre retorna TRIGGER (no INT, TEXT, etc.)
CREATE OR REPLACE FUNCTION nombre_funcion_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- lógica aquí usando NEW, OLD, TG_OP...
    RETURN NEW;   -- o RETURN OLD, o RETURN NULL según el caso
END;
$$;

-- PASO 2: el trigger que conecta el evento con la función
CREATE TRIGGER nombre_trigger
    BEFORE | AFTER    INSERT | UPDATE | DELETE [OR ...]
    ON nombre_tabla
    FOR EACH ROW | FOR EACH STATEMENT
    [WHEN (condición)]
    EXECUTE FUNCTION nombre_funcion_trigger();
```

> **Orden obligatorio:** la función debe existir **antes** de crear el trigger. Si el trigger se crea primero, PostgreSQL lanza un error porque no encuentra la función.

---

## 4. Variables especiales automáticas

Cuando PostgreSQL ejecuta una función trigger, inyecta estas variables automáticamente — no hay que declararlas:

### 4.1 NEW y OLD — las filas implicadas

| Variable | Tipo | Disponible en | Contiene |
|----------|------|---------------|----------|
| `NEW` | RECORD | INSERT, UPDATE | La fila con los **nuevos valores** (los que se van a guardar) |
| `OLD` | RECORD | UPDATE, DELETE | La fila con los **valores anteriores** (los que había antes) |

**Qué contiene cada una según la operación:**

```
Operación   │  OLD                      │  NEW
────────────┼───────────────────────────┼──────────────────────────────
INSERT      │  NULL (no había fila)     │  La fila nueva a insertar
UPDATE      │  La fila antes del cambio │  La fila después del cambio
DELETE      │  La fila que se elimina   │  NULL (no habrá fila)
```

```sql
-- Acceso a columnas de NEW y OLD por nombre:
NEW.nombre          -- el nuevo valor de la columna 'nombre'
OLD.salario_cop     -- el valor anterior de salario_cop
NEW.id_empleado     -- el id del empleado afectado
```

### 4.2 Variables de contexto TG_*

| Variable | Tipo | Contiene |
|----------|------|---------|
| `TG_OP` | TEXT | La operación: `'INSERT'`, `'UPDATE'` o `'DELETE'` |
| `TG_NAME` | TEXT | El nombre del trigger en ejecución |
| `TG_TABLE_NAME` | TEXT | El nombre de la tabla que disparó el trigger |
| `TG_TABLE_SCHEMA` | TEXT | El esquema de esa tabla |
| `TG_WHEN` | TEXT | `'BEFORE'` o `'AFTER'` |
| `TG_LEVEL` | TEXT | `'ROW'` o `'STATEMENT'` |

```sql
-- Uso típico de TG_OP para manejar múltiples eventos en una sola función:
IF TG_OP = 'INSERT' THEN
    -- lógica para insert (NEW disponible, OLD es NULL)
ELSIF TG_OP = 'UPDATE' THEN
    -- lógica para update (OLD y NEW disponibles)
ELSIF TG_OP = 'DELETE' THEN
    -- lógica para delete (OLD disponible, NEW es NULL)
END IF;
```

---

## 5. ¿Qué debe retornar la función trigger?

El valor de retorno tiene efectos distintos según el contexto:

### 5.1 Triggers BEFORE FOR EACH ROW

| Retorna | Efecto |
|---------|--------|
| `RETURN NEW` | La operación se aplica con los valores de `NEW` — si se modificó `NEW`, los cambios se guardan |
| `RETURN OLD` | En UPDATE: se aplica ignorando los nuevos valores (se guardan los anteriores) |
| `RETURN NULL` | La operación **se cancela** para esa fila, silenciosamente |
| `RAISE EXCEPTION` | La operación se cancela y se genera un **error visible** con mensaje |

### 5.2 Triggers AFTER FOR EACH ROW

El valor de retorno es ignorado — el cambio ya ocurrió. Por convención se usa `RETURN NEW` o `RETURN NULL`.

### 5.3 Triggers FOR EACH STATEMENT

Siempre `RETURN NULL`.

### 5.4 Tabla de decisión: qué retornar según el escenario

| Escenario | Retorna |
|-----------|---------|
| BEFORE INSERT/UPDATE: aplicar sin modificar nada | `RETURN NEW` |
| BEFORE INSERT/UPDATE: modifiqué `NEW` y quiero que se guarden los cambios | `RETURN NEW` (modificado) |
| BEFORE INSERT/UPDATE: cancelar silenciosamente | `RETURN NULL` |
| BEFORE INSERT/UPDATE: cancelar con mensaje de error | `RAISE EXCEPTION 'mensaje'` |
| BEFORE DELETE: permitir la eliminación | `RETURN OLD` |
| AFTER cualquier operación | `RETURN NULL` o `RETURN NEW` (indiferente) |
| FOR EACH STATEMENT | `RETURN NULL` |

### 5.5 RETURN NULL vs RAISE EXCEPTION

| Mecanismo | Efecto | Cuándo usarlo |
|-----------|--------|---------------|
| `RETURN NULL` | Cancela la fila **silenciosamente** | Filtrado interno sin que la aplicación note el rechazo |
| `RAISE EXCEPTION` | Cancela **y** lanza un error visible con mensaje | Violaciones de reglas de negocio que el usuario debe conocer |

---

## 6. Casos de uso — Trigger de auditoría (AFTER)

### 6.1 Por qué AFTER para auditoría

Se usa AFTER porque:
- El cambio ya se guardó definitivamente — el log refleja la realidad
- Si el INSERT/UPDATE falla por otra causa, el log tampoco se registra (consistencia)
- No necesitamos modificar los datos, solo observarlos

### 6.2 Crear la tabla de auditoría

```sql
CREATE TABLE log_auditoria (
    id_log      SERIAL       PRIMARY KEY,
    tabla       VARCHAR(50)  NOT NULL,
    operacion   VARCHAR(10)  NOT NULL,   -- 'INSERT', 'UPDATE', 'DELETE'
    id_registro VARCHAR(20),
    descripcion TEXT,
    fecha_hora  TIMESTAMP    NOT NULL DEFAULT NOW(),
    usuario_bd  VARCHAR(100) NOT NULL DEFAULT CURRENT_USER
);
```

### 6.3 Trigger de auditoría de salarios

```sql
-- PASO 1: función
CREATE OR REPLACE FUNCTION fn_auditoria_salario()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- IS DISTINCT FROM maneja NULL correctamente
    -- OLD.salario_cop <> NEW.salario_cop daría NULL si alguno fuera NULL
    IF OLD.salario_cop IS DISTINCT FROM NEW.salario_cop THEN
        INSERT INTO log_auditoria (tabla, operacion, id_registro, descripcion)
        VALUES (
            TG_TABLE_NAME,      -- nombre de la tabla (automático)
            TG_OP,              -- 'UPDATE' (automático)
            NEW.id_empleado,
            NEW.nombre || ': $' || OLD.salario_cop || ' → $' || NEW.salario_cop
        );
    END IF;
    RETURN NEW;
END;
$$;

-- PASO 2: trigger
CREATE TRIGGER tg_auditoria_salario
    AFTER UPDATE ON empleado
    FOR EACH ROW
    EXECUTE FUNCTION fn_auditoria_salario();
```

```sql
-- Probar
UPDATE empleado SET salario_cop = 4500000 WHERE id_empleado = 'EMP-01';

-- Verificar que se registró automáticamente
SELECT tabla, operacion, id_registro, descripcion, fecha_hora
FROM log_auditoria ORDER BY fecha_hora DESC;
-- empleado | UPDATE | EMP-01 | Ana Torres: $4200000 → $4500000
```

### 6.4 Auditoría de INSERT y DELETE en el mismo trigger

Un trigger puede manejar múltiples eventos usando `TG_OP`:

```sql
CREATE OR REPLACE FUNCTION fn_auditoria_empleado()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO log_auditoria (tabla, operacion, id_registro, descripcion)
        VALUES (TG_TABLE_NAME, 'INSERT', NEW.id_empleado,
                'Nuevo empleado: ' || NEW.nombre);
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO log_auditoria (tabla, operacion, id_registro, descripcion)
        VALUES (TG_TABLE_NAME, 'DELETE', OLD.id_empleado,
                'Eliminado: ' || OLD.nombre);
        RETURN OLD;   -- en DELETE retornamos OLD, nunca NEW
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER tg_auditoria_empleado
    AFTER INSERT OR DELETE ON empleado
    FOR EACH ROW
    EXECUTE FUNCTION fn_auditoria_empleado();
```

> **¿Por qué `IS DISTINCT FROM` en lugar de `<>`?**
>
> | Expresión | Resultado cuando uno es NULL |
> |-----------|------------------------------|
> | `NULL <> 5000` | `NULL` — no es TRUE ni FALSE, el `IF` nunca entra |
> | `NULL IS DISTINCT FROM 5000` | `TRUE` — correcto |
> | `NULL IS DISTINCT FROM NULL` | `FALSE` — correcto |
>
> Si una columna puede ser NULL, usar siempre `IS DISTINCT FROM` en lugar de `<>` dentro de triggers.

---

## 7. Casos de uso — Trigger de validación (BEFORE)

### 7.1 Por qué BEFORE para validación

Se usa BEFORE porque necesitamos actuar **antes** de que el dato incorrecto se guarde. En un AFTER ya es tarde.

### 7.2 ¿Cuándo un trigger de validación en lugar de CHECK?

| Situación | Solución recomendada |
|-----------|---------------------|
| El valor debe estar en un rango fijo (`precio > 0`) | `CHECK (precio > 0)` |
| El valor depende de otra columna de la misma fila | `CHECK (fecha_fin > fecha_inicio)` |
| La regla involucra datos en **otra tabla** | Trigger BEFORE — CHECK no puede consultar otras tablas |
| La regla compara con el **valor anterior** (`no bajar el salario más del 10%`) | Trigger BEFORE — CHECK no tiene acceso a OLD |
| La regla depende del **tipo de operación** (solo en INSERT, no en UPDATE) | Trigger BEFORE con `IF TG_OP = 'INSERT'` |

### 7.3 Ejemplo: impedir reducción de salario mayor al 10%

```sql
-- PASO 1: función de validación
CREATE OR REPLACE FUNCTION fn_validar_salario()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        IF NEW.salario_cop < OLD.salario_cop * 0.90 THEN
            RAISE EXCEPTION
                'Reducción no permitida. Actual: $%. Nuevo: $%. Máximo: 10%% de reducción.',
                OLD.salario_cop, NEW.salario_cop;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

-- PASO 2: trigger BEFORE UPDATE
CREATE TRIGGER tg_validar_salario
    BEFORE UPDATE ON empleado
    FOR EACH ROW
    EXECUTE FUNCTION fn_validar_salario();
```

```sql
-- Prueba 1: reducción del 5% — debe pasar
UPDATE empleado SET salario_cop = 3990000 WHERE id_empleado = 'EMP-01';  -- OK

-- Prueba 2: reducción del 30% — debe fallar
UPDATE empleado SET salario_cop = 2940000 WHERE id_empleado = 'EMP-01';
-- ERROR: Reducción no permitida. Actual: $4200000. Nuevo: $2940000...
```

---

## 8. Casos de uso — Trigger de cálculo automático (BEFORE)

### 8.1 Por qué BEFORE para cálculo automático

Se usa BEFORE porque en BEFORE aún podemos cambiar `NEW` — ese es el dato que se va a guardar. En AFTER ya es tarde para modificar la fila (habría que hacer otro UPDATE, lo que dispararía el trigger de nuevo).

### 8.2 Ejemplo: timestamp de última modificación

```sql
ALTER TABLE empleado ADD COLUMN IF NOT EXISTS ultima_modificacion TIMESTAMP;

CREATE OR REPLACE FUNCTION fn_timestamp_modificacion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.ultima_modificacion := NOW();
    RETURN NEW;   -- devuelve NEW con el timestamp ya asignado
END;
$$;

CREATE TRIGGER tg_timestamp_empleado
    BEFORE INSERT OR UPDATE ON empleado
    FOR EACH ROW
    EXECUTE FUNCTION fn_timestamp_modificacion();
```

```sql
UPDATE empleado SET calificacion = 4.9 WHERE id_empleado = 'EMP-01';

SELECT id_empleado, nombre, calificacion, ultima_modificacion
FROM empleado WHERE id_empleado = 'EMP-01';
-- ultima_modificacion se actualizó automáticamente
```

### 8.3 Ejemplo: normalizar texto automáticamente

```sql
CREATE OR REPLACE FUNCTION fn_normalizar_nombre()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.nombre := INITCAP(TRIM(NEW.nombre));
    RETURN NEW;
END;
$$;

CREATE TRIGGER tg_normalizar_nombre
    BEFORE INSERT OR UPDATE ON empleado
    FOR EACH ROW
    EXECUTE FUNCTION fn_normalizar_nombre();
```

```sql
-- Insertar con nombre en minúsculas
INSERT INTO empleado (id_empleado, nombre, email, fecha_ingreso, salario_cop)
VALUES ('EMP-13', 'pedro páez ruiz', 'pedro@test.com', '2024-01-01', 2500000);

SELECT nombre FROM empleado WHERE id_empleado = 'EMP-13';
-- 'Pedro Páez Ruiz'  ← normalizado automáticamente
```

Se puede agregar una condición `WHEN` al trigger para que solo se active cuando se cumple una condición — sin necesidad de escribirla dentro de la función.

```sql
-- Solo auditar cuando el salario realmente cambia
CREATE TRIGGER tg_auditoria_salario
    AFTER UPDATE ON empleado
    FOR EACH ROW
    WHEN (OLD.salario_cop IS DISTINCT FROM NEW.salario_cop)
    EXECUTE FUNCTION fn_auditoria_salario();
```

La condición `WHEN` puede usar `OLD.col` y `NEW.col`. Es más eficiente que poner el `IF` dentro de la función porque PostgreSQL ni siquiera llama la función si la condición no se cumple.

```sql
-- Sin WHEN: la función se llama siempre, decide internamente si actúa
CREATE TRIGGER tg_auditoria_salario
    AFTER UPDATE ON empleado
    FOR EACH ROW
    EXECUTE FUNCTION fn_auditoria_salario();

-- Con WHEN: más eficiente — la función solo se invoca cuando el salario cambió
CREATE TRIGGER tg_auditoria_salario
    AFTER UPDATE ON empleado
    FOR EACH ROW
    WHEN (OLD.salario_cop IS DISTINCT FROM NEW.salario_cop)
    EXECUTE FUNCTION fn_auditoria_salario();
```

La cláusula `WHEN` **no puede** contener subconsultas. Solo puede referenciar `OLD.columna`, `NEW.columna` y constantes.

---

## 10. Administrar triggers: ver, desactivar, eliminar

```sql
-- Ver todos los triggers de una tabla
SELECT trigger_name     AS nombre,
       event_manipulation AS evento,
       action_timing      AS momento,
       action_orientation AS nivel
FROM information_schema.triggers
WHERE event_object_table  = 'empleado'
  AND event_object_schema = 'public'
ORDER BY trigger_name;

-- Desactivar temporalmente (el trigger sigue existiendo, solo no se activa)
ALTER TABLE empleado DISABLE TRIGGER tg_auditoria_salario;
ALTER TABLE empleado DISABLE TRIGGER ALL;   -- desactiva todos los de la tabla

-- Reactivar
ALTER TABLE empleado ENABLE TRIGGER tg_auditoria_salario;
ALTER TABLE empleado ENABLE TRIGGER ALL;

-- Eliminar el trigger (la función NO se elimina automáticamente)
DROP TRIGGER IF EXISTS tg_auditoria_salario ON empleado;

-- Eliminar la función del trigger (paso separado y obligatorio)
DROP FUNCTION IF EXISTS fn_auditoria_salario();
```

> **Nota:** cuando se elimina una tabla, PostgreSQL elimina automáticamente todos sus triggers. Sin embargo, las **funciones** de esos triggers siguen existiendo en la base de datos y hay que eliminarlas manualmente.

---

## 11. Tablas comparativas de referencia rápida

### ¿Qué momento usar según el objetivo?

| Objetivo | Momento | Razón |
|----------|---------|-------|
| Validar datos antes de guardar | BEFORE | Puede cancelar con `RETURN NULL` o `RAISE EXCEPTION` |
| Modificar datos antes de guardar | BEFORE | Puede cambiar `NEW` antes de que se persista |
| Registrar en un log de auditoría | AFTER | El cambio ya es definitivo — el log refleja la realidad |
| Notificar o propagar a otra tabla | AFTER | La fila ya existe con sus valores finales |
| Mantener una tabla resumen actualizada | AFTER | Opera sobre el estado definitivo |

### ¿Qué retornar según el escenario?

| Escenario | Retorna |
|-----------|---------|
| BEFORE INSERT/UPDATE: aplicar sin modificar nada | `RETURN NEW` |
| BEFORE INSERT/UPDATE: modifiqué `NEW`, quiero que los cambios se guarden | `RETURN NEW` (modificado) |
| BEFORE INSERT/UPDATE: cancelar silenciosamente | `RETURN NULL` |
| BEFORE INSERT/UPDATE: cancelar con mensaje de error | `RAISE EXCEPTION 'mensaje'` |
| BEFORE DELETE: permitir la eliminación | `RETURN OLD` |
| AFTER cualquier operación | `RETURN NULL` o `RETURN NEW` (indiferente) |
| FOR EACH STATEMENT | `RETURN NULL` |

### Función trigger vs función normal — diferencias clave

| Característica | Función normal | Función trigger |
|----------------|----------------|-----------------|
| Parámetros en la firma | Declarados explícitamente | Ninguno — los datos llegan en `NEW`/`OLD`/`TG_*` |
| Tipo de retorno en la firma | El tipo real (`INT`, `TEXT`...) | Siempre `TRIGGER` |
| Cómo se invoca | `SELECT f()` o `CALL p()` | Automáticamente — nunca manualmente |
| Variables de contexto | No tiene | `TG_OP`, `TG_TABLE_NAME`, `TG_WHEN`... |

---

## 12. Referencia rápida — plantilla completa

```sql
-- ── PASO 1: función trigger ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_nombre_descriptivo()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_alguna_variable TEXT;   -- si se necesita
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- NEW disponible, OLD es NULL
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        -- OLD: valores anteriores, NEW: valores nuevos
        -- Para BEFORE: puedes modificar NEW aquí
        -- Para AFTER: ya no puedes modificar la fila
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        -- OLD disponible, NEW es NULL
        RETURN OLD;
    END IF;

    RETURN COALESCE(NEW, OLD);   -- fallback
END;
$$;

-- ── PASO 2: trigger ──────────────────────────────────────────────────
CREATE TRIGGER tg_nombre_descriptivo
    BEFORE | AFTER    INSERT | UPDATE | DELETE [OR INSERT OR UPDATE OR DELETE]
    ON nombre_tabla
    FOR EACH ROW
    [WHEN (OLD.col IS DISTINCT FROM NEW.col)]   -- opcional
    EXECUTE FUNCTION fn_nombre_descriptivo();
```

---

## 13. Errores frecuentes

### Trigger que se llama a sí mismo (bucle infinito)

```sql
-- ❌ Peligroso: el trigger hace UPDATE en la misma tabla → se dispara de nuevo → bucle
CREATE OR REPLACE FUNCTION fn_peligroso()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE empleado SET ultima_modificacion = NOW()
    WHERE id_empleado = NEW.id_empleado;   -- ← dispara el mismo trigger de nuevo
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ✅ Correcto: modificar NEW directamente (no genera un nuevo UPDATE)
CREATE OR REPLACE FUNCTION fn_seguro()
RETURNS TRIGGER AS $$
BEGIN
    NEW.ultima_modificacion := NOW();   -- modifica la fila en memoria
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Usar NEW en un trigger de DELETE

```sql
-- ❌ En DELETE, NEW es NULL — acceder a sus columnas es un error de runtime
RAISE NOTICE 'Eliminado: %', NEW.nombre;   -- NULL.nombre → error

-- ✅ En DELETE siempre usar OLD
RAISE NOTICE 'Eliminado: %', OLD.nombre;
RETURN OLD;
```

### Crear el trigger antes que la función

```sql
-- ❌ La función no existe todavía
CREATE TRIGGER tg_ejemplo
    AFTER UPDATE ON empleado
    FOR EACH ROW
    EXECUTE FUNCTION fn_que_no_existe();
-- ERROR: function fn_que_no_existe() does not exist

-- ✅ Siempre crear la función primero, luego el trigger
```

### Comparar con `<>` cuando puede haber NULL

```sql
-- ❌ Si cualquiera de los dos es NULL, retorna NULL (no FALSE)
-- El IF nunca entra aunque los valores sean distintos
IF OLD.calificacion <> NEW.calificacion THEN ...

-- ✅ IS DISTINCT FROM maneja NULL correctamente
IF OLD.calificacion IS DISTINCT FROM NEW.calificacion THEN ...
```

### Intentar modificar datos en AFTER

```sql
-- ❌ En AFTER, modificar NEW no tiene efecto (el dato ya se guardó)
CREATE OR REPLACE FUNCTION fn_after_incorrecto()
RETURNS TRIGGER AS $$
BEGIN
    NEW.nombre := UPPER(NEW.nombre);   -- esta línea no tiene efecto
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ✅ Para modificar datos antes de guardar, usar BEFORE
CREATE TRIGGER tg_normalizar
    BEFORE INSERT OR UPDATE ON empleado
    FOR EACH ROW
    EXECUTE FUNCTION fn_normalizar_nombre();
```
```

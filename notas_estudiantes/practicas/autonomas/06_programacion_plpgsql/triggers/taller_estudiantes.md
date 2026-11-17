# Taller independiente — Clase 26
**PL/pgSQL: Triggers | Base de datos: StaffHub**

---

> Los marcados ★ son para quienes terminen los ejercicios base.

---

## Esquema de referencia

```
DEPARTAMENTO   (id_departamento, nombre, ciudad, presupuesto_anual)
EMPLEADO       (id_empleado, nombre, email, fecha_ingreso, salario_cop,
                calificacion, id_departamento FK, ultima_modificacion)
CARGO          (id_empleado FK, titulo, nivel: 'junior' | 'senior' | 'lead')
LOG_AUDITORIA  (id_log SERIAL, tabla, operacion, id_registro,
                descripcion, fecha_hora, usuario_bd)
```

---

## Ejercicio 1 — Log de cambios de departamento

Crea un trigger `tg_log_cambio_depto` que se active **después** de un UPDATE en `empleado` y registre en `log_auditoria` cuando un empleado cambia de departamento. El mensaje debe indicar el nombre del departamento anterior y el nuevo. Si `id_departamento` no cambió, no registrar nada.

> **Pista:** para obtener el nombre del departamento a partir del id, necesitas un `SELECT INTO` dentro de la función trigger.

---

## Ejercicio 2 — Prevenir la eliminación de empleados con cargo lead

Crea un trigger `tg_proteger_lead` que **impida eliminar** (con `RAISE EXCEPTION`) cualquier empleado que tenga nivel `'lead'` en la tabla `cargo`. Si el empleado no tiene cargo o es de otro nivel, la eliminación debe proceder normalmente.

Pruébalo intentando eliminar a `EMP-03` (Diana Leal, lead) y a `EMP-02` (Carlos Ruiz, junior).

---

## Ejercicio 3 — Normalizar email automáticamente

Crea un trigger `tg_normalizar_email` que se active **antes** de INSERT o UPDATE en `empleado` y convierta el email a minúsculas (`LOWER()`) antes de guardarlo. Si el email es NULL, dejarlo como está.

---

## Ejercicio 4 ★ — Trigger de presupuesto

Crea un trigger `tg_control_presupuesto` que se active **antes** de INSERT o UPDATE en `empleado` y verifique que el departamento al que se asigna el empleado tiene suficiente presupuesto disponible para cubrir los salarios anuales (salario_cop × 12) de todos sus empleados más el del nuevo/modificado.

Si la asignación excede el presupuesto, lanzar un error indicando el presupuesto disponible y el costo total que generaría.

> **Pista:** calcula el gasto actual del departamento (excluye el empleado que se está modificando si es UPDATE) y suma el nuevo salario antes de compararlo con el presupuesto.

---

## Ejercicio 5 ★★ — Trigger de historial de salarios

Crea una tabla `historial_salario`:

```sql
CREATE TABLE historial_salario (
    id_historial SERIAL PRIMARY KEY,
    id_empleado  VARCHAR(10) NOT NULL REFERENCES empleado(id_empleado),
    salario_anterior INT,
    salario_nuevo    INT NOT NULL,
    fecha_cambio     DATE NOT NULL DEFAULT CURRENT_DATE,
    motivo           TEXT
);
```

Crea un trigger `tg_historial_salario` que registre automáticamente en esa tabla cada vez que cambie el `salario_cop` de un empleado. Para un INSERT inicial, registra el salario con `salario_anterior = NULL`. Para UPDATE, registra ambos valores.

Prueba el flujo completo: inserta un empleado nuevo, luego hazle dos aumentos de salario y verifica que el historial tiene 3 filas para ese empleado.

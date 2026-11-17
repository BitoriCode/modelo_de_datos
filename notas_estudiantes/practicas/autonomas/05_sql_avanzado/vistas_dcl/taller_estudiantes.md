# Taller independiente — Clase 24
**Vistas y DCL | Base de datos: StaffHub**

---

> StaffHub debe estar cargada. Si no, ejecuta `staffhub_setup.sql` (clase 23).  
> Trabaja de forma **individual**.  
> Los marcados ★ son para quienes terminen los ejercicios base.

---

## Esquema de referencia

```
DEPARTAMENTO (id_departamento, nombre, ciudad, presupuesto_anual)
EMPLEADO     (id_empleado, nombre, email, fecha_ingreso, salario_cop,
              calificacion NUMERIC(3,1), id_departamento FK)
              EMP-11 y EMP-12 no tienen departamento asignado
CARGO        (id_empleado FK, titulo, nivel: 'junior' | 'senior' | 'lead')
```

---

## Bloque A — Vistas

**1. Vista de empleados con antigüedad**

Crea una vista llamada `v_antiguedad` que muestre para cada empleado: `id_empleado`, `nombre`, `nivel` de cargo, `departamento` (o `'Sin departamento'` si no tiene), los **años completos** en la empresa y una columna `categoria_antiguedad` calculada así:

| Años | Categoría |
|------|-----------|
| Menos de 2 | `'Nuevo'` |
| 2 a 4 | `'En formación'` |
| 5 o más | `'Veterano'` |

Luego consulta la vista para mostrar solo los `'Veterano'` ordenados por años de mayor a menor.

> **Pistas:**
> - `DATE_PART('year', AGE(CURRENT_DATE, fecha_ingreso))::INT` da los años completos.
> - Usa `CASE WHEN` para calcular `categoria_antiguedad`.
> - Necesitas `LEFT JOIN` con `departamento` y `JOIN` con `cargo`.
>
> **¿Cuántas filas esperas en la vista completa?** 12. ¿Cuántos `'Veterano'`? Depende de la fecha de ejecución — con fecha de clase (2026-10-22) son los que ingresaron antes de 2022: **6 empleados**.

---

**2. Vista con presupuesto por empleado**

Crea una vista llamada `v_presupuesto_depto` que muestre por departamento: `nombre`, `ciudad`, `total_empleados`, `presupuesto_anual` y `presupuesto_por_empleado` (redondeado al millar). Incluye solo los departamentos con al menos un empleado asignado.

Luego usa la vista para encontrar el departamento con el **mayor presupuesto por empleado**.

> **Pistas:**
> - Agrupa por `departamento`.
> - `ROUND(presupuesto_anual / COUNT(empleados)::NUMERIC, -3)` para el redondeo al millar.
> - `HAVING COUNT(...) >= 1` para excluir departamentos vacíos.
>
> **¿Cuántas filas esperas?** 4 (todos tienen al menos un empleado).

---

**3. Eliminar y recrear una vista**

Elimina la vista `v_presupuesto_depto` del ejercicio anterior. Luego vuelve a crearla pero esta vez **incluyendo también los departamentos sin empleados** (con `0` en `total_empleados` y `NULL` en `presupuesto_por_empleado`).

> **Pista:** Cambia de `JOIN` a `LEFT JOIN` entre `departamento` y `empleado`. Usa `NULLIF(COUNT(e.id_empleado), 0)` para producir NULL en lugar de dividir por cero en el caso de departamentos vacíos.

---

## Bloque B — DCL

**4. Esquema de permisos por rol**

Diseña e implementa el siguiente esquema de accesos para StaffHub:

| Rol | Acceso permitido |
|-----|-----------------|
| `rol_consulta_publica` | `SELECT` sobre `v_antiguedad` y `v_presupuesto_depto` |
| `rol_rrhh` | Todo lo anterior + `SELECT`, `UPDATE` sobre `empleado` y `cargo` |

Crea ambos roles con sus permisos. Luego crea dos usuarios:
- `usr_analista` con contraseña `'analista2024'` → asígnale `rol_consulta_publica`
- `usr_rrhh` con contraseña `'rrhh2024'` → asígnale `rol_rrhh`

Verifica los privilegios finales con la consulta de `information_schema.role_table_grants`.

---

**5. ★ Vista actualizable**

Crea una vista llamada `v_salarios_marketing` que muestre `id_empleado`, `nombre` y `salario_cop` de los empleados del departamento de Marketing (`id_departamento = 2`).

- ¿Es actualizable? Justifica basándote en los criterios de vistas actualizables.
- Si lo es, aplica un aumento del **8%** al salario de todos los empleados a través de la vista (sin tocar la tabla `empleado` directamente).
- Verifica que el cambio se reflejó en la tabla base.

> **Pista:** La vista es actualizable porque cumple todos los criterios (una sola tabla, sin GROUP BY, sin funciones de agregación). El UPDATE se hace directamente sobre el nombre de la vista:
> ```sql
> UPDATE v_salarios_marketing
> SET salario_cop = ROUND(salario_cop * 1.08);
> ```

---

**6. ★ Vista con `WITH CHECK OPTION`**

Crea una vista llamada `v_junior` que muestre todos los empleados con nivel `'junior'`, con `WITH CHECK OPTION`:

```sql
CREATE VIEW v_junior AS
SELECT e.id_empleado, e.nombre, c.nivel
FROM empleado e
JOIN cargo c ON e.id_empleado = c.id_empleado
WHERE c.nivel = 'junior'
WITH CHECK OPTION;
```

Intenta actualizar un empleado junior a través de la vista para cambiarle el nivel a `'senior'`. ¿Qué ocurre y por qué? ¿Para qué sirve `WITH CHECK OPTION`?

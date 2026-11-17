# Práctica guiada — Clase 24
**Vistas y DCL | Base de datos: StaffHub**

---

> StaffHub debe estar cargada. Si no, ejecuta `staffhub_setup.sql` (clase 23).

---

## Esquema de referencia

```
DEPARTAMENTO (id_departamento, nombre, ciudad, presupuesto_anual)
EMPLEADO     (id_empleado, nombre, email, fecha_ingreso, salario_cop,
              calificacion NUMERIC(3,1), id_departamento FK)
CARGO        (id_empleado FK, titulo, nivel: 'junior' | 'senior' | 'lead')
```

---

## Bloque A — Vistas

**1.** Crea una vista llamada `v_directorio_publico` que muestre: `id_empleado`, `nombre` del empleado, nombre del `departamento`, `ciudad` del departamento y `titulo` del cargo. **No** debe incluir email, salario ni calificación. Los empleados sin departamento deben aparecer igualmente (con `'Sin departamento'` en esa columna).

**2.** Usando la vista del ejercicio anterior, escribe una consulta que liste solo los empleados de Bogotá ordenados alfabéticamente. ¿Cuántas filas obtienes?

**3.** Crea una vista llamada `v_estadisticas_nivel` que muestre, por nivel de cargo (`junior`, `senior`, `lead`): cantidad de empleados, salario promedio redondeado al millar, salario mínimo y salario máximo. Luego consúltala.

**4.** Modifica la vista `v_directorio_publico` con `CREATE OR REPLACE VIEW` para agregarle la columna `nivel` del cargo al final. Verifica que la consulta del ejercicio 2 sigue funcionando sin cambios.

---

## Bloque B — DCL

**5.** Crea un usuario llamado `analista_nomina` con contraseña `'nomina2024'`. Luego otórgale permiso de `SELECT` únicamente sobre la vista `v_directorio_publico` (no sobre las tablas base).

**6.** Crea un rol llamado `rol_reportes` y otórgale `SELECT` sobre `v_estadisticas_nivel`. Luego asigna ese rol al usuario `analista_nomina`. Verifica los privilegios con:

```sql
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND grantee IN ('analista_nomina', 'rol_reportes')
ORDER BY table_name;
```

**7.** Revoca el `SELECT` sobre `v_directorio_publico` que otorgaste directamente a `analista_nomina`. ¿Sigue teniendo acceso a `v_estadisticas_nivel` a través del rol? ¿Por qué?

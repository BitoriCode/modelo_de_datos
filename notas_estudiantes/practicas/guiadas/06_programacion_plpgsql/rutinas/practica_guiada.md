# Práctica guiada — Clase 25
**PL/pgSQL: funciones y procedimientos | Base de datos: StaffHub**

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

## Ejercicio 1 — Función escalar con IF

Crea una función llamada `categoria_calificacion` que reciba el `id_empleado` y devuelva un `TEXT` con la categoría de desempeño según su calificación:

| Calificación | Categoría |
|---|---|
| ≥ 4.5 | `'Destacado'` |
| ≥ 3.5 | `'Satisfactorio'` |
| < 3.5 | `'En desarrollo'` |
| NULL | `'Sin evaluar'` |

Luego consúltala para todos los empleados mostrando nombre, calificación y categoría, ordenado por calificación descendente.

---

## Ejercicio 2 — Función que devuelve tabla

Crea una función llamada `reporte_departamento` que reciba el `id_departamento` y devuelva una tabla con: `nombre` del empleado, `titulo` del cargo, `nivel`, `salario_cop`, `anos_en_empresa` (calculado) y `categoria_calificacion` (usando la función del ejercicio 1). Ordena por salario descendente.

Llámala con `SELECT * FROM reporte_departamento(3)` para el departamento de Finanzas.

---

## Ejercicio 3 — Procedimiento con validación

Crea un procedimiento llamado `actualizar_nivel` que reciba `p_id_empleado VARCHAR` y `p_nuevo_nivel VARCHAR`. El procedimiento debe:

1. Verificar que el empleado existe (si no, `RAISE EXCEPTION`).
2. Verificar que `p_nuevo_nivel` es un valor válido: `'junior'`, `'senior'` o `'lead'` (si no, `RAISE EXCEPTION`).
3. Verificar que el nivel nuevo es diferente al actual (si es igual, `RAISE NOTICE` y terminar sin error).
4. Actualizar el nivel en la tabla `cargo`.
5. Confirmar el cambio con `RAISE NOTICE`.

Pruébalo con:
- `CALL actualizar_nivel('EMP-02', 'senior');` — debe actualizar
- `CALL actualizar_nivel('EMP-02', 'senior');` — debe avisar que ya tiene ese nivel
- `CALL actualizar_nivel('EMP-02', 'director');` — debe fallar con error

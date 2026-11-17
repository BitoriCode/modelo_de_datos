# Taller independiente — Clase 23
**Funciones nativas de PostgreSQL | Base de datos: StaffHub**

---

> Ejecuta [staffhub_setup.sql](../../../../recursos/datasets/staffhub_setup.sql) antes de comenzar.  
> Trabaja de forma **individual**.  
> Los marcados ★ son para quienes terminen los ejercicios base.

---

## Esquema de referencia

```
DEPARTAMENTO (id_departamento, nombre, ciudad, presupuesto_anual)
EMPLEADO     (id_empleado, nombre, email, fecha_ingreso, salario_cop,
              calificacion NUMERIC(3,1), id_departamento FK)
              EMP-11 y EMP-12 no tienen departamento asignado (id_departamento = NULL)
CARGO        (id_empleado FK, titulo, nivel: 'junior' | 'senior' | 'lead')
```

---

## Ejercicio 1 — Texto: tarjetas de presentación

La empresa quiere generar tarjetas de presentación digitales para todos sus empleados. Cada tarjeta debe mostrar la información en este formato exacto:

```
ANA TORRES | Desarrolladora Full Stack | Tecnología — Bogotá
```

Es decir: `nombre en MAYÚSCULAS | título del cargo | nombre del departamento — ciudad del departamento`.

Los empleados **sin departamento asignado** (EMP-11 y EMP-12) deben mostrar `'Sin departamento'` en lugar del nombre del departamento y la ciudad.

Ordena alfabéticamente por nombre del empleado.

> **Pistas:**
> - Necesitas unir las 3 tablas: `empleado`, `cargo` y `departamento`.
> - Usa `UPPER(e.nombre)` para el nombre.
> - Para los sin departamento necesitas `LEFT JOIN` con `departamento` y `COALESCE`.
> - El separador entre nombre del departamento y ciudad es ` — ` (espacio, guion, espacio).
> - Puedes usar `||` o `CONCAT` para ensamblar el texto final.
>
> **¿Cuántas filas esperas?** 12 (todos los empleados, incluyendo los sin departamento).

---

## Ejercicio 2 — Numérico: escala salarial por nivel

El área de RRHH quiere comparar la escala salarial entre niveles de cargo. Para cada nivel (`junior`, `senior`, `lead`) muestra:
- El salario promedio redondeado al millar más cercano (`ROUND(promedio, -3)`)
- El salario mínimo y máximo del nivel
- La cantidad de empleados en ese nivel

Ordena por salario promedio de mayor a menor.

> **Pistas:**
> - Necesitas unir `empleado` con `cargo`.
> - `ROUND(valor, -3)` redondea al millar más cercano (ej: 4.200.000 → 4.000.000 con -3 dígitos... en realidad quedaría 4.200.000 → queda igual. Prueba con 4.750.000 → 5.000.000).
> - Agrupa por `c.nivel`.
>
> **¿Cuántas filas esperas?** 3 (una por nivel).

---

## Ejercicio 3 — Fecha: antigüedad y bono de lealtad

La empresa otorga un bono de lealtad basado en los años completos de antigüedad:
- **1–3 años**: bono = salario × 5%
- **4–6 años**: bono = salario × 10%
- **7 años o más**: bono = salario × 15%

Para cada empleado muestra: nombre, años completos en la empresa, el porcentaje de bono que le corresponde y el valor del bono en pesos (redondeado al peso más cercano). Ordena por años de antigüedad de mayor a menor.

> **Pistas:**
> - Para calcular años completos: `DATE_PART('year', AGE(CURRENT_DATE, fecha_ingreso))::INT`
> - Para asignar el porcentaje según años usa `CASE WHEN`:
>   ```sql
>   CASE
>       WHEN años >= 7 THEN 0.15
>       WHEN años >= 4 THEN 0.10
>       ELSE 0.05
>   END
>   ```
> - Puedes usar una subconsulta o un CTE para calcular primero los años y luego aplicar el CASE.
>
> **¿Cuántas filas esperas?** 12.

---

## Ejercicio 4 — Combinado: reporte de recursos humanos

El director de RRHH necesita un reporte completo. Para cada departamento muestra:
- Nombre del departamento y ciudad
- Número de empleados
- El nombre del empleado **mejor calificado** del departamento (mayor `calificacion`)
- La fecha en que ese empleado cumplirá **10 años** en la empresa
- El presupuesto anual del departamento por empleado (redondeado al peso)

Incluye solo los departamentos que tienen al menos 1 empleado asignado.

> **Pistas:**
> - Para el "mejor calificado" necesitas combinar `MAX(calificacion)` para encontrar el valor y luego obtener el nombre. Una forma es usar un subquery o CTE que encuentre el empleado con `MAX(calificacion)` por departamento.
> - Para la fecha del décimo aniversario: `fecha_ingreso + INTERVAL '10 years'`
> - Para el presupuesto por empleado: `presupuesto_anual / COUNT(empleados)` — usa `ROUND`.
>
> **¿Cuántas filas esperas?** 4 (los 4 departamentos tienen empleados asignados).

---

## Ejercicio 5 ★ — Texto + fecha: informe ejecutivo

Genera un informe ejecutivo en texto libre para cada empleado con el siguiente formato (una fila por empleado):

```
EMP-01 | Ana Torres lleva 7 años en Tecnología desde el 15/03/2019. Cargo: Desarrolladora Full Stack (senior). Calificación: 4.8/5.0
```

Exactamente ese formato: `id | Nombre lleva N años en Departamento desde DD/MM/YYYY. Cargo: Título (nivel). Calificación: X.X/5.0`

Para los empleados sin departamento, usar `'la empresa'` en lugar del nombre del departamento.

> **Pistas:**
> - `TO_CHAR(fecha_ingreso, 'DD/MM/YYYY')` para el formato de fecha.
> - `DATE_PART('year', AGE(CURRENT_DATE, fecha_ingreso))::INT` para los años.
> - Ensambla todo con `||` o `CONCAT`.
> - Necesitas `LEFT JOIN` con `departamento` para los empleados sin departamento.
> - Los años variarán según la fecha real de ejecución de la consulta.
>
> **¿Cuántas filas esperas?** 12.

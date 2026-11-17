# Práctica guiada — Clase 27
**Expresiones regulares | Base de datos: StaffHub**

---

## Esquema de referencia

```
EMPLEADO (id_empleado, nombre, email, fecha_ingreso, salario_cop, calificacion, id_departamento FK)
CARGO    (id_empleado FK, titulo, nivel)
```

---

## Ejercicio 1 — Búsqueda con operadores `~` y `!~`

**a)** Lista todos los empleados cuyo nombre contiene exactamente dos palabras (sin segundo apellido). Es decir, el nombre tiene exactamente un espacio.

**b)** Lista todos los empleados cuyo email NO sigue el patrón `nombre.apellido@dominio.com` (o sea, el usuario del email no contiene un punto).

**c)** Muestra el nombre y email de los empleados cuyo id sigue el patrón `EMP-0X` (X es un solo dígito, es decir del 01 al 09).

---

## Ejercicio 2 — REGEXP_REPLACE

**a)** Genera una versión "anonimizada" del email de cada empleado donde el usuario (parte antes del `@`) quede reemplazado por `'usuario'`. Por ejemplo: `ana.torres@staffhub.com` → `usuario@staffhub.com`.

**b)** Formatea los salarios como texto con puntos de miles. Por ejemplo: `4200000` → `4.200.000`. Usa `REGEXP_REPLACE` o `TO_CHAR` con el formato `'FM9G999G999'`.

---

## Ejercicio 3 — REGEXP_SPLIT_TO_ARRAY

Para cada empleado, extrae el primer nombre y el apellido usando `REGEXP_SPLIT_TO_ARRAY`. Muestra tres columnas: `nombre_completo`, `primer_nombre` y `apellido`. Ordena por apellido.

---

## Ejercicio 4 — Validación combinada

Usando expresiones regulares, identifica en la tabla `empleado` cualquier fila que tenga datos que no cumplan estas reglas:

- `id_empleado` debe tener el formato `EMP-` seguido de exactamente 2 dígitos.
- `email` debe contener exactamente un `@`.
- `nombre` no debe contener dígitos.

Muestra los empleados que **fallan** al menos una de estas validaciones. (En el dataset actual todos deberían pasar — úsalo para verificar la integridad de los datos.)

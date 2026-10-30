# Taller independiente — Clase 27
**Expresiones regulares | Base de datos: StaffHub**

---

> Los marcados ★ son para quienes terminen los ejercicios base.

---

## Esquema de referencia

```
EMPLEADO (id_empleado, nombre, email, fecha_ingreso, salario_cop, calificacion, id_departamento FK)
CARGO    (id_empleado FK, titulo, nivel)
DEPARTAMENTO (id_departamento, nombre, ciudad, presupuesto_anual)
```

---

## Ejercicio 1 — Búsqueda de patrones

**a)** Lista todos los empleados cuyo título de cargo (`titulo` de la tabla `cargo`) contiene la palabra `'de'` como palabra completa — no como parte de otra palabra. Por ejemplo, debe coincidir con `'Analista de Datos'` pero no con `'Director'`.

**b)** Muestra los empleados cuyo nombre empieza con alguna vocal (A, E, I, O, U), insensible a mayúsculas.

---

## Ejercicio 2 — Extracción de información

**a)** Para cada empleado, extrae la extensión del dominio de su email (lo que va después del último punto, por ejemplo `'com'`). Muestra nombre y la extensión extraída.

**b)** Extrae el número de empleado de cada `id_empleado` como entero. Por ejemplo, `'EMP-01'` → `1`, `'EMP-12'` → `12`. Ordena de mayor a menor.

---

## Ejercicio 3 — Limpieza y transformación

Genera un reporte de tarjetas de presentación con el siguiente formato exacto para cada empleado:

```
TORRES, Ana | Desarrolladora Full Stack | ana.torres@staffhub.com
```

Es decir: `APELLIDO, PrimerNombre | Título | email`

Donde el apellido está en MAYÚSCULAS y el primer nombre con la primera letra en mayúscula. Ordena por apellido.

> **Pista:** usa `REGEXP_SPLIT_TO_ARRAY` para separar el nombre, `UPPER` para el apellido y `||` para ensamblar.

---

## Ejercicio 4 — Validación de formato de cargos ★

Algunos títulos en la tabla `cargo` tienen formato inconsistente. Escribe una consulta que identifique los títulos que:
- Empiezan con minúscula (no con una letra mayúscula).
- Tienen dos o más espacios seguidos.
- Tienen caracteres distintos a letras, espacios y `/` (barra para cargos como `'Diseñadora UX/UI'`).

Muestra el `titulo` y el tipo de problema detectado. (En el dataset actual todos deberían estar limpios — el ejercicio enseña a escribir consultas de auditoría.)

---

## Ejercicio 5 ★★ — Función con validación por regex

Crea una función `crear_empleado_validado` que reciba todos los campos necesarios para insertar un empleado y realice estas validaciones con expresiones regulares antes de insertar:

1. `p_email`: debe tener formato `texto@texto.texto` (básico).
2. `p_id`: debe seguir el patrón `EMP-\d{2}`.
3. `p_nombre`: no debe contener dígitos ni caracteres especiales (solo letras, espacios y tildes: `[a-zA-ZáéíóúÁÉÍÓÚñÑ ]`).

Si alguna validación falla, lanzar un `RAISE EXCEPTION` descriptivo. Si todo es válido, insertar el empleado y devolver un mensaje de confirmación.

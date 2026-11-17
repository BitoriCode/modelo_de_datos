# Práctica guiada — Clase 23
**Funciones nativas de PostgreSQL | Base de datos: StaffHub**

---

> Ejecuta [staffhub_setup.sql](../../../../recursos/datasets/staffhub_setup.sql) antes de comenzar.

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

## Bloque A — Funciones de texto

**1.** Genera un directorio interno de empleados mostrando: el nombre en **mayúsculas**, el nombre del dominio extraído del email (la parte después de `@`) y la longitud total del nombre. Ordena de mayor a menor longitud.

> *Funciones a usar: `UPPER`, `SPLIT_PART`, `LENGTH`*

**2.** Construye una etiqueta de identificación para cada empleado que combine nombre, cargo y nivel en el formato:
`Ana Torres — Desarrolladora Full Stack [senior]`
Ordena alfabéticamente por nombre.

> *Funciones a usar: `CONCAT` o el operador `||`, necesitas unir con `cargo`*

**3.** Extrae el **primer nombre** de cada empleado (la palabra antes del primer espacio) y el **usuario del email** (la parte antes de `@`). Verifica que ambos coincidan o muestra las diferencias.

> *Funciones a usar: `SPLIT_PART`*

---

## Bloque B — Funciones numéricas

**4.** Muestra cada empleado con su salario en millones redondeado a 2 decimales, la calificación redondeada hacia **arriba** (`CEIL`) y hacia **abajo** (`FLOOR`), y el residuo de dividir el salario entre 500.000 (para identificar fracciones de medio millón).

> *Funciones a usar: `ROUND`, `CEIL`, `FLOOR`, `MOD`*

**5.** Por departamento, calcula: el salario promedio redondeado al entero más cercano, el salario máximo, el salario mínimo y la diferencia entre ambos. Incluye solo los departamentos con al menos 2 empleados.

> *Funciones a usar: `ROUND`, `MAX`, `MIN`, necesitas JOIN con `empleado`*

---

## Bloque C — Funciones de fecha/hora

**6.** Muestra el nombre de cada empleado, su fecha de ingreso formateada como `'15 de Marzo de 2019'` y cuántos **años completos** lleva en la empresa.

> *Funciones a usar: `TO_CHAR`, `DATE_PART` + `AGE` (o `EXTRACT`)*

**7.** Lista los empleados que ingresaron **hace más de 4 años**, mostrando su nombre, fecha de ingreso y la fecha exacta en que cumplirán (o cumplieron) **7 años** en la empresa.

> *Funciones a usar: `AGE`, `CURRENT_DATE`, `INTERVAL`*

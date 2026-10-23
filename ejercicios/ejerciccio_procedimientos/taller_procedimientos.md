# Taller independiente — Clase 25
**PL/pgSQL: funciones y procedimientos | Base de datos: StaffHub**

---

> Trabaja de forma **individual**. Los marcados ★ son para quienes terminen antes.

---

## Esquema de referencia

```
DEPARTAMENTO (id_departamento, nombre, ciudad, presupuesto_anual)
EMPLEADO     (id_empleado, nombre, email, fecha_ingreso, salario_cop,
              calificacion NUMERIC(3,1), id_departamento FK)
              EMP-11 y EMP-12 sin departamento asignado
CARGO        (id_empleado FK, titulo, nivel: 'junior' | 'senior' | 'lead')
```

---

## Ejercicio 1 — Función escalar: salario proyectado

Crea una función `salario_proyectado` que reciba el `id_empleado` y un `p_aumento_pct NUMERIC` (porcentaje de aumento). La función debe devolver el salario actual más el aumento calculado, redondeado al peso. Si el empleado no existe, devolver `NULL`.

Consúltala mostrando todos los empleados con su salario actual y el proyectado con un aumento del 8%.

---

## Ejercicio 2 — Función escalar: presupuesto disponible

Crea una función `presupuesto_disponible` que reciba el `id_departamento` y devuelva cuánto presupuesto anual le queda al departamento después de pagar los salarios anuales de sus empleados (salario_cop × 12). Si el departamento no existe, devolver `NULL`. Si no tiene empleados, devolver el presupuesto completo.

Muestra para cada departamento su nombre, presupuesto anual, gasto en salarios y lo que devuelve la función.

---

## Ejercicio 3 — Función que devuelve tabla: empleados sin departamento

Crea una función `empleados_sin_depto` sin parámetros que devuelva una tabla con los empleados que no tienen departamento asignado (`id_departamento IS NULL`). Incluye: `id_empleado`, `nombre`, `titulo`, `nivel` y `salario_cop`.

Luego consúltala con un filtro para mostrar solo los de nivel `'junior'`.

---

## Ejercicio 4 — Procedimiento con FOR y RAISE

Crea un procedimiento `listar_departamento` que reciba el `id_departamento` e itere sobre todos sus empleados con un `FOR` loop, imprimiendo para cada uno (con `RAISE NOTICE`) un mensaje en el formato:

```
[EMP-01] Ana Torres | senior | $4.200.000 | 7 años
```

Usa la función `antiguedad_anos` de la clase (o recalcula los años si no está disponible). Si el departamento no tiene empleados, imprime `'El departamento no tiene empleados registrados'`.

---

## Ejercicio 5 ★ — Procedimiento de normalización salarial

Crea un procedimiento `normalizar_salarios` que reciba el `id_departamento` y un `p_salario_objetivo INT`. El procedimiento debe:

1. Calcular el salario promedio actual del departamento.
2. Si el promedio ya supera `p_salario_objetivo`, imprimir un aviso y no hacer nada.
3. Si no, calcular el porcentaje de aumento necesario para llevar el promedio al objetivo.
4. Aplicar ese porcentaje de aumento a todos los empleados del departamento cuyo salario esté **por debajo del promedio actual**.
5. Reportar cuántos empleados fueron actualizados y el nuevo promedio del departamento.

> **Pista:** `GET DIAGNOSTICS v_n = ROW_COUNT` después del UPDATE captura cuántas filas se modificaron.

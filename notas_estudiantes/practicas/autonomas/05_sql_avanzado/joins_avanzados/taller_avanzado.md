# Taller independiente — Clase 19
**JOINs avanzados | Base de datos: MediCare**

---

> Ejecuta el bloque de preparación de [practica_guiada.md](../../../guiadas/05_sql_avanzado/joins_avanzados/practica_guiada.md) antes de comenzar.

---

## Esquema de referencia

```
ESPECIALIDAD  (id_especialidad, nombre_especialidad)
MEDICO        (id_medico, nombre_medico, id_especialidad)
PACIENTE      (id_paciente, nombre_paciente, email_paciente)
TURNO         (id_paciente, id_medico, fecha_turno, tipo_consulta, costo_cop)
              PK: (id_paciente, id_medico)
```

---

## Bloque A — RIGHT JOIN, FULL OUTER JOIN, CROSS JOIN

**1.** Lista todos los médicos con el nombre de sus pacientes. Los médicos sin ningún turno registrado deben aparecer igualmente.  
*(RIGHT JOIN con turno y paciente; debes unir las 3 tablas)*

**2.** Usa `FULL OUTER JOIN` entre `paciente` y `turno`. ¿Cuántas filas resultan en total? ¿Qué pacientes aparecen con `NULL` en las columnas del turno?

**3.** Usa `CROSS JOIN` para generar todas las combinaciones posibles de médicos y pacientes.  
¿Cuántas filas genera? ¿Cuántos turnos reales existen en la base de datos?

---

## Bloque B — Combinación

**4.** Lista los pacientes que tienen al menos un turno registrado pero ninguno de tipo `'Urgencia'`.  
*(EXISTS + NOT EXISTS, o NOT IN)*

**5.** ★ Para cada médico que tiene turnos, muestra su nombre, su especialidad y el total recaudado. Ordena de mayor a menor recaudación.  
*(INNER JOIN 3 tablas + GROUP BY)*

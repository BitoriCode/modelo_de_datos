# Taller por equipos — Clase 16
**Base de datos: MediCare | 7 equipos · 3 ejercicios cada uno**

> Ejecutar el bloque de preparación que esta en el archivo `medicare_setup.sql` antes de comenzar.

---

## Esquema de referencia

```
ESPECIALIDAD  (id_especialidad, nombre_especialidad)
MEDICO        (id_medico, nombre_medico, id_especialidad FK)
PACIENTE      (id_paciente, nombre_paciente, email_paciente)
TURNO         (id_paciente FK, id_medico FK → PK compuesta,
               fecha_turno, tipo_consulta, costo_cop)

Tipos de consulta: 'Primera vez' | 'Control' | 'Urgencia'
```

---

---

# EQUIPO 1

### Ejercicio 1
Para cada especialidad muestra su nombre, cuántos médicos tienen turnos registrados, cuántos turnos se han registrado en total y la recaudación total.
Ordena por recaudación descendente.

---

### Ejercicio 2
Muestra el nombre de todos los pacientes que **no tienen email registrado**, junto con la especialidad de cada médico que consultaron, el tipo de consulta y el costo.
Ordena por especialidad y luego por nombre del paciente.

---

### Ejercicio 3 ★
Lista los pacientes que han consultado a un médico de **cada una de las tres especialidades** disponibles (Medicina General, Pediatría y Cardiología).
Muestra solo el nombre del paciente. 

---

---

# EQUIPO 2

### Ejercicio 1
Muestra el nombre de los pacientes que tienen al menos un turno y su gasto total en la clínica.
Ordena de mayor a menor gasto.

---

### Ejercicio 2
Para cada combinación de **especialidad + tipo de consulta**, muestra cuántos turnos hay y el total recaudado.
Muestra solo las combinaciones que hayan generado **más de $200 000**. Ordena por especialidad y luego por total descendente.

---

### Ejercicio 3 ★
Lista los pacientes que tienen **más turnos que el promedio de turnos por paciente** (considerando solo pacientes con al menos un turno).
Muestra el nombre y el número de turnos.
---

---

# EQUIPO 3

### Ejercicio 1
Lista los médicos que **no han atendido ningún turno de tipo `'Urgencia'`**, incluyendo los médicos que no tienen ningún turno registrado.
Muestra nombre del médico y su especialidad.

---

### Ejercicio 2 ★
Muestra las especialidades en las que **todos sus médicos tienen al menos un turno registrado**.


---

### Ejercicio 3
Lista los pacientes que han tenido al menos un turno con un médico de **Medicina General** pero **nunca** han consultado a un médico de **Cardiología**.


---

---

# EQUIPO 4

### Ejercicio 1
Para cada paciente con al menos un turno, muestra su nombre, el tipo de su consulta **más cara**, el nombre del médico que se la realizó y el costo.

---

### Ejercicio 2
Para cada médico con turnos, muestra su nombre y el nombre del paciente que lo consultó **más recientemente** (última fecha registrada).
Incluye la fecha de ese turno. Ordena por fecha descendente.

---

### Ejercicio 3 ★
Muestra el nombre y el gasto total de los pacientes que han gastado **más que el paciente con menor gasto total** (entre los que tienen al menos un turno).
Ordena por gasto total descendente.

---

---

# EQUIPO 5

### Ejercicio 1
Usando `RIGHT JOIN` (con `turno` como tabla izquierda), muestra todos los médicos de la especialidad **Cardiología** junto con sus turnos.


---

### Ejercicio 2
Para cada especialidad, muestra su nombre y la **fecha del turno más reciente** registrado entre todos sus médicos.

---

### Ejercicio 3 ★
Lista los médicos con turnos junto con su nombre, especialidad y la **fecha de su primer turno** registrado.
Ordena de más antiguo a más reciente.
Solo deben aparecer médicos que tengan al menos un turno.

---

---

# EQUIPO 6

### Ejercicio 1
Para cada médico con al menos un turno, muestra su nombre, el número total de turnos, y cuántos de esos turnos son de tipo `'Urgencia'`.
Usa subconsultas correlacionadas (una para total, otra para urgencias). Ordena por turnos de urgencia descendente.

---

### Ejercicio 2
Para cada médico con turnos, muestra su nombre, su especialidad y el número de **tipos de consulta distintos** que ha realizado.
Solo muestra los médicos que hayan realizado exactamente **2 tipos** distintos de consulta. 

---

### Ejercicio 3 ★
Para cada paciente que ha tenido al menos un turno de tipo `'Control'`, muestra su nombre, cuántos tipos de consulta distintos tiene en total, y el costo promedio de sus turnos de `'Primera vez'` y de `'Urgencia'` (NULL si no tiene de ese tipo).


---

---

# EQUIPO 7

### Ejercicio 1
Para cada médico con turnos, muestra su nombre, la cantidad de pacientes distintos que ha atendido y la fecha de su turno más reciente.
Ordena por fecha de último turno descendente.

---

### Ejercicio 2 ★
Muestra las especialidades cuyos médicos han atendido, **en conjunto**, a más de **5 pacientes distintos**.
Muestra el nombre de la especialidad y el conteo de pacientes distintos. 

---

### Ejercicio 3
Muestra el nombre y el gasto total de los pacientes que han gastado **estrictamente más** que Ana Torres.


---

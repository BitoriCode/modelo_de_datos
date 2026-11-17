# Ejercicios de JOINs — Clase 18
**Subconsultas correlacionadas · EXISTS · INNER JOIN · LEFT JOIN · JOINs encadenados**
**Base de datos:** AeroPass

---

## Esquema de referencia

```
aerolinea (id_aerolinea PK, nombre_aerolinea)
pasajero  (id_pasajero PK, nombre_pasajero, email_pasajero)
vuelo     (id_vuelo PK, origen_vuelo, destino_vuelo, id_aerolinea FK)
reserva   (id_pasajero FK, id_vuelo FK → PK compuesta, fecha_reserva,
           num_asiento, clase, precio_cop)
```

---

---

# BLOQUE A — Subconsultas correlacionadas

> Una subconsulta correlacionada referencia una columna de la consulta exterior. Se ejecuta **una vez por cada fila** de la consulta exterior.

---

### A1 — Cantidad de reservas por pasajero

Muestra el nombre de cada pasajero y cuántas reservas tiene en total.
Ordena de mayor a menor.

---

### A2 — Pasajeros con más de 2 reservas

¿Qué pasajeros tienen **más de 2 reservas**?
Usa una subconsulta correlacionada en el `WHERE`.

---

### A3 — Precio de la reserva más cara de cada pasajero

Para cada pasajero, muestra su nombre y el precio de su reserva más cara.
Incluye pasajeros aunque no tengan reservas.

---

### A4 ★ — Pasajeros que gastaron más que el promedio general

Muestra los pasajeros cuyo gasto total en reservas supera el **promedio de gasto total** de todos los pasajeros.

---

---

# BLOQUE B — EXISTS y NOT EXISTS

> `EXISTS` devuelve `TRUE` si la subconsulta retorna **al menos una fila**.
> Se detiene al encontrar la primera coincidencia — más eficiente que `IN` para verificar existencia.

---

### B1 — Pasajeros que tienen al menos una reserva

Lista los pasajeros que hicieron **al menos una reserva**.
Usa `EXISTS`.

---

### B2 — Vuelos sin ninguna reserva

¿Qué vuelos no tienen ninguna reserva?
Usa `NOT EXISTS`.

---

### B3 — Aerolíneas que operan vuelos en clase Primera

¿Qué aerolíneas tienen **al menos un vuelo** con reservas en clase `'Primera'`?
Usa `EXISTS`.

---

### B4 ★ — Pasajeros que nunca viajaron en clase Económica

Muestra los pasajeros que **nunca** hicieron una reserva en clase `'Económica'`.
Usa `NOT EXISTS`.

---

---

# BLOQUE C — INNER JOIN

> `INNER JOIN` devuelve **solo las filas que tienen coincidencia** en ambas tablas.
> Si un registro no tiene pareja en la otra tabla, queda excluido.

---

### C1 — Unir pasajeros con sus reservas

Muestra el nombre del pasajero, el ID del vuelo, la clase y el precio de cada reserva.
Ordena por nombre del pasajero.

---

### C2 — Tres tablas: pasajero + reserva + vuelo

Muestra el nombre del pasajero, el origen y destino del vuelo, la clase y el precio de cada reserva.
Ordena por precio de mayor a menor.

---

### C3 — Cuatro tablas: incluir aerolínea

Muestra el nombre del pasajero, el nombre de la aerolínea, el origen, destino, clase y precio.
Ordena por aerolínea y luego por pasajero.

---

### C4 — Gasto total por pasajero

¿Cuánto gastó en total cada pasajero?
Muestra el nombre y el total. Ordena de mayor a menor.

---

### C5 — Filtrar después del JOIN

Muestra el nombre del pasajero y el vuelo de todas las reservas en clase `'Primera'`.
Incluye origen y destino.

---

### C6 — Ingresos por aerolínea

¿Cuánto ingresó cada aerolínea por reservas?
Muestra el nombre de la aerolínea, la cantidad de reservas y el total recaudado.

---

---

# BLOQUE D — LEFT JOIN

> `LEFT JOIN` devuelve **todas las filas de la tabla izquierda**, aunque no tengan coincidencia en la tabla derecha.
> Las columnas de la derecha aparecen como `NULL` cuando no hay pareja.

---

### D1 — Todos los pasajeros, con o sin reservas

Muestra todos los pasajeros y sus reservas.
Si un pasajero no tiene reservas, igual debe aparecer (con `NULL` en los campos de reserva).

---

### D2 — Pasajeros sin reservas

¿Qué pasajeros **no tienen ninguna reserva**?
Usa `LEFT JOIN` + `WHERE ... IS NULL`.

---

### D3 — Gasto total por pasajero, incluyendo los que no gastaron

Muestra el gasto total de **todos** los pasajeros, incluyendo los que no han hecho ninguna reserva (deben mostrar `0`, no `NULL`).
Ordena de mayor a menor.

---

### D4 — Vuelos con y sin reservas de clase Primera

Muestra todos los vuelos y, si tienen reservas en clase `'Primera'`, muestra el nombre del pasajero.
Si el vuelo no tiene clase Primera, el nombre debe aparecer como `NULL`.

---

### D5 — Comparar INNER vs LEFT JOIN

¿Cuál es la diferencia entre estas dos consultas? ¿Cuántas filas devuelve cada una?

```sql
-- Consulta A
SELECT p.nombre_pasajero, r.id_vuelo
FROM pasajero p
INNER JOIN reserva r ON p.id_pasajero = r.id_pasajero;

-- Consulta B
SELECT p.nombre_pasajero, r.id_vuelo
FROM pasajero p
LEFT JOIN reserva r ON p.id_pasajero = r.id_pasajero;
```

---

---

# BLOQUE E — JOINs encadenados con agrupación

---

### E1 — Destinos más populares

¿Cuáles son los 3 destinos de vuelo con más reservas?
Muestra el destino y la cantidad de reservas.

---

### E2 — Pasajeros con gasto superior a 1 millón

Lista los pasajeros cuyo gasto total en reservas supera **$1 000 000 COP**.
Muestra nombre, cantidad de reservas y gasto total.

---

### E3 — Aerolínea con más pasajeros únicos

¿Qué aerolínea transportó la mayor cantidad de **pasajeros distintos**?

---

### E4 — Promedio de precio por clase y aerolínea

Muestra el promedio de precio de las reservas agrupado por aerolínea y clase.
Ordena por aerolínea y luego por promedio descendente.

---

### E5 ★ — Ranking de pasajeros por aerolínea

Para cada aerolínea, muestra el pasajero que **más gastó**.
Incluye el nombre de la aerolínea, el nombre del pasajero y el monto total.

# Taller independiente — Clase 17
**DML: INSERT, UPDATE, DELETE + subconsultas | Base de datos: AeroPass**

---

## Esquema de referencia

```
AEROLINEA (id_aerolinea, nombre_aerolinea)
PASAJERO  (id_pasajero, nombre_pasajero, email_pasajero)
VUELO     (id_vuelo, origen_vuelo, destino_vuelo, id_aerolinea)
RESERVA   (id_pasajero, id_vuelo, fecha_reserva, num_asiento, clase, precio_cop)
           PK: (id_pasajero, id_vuelo)
```

> Ejecuta el bloque de preparación de [practica_guiada.md](../../../guiadas/04_sql_basico/dml_basico/practica_guiada.md) antes de comenzar.

---

## Bloque A — INSERT

**1.** Registra los siguientes tres pasajeros en un solo `INSERT`:

| id | nombre | email |
|---|---|---|
| PAS-012 | Diana Ospina | diana@mail.co |
| PAS-013 | Felipe Mora | NULL |
| PAS-014 | Isabel Reyes | isabel@mail.co |

**2.** Agrega un nuevo vuelo: `VUE-920`, de `Bogotá` a `Manizales`, operado por `AER-1`.

**3.** Registra una reserva para `PAS-012` en el vuelo `VUE-920`, fecha `2024-10-15`, asiento `4B`, clase `Ejecutiva`, precio `680000`.

**4.** Intenta insertar una reserva para `PAS-012` en el mismo vuelo `VUE-920` otra vez. ¿Qué error aparece y por qué?

---

## Bloque B — UPDATE

**5.** La aerolínea Wingo (`AER-3`) cambió su nombre a `"Wingo Airlines"`. Actualízalo.

**6.** El pasajero `PAS-013` proporcionó su email: `felipe@mail.co`. Actualízalo.

**7.** Todas las reservas en clase `'Económica'` realizadas en septiembre de 2024 subieron $30.000. Aplica el aumento.

**8.** El vuelo `VUE-613` fue reasignado a la aerolínea `AER-2`. Actualiza su `id_aerolinea`.

---

## Bloque C — DELETE

**9.** Elimina los pasajeros que no tienen email registrado **y** que tampoco tienen ninguna reserva.
*(Pista: `NOT IN (SELECT id_pasajero FROM reserva)` + `IS NULL`)*

**10.** Elimina todas las reservas en clase `'Económica'` con precio inferior al precio mínimo de clase `'Ejecutiva'`.
*(Pista: subconsulta escalar con `MIN`)*

---

## Bloque D — Subconsultas

**11.** Lista las reservas cuyo precio esté por encima del precio promedio de su propia clase.
*(Pista: subconsulta escalar para cada clase — puedes hacer una consulta por clase)*

**12.** Lista los vuelos que tienen **más de 2 reservas** registradas.
*(Pista: `IN (SELECT id_vuelo FROM reserva GROUP BY id_vuelo HAVING COUNT(*) > 2)`)*

**13.** Lista los pasajeros que hicieron reservas en **más de una clase distinta**.
*(Pista: subquery con `GROUP BY id_pasajero HAVING COUNT(DISTINCT clase) > 1`)*

**14.** ★ Sube un 5% el precio de las reservas de los pasajeros que **no tienen email registrado**.
*(UPDATE + subconsulta de lista con IS NULL)*

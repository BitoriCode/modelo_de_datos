# Solución — Normalización AeroPass

## Paso 1 — 1FN
No hay violación. Todas las celdas contienen un solo valor atómico.

---

## Paso 2 — Dependencias

| Columna | Solo de `id_pasajero` | Solo de `id_vuelo` | De la PK completa |
|---|---|---|---|
| `fecha_reserva` | | | ✓ |
| `nombre_pasajero` | ✓ | | |
| `email_pasajero` | ✓ | | |
| `origen_vuelo` | | ✓ | |
| `destino_vuelo` | | ✓ | |
| `id_aerolinea` | | ✓ | |
| `nombre_aerolinea` | | ✓ | |
| `num_asiento` | | | ✓ |
| `clase` | | | ✓ |

---

## Paso 3 — 2FN

```
Tabla A — PASAJERO:
  id_pasajero, nombre_pasajero, email_pasajero

Tabla B — VUELO:
  id_vuelo, origen_vuelo, destino_vuelo, id_aerolinea, nombre_aerolinea

Tabla C — RESERVA:
  id_pasajero, id_vuelo, fecha_reserva, num_asiento, clase
```

---

## Paso 4 — 3FN

En VUELO: `id_aerolinea → nombre_aerolinea` — dependencia transitiva.

```
Tabla nueva — AEROLINEA:
  id_aerolinea, nombre_aerolinea

Tabla B modificada — VUELO:
  id_vuelo, origen_vuelo, destino_vuelo, id_aerolinea
```

---

## Paso 5 — Esquema final en 3FN

```
AEROLINEA(id_aerolinea [PK], nombre_aerolinea)

PASAJERO(id_pasajero [PK], nombre_pasajero, email_pasajero)

VUELO(id_vuelo [PK], origen_vuelo, destino_vuelo, id_aerolinea [FK → aerolinea])

RESERVA(id_pasajero [PK, FK → pasajero],
        id_vuelo    [PK, FK → vuelo],
        fecha_reserva, num_asiento, clase)
```

**Orden de creación:** AEROLINEA → PASAJERO → VUELO → RESERVA

---

## Pregunta de análisis

`num_asiento` y `clase` dependen de ambas partes de la PK:
el mismo pasajero puede tener asiento 12A en un vuelo y 5C en otro;
el mismo vuelo tiene asientos distintos para distintos pasajeros.
No pertenecen exclusivamente ni al pasajero ni al vuelo — pertenecen a la reserva específica.

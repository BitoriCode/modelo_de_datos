# Práctica — Normalización
**AeroPass — sistema de reservas de vuelos**


---

## Tabla de partida

| id_pasajero | id_vuelo | fecha_reserva | nombre_pasajero | email_pasajero | origen_vuelo | destino_vuelo | id_aerolinea | nombre_aerolinea | num_asiento | clase |
|---|---|---|---|---|---|---|---|---|---|---|
| PAS-001 | VUE-101 | 2024-08-15 | Carlos Ruiz | carlos@mail.co | Medellín | Bogotá | AER-1 | Avianca | 12A | Económica |
| PAS-001 | VUE-205 | 2024-08-16 | Carlos Ruiz | carlos@mail.co | Bogotá | Cali | AER-2 | LATAM | 5C | Ejecutiva |
| PAS-002 | VUE-101 | 2024-08-15 | Laura Mesa | laura@mail.co | Medellín | Bogotá | AER-1 | Avianca | 12B | Económica |
| PAS-003 | VUE-312 | 2024-08-17 | Jorge Vega | jorge@mail.co | Cali | Barranquilla | AER-2 | LATAM | 7A | Económica |

**PK: (`id_pasajero`, `id_vuelo`)** — un pasajero puede reservar varios vuelos; un vuelo tiene varios pasajeros.

---

## Paso 1 — Verificar 1FN

¿Alguna columna contiene listas o grupos de columnas repetidos? **Sí / No**

```
Si marcaste Sí: columna afectada y solución:
```

---

## Paso 2 — Identificar dependencias (marca con ✓)

| Columna | Solo de `id_pasajero` | Solo de `id_vuelo` | De la PK completa |
|---|---|---|---|
| `fecha_reserva` | | | |
| `nombre_pasajero` | | | |
| `email_pasajero` | | | |
| `origen_vuelo` | | | |
| `destino_vuelo` | | | |
| `id_aerolinea` | | | |
| `nombre_aerolinea` | | | |
| `num_asiento` | | | |
| `clase` | | | |

---

## Paso 3 — Aplicar 2FN

Escribe las tablas que resultan de separar las dependencias parciales:

```
Tabla A — columnas que dependen solo de id_pasajero:


Tabla B — columnas que dependen solo de id_vuelo:


Tabla C — columnas que dependen de la PK completa:
```

---

## Paso 4 — Aplicar 3FN

Revisa la **Tabla B**. ¿`id_aerolinea` determina a `nombre_aerolinea`?

```
Sí / No — dependencia transitiva: id_vuelo → id_aerolinea → nombre_aerolinea

Tabla nueva que resuelve esto:


Tabla B modificada:
```

---

## Paso 5 — Esquema final en 3FN
---

## Pregunta de análisis

`num_asiento` y `clase` quedan en la tabla de relación. ¿Por qué no van en PASAJERO ni en VUELO?

```
Respuesta:
```

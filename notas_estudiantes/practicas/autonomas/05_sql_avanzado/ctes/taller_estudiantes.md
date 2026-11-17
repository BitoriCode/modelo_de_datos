# Taller independiente — Clase 20
**CTEs (Common Table Expressions) | Base de datos: CinePlay**

---

> Ejecuta [cineplay_setup.sql](../../../../recursos/datasets/cineplay_setup.sql) antes de comenzar.

---

## Esquema de referencia

```
GENERO       (id_genero, nombre)
PLAN         (id_plan, nombre_plan, precio_mes)
PELICULA     (id_pelicula, titulo, anio, duracion_min, id_genero FK)
USUARIO      (id_usuario, nombre, email, id_plan FK — puede ser NULL)
REPRODUCCION (id_rep, id_usuario FK, id_pelicula FK, fecha_rep, completada)
```

---

## Bloque A — CTE básico

**1.** Usa un CTE para calcular el promedio de reproducciones por usuario activo (solo los que tienen al menos una). Luego lista los usuarios que están **por encima** de ese promedio. Muestra nombre, plan y total de reproducciones.

**2.** Crea un CTE que identifique los usuarios que tienen plan activo (`id_plan IS NOT NULL`). Luego, de ese conjunto, muestra los que **nunca han reproducido** ninguna película.

**3.** Usa un CTE para calcular el total de reproducciones de cada película. Muestra solo las películas que han sido reproducidas **más de 2 veces**, con su título y género.

---

## Bloque B — CTEs encadenados

**4.** Define dos CTEs:
- `completadas_por_usuario`: cuenta cuántas reproducciones con `completada = TRUE` tiene cada usuario.
- `incompletas_por_usuario`: cuenta cuántas tienen `completada = FALSE`.

Muestra, por usuario, su nombre, cuántas completó y cuántas no completó. Incluye solo los usuarios que tienen al menos una reproducción incompleta.

**5.** Define dos CTEs encadenados:
- `repros_por_pelicula`: total de veces reproducida cada película.
- `ranking_peliculas`: agrega una columna `posicion` usando `RANK()` ... en realidad, sin funciones de ventana — ordena el CTE con `ORDER BY total DESC` y usa `LIMIT 5`.

Muestra el título, género y total de reproducciones de las 5 películas más vistas.

---

## Bloque C — CTE recursivo ★

**6.** Genera con un CTE recursivo los números del 1 al 12 (meses del año). Para cada número, muestra el nombre del mes usando `TO_CHAR(DATE '2024-01-01' + ((n-1) || ' month')::INTERVAL, 'Month')`. No es necesario cruzar con ninguna tabla.

**7. ★★** Para cada género, encuentra la película con más reproducciones. Si hay empate, deben aparecer todas las películas empatadas. Usa tres CTEs encadenados:
- `repros_pelicula`: reproducciones por película.
- `max_por_genero`: máximo de reproducciones por género.
- `ganadores`: películas que igualan ese máximo en su género.

Muestra género, título y total de reproducciones, ordenado por género.

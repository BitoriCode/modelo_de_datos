# Práctica guiada — Clase 20
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
REPRODUCCION (id_rep PK serial, id_usuario FK, id_pelicula FK,
              fecha_rep, completada)
```

---

## Bloque A — CTE básico

**1.** Usa un CTE llamado `resumen` que calcule, por usuario, cuántas películas ha reproducido en total (incluyendo los que tienen cero). Luego selecciona solo los usuarios con 3 o más reproducciones.

**2.** Crea un CTE llamado `activos` con los `id_usuario` que tienen al menos una reproducción. Luego lista los usuarios que **no** están en ese conjunto (usuarios sin ninguna reproducción).

**3.** Crea un CTE que calcule la duración promedio de todas las películas. Úsalo para listar las películas cuya duración supera ese promedio. Muestra título, duración y género.

---

## Bloque B — CTEs encadenadas

**4.** Define dos CTEs encadenados:
- `repros_genero`: total de reproducciones por género (une `pelicula` y `reproduccion`).
- `promedio_generos`: promedio de reproducciones entre todos los géneros.

Luego muestra solo los géneros con más reproducciones que ese promedio.

**5.** Define dos CTEs encadenados:
- `repros_usuario`: total de reproducciones por usuario.
- `top3`: los 3 usuarios con más reproducciones (usa `ORDER BY ... LIMIT 3` dentro del CTE).

Muestra nombre, plan y total de reproducciones para esos 3 usuarios.

---

## Bloque C — CTE recursiva

**6.** Genera la serie de meses de enero a junio de 2024 con un CTE recursivo. Para cada mes, muestra cuántas reproducciones hubo. Los meses sin actividad deben mostrar `0`.

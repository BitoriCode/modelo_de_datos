# Taller independiente — Clase 21
**DML avanzado | Base de datos: UrbanBike**

---

> Ejecuta [urbanbike_setup.sql](../../../../recursos/datasets/urbanbike_setup.sql) antes de comenzar.

---

## Esquema de referencia

```
ESTACION  (id_estacion, nombre, barrio, capacidad)
BICICLETA (id_bici, modelo, estado, id_estacion FK — NULL si en tránsito)
           estado: 'disponible' | 'en_uso' | 'mantenimiento'
CLIENTE   (id_cliente, nombre, email, plan)
           plan: 'básico' | 'premium'
VIAJE     (id_viaje, id_cliente FK, id_bici FK,
           id_origen FK, id_destino FK — NULL si en curso,
           fecha, duracion_min — NULL si en curso,
           tarifa_cop — NULL si en curso)
```

---

## Bloque A — INSERT ... SELECT

**1.** Crea una tabla `top_rutas` con las columnas `(id_origen, id_destino, total_viajes)` y pó­bla­la con las rutas que tienen **más de 1 viaje** completado, ordenadas por `total_viajes DESC`.

**2.** Crea una tabla `bicicletas_activas` con `(id_bici, modelo, total_viajes, tarifa_promedio)` e inserta los datos de todas las bicicletas con **al menos un viaje completado**.

---

## Bloque B — UPDATE ... FROM

**3.** Usando `UPDATE ... FROM`, actualiza la columna `id_estacion` de cada bicicleta al **destino de su último viaje completado**.  
*(Pista: necesitas una subconsulta o CTE que encuentre el `MAX(id_viaje)` completado por bicicleta.)*

**4.** Aplica un **descuento del 10%** a la tarifa de todos los viajes cuya bicicleta sea modelo `'Trek 3'`. Usa `UPDATE ... FROM` uniendo `viaje` con `bicicleta`.

---

## Bloque C — DELETE USING · CTE + DML

**5.** Con `DELETE USING`, elimina todos los viajes **completados** (tarifa_cop IS NOT NULL) de bicicletas que están actualmente en estado `'mantenimiento'`.  
*(¿Cuántos viajes se eliminan? ¿De qué bicicletas?)*

**6. ★** Usa un CTE llamado `bicicletas_sin_uso` que identifique las bicicletas que **no tienen ningún viaje completado**. Luego:
- Actualiza su `estado` a `'mantenimiento'`.
- Crea una tabla `log_retiro` con `(id_bici, modelo, motivo)` e inserta ahí las bicicletas retiradas con el texto `'Sin uso registrado'` en `motivo`.  
*(Dos operaciones separadas que usan el mismo CTE — ejecutar una tras otra.)*

**7. ★★** Usa dos CTEs encadenados:
- `gastos_cliente`: gasto total por cliente en viajes completados.
- `diferencia_plan`: calcula cuánto paga cada plan por mes (`precio_mes` de una tabla de referencia que debes crear o hardcodear).

Con ese resultado, actualiza el plan del cliente a `'premium'` si su `gasto_total` supera **10 veces** el precio mensual de su plan actual.  
*(Usa `UPDATE ... FROM` con el CTE.)*

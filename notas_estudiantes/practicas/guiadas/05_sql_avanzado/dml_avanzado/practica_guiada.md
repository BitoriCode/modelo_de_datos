# Práctica guiada — Clase 21
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

**1.** Crea la siguiente tabla y pó­bla­la con un único `INSERT ... SELECT` con los viajes completados agrupados por estación de **origen**:

```sql
CREATE TABLE resumen_estacion (
    id_estacion   VARCHAR(10) PRIMARY KEY REFERENCES estacion(id_estacion),
    total_viajes  INT NOT NULL,
    duracion_prom INT NOT NULL
);
```

**2.** Crea esta tabla y copia en ella todos los clientes básicos que tienen al menos un viaje completado:

```sql
CREATE TABLE clientes_basico_activos (
    id_cliente VARCHAR(10) PRIMARY KEY,
    nombre     VARCHAR(100),
    total      INT
);
```
*(Incluye el conteo de viajes completados de cada uno en la columna `total`.)*

---

## Bloque B — UPDATE ... FROM · DELETE USING · CTE + DML

**3.** Aplica un **aumento del 20%** a la tarifa de todos los viajes que partieron desde estaciones con capacidad **mayor a 10**. Usa `UPDATE ... FROM` uniendo `viaje` con `estacion`.

**4.** Elimina, con `DELETE USING`, todos los viajes en curso (`tarifa_cop IS NULL`) cuya bicicleta esté actualmente en estado `'mantenimiento'`.

**5.** Usa un CTE llamado `clientes_frecuentes` que identifique los clientes con **2 o más** viajes completados. Luego usa ese CTE en un `UPDATE` para cambiar su plan a `'premium'` si actualmente son `'básico'`.

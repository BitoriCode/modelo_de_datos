-- Preparación compartida (recursos/datasets desde la raíz de notas): aeropass_setup.sql
-- en una base de práctica. Las tablas y datos tienen una sola fuente.



-- ============================================================
--  ESQUEMA DE REFERENCIA
--
--  AEROLINEA (id_aerolinea, nombre_aerolinea)
--  PASAJERO  (id_pasajero, nombre_pasajero, email_pasajero)
--  VUELO     (id_vuelo, origen_vuelo, destino_vuelo, id_aerolinea)
--  RESERVA   (id_pasajero, id_vuelo, fecha_reserva, num_asiento, clase, precio_cop)
--  PK reserva: (id_pasajero, id_vuelo)
-- ============================================================


-- ============================================================
--  PARTE 2 — EJERCICIOS
-- ============================================================


-- ------------------------------------------------------------
--  BLOQUE A — SELECT básico
-- ------------------------------------------------------------

-- EJERCICIO 1
-- Lista todos los pasajeros.
-- Renombra las columnas como: codigo, nombre_completo, correo.



-- EJERCICIO 2
-- Lista las rutas disponibles mostrando cada vuelo en el formato:
--   "Medellín → Bogotá" en una sola columna llamada ruta.
-- (Pista: concatenación con ||)



-- EJERCICIO 3
-- ¿Cuántos destinos distintos existen en la tabla vuelo?
-- (Pista: DISTINCT + COUNT)



-- ------------------------------------------------------------
--  BLOQUE B — WHERE: filtros
-- ------------------------------------------------------------

-- EJERCICIO 4
-- Lista todas las reservas en clase 'Primera'.
-- Muestra: id_pasajero, id_vuelo, fecha_reserva y precio_cop.



-- EJERCICIO 5
-- ¿Qué pasajeros no tienen email registrado?
-- Muestra su código y nombre.



-- EJERCICIO 6
-- Lista los vuelos cuyo destino sea 'Bogotá' o 'Medellín'.
-- Usa IN.



-- EJERCICIO 7
-- Lista las reservas realizadas entre el 15 y el 31 de agosto de 2024 (incluyente).



-- EJERCICIO 8
-- Lista los pasajeros cuyo nombre empiece con la letra 'A'.
-- (No importa si es mayúscula o minúscula — usa ILIKE)



-- EJERCICIO 9
-- Lista las reservas que NO sean de clase 'Económica'.
-- Ordena por precio_cop de mayor a menor.



-- EJERCICIO 10
-- Lista las reservas de vuelos de la aerolínea 'AER-1'
-- que además sean en clase 'Económica'.
-- (Pista: JOIN no es necesario — usa id_aerolinea en la tabla vuelo
--  y luego filtra reservas. Trabaja con cada tabla por separado si aún no sabes JOIN)
-- Alternativa válida: filtra en reserva por los id_vuelo que correspondan a AER-1.



-- EJERCICIO 11
-- Lista las reservas de septiembre de 2024 que sean en clase 'Ejecutiva' o 'Primera'.
-- Ordena por fecha_reserva.



-- ------------------------------------------------------------
--  BLOQUE C — ORDER BY y LIMIT
-- ------------------------------------------------------------

-- EJERCICIO 12
-- ¿Cuáles son las 3 reservas más caras?
-- Muestra: id_pasajero, id_vuelo, clase y precio_cop.



-- EJERCICIO 13
-- Lista todos los vuelos ordenados por origen alfabéticamente
-- y, en caso de empate, por destino también alfabéticamente.



-- ------------------------------------------------------------
--  BLOQUE D — Funciones de agregación
-- ------------------------------------------------------------

-- EJERCICIO 14
-- ¿Cuántas reservas hay en total?
-- ¿Cuántos pasajeros tienen email registrado?
-- Muéstralo en una sola consulta con dos columnas.



-- EJERCICIO 15
-- ¿Cuál es el precio total de todas las reservas?
-- ¿Cuál es el precio promedio? (redondea a 0 decimales)
-- ¿Cuál es el precio más alto y el más bajo?
-- Todo en una sola consulta.



-- EJERCICIO 16
-- ¿Cuál fue la fecha de reserva más reciente y la más antigua?



-- ------------------------------------------------------------
--  BLOQUE E — GROUP BY y HAVING
-- ------------------------------------------------------------

-- EJERCICIO 17
-- ¿Cuántas reservas hay en cada clase?
-- Ordena de mayor a menor cantidad.



-- EJERCICIO 18
-- ¿Cuánto se ha recaudado en total por cada clase?
-- Muestra también el precio promedio por clase.
-- Ordena por total recaudado de mayor a menor.



-- EJERCICIO 19
-- ¿Cuántas reservas ha hecho cada pasajero?
-- Muestra el id_pasajero y el número de reservas.
-- Ordena de mayor a menor.



-- EJERCICIO 20
-- Lista solo los pasajeros que tienen más de 2 reservas.
-- Muestra el id_pasajero y el total de reservas.



-- EJERCICIO 21
-- ¿Cuántos vuelos tiene registrados cada aerolínea?
-- Muestra el id_aerolinea y el número de vuelos.
-- Muestra solo las aerolíneas con más de 2 vuelos.



-- EJERCICIO 22  ★ Desafío
-- ¿Qué clases tienen un precio promedio superior a $500.000
-- considerando únicamente las reservas realizadas en agosto de 2024?
-- Muestra la clase y el promedio redondeado.
-- (Pista: WHERE para filtrar el mes + GROUP BY + HAVING)

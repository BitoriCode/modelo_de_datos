# Preparación de los datos de práctica

[Índice de notas](../../README.md) · [Prácticas](../../practicas/README.md)

Esta carpeta es la fuente compartida de los datasets. Las notas, guías y soluciones deben cargar estos archivos, sin mantener otra copia en una carpeta de clase.

Ejecuta los scripts únicamente en una base de ejercicios: nueve de ellos **eliminan y recrean las tablas del caso**. No deben ejecutarse sobre datos que quieras conservar. Cada caso se carga en una base o esquema separado para evitar cruces de nombres. El megataller crea sus propios cuatro esquemas y rechaza la carga si alguno ya existe, sin borrarlos.

| Preparación | Uso | Recuentos iniciales |
|---|---|---|
| [algebra_setup.sql](algebra_setup.sql) | Álgebra: people y products | 8 people, 7 products |
| [aeropass_intro_setup.sql](aeropass_intro_setup.sql) | AeroPass introductorio, sin precio_cop | 3 aerolinea, 4 pasajero, 4 vuelo, 5 reserva |
| [aeropass_setup.sql](aeropass_setup.sql) | AeroPass con precios, para SELECT y JOINs | 3 aerolinea, 8 pasajero, 8 vuelo, 20 reserva |
| [techdist_setup.sql](techdist_setup.sql) | TechDist, ejercicios de SELECT y DML | 12 productos, 25 ventas |
| [medicare_setup.sql](medicare_setup.sql) | MediCare, JOINs avanzados | 4 especialidad, 10 medico, 13 paciente, 33 turno |
| [cineplay_setup.sql](cineplay_setup.sql) | CinePlay, CTEs | 6 genero, 3 plan, 12 pelicula, 10 usuario, 25 reproduccion |
| [shopeasy_setup.sql](shopeasy_setup.sql) | ShopEasy, índices y planes | 8 categoria, 14 producto, 10 cliente, 18 pedido, 30 detalle_pedido |
| [staffhub_setup.sql](staffhub_setup.sql) | StaffHub, funciones y programación | 4 departamento, 12 empleado, 12 cargo |
| [urbanbike_setup.sql](urbanbike_setup.sql) | UrbanBike, DML avanzado | 6 estacion, 10 bicicleta, 8 cliente, 21 viaje |
| [megataller_setup.sql](megataller_setup.sql) | Megataller, escenarios defectuosos de repaso | Cuatro esquemas mt_ con defectos intencionados. |

## Orden de trabajo y reinicio

1. Crea una base de práctica vacía o un esquema de ejercicios y abre su editor SQL en pgAdmin/DBeaver.
2. Ejecuta el setup completo del caso requerido, no todos los archivos de la carpeta en la misma base.
3. Comprueba sus recuentos, también disponibles en [catalogo.json](catalogo.json).
4. Ejecuta después la nota o práctica. Las plantillas incompletas y los errores esperados no forman un único script de éxito.
5. Para comparar modificaciones, restaura los datos o revierte cada variante con ROLLBACK.

En los nueve datasets de tablas, repetir el setup restaura los objetos que declara; no elimina todas las rutinas o tablas auxiliares creadas por ejercicios posteriores. Para un reinicio completo usa otra base de práctica vacía. **El megataller siempre requiere otra base vacía si ya fue preparado**: no se quitó su protección para forzar un reinicio.

## Variantes que no deben mezclarse

- **AeroPass introductorio** tiene 5 reservas y no incluye precio_cop; sirve para la primera práctica de normalización/DML.
- **AeroPass con precios** tiene 20 reservas y es el utilizado por las notas de SELECT, agregación y JOINs. No reemplazarlo por el introductorio.
- Álgebra utiliza people/products. TechDist utiliza productos/ventas: no son traducciones del mismo dataset.
- StaffHub se reutiliza en funciones nativas, vistas, PL/pgSQL y triggers. cierre_salario, log_auditoria y ultima_modificacion se crean cuando la nota los necesita.
- Los errores de diseño del megataller son parte del enunciado. Cargar sus datos no significa que sus restricciones o vistas sean soluciones correctas.

Las preparaciones particulares que forman parte de un reto DDL o de una variante distinta se conservan en ese ejercicio. Las dos copias completas idénticas de StaffHub y UrbanBike se consolidaron aquí.

Los ejemplos de programación se probaron con PostgreSQL 18.1. La versión del aula debe comprobarse antes de distribuir el entorno; los parámetros OUT de procedimientos requieren PostgreSQL 14 o posterior.

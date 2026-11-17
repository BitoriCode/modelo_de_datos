# Práctica guiada — Clase 26
**PL/pgSQL: Triggers | Base de datos: StaffHub**

---

> Carga [StaffHub](../../../../recursos/datasets/staffhub_setup.sql) y crea `log_auditoria` con la sección 6.2 de la [nota de triggers](../../../../06_programacion_plpgsql/triggers.md). No necesitas acceder a la carpeta docente.

---

## Esquema de referencia

```
DEPARTAMENTO   (id_departamento, nombre, ciudad, presupuesto_anual)
EMPLEADO       (id_empleado, nombre, email, fecha_ingreso, salario_cop,
                calificacion, id_departamento FK, ultima_modificacion)
CARGO          (id_empleado FK, titulo, nivel)
LOG_AUDITORIA  (id_log SERIAL, tabla, operacion, id_registro,
                descripcion, fecha_hora, usuario_bd)
```

---

## Ejercicio 1 — Trigger de auditoría de calificaciones

Crea un trigger llamado `tg_auditoria_calificacion` que se active **después** de un UPDATE en la tabla `empleado` y registre en `log_auditoria` cualquier cambio en la columna `calificacion`. El mensaje en `descripcion` debe tener el formato:

```
Calificación de [nombre]: 4.8 → 3.5
```

Pruébalo actualizando la calificación de dos empleados y verificando el log.

---

## Ejercicio 2 — Trigger de validación de calificación

Crea un trigger `tg_validar_calificacion` que se active **antes** de INSERT o UPDATE en `empleado` y verifique que `calificacion` esté entre `1.0` y `5.0`. Si está fuera de rango, debe lanzar un error con `RAISE EXCEPTION`. Si `calificacion` es NULL, debe dejarlo pasar sin error.

Prueba los tres casos: insertar con calificación válida, con calificación fuera de rango y con calificación NULL.

---

## Ejercicio 3 — Trigger de normalización de texto

Crea un trigger `tg_normalizar_nombre` que se active **antes** de INSERT o UPDATE en `empleado` y aplique `INITCAP()` al nombre para garantizar que siempre se guarda con la primera letra de cada palabra en mayúscula. El cambio debe hacerse directamente sobre `NEW.nombre` antes de guardarse.

Inserta un empleado de prueba con el nombre en minúsculas y verifica que se guardó correctamente normalizado.

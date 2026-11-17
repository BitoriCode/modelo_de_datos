# Taller integrador — Traslados de personal en StaffHub

[Índice de notas](../README.md) · [Ruta de estudio](../ruta_estudio_programacion.md)

## Preparación y objetivo

**Sesión de referencia:** S31, 100 minutos. Este es un taller formativo; no añade porcentajes de evaluación. Necesitas funciones, procedimientos, excepciones, triggers y DML avanzado. Utiliza una base de práctica nueva con [StaffHub](../recursos/datasets/staffhub_setup.sql) y crea la función `bono_desempeno` de [la práctica de funciones](03_funciones.md).

**Al finalizar podrás:** ejecutar una operación sobre varias tablas y demostrar que los datos y su auditoría se conservan o revierten juntos. Antes de la clase, escribe una propuesta de tablas y procedimiento. La clase se dedica a integrarla, probarla y corregirla.

El caso reutiliza el modelo conocido para concentrarse en programación; después aplica las mismas decisiones al modelo de tu proyecto.

## 1. Caso y reglas

Recursos Humanos necesita trasladar una persona a otro departamento y registrar el motivo. Cada solicitud conserva el departamento anterior y el nuevo. Además, cualquier cambio de departamento, incluso mediante UPDATE directo, debe quedar en una auditoría.

- Una persona inexistente o un departamento destino inexistente deben producir un error visible.
- El destino y el motivo son obligatorios. El motivo guardado admite hasta 80 caracteres y no puede contener solo espacios.
- Repetir el traslado al mismo departamento no crea otra solicitud ni auditoría.
- Una persona sin departamento puede recibir una primera asignación: se debe conservar el origen NULL.
- Si falla el registro de la solicitud, no puede quedar aplicado el traslado ni su auditoría.
- El bono de desempeño no cambia por el traslado; reutiliza la función para demostrarlo.

## 2. Entregables formativos

1. Tablas `solicitud_traslado` y `auditoria_departamento`, con claves y restricciones justificadas.
2. Procedimiento `solicitar_traslado(p_id VARCHAR, p_destino INT, p_motivo TEXT)` que modifique empleado y registre la solicitud.
3. Función y trigger AFTER que auditen cambios reales de departamento, incluyendo transiciones desde NULL mediante IS DISTINCT FROM.
4. Matriz con entrada, resultado esperado, resultado observado y evidencia para cada prueba.
5. Explicación de qué resuelven las restricciones, qué hace el procedimiento y por qué se justifica el trigger.

## 3. Trabajo en clase

| Actividad | Minutos |
|---|---:|
| Revisar propuesta previa y estado inicial | 10 |
| Integrar tablas y restricciones | 15 |
| Completar función reutilizada, procedimiento y trigger | 25 |
| Ejecutar y corregir pruebas positivas y negativas | 30 |
| Explicar decisiones y transferir al proyecto | 20 |
| **Total** | **100** |

## 4. Pruebas obligatorias

Parte siempre del estado inicial o revierte cada caso. No mezcles resultados de llamadas anteriores con la prueba actual.

| Caso | Entrada | Resultado esperado |
|---|---|---|
| Éxito | EMP-11 → departamento 2, motivo válido | Cambia empleado; una solicitud con origen NULL y una auditoría. |
| Repetición | Repetir el caso dentro de la misma transacción | No aumenta el número de solicitudes ni de auditorías. |
| Ausencia | EMP-99 → 2 | Error y ninguna fila nueva. |
| Destino inválido | EMP-11 → 99 | Error y ninguna modificación. |
| Nulos y espacios | Destino NULL o motivo NULL/vacío | Error, no una solicitud incompleta. |
| Fallo tardío | EMP-11 → 2, motivo de 81 caracteres | Error al registrar VARCHAR(80); se revierten también el cambio de empleado y el log previo. |
| UPDATE directo | Asignar EMP-12 a departamento 2 | Una auditoría, pero ninguna solicitud del procedimiento. |
| UPDATE sin cambio | Asignar de nuevo el mismo departamento | No crea otra auditoría. |
| ROLLBACK externo | Traslado válido dentro de BEGIN y luego ROLLBACK | Vuelven el empleado, las solicitudes y la auditoría a su estado anterior. |

La prueba de fallo tardío enseña atomicidad. Una interfaz real puede validar antes la longitud; la restricción de la tabla sigue siendo la última garantía. No hace falta usar COMMIT para probar el procedimiento.

## 5. Solución de referencia y comprobación

Intenta el taller antes de abrir [la solución SQL](../practicas/soluciones_formativas/solucion_taller_plpgsql.sql). Ese archivo crea sus tablas y rutinas, pero no vuelve a cargar StaffHub ni ejecuta traslados. Ejecútalo una sola vez en la base preparada; para repetir desde cero usa otra base de práctica.

Después puedes ejecutar esta comprobación completa:

```sql
-- practica_s31_exito
BEGIN;
CALL solicitar_traslado('EMP-11', 2, 'Refuerzo de equipo');
SELECT id_departamento FROM empleado WHERE id_empleado = 'EMP-11';
SELECT departamento_origen, departamento_destino FROM solicitud_traslado;
SELECT departamento_anterior, departamento_nuevo FROM auditoria_departamento;
SELECT bono_desempeno('EMP-11') AS bono;  -- 110000, igual que antes del traslado
CALL solicitar_traslado('EMP-11', 2, 'Solicitud repetida');
SELECT COUNT(*) AS solicitudes FROM solicitud_traslado;  -- 1
ROLLBACK;
```

No copies solo las llamadas sin preparar las tablas. Tras el ROLLBACK, EMP-11 vuelve a no tener departamento y ambas tablas auxiliares quedan vacías.

## 6. Discusión y autoevaluación

- ¿Por qué el trigger no registra solicitudes? Audita cualquier cambio; la solicitud expresa una acción explícita con un motivo, que corresponde al procedimiento.
- ¿Por qué no reemplazar el CHECK del motivo con un trigger? La regla pertenece a la fila y se expresa de forma suficiente con una restricción.
- ¿Qué demuestra un rechazo ocurrido después del UPDATE? Que una sola llamada fallida no deja una mitad de la operación ni una auditoría confirmada.
- ¿Una auditoría AFTER es un registro externo de intentos fallidos? No; participa en la misma transacción y también se revierte.
- ¿Para qué se usa FOR UPDATE en la solución? Bloquea la fila seleccionada hasta terminar la transacción. Es una ampliación sobre concurrencia; la práctica verifica atomicidad con una sesión y no sustituye una prueba de varias sesiones.

**Criterio de logro:** defender las pruebas sin depender de leer el código del compañero. Traslada después el patrón a una regla de negocio de tu proyecto, sin agregar triggers que no se necesiten.

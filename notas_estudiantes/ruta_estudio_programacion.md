# Ruta de estudio — De SQL básico a programación en PostgreSQL

[Índice de notas](README.md)

Esta ruta relaciona los materiales con las sesiones del programa propuesto. No contiene fechas ni modifica las ponderaciones. Las notas son material para estudiar y consultar; los apartados de ampliación no deben exponerse íntegros en una clase de 100 minutos.

## Material por sesión

| Sesión | Preparación y nota | Práctica y evidencia al terminar |
|---|---|---|
| S12 | [Restricciones DDL](04_sql_basico/ddl_restricciones.md); antes, CREATE TABLE y claves | Formación del personal y dos retos: justificar y comprobar PK, FK, UNIQUE, NOT NULL, CHECK y DEFAULT. |
| S16 | [DML básico](04_sql_basico/dml_basico.md); antes, SELECT y restricciones | Altas/bajas relacionadas y aumento con subconsulta; comprobar filas afectadas y revertir. |
| S25 | [Bloques y variables](06_programacion_plpgsql/01_bloques_variables.md) | Dos bloques propios: búsqueda con FOUND y agregación. |
| S26 | [Control de flujo](06_programacion_plpgsql/02_control_flujo.md) | Clasificación con IF y comparación FOR frente a SUM. |
| S27 | [Funciones](06_programacion_plpgsql/03_funciones.md) | Función escalar de bono y función tabular, con casos nulos y ausentes. |
| S28 | [Procedimientos](06_programacion_plpgsql/04_procedimientos.md) | Alta en dos tablas y asignación de departamento; demostrar ausencia de registros parciales. |
| S29 | [Errores y pruebas](06_programacion_plpgsql/05_errores.md) | Consulta STRICT y matriz de pruebas con resultados observables. |
| S30 | [Triggers](06_programacion_plpgsql/triggers.md) | Auditoría, rechazo de regla dependiente del valor anterior y prueba con ROLLBACK. |
| S31 | [Taller integrador](06_programacion_plpgsql/taller_integrador.md) | Traslado de personal, solicitud, auditoría y casos de fallo. Transferencia al proyecto. |

## Preparación común

Usa [StaffHub y las instrucciones de reinicio](recursos/datasets/README.md). Antes de los ejemplos verifica los recuentos; antes de los retos restaura las tablas o usa una base nueva si hay rutinas o tablas auxiliares de ejercicios anteriores.

Las soluciones razonadas están desplegables en cada nota. Intenta primero el ejercicio; compara después la lógica, ejecuta y registra diferencias. En S31 la solución es un archivo SQL separado. No se exige instalar otro motor ni cambiar de dataset durante el bloque de programación.

## Ritmo de una sesión ordinaria

| Momento | Minutos | Evidencia |
|---|---:|---|
| Recuperar conocimientos previos | 10 | Predicción breve antes de ejecutar. |
| Explicación y ejemplo | 25 | Identificar entradas, instrucciones y resultado. |
| Práctica guiada | 25 | Escribir y ejecutar una solución con acompañamiento. |
| Práctica autónoma | 30 | Resolver los retos sin copiar de inmediato. |
| Cierre | 10 | Explicar un resultado y un error esperado. |
| **Total** | **100** | |

S31 utiliza la distribución específica de su taller. Los 20 minutos hasta el máximo de dos horas quedan como margen de acompañamiento, no para añadir contenidos obligatorios.

## Qué dejar como ampliación

- S25: `%ROWTYPE` y `RECORD` después de dominar una variable escalar.
- S26: todas las variantes de ciclos; el núcleo es decidir y recorrer una consulta.
- S27: catálogo de funciones adicional, parámetros por defecto y consultas de catálogo.
- S28: OUT, permisos y COMMIT por etapas. El núcleo conserva atomicidad y evita confirmar pasos parciales.
- S29: catálogo completo de SQLSTATE y plantillas generales.
- S30: triggers por sentencia, INSTEAD OF, administración y variantes de WHEN después de probar un trigger por fila.

## Comprobación del aprendizaje

En cada sesión se pide escribir, ejecutar y explicar. Una captura de pantalla sin código ni predicción no demuestra que se comprenda la operación. Usa una tabla de entrada, resultado esperado, resultado observado y estado posterior; incluye al menos un caso normal y uno límite o inválido.

Estos ejercicios son formativos. Las instrucciones y rúbricas de las evaluaciones se actualizarán en la fase correspondiente; esta ruta no añade entregas calificadas ni cambia sus pesos.

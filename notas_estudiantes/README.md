# Notas de Estudio — Modelo de Datos
**Carrera:** Ingeniería de Sistemas | **Semestre:** 4  
**Herramienta del curso:** PostgreSQL + pgAdmin

---

## Cómo usar estas notas

El índice reúne las notas por temas, incluida la secuencia ampliada de PL/pgSQL. Los capítulos tienen rutas temáticas; los números de clase que aparezcan en prácticas anteriores son identificadores históricos y **no corresponden a las sesiones del calendario actualizado**.

Para estudiar, identifica el tema de la sesión en el programa de tu edición y abre la nota correspondiente. Revisa los conceptos previos antes de ejecutar ejemplos y vuelve al índice mediante el enlace al comienzo de cada capítulo.

Consulta los [diez datasets y sus instrucciones de preparación](recursos/datasets/README.md), las [prácticas guiadas y autónomas](practicas/README.md) y los [recursos](recursos/README.md). Todo está incluido en esta carpeta; no necesitas descargar las carpetas docentes ni administrativas.

## Índice por temas

### 1. Fundamentos

- [Introducción a las bases de datos](01_fundamentos/introduccion.md).
- [DBMS, tablas, tipos de datos, SQL y arquitectura ANSI/SPARC](01_fundamentos/dbms_sql_arquitectura.md).
- [Modelo de datos y tipos de usuarios](01_fundamentos/modelos_usuarios.md).

### 2. Modelo entidad-relación

- [Entidades y atributos](02_modelado_er/entidades_atributos.md).
- [Relaciones, cardinalidades y casos complejos](02_modelado_er/relaciones_casos.md).

### 3. Diseño relacional e implementación

- [Del modelo E-R al modelo relacional](03_relacional_normalizacion/conversion_relacional.md).
- [Normalización: 1FN, 2FN y 3FN](03_relacional_normalizacion/normalizacion.md).
- [DDL: introducción y primer CREATE TABLE](04_sql_basico/ddl_inicial.md).
- [DDL: restricciones, ALTER TABLE e integridad](04_sql_basico/ddl_restricciones.md).

### 4. Consultas y SQL avanzado

- [Álgebra relacional y operaciones de conjuntos](04_sql_basico/algebra_conjuntos.md).
- [SELECT, filtros y funciones de agregación](04_sql_basico/select_agregacion.md).
- [DML básico: INSERT, UPDATE, DELETE y subconsultas iniciales](04_sql_basico/dml_basico.md).
- [Subconsultas avanzadas y JOINs](05_sql_avanzado/subconsultas_joins.md).
- [JOINs avanzados y tablas derivadas](05_sql_avanzado/joins_tablas_derivadas.md).
- [CTEs: Common Table Expressions con WITH](05_sql_avanzado/ctes.md).
- [JOINs, optimización e índices](05_sql_avanzado/joins_indices.md).
- [DML avanzado: INSERT SELECT, UPDATE FROM, DELETE USING y CTE + DML](05_sql_avanzado/dml_avanzado.md).

### 5. Funciones nativas, expresiones regulares, vistas y acceso

- [Funciones nativas de texto, numéricas y fecha/hora](05_sql_avanzado/funciones_nativas.md).
- [Expresiones regulares](05_sql_avanzado/expresiones_regulares.md).
- [Vistas, usuarios y privilegios (DCL)](05_sql_avanzado/vistas_dcl.md).

### 6. Programación en PostgreSQL

- [PL/pgSQL I: bloques, variables, SELECT INTO y FOUND](06_programacion_plpgsql/01_bloques_variables.md).
- [PL/pgSQL II: condicionales y ciclos](06_programacion_plpgsql/02_control_flujo.md).
- [PL/pgSQL III: funciones y retorno de resultados](06_programacion_plpgsql/03_funciones.md).
- [PL/pgSQL IV: procedimientos y operaciones sobre varias tablas](06_programacion_plpgsql/04_procedimientos.md).
- [PL/pgSQL V: excepciones y pruebas](06_programacion_plpgsql/05_errores.md).
- [PL/pgSQL: triggers](06_programacion_plpgsql/triggers.md).
- [Taller integrador: traslados y auditoría](06_programacion_plpgsql/taller_integrador.md).

Consulta la [ruta por sesiones, objetivos y prácticas](ruta_estudio_programacion.md). La [antigua nota de funciones y procedimientos](clase_22_plpgsql_funciones_procedimientos.md) conserva su enlace y dirige a las unidades nuevas.

## Orientación para el estudio

El recorrido general es fundamentos → modelo E-R → modelo relacional y normalización → DDL → consultas → programación. Algunas notas amplias se utilizan en varias sesiones; no es necesario abordar todas sus secciones de una vez.

- Para DDL, parte del esquema relacional que vas a implementar; completa CREATE TABLE con la nota de restricciones.
- Para subconsultas y JOINs, repasa primero `SELECT`, filtros y agregación.
- Para DML avanzado, practica primero `INSERT`, `UPDATE`, `DELETE` y las subconsultas iniciales de la nota de DML básico.
- Para PL/pgSQL, repasa SQL y funciones nativas. Estudia bloques y variables antes de funciones y procedimientos; después aborda triggers.
- La introducción a regex se puede estudiar después de las funciones de texto. Sus ejemplos con funciones o triggers se retoman después de estudiar PL/pgSQL.

## Programa y evaluaciones

Las fechas, la distribución por sesiones, los contenidos evaluables y las ponderaciones se consultan en el **programa y el calendario de la edición entregados por el docente**. Este índice se centra en el material de estudio para que pueda reutilizarse entre semestres sin mantener calendarios duplicados.

---

## Herramientas para practicar SQL sin instalar nada

- [onecompiler.com/postgresql](https://onecompiler.com/postgresql) — ejecuta SQL de PostgreSQL en el navegador
- [db-fiddle.com](https://www.db-fiddle.com) — selecciona PostgreSQL en el menú

---

## Recursos recomendados

- **Documentación oficial de PostgreSQL:** [postgresql.org/docs](https://www.postgresql.org/docs/)
- **Libro de referencia:** *Fundamentals of Database Systems* — Elmasri & Navathe (el E-R está en los capítulos 3-5)
- **Libro clásico de SQL:** *Learning SQL* — Alan Beaulieu (O'Reilly)
- **draw.io:** herramienta gratuita para dibujar diagramas E-R: [app.diagrams.net](https://app.diagrams.net)

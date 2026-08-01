# Clase 1 — Introducción a las Bases de Datos
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**

---

## ¿Por qué estudiar bases de datos?

Toda aplicación que usas a diario depende de una base de datos: tu cuenta bancaria, la plataforma de streaming que ves, el sistema de notas de tu universidad, el e-commerce donde compras. Como ingeniero de sistemas **vas a diseñar, construir y mantener** estos sistemas. Necesitas entender desde los cimientos cómo se organiza y gestiona la información.

---

## 1. Datos vs. Información

Antes de hablar de bases de datos, hay que distinguir dos conceptos fundamentales:

| Concepto | Definición | Ejemplo |
|---|---|---|
| **Dato** | Hecho crudo, sin contexto ni interpretación | `22`, `'García'`, `TRUE` |
| **Información** | Datos procesados y organizados que tienen significado | *"Ana García tiene 22 años y está activa"* |

> **Clave:** Una base de datos almacena **datos**. El sistema y las consultas los convierten en **información útil**.

---

## 2. ¿Qué es una base de datos?

> Una **base de datos** es una colección organizada de datos relacionados entre sí, que representan algún aspecto del mundo real y que son gestionados por un software especializado.

Tres palabras clave en esa definición:
- **Organizada:** los datos tienen estructura, no son un caos de texto
- **Relacionados entre sí:** los datos de una tabla pueden conectarse con los de otra
- **Mundo real:** la base de datos es una representación (modelo) de algo real — una universidad, una tienda, un hospital

---

## 3. El problema de los archivos planos

Antes de los sistemas de bases de datos, las empresas guardaban su información en archivos: Excel, .csv, .txt, documentos de Word. Esto genera problemas graves:

| Problema | Descripción | Ejemplo |
|---|---|---|
| **Redundancia de datos** | El mismo dato se repite en múltiples archivos | El nombre del cliente en el archivo de ventas, en el de envíos y en el de facturación |
| **Inconsistencia** | Al actualizar, solo se cambia en un lugar y queda desactualizado en otro | El cliente cambia de dirección; se actualiza en facturación pero no en envíos |
| **Sin control de acceso** | Cualquiera puede abrir y modificar un archivo | Un empleado edita las notas de los estudiantes en Excel |
| **Concurrencia imposible** | Dos personas no pueden editar el mismo archivo a la vez | Dos vendedores actualizan el inventario simultáneamente y uno sobreescribe al otro |
| **Sin integridad** | No hay validación automática | Se guarda una edad negativa o una fecha inválida |
| **Difícil cruzar datos** | Para combinar información de dos archivos hay que hacerlo manualmente | Cruzar el listado de clientes con el de pedidos requiere horas en Excel |

Las bases de datos fueron diseñadas para resolver exactamente estos problemas.

---

## 4. Propiedades de una base de datos bien diseñada

Una buena base de datos cumple estas propiedades:

1. **Integridad:** los datos son correctos y coherentes (no existen notas de 15/10 ni edades negativas)
2. **Consistencia:** los datos no se contradicen entre sí
3. **No redundancia:** el mismo dato no se repite innecesariamente
4. **Disponibilidad:** los datos están accesibles cuando se necesitan
5. **Seguridad:** solo los usuarios autorizados pueden acceder y modificar datos
6. **Persistencia:** los datos sobreviven al apagado del sistema

---

## 5. ¿Qué es un sistema de base de datos?

Un sistema de base de datos completo tiene tres capas:

```
┌─────────────────────────────────┐
│        USUARIOS / APLICACIONES  │  ← El que consulta (tú, una app web)
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│       DBMS (Software gestor)    │  ← Intermediario inteligente
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│       BASE DE DATOS (Datos)     │  ← Los archivos físicos en disco
└─────────────────────────────────┘
```

- La **base de datos** es el conjunto de datos almacenados
- El **DBMS** es el software que la administra (PostgreSQL, MySQL, Oracle)
- Los **usuarios y aplicaciones** interactúan solo con el DBMS, nunca directamente con los archivos

> El DBMS actúa como portero: filtra quién entra, qué puede hacer, y garantiza que todo quede en orden.

---

## 6. Tipos de bases de datos

### Por modelo de datos

| Tipo | Cómo organiza los datos | Ejemplo de software | Cuándo se usa |
|---|---|---|---|
| **Relacional** | Tablas con filas y columnas | PostgreSQL, MySQL, Oracle | La gran mayoría de sistemas empresariales |
| **Documental** | Documentos JSON/BSON | MongoDB, CouchDB | APIs, catálogos de productos flexibles |
| **Clave-Valor** | Pares clave → valor | Redis, DynamoDB | Caché, sesiones de usuario |
| **Columnar** | Columnas en lugar de filas | Cassandra, HBase | Big Data, analítica masiva |
| **Grafos** | Nodos y aristas (relaciones) | Neo4j | Redes sociales, recomendaciones |

> En este curso trabajamos con el **modelo relacional** usando **PostgreSQL**, que es el estándar de la industria para aplicaciones transaccionales.

### Por tipo de carga de trabajo

| Tipo | Nombre completo | Para qué sirve | Ejemplo |
|---|---|---|---|
| **OLTP** | Online Transaction Processing | Operaciones del día a día (insertar, actualizar, eliminar) | Sistema de pagos, registro de notas |
| **OLAP** | Online Analytical Processing | Análisis de grandes volúmenes de datos históricos | Dashboard de ventas anuales, Business Intelligence |

---

## 7. Breve historia de las bases de datos

| Época | Hito |
|---|---|
| **Años 60** | Bases de datos jerárquicas (IBM IMS). Datos como árbol padre-hijo. Rígidas y difíciles de modificar. |
| **Años 70** | Bases de datos en red (CODASYL). Más flexibles que la jerárquica, pero muy complejas de programar. |
| **1970** | Edgar F. Codd (IBM) publica *"A Relational Model of Data for Large Shared Data Banks"* — nace el modelo relacional. |
| **Años 80** | Surge SQL como lenguaje estándar. Oracle, DB2, Sybase aparecen en el mercado. |
| **Años 90** | Bases relacionales dominan. Primer boom del e-commerce. PostgreSQL y MySQL aparecen como proyectos open source. |
| **Años 2000** | Explosión de datos en internet. Surgen las bases NoSQL para manejar escala masiva. |
| **Hoy** | Coexisten SQL y NoSQL. PostgreSQL es considerado el DBMS relacional open source más avanzado. |

---

## 8. ¿Por qué PostgreSQL en este curso?

- Es completamente **open source** y gratuito — ideal para aprender sin licencias
- Implementa el estándar **SQL completo** — lo que aprendas aquí aplica en Oracle, MySQL, SQL Server
- Usado en producción por Spotify, Instagram, Reddit, Twitch
- Soporta tipos avanzados: JSON, arrays, expresiones regulares, funciones propias
- Documentación oficial excelente: [postgresql.org/docs](https://www.postgresql.org/docs/)

---

## Vocabulario esencial de la Clase 1

| Término | Definición |
|---|---|
| **Dato** | Hecho crudo sin contexto |
| **Información** | Datos procesados con significado |
| **Base de datos** | Colección organizada de datos relacionados |
| **DBMS** | Software que gestiona la base de datos |
| **Sistema de base de datos** | DBMS + Base de datos + Usuarios |
| **Redundancia** | Repetición innecesaria del mismo dato |
| **Inconsistencia** | Mismo dato con valores diferentes en distintos lugares |
| **Integridad** | Garantía de que los datos son correctos |
| **OLTP** | Sistema para operaciones transaccionales del día a día |
| **OLAP** | Sistema para análisis masivo de datos históricos |
| **Modelo relacional** | Organización de datos en tablas con filas y columnas |

---

## Preguntas de autoevaluación

1. ¿Cuál es la diferencia entre un **dato** y una **información**? Da un ejemplo de cada uno.
2. Menciona **tres problemas** que ocurren al guardar datos en hojas de cálculo (Excel) en lugar de una base de datos.
3. ¿Qué diferencia hay entre una **base de datos** y un **DBMS**? ¿Cuál es el rol de cada uno?
4. Un hospital decide guardar la historia clínica de sus pacientes. ¿Usarían OLTP u OLAP? Justifica.
5. ¿Por qué el modelo **relacional** es el más usado en la industria para sistemas transaccionales?

---

## Para recordar

```
Dato ──(procesado)──► Información
Base de datos = colección organizada de datos relacionados
DBMS = software que gestiona esa colección
Archivos planos → redundancia, inconsistencia, sin control
Modelo relacional → tablas, SQL, el estándar de la industria
```

---

*Siguiente clase: DBMS en profundidad — componentes, arquitectura ANSI/SPARC e independencias.*

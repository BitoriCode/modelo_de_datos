# Clase 3 — Modelo de Datos y Tipos de Usuarios
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**

---

## Repaso rápido — Clase 2

- **DBMS:** software que gestiona la BD; tiene 5 componentes principales
- **Tabla:** filas (registros) + columnas (atributos), cada columna tiene un tipo de dato
- **SQL:** DDL (estructura), DML (datos), DCL (permisos), TCL (transacciones)
- **ANSI/SPARC:** 3 niveles — externo, conceptual, interno
- **Independencias:** física (cambiar almacenamiento sin afectar tablas) y lógica (cambiar tablas sin romper consultas)

---

## 1. ¿Qué es un modelo de datos?

Antes de crear una base de datos en PostgreSQL, alguien tiene que **planificar** qué va a contener: qué información se guarda, cómo se organiza, qué reglas debe cumplir. Ese plan es el modelo de datos.

> Un **modelo de datos** es una representación abstracta que describe qué datos existen en un sistema, cómo se relacionan entre sí, qué restricciones deben cumplir y qué operaciones se pueden realizar sobre ellos.

**Analogía:** el modelo de datos es el plano del arquitecto antes de construir el edificio. PostgreSQL es la constructora que convierte ese plano en realidad.

---

## 2. Los 3 componentes de un modelo de datos

Todo modelo de datos tiene exactamente tres componentes. Si falta uno, el modelo está incompleto.

### 2.1 Estructura — ¿qué cosas vamos a guardar?

Define las **entidades** (objetos del mundo real) y cómo se relacionan entre sí.

```
[Estudiante] ──── se matricula en ──── [Curso]
  · nombre                                · nombre
  · código                                · créditos
  · carrera                               · semestre
```

La estructura responde: ¿qué tablas necesito? ¿qué columnas tiene cada una? ¿cómo se conectan?

### 2.2 Restricciones — ¿qué está permitido y qué no?

Son las **reglas de negocio** que los datos deben cumplir. Sin restricciones, el DBMS acepta cualquier valor, incluyendo datos absurdos o fraudulentos.

| Restricción | Ejemplo |
|---|---|
| Unicidad | El código de un estudiante no puede repetirse |
| Integridad referencial | Una matrícula no puede existir sin un estudiante válido |
| Dominio | Los créditos de un curso deben ser un número positivo |
| Obligatoriedad | El nombre del estudiante no puede quedar vacío |

> Sin restricciones: PostgreSQL acepta notas negativas, matrículas sin estudiante, cursos con -3 créditos.

### 2.3 Operaciones — ¿qué se puede hacer con los datos?

Define qué acciones están permitidas sobre los datos. En el modelo relacional, las operaciones básicas son:

| Operación del modelo | Comando SQL |
|---|---|
| Leer | `SELECT` |
| Agregar | `INSERT` |
| Modificar | `UPDATE` |
| Eliminar | `DELETE` |

---

## 3. Los 3 niveles de abstracción de un modelo de datos

Un modelo de datos puede describirse a tres niveles de detalle. Cada nivel sirve para una audiencia diferente.

```
MUNDO REAL
    ↓  (análisis de requisitos — entrevistas, documentos)
NIVEL CONCEPTUAL    → "¿Qué existe?"          → Diagrama E-R
    ↓  (transformación)
NIVEL LÓGICO        → "¿Cómo se organiza?"    → Tablas y columnas
    ↓  (implementación)
NIVEL FÍSICO        → "¿Cómo se implementa?"  → SQL en PostgreSQL
```

### 3.1 Nivel conceptual

- **Qué describe:** qué entidades existen y cómo se relacionan, sin pensar en tablas ni SQL
- **Herramienta:** Diagrama Entidad-Relación (E-R) — lo veremos desde la clase 4
- **Audiencia:** diseñadores, analistas de negocio, clientes
- **Ejemplo:** *"Un Estudiante puede matricularse en varios Cursos. Un Curso puede tener muchos Estudiantes."*

### 3.2 Nivel lógico

- **Qué describe:** las tablas, columnas, tipos de datos, relaciones y restricciones — independiente del DBMS específico
- **Herramienta:** diagrama de tablas o notación relacional
- **Audiencia:** diseñadores de BD, desarrolladores
- **Ejemplo:**

```
estudiantes(id, nombre, carrera)
cursos(id, nombre, creditos)
matriculas(estudiante_id → estudiantes.id, curso_id → cursos.id, fecha, nota)
```

### 3.3 Nivel físico

- **Qué describe:** la implementación concreta en el DBMS elegido, con todos los detalles de SQL
- **Herramienta:** SQL en PostgreSQL (o MySQL, Oracle, etc.)
- **Audiencia:** desarrolladores, DBAs
- **Ejemplo:**

```sql
CREATE TABLE estudiantes (
    id      SERIAL         PRIMARY KEY,
    nombre  VARCHAR(100)   NOT NULL,
    carrera VARCHAR(80)
);

CREATE TABLE cursos (
    id       SERIAL        PRIMARY KEY,
    nombre   VARCHAR(100)  NOT NULL,
    creditos INT           NOT NULL CHECK (creditos > 0)
);

CREATE TABLE matriculas (
    estudiante_id INT REFERENCES estudiantes(id),
    curso_id      INT REFERENCES cursos(id),
    fecha         DATE NOT NULL,
    nota          NUMERIC(4,2),
    PRIMARY KEY (estudiante_id, curso_id)
);
```

### 3.4 Relación con la arquitectura ANSI/SPARC

| Nivel del modelo | Nivel ANSI/SPARC |
|---|---|
| Conceptual | Nivel conceptual |
| Lógico | Nivel conceptual (detallado) |
| Físico | Nivel interno |

> El nivel externo de ANSI/SPARC corresponde a las **vistas** que cada usuario ve — resultado de un `SELECT` sobre el modelo físico.

---

## 4. Tipos de modelos de datos (clasificación histórica)

Los modelos de datos evolucionaron a lo largo de la historia. Conocer su historia ayuda a entender por qué el modelo relacional ganó.

| Modelo | Época | Estructura | Problema |
|---|---|---|---|
| **Jerárquico** | Años 60 | Árbol padre-hijo | Solo permite relaciones uno-a-muchos; difícil navegar hacia arriba |
| **En red** | Años 70 | Grafo con nodos y aristas | Más flexible, pero extremadamente complejo de programar |
| **Relacional** | 1970 (Codd) | Tablas con filas y columnas | **Estándar actual.** Simple, flexible, soportado por SQL |
| **Orientado a objetos** | Años 90 | Objetos con atributos y métodos | Complejo; no escaló en la práctica como BD general |
| **NoSQL** | Años 2000 | Documentos, clave-valor, columnar, grafos | Sacrifica algunas garantías ACID por escala y flexibilidad |

---

## 5. Tipos de usuarios de una base de datos

Una base de datos tiene múltiples tipos de usuarios. Cada uno interactúa con el sistema de forma diferente y necesita distintos permisos.

### 5.1 Los 4 tipos principales

| Tipo | ¿Qué hace? | Nivel ANSI/SPARC | Conoce SQL |
|---|---|---|---|
| **DBA** (Database Administrator) | Gestiona todo: usuarios, backups, rendimiento, seguridad | Los 3 niveles | Experto |
| **Diseñador** | Crea el diagrama E-R y el modelo lógico antes de implementar | Conceptual | Sí (diseño, no operación) |
| **Desarrollador** | Escribe las consultas SQL y construye la aplicación | Conceptual + externo | Sí |
| **Usuario final** | Usa la aplicación en el día a día | Solo externo | No necesariamente |

**Analogías para entender cada rol:**
- **DBA:** el gerente de la bodega — tiene llave de todo y responde si algo falla
- **Diseñador:** el arquitecto — hace los planos, no construye
- **Desarrollador:** el contratista — trabaja dentro de los planos ya definidos
- **Usuario final:** quien vive en la casa — solo quiere que la luz funcione

### 5.2 Subtipos de usuario final

| Subtipo | Descripción | Ejemplo |
|---|---|---|
| **Paramétrico** | Usa formularios o aplicaciones sin saber SQL | Cajero de banco, secretaria académica |
| **Especializado** | Conoce algo de SQL y crea sus propias consultas | Analista de datos, contador con acceso directo |
| **Casual** | Accede ocasionalmente con consultas simples | Gerente que consulta reportes ocasionalmente |

### 5.3 Relación entre usuarios y niveles ANSI/SPARC

```
┌────────────────────────────────────────────────────┐
│    NIVEL EXTERNO (vistas, interfaces, reportes)    │ ← Usuario final
├────────────────────────────────────────────────────┤
│    NIVEL CONCEPTUAL (tablas, relaciones, tipos)    │ ← Diseñador, Desarrollador
├────────────────────────────────────────────────────┤
│    NIVEL INTERNO (almacenamiento físico, índices)  │ ← DBA
└────────────────────────────────────────────────────┘
```

> El usuario final **no necesita saber** que existen tablas. La aplicación le muestra la información de forma útil. El DBA decide quién accede a qué.

---

## 6. Control de acceso: autenticación y autorización

### 6.1 Autenticación — ¿Quién eres?

> **Autenticación** es el proceso de **verificar la identidad** de un usuario antes de darle acceso al sistema.

Mecanismo: usuario + contraseña (más común), certificados digitales, tokens, biometría.

**Analogía:** mostrar el carné de identidad en la entrada del edificio.

### 6.2 Autorización — ¿Qué puedes hacer?

> **Autorización** es el proceso de determinar **qué operaciones puede realizar** un usuario autenticado sobre qué recursos.

Después de entrar, ¿en qué pisos puedes estar? ¿Qué puertas puedes abrir?

**Analogía:** la lista de acceso a cada piso del edificio, diferente para cada empleado.

### 6.3 Diferencia clave

| Concepto | Pregunta que responde | Momento |
|---|---|---|
| **Autenticación** | ¿Quién eres? | Al intentar conectarse al DBMS |
| **Autorización** | ¿Qué puedes hacer? | Al intentar ejecutar una operación |

Son independientes: puedes estar autenticado y aun así no tener autorización para ciertas tablas.

### 6.4 Permisos básicos en SQL

| Permiso | ¿Qué permite? | Ejemplo de usuario que lo necesita |
|---|---|---|
| `SELECT` | Leer datos | Analista, contador |
| `INSERT` | Agregar registros | Vendedor registrando pedidos |
| `UPDATE` | Modificar registros | Docente actualizando notas |
| `DELETE` | Eliminar registros | Administrador |
| `ALL` | Todos los permisos | DBA, dueño de la tabla |

Los comandos SQL para gestionar permisos son **DCL** (vistos en clase 2):

```sql
-- Dar permiso de lectura al usuario 'analista'
GRANT SELECT ON estudiantes TO analista;

-- Dar permiso de insertar y leer
GRANT SELECT, INSERT ON pedidos TO vendedor;

-- Quitar el permiso
REVOKE INSERT ON pedidos FROM vendedor;
```

---

## 7. Principio de mínimo privilegio

> **Cada usuario solo debe tener los permisos estrictamente necesarios para realizar su trabajo. Nada más.**

Este es uno de los principios fundamentales de la **seguridad informática** y aplica directamente al diseño de bases de datos.

### 7.1 ¿Por qué es importante?

Violaciones del principio de mínimo privilegio llevan a:

| Caso | Consecuencia |
|---|---|
| El estudiante puede hacer `UPDATE` en su propia nota | Fraude académico |
| El cajero puede hacer `DELETE` en transacciones | Fraude financiero |
| El desarrollador tiene acceso a la tabla de salarios | Fuga de información confidencial |
| La aplicación web tiene permisos de `DROP TABLE` | Un atacante puede borrar toda la BD |

### 7.2 Guía práctica para asignar permisos

1. Empieza con **cero permisos** para cada usuario nuevo
2. Agrega **solo los permisos necesarios** para su rol
3. Prefiere permisos a **nivel de columna** cuando sea posible (no dar acceso a toda la tabla)
4. **Revisa periódicamente** si los permisos siguen siendo necesarios
5. Cuando un usuario cambia de rol o se va, **revoca inmediatamente** sus permisos

---

## 8. Roles — Gestión eficiente de permisos

> Un **rol** es un conjunto de permisos con nombre que puede asignarse a múltiples usuarios.

**Problema sin roles:** si tienes 50 analistas y cambias la política de acceso, debes actualizar los permisos de los 50 usuarios uno por uno.

**Solución con roles:** creas el rol `analista_datos`, le asignas los permisos y luego asignas ese rol a los 50 usuarios. Si cambia la política, solo modificas el rol.

```sql
-- Crear un rol (grupo de permisos)
CREATE ROLE analista_datos;

-- Dar permisos al rol
GRANT SELECT ON ventas TO analista_datos;
GRANT SELECT ON clientes TO analista_datos;

-- Asignar el rol a un usuario
GRANT analista_datos TO juan_perez;
GRANT analista_datos TO maria_gomez;

-- Ahora juan_perez y maria_gomez pueden hacer SELECT en ventas y clientes
```

> En PostgreSQL, los roles y los usuarios son el mismo concepto — `CREATE USER` es equivalente a `CREATE ROLE ... LOGIN`.

---

## Vocabulario esencial de la Clase 3

| Término | Definición |
|---|---|
| **Modelo de datos** | Representación abstracta de la estructura, restricciones y operaciones de una BD |
| **Estructura** | Componente del modelo que define qué entidades y relaciones existen |
| **Restricción** | Regla que los datos deben cumplir (unicidad, integridad referencial, dominio) |
| **Nivel conceptual** | Descripción de qué existe, usando diagramas E-R (independiente del DBMS) |
| **Nivel lógico** | Descripción de cómo se organiza en tablas, independiente del DBMS específico |
| **Nivel físico** | Implementación concreta en SQL sobre un DBMS específico |
| **DBA** | Administrador de la BD — gestiona todo, accede a los 3 niveles |
| **Diseñador** | Crea el modelo conceptual y lógico antes de implementar |
| **Desarrollador** | Escribe el SQL y construye la aplicación |
| **Usuario final** | Usa la aplicación sin necesitar conocer SQL |
| **Autenticación** | Verificar la identidad (¿quién eres?) |
| **Autorización** | Verificar los permisos (¿qué puedes hacer?) |
| **Mínimo privilegio** | Principio: solo dar los permisos estrictamente necesarios |
| **Rol** | Conjunto de permisos con nombre, asignable a múltiples usuarios |

---

## Preguntas de autoevaluación

1. Menciona los **3 componentes** de un modelo de datos y explica brevemente cada uno.
2. ¿Cuál es la diferencia entre el **nivel conceptual** y el **nivel lógico** de un modelo de datos?
3. Un sistema universitario tiene: el rector que necesita ver reportes generales, la secretaria que registra matrículas, el desarrollador que escribe las consultas, y el DBA que administra el servidor. Clasifica cada uno en el tipo de usuario que corresponde.
4. ¿Cuál es la diferencia entre **autenticación** y **autorización**? ¿Pueden estar desconectadas?
5. Explica con un ejemplo concreto por qué el **principio de mínimo privilegio** es importante en una base de datos universitaria.
6. ¿Qué ventaja tienen los **roles** sobre asignar permisos directamente a cada usuario?

---

## Para recordar

```
Modelo de datos = estructura + restricciones + operaciones
3 niveles: conceptual (qué existe) → lógico (cómo se organiza) → físico (SQL)
4 usuarios: DBA (todo) | Diseñador (conceptual) | Dev (SQL) | Usuario (externo)
Autenticación = ¿quién eres? | Autorización = ¿qué puedes hacer?
Mínimo privilegio = solo los permisos necesarios, nada más
Rol = conjunto reutilizable de permisos
```

---

*Siguiente clase: Modelo Entidad-Relación — el lenguaje visual para diseñar bases de datos antes de escribir SQL.*

# Clase 12 — Normalización: 1FN, 2FN y 3FN
**Materia:** Modelo de Datos | **Semestre:** 4 | **Ingeniería de Sistemas**

---

## Cadena de diseño — dónde estamos

```
Mundo real
    ↓  análisis de requisitos
Diagrama E-R (modelo conceptual)              ← Clases 4, 7, 8, 9
    ↓  transformación
Esquema relacional (modelo lógico)            ← Clase 10
    ↓  normalización  ← Estamos aquí
Esquema normalizado (modelo lógico refinado)
    ↓  implementación
SQL en PostgreSQL (DDL)                       ← Clases 11, 14
```

La normalización evalúa si las tablas del esquema relacional están bien diseñadas
antes de implementarlas en código. Su objetivo es eliminar la **redundancia**.

---

## 1. ¿Por qué normalizar? Las tres anomalías

Imagina una tabla `ORDEN_ITEM` que guarda todo en un solo lugar:

```
ORDEN_ITEM
id_orden | id_producto | fecha_orden | id_cliente | nombre_cliente | ciudad_cliente | nombre_producto | precio_unidad | cantidad
ORD-001  | PROD-A      | 2024-03-01  | CLI-10     | Ana Torres     | Medellín       | Teclado USB     | 45.000        | 2
ORD-001  | PROD-B      | 2024-03-01  | CLI-10     | Ana Torres     | Medellín       | Mouse inalámbrico| 35.000       | 1
ORD-002  | PROD-A      | 2024-03-02  | CLI-20     | Luis Pérez     | Bogotá         | Teclado USB     | 45.000        | 1
ORD-003  | PROD-C      | 2024-03-03  | CLI-10     | Ana Torres     | Medellín       | Webcam HD       | 120.000       | 1
```

Esta tabla tiene **redundancia**: "Ana Torres, Medellín" y "Teclado USB, 45.000" aparecen repetidos.
Esa redundancia causa tres tipos de anomalías:

| Anomalía | Descripción | Ejemplo concreto |
|---|---|---|
| **Actualización** | Cambiar un dato exige modificar muchas filas. Si se olvida alguna, la BD queda inconsistente. | Ana Torres se muda: hay que actualizar 3 filas. Si una queda como "Medellín" y otras como "Cali", la BD contradice a sí misma. |
| **Eliminación** | Borrar una fila puede destruir información valiosa. | Cancelar ORD-002 (única orden de CLI-20) borra que Luis Pérez existe como cliente. |
| **Inserción** | No se puede insertar ciertos datos sin otros datos que "no aplican todavía". | No puedo registrar un producto nuevo (Webcam 4K) hasta que alguien lo compre, porque id_orden sería NULL — viola la PK. |

> **Diagnóstico:** las anomalías ocurren porque un mismo dato está en más de una fila.
> La normalización descompone la tabla para que cada hecho se almacene exactamente una vez.

---

## 2. Integridad referencial

La **integridad referencial** garantiza que las relaciones entre tablas sean consistentes al momento de insertar, actualizar o eliminar datos.

En una relación 1:N, cada fila de la tabla hija (lado N) debe tener un registro correspondiente en la tabla padre (lado 1). No puede existir un hijo sin padre.

**Ejemplo:** si `INSCRIPCION` tiene `cod_estudiante` como FK hacia `ESTUDIANTE`, no puede existir una inscripción cuyo `cod_estudiante` no exista en `ESTUDIANTE`.

| Operación | Lo que la integridad referencial prohíbe |
|---|---|
| INSERT en tabla hija | Insertar un valor de FK que no existe en la tabla padre |
| DELETE en tabla padre | Eliminar un padre que aún tiene filas hijas referenciándolo |
| UPDATE en tabla padre | Cambiar la PK de un padre que aún tiene filas hijas |

> En SQL se implementa con `REFERENCES` (clase 14). La normalización separa los datos en tablas correctas; la integridad referencial mantiene las relaciones consistentes entre esas tablas.

---

## 3. Dependencias funcionales

Una **dependencia funcional (DF)** expresa que un atributo (o conjunto) determina unívocamente a otro:

```
X → Y     "X determina funcionalmente a Y"
           "si conozco X, sé exactamente cuál es Y"
```

**Ejemplos:**
- `id_cliente → nombre_cliente` — si sé el id del cliente, sé su nombre
- `id_producto → precio_unidad` — si sé el id del producto, sé su precio
- `cod_categoria → nombre_categoria` — si sé el código de categoría, sé su nombre
- `(id_orden, id_producto) → cantidad` — necesito AMBOS para saber cuánto se vendió

> La PK de una tabla debe determinar a TODOS los demás atributos.
> Cuando otros atributos no-clave se determinan entre sí, eso es un problema.

---

## 4. Primera Forma Normal (1FN)

**Regla:** cada celda contiene un **único valor atómico**. No hay listas ni grupos de valores repetidos.

### Ejemplo de violación

```
EMPLEADO(id_emp, nombre, idiomas)

id_emp | nombre      | idiomas
-------+-------------+---------------------------
EMP-01 | Carlos Ruiz | "español, inglés, francés"
EMP-03 | David Kim   | "inglés, coreano"
```

`idiomas` es multivaluado — viola 1FN.

### Cómo se corrige

Crear una tabla nueva con **una fila por valor**. La PK de la nueva tabla es compuesta.

```
EMPLEADO(id_emp [PK], nombre)

EMPLEADO_IDIOMA(id_emp [PK, FK → empleado], idioma [PK])

id_emp | idioma
-------+-----------
EMP-01 | español
EMP-01 | inglés
EMP-01 | francés
EMP-03 | inglés
EMP-03 | coreano
```

### Señales de violación de 1FN
- Columnas con listas separadas por comas: `"español, inglés, francés"`
- Grupos de columnas con el mismo concepto: `telefono1`, `telefono2`, `telefono3`
- Columnas que contienen JSON o XML embebido
### Tipo 2: grupos de columnas repetidas

Otra forma de violar 1FN es crear múltiples columnas para el mismo tipo de dato:

```
EMPLEADO(id_emp, nombre, tel_1, tel_2, tel_3)
```

Problemas:
- Si se necesita un cuarto teléfono hay que **cambiar la estructura** de la tabla.
- Si el empleado solo tiene un teléfono, `tel_2` y `tel_3` quedan en `NULL`.
- No hay forma simple de contar cuántos teléfonos tiene sin revisar qué columnas tienen `NULL`.

**Corrección:** tabla separada con una fila por valor:
```
EMPLEADO_TELEFONO(id_emp [PK, FK → empleado], telefono [PK])
```

### Principio adicional: independencia del orden

Las filas de una tabla no deben depender de su orden físico para tener significado.
Cada fila se identifica por su PK, no por su posición. Las consultas que requieren orden deben usar `ORDER BY` explícito — nunca asumir que el motor devuelve las filas en un orden particular.
---

## 5. Segunda Forma Normal (2FN)

**Regla:** la tabla está en 1FN **y ningún atributo no-clave depende de solo una parte de la PK compuesta**.

> 2FN **solo aplica** cuando la PK es compuesta (más de una columna).
> Si la PK es de una sola columna y la tabla está en 1FN, automáticamente está en 2FN.

Una **dependencia parcial** ocurre cuando un atributo `A` depende solo de `X` (parte de la PK `X, Y`),
y no de `Y`.

### Ejemplo

```
ORDEN_ITEM(id_orden, id_producto, fecha_orden, nombre_cliente, nombre_producto, precio_unidad, cantidad)
PK: (id_orden, id_producto)
```

| Atributo | Depende de… | ¿Parcial? |
|---|---|---|
| `fecha_orden` | solo `id_orden` | ⚠ Sí — parcial |
| `nombre_cliente` | solo `id_orden` | ⚠ Sí — parcial |
| `nombre_producto` | solo `id_producto` | ⚠ Sí — parcial |
| `precio_unidad` | solo `id_producto` | ⚠ Sí — parcial |
| `cantidad` | `id_orden` **y** `id_producto` | ✅ No — completa |

### Cómo se corrige

Cada grupo de dependencias parciales sale a su propia tabla:

```
ORDEN(id_orden [PK], fecha_orden, nombre_cliente)
              ↑ todo lo que depende solo de id_orden

PRODUCTO(id_producto [PK], nombre_producto, precio_unidad)
                 ↑ todo lo que depende solo de id_producto

ORDEN_ITEM(id_orden [PK, FK], id_producto [PK, FK], cantidad)
                      ↑ solo lo que depende de la PK completa
```

---

## 6. Tercera Forma Normal (3FN)

**Regla:** la tabla está en 2FN **y ningún atributo no-clave determina a otro atributo no-clave**.

Una **dependencia transitiva** ocurre cuando existe una cadena:
`PK → A → B`, donde `A` no es clave pero determina `B`.

### Ejemplo

Después de aplicar 2FN al ejemplo anterior, la tabla ORDEN queda:

```
ORDEN(id_orden, fecha_orden, id_cliente, nombre_cliente, ciudad_cliente)
PK: id_orden
```

Dependencias presentes:
- `id_orden → fecha_orden` ✅ (id_orden es la PK)
- `id_orden → id_cliente` ✅ (id_orden es la PK)
- `id_cliente → nombre_cliente` ⚠ **transitiva** — `id_cliente` no es la PK
- `id_cliente → ciudad_cliente` ⚠ **transitiva**

Cadena: `id_orden → id_cliente → {nombre_cliente, ciudad_cliente}`

Y en PRODUCTO:

```
PRODUCTO(id_producto, nombre_producto, cod_categoria, nombre_categoria, precio_unidad)
PK: id_producto
```

- `cod_categoria → nombre_categoria` ⚠ **transitiva** — `cod_categoria` no es la PK

### Cómo se corrige

El atributo que "causa" la transitiva sale a su propia tabla, llevándose todo lo que determina.
La tabla original se queda solo con la FK.

```
ORDEN(id_orden [PK], fecha_orden, id_cliente [FK])
CLIENTE(id_cliente [PK], nombre_cliente, ciudad_cliente)
              ↑ nueva tabla

PRODUCTO(id_producto [PK], nombre_producto, cod_categoria [FK], precio_unidad)
CATEGORIA(cod_categoria [PK], nombre_categoria)
              ↑ nueva tabla

ORDEN_ITEM(id_orden [PK, FK], id_producto [PK, FK], cantidad)
              ↑ sin cambios
```

---

## 7. El proceso completo de normalización

### Hoja de ruta

| Forma | Pregunta que responde | Acción correctiva |
|---|---|---|
| **1FN** | ¿Hay celdas con múltiples valores? | Crear tabla nueva con una fila por valor; PK compuesta. |
| **2FN** | ¿Algún no-clave depende de PARTE de la PK compuesta? | Separar cada grupo de dependencias parciales en su propia tabla. |
| **3FN** | ¿Algún no-clave determina a otro no-clave? | Sacar el atributo determinante y sus dependencias a una tabla nueva; dejar solo la FK. |

### Resultado final — ORDEN_ITEM en 3FN

```
ORDEN(id_orden [PK], fecha_orden, id_cliente [FK → cliente])
CLIENTE(id_cliente [PK], nombre_cliente, ciudad_cliente)
PRODUCTO(id_producto [PK], nombre_producto, cod_categoria [FK → categoria], precio_unidad)
CATEGORIA(cod_categoria [PK], nombre_categoria)
ORDEN_ITEM(id_orden [PK, FK → orden], id_producto [PK, FK → producto], cantidad)
```

Cinco tablas. Cada hecho almacenado exactamente una vez. Las tres anomalías, eliminadas.

---

## 8. Señales rápidas para detectar problemas

| Si ves esto en una tabla… | Forma normal que viola | Acción |
|---|---|---|
| Columna con lista de valores (`"a, b, c"`) | 1FN | Tabla nueva con una fila por valor |
| Columna que no cambia al cambiar parte de la PK compuesta | 2FN | Sacar a tabla propia |
| Columna que determina otras columnas no-clave | 3FN | Sacar a tabla propia con FK |
| El mismo dato aparece en muchas filas | Cualquiera | Analizar de dónde viene la redundancia |

---

## 9. Normalización vs. E-R → Relacional

Cuando se aplican bien las 9 reglas de conversión E-R → Relacional (clase 10), el esquema resultante
**generalmente ya está en 3FN**. La normalización actúa como verificación y corrección:

- Si el E-R tenía atributos multivaluados y se convirtieron correctamente → ya estamos en 1FN.
- Si las entidades estaban bien separadas → raramente hay violaciones de 2FN.
- Si los atributos derivados se eliminaron → menos riesgo de transitivas.

La normalización es especialmente útil cuando:
- Se hereda una BD existente con tablas mal diseñadas.
- Se diseña directamente en tablas sin pasar por el E-R.
- Se quiere auditar el diseño antes de implementarlo.

---

## 10. Datos calculados — no los almacenes

Un **dato calculado** es aquel que puede obtenerse ejecutando una consulta sobre datos ya almacenados. Guardarlo introduce redundancia y obliga a mantener dos copias sincronizadas.

| Dato calculado | Cómo obtenerlo sin almacenarlo |
|---|---|
| `edad` de una persona | `CURRENT_DATE - fecha_nacimiento` en la consulta |
| `total_orden` | `SUM(precio_unidad * cantidad)` sobre los ítems |
| `num_cursos_profesor` | `COUNT(*)` sobre la tabla de asignaciones |
| `num_vuelos_aeronave` | `COUNT(*)` sobre la tabla de vuelos |

**Regla:**
> *"No almacenes datos que puedes calcular. Si lo haces, tienes dos copias del mismo hecho. Cuando una cambia y la otra no, la base de datos miente."*

**Excepción:** en sistemas de alto rendimiento a veces se almacenan resultados precomputados (caché de BD). Es una decisión consciente y documentada, no un hábito.

> Conecta con lo que ya sabes: en el Modelo E-R los **atributos derivados** (como `edad` en clase 4) se marcaban con línea discontinua y se omitían al pasar al esquema relacional. La misma razón aplica aquí.

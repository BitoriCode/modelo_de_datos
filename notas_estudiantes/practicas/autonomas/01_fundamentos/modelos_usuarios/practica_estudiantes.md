# Práctica — Diseño de modelo de datos
**Curso:** Modelos de Datos | **Clase 3**

---

## Enunciado — MelodyStream

MelodyStream es una plataforma de streaming de música que quiere construir su base de datos desde cero. La empresa te contrató como diseñador de datos para definir el modelo antes de que los desarrolladores empiecen a programar.

Lo que sabes del negocio:

- Los usuarios se registran con su nombre, correo electrónico y fecha de nacimiento. Pueden tener una suscripción gratuita o premium. La suscripción premium tiene un precio mensual y habilita funciones como escuchar sin anuncios y descargar canciones para escuchar sin internet.

- La plataforma tiene canciones. Cada canción tiene un título, una duración y pertenece a un álbum. Algunos álbumes son de un solo artista; otros son compilaciones con múltiples artistas. Cada canción puede tener géneros asociados (pop, rock, reggaeton, etc.).

- Los artistas tienen un nombre artístico, un país de origen y un estado de verificación (verificado / no verificado). Un artista puede tener múltiples álbumes a lo largo de su carrera.

- Los usuarios pueden crear listas de reproducción (playlists) con las canciones que quieran. Una playlist puede ser pública (visible para todos) o privada (solo para su creador). Una misma canción puede aparecer en múltiples playlists.

- La plataforma registra el historial de reproducciones: qué usuario escuchó qué canción, cuándo y desde qué tipo de dispositivo (móvil, escritorio, TV). Este historial es la base de las recomendaciones.

- Los usuarios también pueden seguir a artistas para recibir notificaciones cuando publiquen música nueva.

---

## Actividad 1 — Estructura

¿Qué "cosas" del negocio necesitamos guardar? Para cada entidad que identifiques, define:

- **Nombre** de la entidad
- **Atributos** que la describen
- **Atributo identificador** — el que la hace única (su "cédula")


> **Pregunta de debate:** ¿"Género musical" es una entidad o simplemente un atributo de canción? ¿Por qué importa esa decisión?

---

## Actividad 2 — Restricciones

Para cada entidad y relación, define las reglas de integridad que el sistema debe garantizar siempre. Para cada restricción indica:

- A qué **entidad o relación** aplica
- Qué **regla** establece
- **Por qué importa** (qué pasaría si no existiera)

> **Mínimo:** 2 restricciones por cada entidad identificada en la Actividad 1.

---

## Actividad 3 — Relaciones

Conecta las entidades entre sí. Para cada relación indica:

- Las **dos entidades** que se conectan
- El **nombre** de la relación (un verbo: "tiene", "pertenece a", "crea", "escucha"…)
- La **naturaleza** de la relación:
  - **1 a 1** — cada A se relaciona con exactamente un B y viceversa
  - **1 a N** — cada A puede tener muchos B, pero cada B pertenece a un solo A
  - **N a M** — cada A puede relacionarse con muchos B, y cada B con muchos A
- Una **justificación** de por qué elegiste esa naturaleza

> **Ejemplo del enunciado para arrancar:**
> *"Un artista puede tener muchos álbumes, pero cada álbum pertenece a un artista"*
> → Artista — *publica* → Álbum **(1 a N)**

> **Pregunta de debate:** ¿Puede una canción tener más de un artista? (Piensa en canciones con "feat." — ej: *Canción X ft. Artista Y*). ¿Cómo cambiaría eso la relación entre Canción y Artista?


---

## Actividad 4.

**Parte A — Nivel de abstracción**

El diseño que hiciste en las Actividades 1, 2 y 3, ¿en qué nivel de abstracción está: conceptual, lógico o físico? ¿Qué le faltaría para pasar al siguiente nivel?

**Parte B — Usuarios del sistema**

Identifica los tipos de usuarios que interactuarían con MelodyStream desde el punto de vista de la base de datos. Para cada tipo indica qué operaciones necesitaría (SELECT / INSERT / UPDATE / DELETE) y sobre qué entidades.

**Parte C — Reflexión final**

Durante el diseño, ¿encontraste alguna decisión difícil de tomar? ¿Hubo algo que el enunciado no decía claramente y tuviste que asumir?

Anota esas decisiones — en un proyecto real, esas son exactamente las preguntas que le harías al cliente antes de implementar.

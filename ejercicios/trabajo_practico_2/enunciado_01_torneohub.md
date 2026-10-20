# Enunciado 1 — TorneoHub
## Evento Evaluativo VI | Modelo de Datos

---

TorneoHub es una plataforma digital colombiana que permite a federaciones deportivas, ligas amateur y clubes independientes organizar y gestionar torneos de distintas disciplinas. La plataforma atiende principalmente torneos de fútbol, baloncesto, voleibol y tenis de mesa, aunque aspira a soportar cualquier deporte estructurado en equipos o individuos.

Las organizaciones que usan la plataforma registran sus torneos con un nombre, la disciplina, la ciudad sede, las fechas de inicio y cierre de inscripciones, la fecha de inicio de competencia y el formato de juego (grupos + eliminación, todos contra todos, eliminación directa). Cada torneo define además un número máximo de equipos participantes y una cuota de inscripción.

Los equipos que participan en un torneo se inscriben formalmente, y esa inscripción tiene una fecha y un estado que puede cambiar si el equipo es descalificado o se retira. Cada equipo tiene un nombre, una ciudad de origen y un representante o delegado que responde por él ante la organización. Un equipo puede participar en varios torneos a lo largo del tiempo, y un torneo recibe múltiples equipos.

Cada equipo está conformado por jugadores. Un jugador tiene número de documento, nombre completo, fecha de nacimiento y posición habitual dentro del campo de juego. Un jugador puede pertenecer a diferentes equipos en diferentes torneos, pero dentro de un mismo torneo solo puede estar inscrito en un equipo. La plataforma lleva el registro de esa inscripción por torneo.

Los partidos son el núcleo operativo del sistema. Cada partido enfrenta exactamente dos equipos, ocurre en una fecha y hora determinadas, y se realiza en una cancha o instalación que tiene nombre, dirección y aforo. Al finalizar el partido, el sistema registra el marcador de cada equipo. Si el partido no ha sido jugado aún, el marcador permanece sin registrar.

La plataforma cuenta también con árbitros registrados. Cada árbitro tiene un número de licencia, nombre, categoría de certificación y años de experiencia. A cada partido se le asigna un árbitro principal; opcionalmente puede tener árbitros asistentes. La misma persona puede arbitrar partidos de diferentes torneos.

Finalmente, el sistema calcula automáticamente la tabla de posiciones de cada torneo según los resultados registrados: puntos acumulados, partidos jugados, ganados, empatados y perdidos, diferencia de goles o puntos según la disciplina. Estos datos no se almacenan directamente sino que se calculan a partir de los resultados de los partidos.

---

*Construye el modelo de datos completo según las instrucciones generales del Evento VI.*

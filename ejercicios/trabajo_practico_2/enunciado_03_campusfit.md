# Enunciado 3 — CampusFit
## Evento Evaluativo VI | Modelo de Datos

---

CampusFit es una red de gimnasios con sedes en varias ciudades colombianas. A diferencia de los gimnasios tradicionales, CampusFit opera con un modelo de membresía cruzada: un miembro puede usar cualquier sede de la red con la misma membresía. La empresa quiere un sistema centralizado que gestione sedes, miembros, planes, clases grupales y equipos.

Cada sede tiene nombre, ciudad, dirección, teléfono y un gerente responsable. Las sedes tienen equipos de ejercicio registrados individualmente: cada equipo tiene un identificador, tipo (cardio, pesas, funcional, rehabilitación), marca, fecha de adquisición y estado (operativo, en mantenimiento, de baja). Un equipo pertenece a una única sede.

Los miembros se registran con nombre completo, documento de identidad, fecha de nacimiento, correo y teléfono. Cada miembro adquiere una membresía que tiene un plan asociado, una fecha de inicio, una fecha de vencimiento y el valor pagado. Los planes tienen nombre (básico, estándar, premium), precio mensual, una descripción de beneficios y la cantidad de clases grupales mensuales incluidas. Un miembro puede tener varias membresías a lo largo del tiempo, pero solo una activa a la vez.

Las clases grupales son el servicio más demandado. Cada clase tiene un nombre (spinning, yoga, crossfit, pilates, rumba, entre otros), un nivel de dificultad, una duración en minutos y un cupo máximo. Las clases se programan con un horario específico: día de la semana, hora de inicio, sede donde se dicta e instructor responsable. Un instructor puede dictar clases en diferentes sedes. Los miembros se inscriben en programaciones concretas; la inscripción registra si el miembro asistió efectivamente o no.

Los instructores tienen nombre, documento, especialidades (pueden estar certificados en varias modalidades), fecha de ingreso a la empresa y tipo de vinculación (planta o freelance).

La empresa lleva además un registro de los ingresos de cada sede: cada pago de membresía queda asociado a la sede donde se realizó el registro. También es importante saber qué clases tienen mayor demanda por sede, qué instructores tienen más asistencia y cuáles son los meses con mayor renovación de membresías.

---

*Construye el modelo de datos completo según las instrucciones generales del Evento VI.*

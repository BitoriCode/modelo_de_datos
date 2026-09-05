# Enunciado 6 — EduPro S.A.S.
## Evento Evaluativo III | Modelo de Datos

---

EduPro S.A.S. es una red colombiana de colegios privados bilingües con campus en Bogotá (sede norte y sede sur), Medellín y Cali. La institución ofrece educación desde preescolar hasta grado once y necesita un sistema para gestionar su operación académica y administrativa de forma unificada.

De cada campus se registra un código, nombre, ciudad, dirección completa —calle, número, barrio y localidad—, teléfono central, correo institucional y rector responsable. Dentro de cada campus existen aulas de clase identificadas por un código alfanumérico. Ese código identifica al aula únicamente dentro del campus al que pertenece: el aula A-12 del campus norte de Bogotá y el aula A-12 del campus Medellín son instancias completamente distintas. De cada aula se registra la capacidad máxima en número de estudiantes, el tipo (salón regular, laboratorio, salón de idiomas, sala de sistemas) y el estado (disponible o en mantenimiento). Un aula no puede existir en el sistema sin estar asignada a un campus.

Los docentes se identifican por su número de cédula y se registran con nombre completo —primer nombre y apellidos—, fecha de nacimiento, correo institucional, teléfono y nivel de formación (técnico, tecnólogo, profesional, especialista, magíster o doctor). La antigüedad de cada docente se calcula desde su fecha de vinculación y no se almacena directamente. Por tratarse de una red de colegios bilingües, la institución registra los idiomas que cada docente domina; un docente puede dominar varios idiomas o solo uno. Un docente puede estar certificado para enseñar varias asignaturas —matemáticas, inglés, ciencias naturales, español, entre otras—, y una asignatura puede ser impartida por varios docentes; la institución solo necesita saber qué docentes tienen habilitación para qué asignaturas, sin necesidad de almacenar datos adicionales de esa habilitación.

Las asignaturas tienen un código, nombre, área del conocimiento (ciencias, humanidades, matemáticas, tecnología, idiomas), intensidad horaria semanal y si es obligatoria o electiva. Los estudiantes se identifican por su número de documento y se registran con nombre completo, fecha de nacimiento, correo, ciudad de residencia y condición de salud relevante para la institución —si la tiene—, ya que algunos estudiantes tienen condiciones que requieren atención diferencial. La edad del estudiante no se almacena; se calcula a partir de su fecha de nacimiento.

Cada estudiante tiene uno o varios acudientes registrados. De cada acudiente se registra nombre completo, relación con el estudiante (padre, madre, abuelo, tutor legal), número de cédula, teléfonos de contacto, correo y si está autorizado a retirar al estudiante. Un acudiente puede estar registrado para varios estudiantes (por ejemplo, cuando tiene varios hijos en el mismo colegio).

Cada año, un estudiante se matricula en un campus para cursar un grado específico. La matrícula registra el año lectivo, el grado cursado (preescolar, primero, ..., once), el campus al que ingresa, la fecha de pago, el valor de la matrícula cancelado, la modalidad de pago (contado, financiado) y el estado (activa, cancelada o congelada). Un estudiante puede haberse matriculado en distintos campus en diferentes años; un campus recibe matrículas de múltiples estudiantes cada año.

La institución también registra el desempeño académico período a período. Al cierre de cada uno de los cuatro períodos del año lectivo, se registra la nota del estudiante en cada asignatura que cursa en esa matrícula: la nota obtenida —en escala de 1.0 a 5.0—, el porcentaje de inasistencia y si la asignatura quedó aprobada o en recuperación. Un estudiante matriculado puede ser evaluado en varias asignaturas, y una misma asignatura puede tener notas de múltiples estudiantes en el mismo período. Para registrar una nota es necesario conocer a qué matrícula y a qué asignatura corresponde, y llevar registro del número de período; la combinación de esos tres datos identifica de forma única cada calificación.

---

*Construye el modelo E-R completo, el diagrama relacional y documenta cada decisión de diseño según las instrucciones generales del evento.*


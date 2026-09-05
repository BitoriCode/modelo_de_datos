# Enunciado 2 — SaludVida IPS
## Evento Evaluativo III | Modelo de Datos

---

SaludVida IPS es una institución prestadora de salud con sedes en Bogotá, Medellín y Barranquilla que ofrece atención médica especializada en consulta externa. La institución necesita un sistema de información para gestionar su operación clínica y administrativa.

De cada sede se registra un código, nombre, ciudad, dirección completa —calle, número, barrio y departamento—, teléfono central, correo institucional y jornada de atención (mañana, tarde o jornada completa). Cada sede alberga un conjunto de consultorios numerados. El número de consultorio identifica únicamente al consultorio dentro de su propia sede: el consultorio 5 de la sede Bogotá Centro y el consultorio 5 de la sede Medellín El Poblado son instancias distintas del sistema. De cada consultorio se registra el estado (habilitado o en mantenimiento), la capacidad en número de camillas y el equipamiento disponible —ecógrafo, electrocardiógrafo, tensiómetro digital, lámpara de procedimientos, entre otros—, que varía por consultorio y puede incluir varios elementos o ninguno. Un consultorio no puede existir en el sistema sin estar asignado a una sede.

Los médicos se identifican por su número de registro médico y se registran con nombre completo —primer nombre y apellidos—, número de cédula, fecha de grado, correo profesional y teléfono. La antigüedad de cada médico en la IPS se calcula desde su fecha de vinculación y no se almacena directamente. Cada médico puede tener varios títulos de posgrado —especializaciones, maestrías o doctorados— que la institución registra de forma individual, pues son relevantes para la asignación de procedimientos complejos. Un médico puede estar habilitado en varias especialidades —medicina general, cardiología, pediatría, dermatología, entre otras—, y una especialidad puede tener múltiples médicos habilitados; la institución solo necesita saber qué médicos cubren qué especialidades, sin requerir datos adicionales de esa relación.

Los pacientes se registran con su número de documento, nombre completo, fecha de nacimiento, sexo biológico, correo, ciudad de residencia y teléfonos de contacto (fijo y celular). La edad del paciente no se almacena; se calcula a partir de su fecha de nacimiento. Un paciente puede tener registradas varias alergias a medicamentos —penicilina, sulfa, AINES, entre otras—; un paciente puede tener varias alergias conocidas o ninguna. Los pacientes pueden estar afiliados a uno o varios seguros médicos —EPS, medicina prepagada o póliza privada—; de cada seguro se registra su NIT, nombre de la entidad, tipo (EPS, prepagada, póliza), teléfono de autorización y estado de vigencia.

Cuando un paciente agenda una cita, el sistema registra el motivo de consulta, la fecha, la hora, el diagnóstico (que puede quedar en blanco hasta que el médico lo complete), el estado (programada, atendida, cancelada o no asistida) y el valor cobrado. La cita pertenece a exactamente un médico y a exactamente un paciente. Un paciente puede tener múltiples citas con el mismo o diferentes médicos a lo largo del tiempo; un médico puede atender a muchos pacientes en distintas fechas. Cada cita queda también vinculada al consultorio donde se realiza.

En algunas citas el médico emite órdenes médicas: solicitudes de exámenes de laboratorio, imágenes diagnósticas o remisiones a especialistas. El número de orden identifica a la orden únicamente dentro de la cita en que fue emitida: la orden número 2 de la cita C-1001 y la orden número 2 de la cita C-1002 son registros completamente distintos. De cada orden se registra el tipo (laboratorio, imagen diagnóstica o remisión a especialista), la descripción, la prioridad (urgente o rutinaria) y el estado (pendiente, ejecutada o cancelada). Una orden no puede existir en el sistema sin estar asociada a la cita que la generó.

En algunas citas el médico receta medicamentos. De cada medicamento del sistema se registra un código, nombre genérico, concentración, forma farmacéutica (tableta, cápsula, jarabe, inyectable, crema) y el laboratorio fabricante. Un medicamento puede ser recetado en múltiples citas, y en una misma cita pueden recetarse varios medicamentos; como la institución solo necesita registrar qué medicamentos se prescribieron, sin almacenar dosis ni frecuencia por cita, esta relación no requiere atributos adicionales.

---

*Construye el modelo E-R completo, el diagrama relacional y documenta cada decisión de diseño según las instrucciones generales del evento.*


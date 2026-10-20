# Enunciado 5 — ClínicaVet Pro
## Evento Evaluativo VI | Modelo de Datos

---

ClínicaVet Pro es una red de clínicas veterinarias con varias sedes en Colombia. Cada sede ofrece servicios de consulta general, especialidades médicas, cirugías, hospitalización y venta de medicamentos. La empresa quiere un sistema único que integre la gestión clínica, el personal médico y la atención a los pacientes a través de toda la red.

Cada sede tiene una ciudad, dirección, teléfono, correo y un médico veterinario que actúa como director clínico. Los veterinarios de la red pueden ejercer en una o más sedes según contrato, y cada uno tiene especialidades médicas en las que está certificado (dermatología, traumatología, cardiología, oftalmología, medicina interna, entre otras). La especialidad determina qué tipo de consultas puede atender el profesional.

Los propietarios de animales se registran con nombre completo, documento de identidad, dirección, teléfono y correo. Un propietario puede tener uno o varios animales registrados. De cada animal se guarda su nombre, especie (perro, gato, ave, reptil, roedor u otro), raza si aplica, fecha de nacimiento o edad estimada, sexo y si está esterilizado. El peso actual del animal no se almacena directamente; se registra en cada consulta.

Cuando un animal llega a una consulta, el sistema genera un registro clínico que incluye la fecha y hora, la sede, el veterinario que atiende, el motivo de consulta, el peso del animal ese día, el diagnóstico emitido y el tratamiento recomendado. Cada consulta puede generar una o varias prescripciones de medicamentos. De cada medicamento dispensado se registra el nombre, la dosis y la duración del tratamiento.

Si el animal requiere hospitalización, queda asignado a un espacio de hospitalización en la sede con una fecha de ingreso y una fecha de egreso cuando se da de alta. Un animal no puede estar hospitalizado en más de una sede al mismo tiempo.

La clínica también aplica vacunas. Cada vacuna tiene un nombre, el laboratorio fabricante y la enfermedad que previene. El sistema registra cada aplicación de vacuna: animal, fecha, veterinario que la aplicó, sede y la fecha programada para el refuerzo.

Los medicamentos que la clínica vende o dispensa provienen de proveedores registrados. El inventario de cada medicamento varía por sede, y el sistema alerta cuando el stock cae por debajo del mínimo definido.

---

*Construye el modelo de datos completo según las instrucciones generales del Evento VI.*

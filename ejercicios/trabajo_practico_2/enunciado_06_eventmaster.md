# Enunciado 6 — EventMaster
## Evento Evaluativo VI | Modelo de Datos

---

EventMaster es una empresa bogotana especializada en la planeación y ejecución integral de eventos. Organiza matrimonios, lanzamientos de productos, conferencias empresariales, grados universitarios y fiestas corporativas. La empresa gestiona un equipo propio de coordinadores y mantiene relaciones comerciales con una red de proveedores externos especializados.

Los clientes que contratan a EventMaster pueden ser personas naturales o empresas. De cada cliente se guarda nombre o razón social, documento o NIT, correo, teléfono y ciudad. Un cliente puede contratar varios eventos con la empresa a lo largo del tiempo.

Cada evento tiene un nombre interno, un tipo (matrimonio, corporativo, social, cultural u otro), una fecha de realización, un número estimado de asistentes y un presupuesto aprobado. Todo evento tiene asignado un coordinador principal de la empresa, que es el responsable directo ante el cliente. Un coordinador puede llevar varios eventos simultáneamente.

Los eventos se realizan en espacios físicos que EventMaster tiene catalogados: salones, haciendas, auditorios, terrazas y similares. Cada espacio tiene nombre, dirección, ciudad, capacidad máxima, precio por hora o por día, y el tipo de eventos para el que está habilitado. EventMaster no es dueña de todos los espacios; algunos son aliados. Un evento se realiza en un único espacio.

Para cada evento se contratan proveedores según las necesidades: catering, fotografía, decoración, sonido e iluminación, entretenimiento artístico, transporte, entre otros. Un mismo proveedor puede participar en distintos eventos y un evento puede requerir varios proveedores de distintas categorías. Cuando se contrata un proveedor para un evento, se registra el servicio puntual que prestará, el costo acordado y el estado del contrato (cotización, confirmado, pagado, cancelado).

El equipo de EventMaster está compuesto por coordinadores y asistentes. Los coordinadores lideran eventos y pueden tener asistentes a su cargo en eventos específicos. De cada empleado se guarda nombre, documento, cargo, fecha de ingreso y salario mensual. El salario es información confidencial que solo el área administrativa debe consultar.

Cada evento tiene un cronograma de actividades con momentos clave: llegada de proveedores, inicio del evento, corte de torta o momento central, cierre. Cada actividad tiene nombre, hora programada, hora real de ejecución (si ya ocurrió) y un responsable dentro del equipo.

La gerencia necesita reportes de rentabilidad por tipo de evento, análisis de los proveedores más contratados, y seguimiento del desempeño de los coordinadores.

---

*Construye el modelo de datos completo según las instrucciones generales del Evento VI.*

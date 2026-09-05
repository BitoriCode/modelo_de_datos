# Enunciado 7 — TeleCel Colombia
## Evento Evaluativo III | Modelo de Datos

---

TeleCel Colombia es un operador de telefonía móvil y servicios digitales con presencia en todas las regiones del país. La empresa gestiona su infraestructura de red, sus planes de servicio, la base de clientes y la operación de sus sucursales de atención.

El territorio de operación está dividido en regiones de cobertura. De cada región se registra un código, nombre, departamentos que cubre y el porcentaje de cobertura 4G y 5G reportado. Cada región cuenta con un conjunto de torres de antena instaladas. El número de torre identifica a la torre únicamente dentro de su región: la torre 7 de la región Pacífico y la torre 7 de la región Caribe son instancias completamente distintas. De cada torre se registra la ubicación geográfica (municipio, coordenadas), las tecnologías de red que soporta —una torre puede operar en 2G, 3G, 4G y 5G simultáneamente o solo en algunas de ellas—, la capacidad de carga en número de conexiones simultáneas y el estado operativo (activa, en mantenimiento o fuera de servicio). Una torre no puede existir en el sistema sin estar asignada a una región.

TeleCel ofrece distintos planes a sus clientes: planes prepago, pospago y planes de datos. De cada plan se registra un código, nombre comercial, tipo (prepago, pospago básico, pospago ilimitado, datos empresariales), precio mensual, megas de datos incluidos, minutos de voz nacionales, si incluye llamadas internacionales y si aplica para roaming. Un plan puede estar disponible en varias regiones, y una región puede tener múltiples planes activos; la empresa solo necesita saber en qué regiones está disponible cada plan, sin registrar condiciones adicionales de esa disponibilidad.

Los clientes se identifican por su número de documento y se registran con nombre completo —primer nombre y apellidos—, fecha de nacimiento, correo electrónico, estrato socioeconómico y dirección de correspondencia —compuesta por calle, número, ciudad y departamento—. La edad del cliente no se almacena; se calcula a partir de su fecha de nacimiento. Un cliente puede registrar varios números de teléfono de contacto alternativos, además del número de la línea TeleCel que tiene activa.

Los clientes pueden poseer uno o varios dispositivos registrados en la plataforma. De cada dispositivo se registra el IMEI como identificador, la marca, el modelo, el sistema operativo, la capacidad de almacenamiento y la fecha de activación en la red TeleCel.

Cuando un cliente contrata un plan, el sistema genera un contrato que registra la fecha de activación, la fecha de vencimiento, el número de línea asignada, el ciclo de facturación (día del mes en que se cobra), el estado del contrato (activo, suspendido, cancelado) y si tiene cláusula de permanencia y por cuántos meses. Los meses de vigencia restante —calculados entre la fecha actual y la fecha de vencimiento— no se almacenan directamente. Un cliente puede tener contratos vigentes con distintos planes a lo largo del tiempo, y un plan puede estar contratado por múltiples clientes. Cada contrato queda atendido por un asesor comercial de la sucursal donde se realizó la vinculación.

Los clientes pueden presentar reclamaciones o PQR (peticiones, quejas o reclamos) vinculadas a un contrato específico. El número de reclamación identifica al registro únicamente dentro del contrato al que pertenece: la reclamación número 3 del contrato C-001 y la reclamación número 3 del contrato C-002 son instancias completamente distintas. De cada reclamación se registra el tipo (petición, queja o reclamo), el motivo, la descripción, la fecha de radicación, la fecha de resolución —que puede estar vacía si aún no se ha resuelto— y el estado (abierta, en proceso o resuelta). Una reclamación no puede existir en el sistema sin estar asociada al contrato que la origina.

Las sucursales de atención al cliente tienen un código, ciudad, dirección, teléfono, horario de atención y el número de asesores disponibles. De cada asesor —empleado de TeleCel— se registra código, nombre completo, cargo, fecha de ingreso, correo corporativo y la sucursal a la que está asignado. La antigüedad de cada asesor se calcula desde su fecha de ingreso y no se almacena directamente.

---

*Construye el modelo E-R completo, el diagrama relacional y documenta cada decisión de diseño según las instrucciones generales del evento.*


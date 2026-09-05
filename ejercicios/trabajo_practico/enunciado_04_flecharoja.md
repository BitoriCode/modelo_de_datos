# Enunciado 4 — Flecha Roja S.A.
## Evento Evaluativo III | Modelo de Datos

---

Flecha Roja S.A. es una empresa colombiana de transporte intermunicipal de pasajeros con más de 30 años de operación. Cuenta con terminales en Bogotá, Medellín, Cali, Manizales, Pereira, Armenia, Ibagué y Neiva, y opera rutas entre estas ciudades con una flota propia de vehículos.

De cada terminal se registra un código, el nombre oficial, la ciudad, la dirección completa —calle, número y barrio—, el teléfono central y el horario de atención (apertura y cierre). Dentro de cada terminal existen múltiples taquillas de venta. El número de taquilla identifica a la taquilla únicamente dentro de su propio terminal: la taquilla 3 del terminal de Bogotá y la taquilla 3 del terminal de Cali son instancias completamente distintas. De cada taquilla se registra el estado (activa o fuera de servicio) y la jornada asignada (mañana, tarde, nocturna). Una taquilla no puede existir en el sistema sin estar asignada a un terminal.

Las rutas conectan dos terminales: uno de origen y uno de destino. De cada ruta se registra un código, la distancia en kilómetros, la duración estimada del recorrido en horas, el precio base del tiquete, la categoría del servicio (corriente, ejecutivo o directo) y si la ruta es activa o suspendida. Una misma ruta puede ser operada por múltiples conductores en diferentes salidas, y un conductor puede operar en distintas rutas a lo largo del tiempo; la empresa solo necesita saber qué conductores están habilitados para qué rutas, sin registrar datos adicionales de esa habilitación.

Los vehículos se identifican por su placa y se registran con marca, modelo, año de fabricación, número de asientos, tipo de carrocería (bus, buseta, minivan) y el kilometraje actual. El número de asiento identifica al asiento únicamente dentro del vehículo al que pertenece: el asiento 12 del bus ABC-123 y el asiento 12 del bus XYZ-456 son instancias distintas. De cada asiento se registra la clase (estándar, ejecutivo o cama), si tiene ventana (sí o no) y si está habilitado o bloqueado. Un asiento no puede existir sin estar asignado a un vehículo.

Los conductores se identifican por su número de cédula y se registran con nombre completo —primer nombre y apellidos—, fecha de nacimiento, licencia de conducción (categoría y fecha de vencimiento), teléfono y correo. La antigüedad de cada conductor en la empresa se calcula desde su fecha de vinculación y no se almacena directamente. Un conductor puede poseer varias categorías de licencia registradas en el sistema.

Los pasajeros se registran con número de documento, nombre completo, fecha de nacimiento, correo y teléfono. La edad del pasajero no se almacena; se calcula a partir de su fecha de nacimiento.

Cuando un pasajero adquiere un tiquete para una salida específica, el sistema registra el número de tiquete, la fecha y hora de compra, el canal de venta (taquilla, web o aplicación móvil), el precio pagado, el asiento asignado, el estado del tiquete (válido, usado o cancelado) y si se solicitó asistencia especial. Un pasajero puede comprar múltiples tiquetes en diferentes fechas y rutas. Cada salida tiene una fecha y hora de partida, un vehículo asignado y un conductor responsable, y de esa combinación se genera el listado de tiquetes disponibles.

---

*Construye el modelo E-R completo, el diagrama relacional y documenta cada decisión de diseño según las instrucciones generales del evento.*


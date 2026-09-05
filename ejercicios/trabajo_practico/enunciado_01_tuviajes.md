# Enunciado 1 — TuriViajes S.A.S.
## Evento Evaluativo III | Modelo de Datos

---

TuriViajes S.A.S. es una agencia de viajes colombiana fundada en Medellín que opera sedes en Bogotá, Cali, Cartagena y Bucaramanga. La empresa diseña y vende paquetes turísticos nacionales e internacionales, y administra una red de alojamientos aliados en los destinos donde opera.

De cada sede se registra un código único, la ciudad, la dirección completa —compuesta por calle, número, ciudad y departamento—, el teléfono principal y la fecha de apertura. Cada sede tiene asesores turísticos que trabajan exclusivamente en ella; estos asesores son quienes gestionan directamente las reservas con los clientes.

Los paquetes turísticos tienen un código, nombre comercial, descripción, precio base, duración en días y una categoría (aventura, cultural, relax o gastronómico). Un paquete puede incluir varios destinos —por ejemplo, el paquete "Eje Cafetero Express" recorre Manizales, Pereira y Armenia—, y un mismo destino puede aparecer en múltiples paquetes. La empresa no necesita registrar ningún dato adicional sobre esa relación; lo relevante es saber qué destinos cubre cada paquete.

De cada destino se registra un código, nombre, país, descripción breve, el tipo de turismo que predomina (playa, montaña, ciudad, ecoturismo) y uno o más teléfonos de atención local, ya que algunos destinos tienen varias líneas de contacto regional.

Los guías turísticos tienen un código, nombre completo —con primer nombre y apellidos por separado—, número de cédula y fecha de vinculación a la agencia. La antigüedad de cada guía se calcula desde su fecha de vinculación y no se almacena directamente. Dado que la agencia atiende turistas extranjeros, cada guía puede dominar varios idiomas; un mismo idioma puede ser dominado por varios guías, y este dato es clave para las asignaciones. Los guías pueden ser asignados a paquetes de diferentes sedes según la temporada.

Los clientes se registran con su número de documento como identificador único, nombre completo, fecha de nacimiento, correo electrónico y números de contacto (un cliente puede tener teléfono fijo, celular personal y celular empresarial registrados). La edad del cliente no se almacena; se calcula a partir de su fecha de nacimiento. Algunos clientes declaran restricciones médicas o alimentarias relevantes para los tours —como vegetarianismo, alergias o movilidad reducida—; un cliente puede registrar varias restricciones o ninguna.

Cuando un cliente reserva un paquete, el sistema genera una reserva que registra la fecha en que se hizo la reserva, la fecha de inicio del viaje, el número de acompañantes, el canal de venta (presencial, telefónico o web), el estado (pendiente, confirmada o cancelada) y el asesor responsable. El costo total de la reserva se calcula como el precio base del paquete multiplicado por el número total de viajeros (cliente + acompañantes), y no se almacena directamente. Toda reserva queda asociada a exactamente un asesor.

TuriViajes también gestiona los alojamientos aliados. De cada alojamiento se registra un código, nombre, dirección, categoría en estrellas, correo institucional y teléfono. Cada alojamiento dispone de habitaciones, y el número de habitación solo identifica a la habitación dentro del propio alojamiento: la habitación 201 del Hotel Dann Carlton y la habitación 201 de la Posada del Virrey son instancias completamente distintas del sistema. De cada habitación se registra el tipo (sencilla, doble, suite ejecutiva), el precio por noche, la capacidad máxima de personas y las comodidades disponibles —piscina, jacuzzi, vista al mar, balcón, TV satelital, entre otras—, que pueden ser varias o ninguna. Una habitación no puede existir en el sistema sin estar asignada a un alojamiento.

---

*Construye el modelo E-R completo, el diagrama relacional y documenta cada decisión de diseño según las instrucciones generales del evento.*


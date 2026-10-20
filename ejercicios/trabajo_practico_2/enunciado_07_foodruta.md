# Enunciado 7 — FoodRuta
## Evento Evaluativo VI | Modelo de Datos

---

FoodRuta es una plataforma colombiana de pedidos de comida a domicilio que opera en varias ciudades. Conecta restaurantes con clientes finales a través de una aplicación móvil y web, y gestiona una flota de repartidores independientes. La empresa quiere estructurar toda la información de su operación en una base de datos robusta que soporte el crecimiento de la plataforma.

Los restaurantes afiliados tienen nombre comercial, dirección, ciudad, teléfono, correo y una categoría de cocina principal (italiana, japonesa, americana, colombiana, saludable, etc.). Un restaurante puede tener además categorías secundarias. Cada restaurante opera en horarios específicos que varían por día de la semana; por ejemplo, un restaurante puede abrir de lunes a viernes de 11 a.m. a 9 p.m. y los fines de semana de 12 m. a 10 p.m.

Cada restaurante gestiona su propio menú. El menú se organiza en categorías internas del restaurante: entradas, platos fuertes, bebidas, postres, combos especiales, etc. Cada ítem del menú tiene nombre, descripción, precio, tiempo estimado de preparación, si está disponible actualmente y si contiene algún alérgeno relevante como gluten, lácteos o mariscos. Un ítem pertenece a exactamente una categoría del menú de su restaurante.

Los clientes de la plataforma se registran con nombre, correo, número de celular y una o varias direcciones de entrega registradas. Cada dirección de entrega tiene una etiqueta (casa, trabajo, otro), la dirección completa y el barrio o zona. Cuando un cliente hace un pedido, elige una de sus direcciones guardadas como destino de entrega.

Un pedido contiene uno o más ítems del menú de un único restaurante, con sus respectivas cantidades. El pedido registra la fecha y hora en que se hizo, el canal (app móvil o web), la dirección de entrega seleccionada, y pasa por estados secuenciales: recibido, en preparación, listo para recoger, en camino, entregado o cancelado. El valor total del pedido se calcula a partir de los ítems pedidos más un costo de domicilio que depende de la zona de entrega.

Los repartidores son trabajadores independientes registrados en la plataforma con nombre, documento, teléfono, tipo de vehículo (moto, bicicleta, patineta eléctrica) y ciudad de operación. Cuando un pedido está listo para recoger, el sistema asigna un repartidor disponible. El repartidor registra la hora en que recoge el pedido y la hora en que lo entrega.

La plataforma permite que tanto restaurantes como repartidores sean calificados. Después de recibir un pedido, el cliente puede asignar una calificación de 1 a 5 al restaurante y otra al repartidor, con un comentario opcional. La plataforma usa estas calificaciones para mostrar rankings y también para detectar problemas de calidad en el servicio.

---

*Construye el modelo de datos completo según las instrucciones generales del Evento VI.*

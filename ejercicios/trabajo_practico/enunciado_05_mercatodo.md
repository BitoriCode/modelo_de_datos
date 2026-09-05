# Enunciado 5 — Mercatodo S.A.S.
## Evento Evaluativo III | Modelo de Datos

---

Mercatodo S.A.S. es una cadena colombiana de supermercados de barrio con locales en Bogotá, Medellín, Cali y Bucaramanga. La empresa gestiona sus puntos de venta, inventario, proveedores y un programa de clientes frecuentes, y necesita un sistema de información centralizado para integrar todos esos datos.

De cada sede se registra un código, nombre del punto, ciudad, dirección completa —calle, número, barrio y localidad—, teléfono de contacto, horario de apertura y cierre, y si dispone de parqueadero. Dentro de cada sede operan varias cajas registradoras. El número de caja identifica a la caja únicamente dentro de la sede a la que pertenece: la caja 4 de la sede Chapinero y la caja 4 de la sede Laureles son instancias completamente distintas. De cada caja se registra el estado (activa o fuera de servicio) y la jornada en que opera. Una caja no puede existir en el sistema sin estar asignada a una sede.

Cada sede cuenta además con bodegas de almacenamiento para el inventario. El número de bodega identifica a la bodega únicamente dentro de la sede en que se encuentra: la bodega 2 de la sede Chapinero y la bodega 2 de la sede Laureles son instancias completamente distintas del sistema. De cada bodega se registra la capacidad en metros cuadrados, el tipo (seca, refrigerada o de congelados) y el estado (activa o fuera de servicio). Una bodega no puede existir en el sistema sin estar asignada a una sede.

Los productos se identifican por un código de barras y se registran con nombre, descripción, precio de venta, precio de costo, unidad de medida (unidad, kilogramo, litro, caja) y si está activo en el catálogo. El margen de ganancia de cada producto —diferencia entre el precio de venta y el de costo— se calcula y no se almacena directamente. Cada producto pertenece a exactamente una categoría —lácteos, carnes, frutas y verduras, bebidas, aseo del hogar, entre otras—; de cada categoría se registra un código, nombre y descripción. Los productos pueden tener varias presentaciones registradas como etiquetas adicionales —mini, familiar, industrial—, que varían por producto.

Los proveedores abastecen a las sedes con los productos del catálogo. De cada proveedor se registra su NIT, razón social, ciudad, dirección, teléfonos de contacto y correo comercial. Un proveedor puede abastecer a múltiples sedes de la cadena, y una sede recibe productos de múltiples proveedores; la empresa solo necesita saber qué proveedores surten a qué sedes, sin registrar condiciones específicas de esa relación de abastecimiento.

Los empleados tienen un código, nombre completo —primer nombre y apellidos—, número de cédula, cargo (cajero, reponedor, supervisor de piso, administrador), teléfono y correo. La antigüedad de cada empleado se calcula desde su fecha de ingreso y no se almacena directamente. Un empleado trabaja en una sola sede a la vez.

El programa de clientes frecuentes registra a los clientes inscritos con su número de documento, nombre completo, fecha de nacimiento, correo y teléfonos de contacto. La edad del cliente no se almacena; se calcula a partir de su fecha de nacimiento. Un cliente puede registrar varias direcciones de domicilio (casa, trabajo, familiar).

Cuando un cliente frecuente realiza una compra en una caja, el sistema registra una transacción de compra que incluye la fecha y hora, el método de pago (efectivo, tarjeta débito, tarjeta crédito o transferencia), el total de la compra, el número de puntos acumulados y el cajero que atendió. Un cliente frecuente puede realizar múltiples compras en distintas cajas y sedes a lo largo del tiempo. En cada compra se adquieren uno o varios productos en distintas cantidades y con posibles descuentos por unidad; estos datos de detalle deben registrarse para cada compra.

---

*Construye el modelo E-R completo, el diagrama relacional y documenta cada decisión de diseño según las instrucciones generales del evento.*


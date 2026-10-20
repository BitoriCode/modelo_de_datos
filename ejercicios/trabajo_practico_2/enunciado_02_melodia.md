# Enunciado 2 — Melodía
## Evento Evaluativo VI | Modelo de Datos

---

Melodía es una cadena colombiana de tiendas especializadas en música que opera en las principales ciudades del país. Cada sede vende instrumentos musicales y accesorios, y ofrece clases de música para distintos niveles e instrumentos. La empresa quiere unificar en un solo sistema toda la información de inventario, ventas, instructores y alumnos.

Cada sede tiene una ciudad, una dirección, un teléfono y un administrador responsable. El inventario de instrumentos varía por sede: cada sede decide qué productos tiene disponibles y en qué cantidad. Los productos se organizan por categorías (cuerdas, vientos, percusión, teclas, electrónica) y cada producto tiene un nombre comercial, marca, referencia interna, precio de venta y una descripción técnica opcional. Un mismo producto puede estar disponible en varias sedes con distintos niveles de stock.

Las ventas se realizan presencialmente en cada sede. Cuando un cliente compra, el sistema registra la fecha, el vendedor que atendió, los productos adquiridos con sus cantidades y precios al momento de la venta, y la forma de pago (efectivo, tarjeta o transferencia). Un cliente puede hacer varias compras en distintas sedes a lo largo del tiempo. De los clientes se guardan nombre, documento de identidad, correo y teléfono de contacto.

En paralelo al negocio de ventas, cada sede ofrece clases de música. Los instructores trabajan para la cadena y pueden dictar clases en una o varias sedes según su disponibilidad. Cada instructor tiene su nombre, documento, especialidades instrumentales (puede dominar varios instrumentos), tarifa por hora y fecha de vinculación a la empresa.

Las clases se organizan en grupos de nivel: iniciación, intermedio y avanzado. Cada grupo tiene un instrumento, un horario semanal fijo, una sede asignada, un instructor y un cupo máximo. Los alumnos se matriculan en grupos; un alumno puede estar matriculado en más de un grupo si practica más de un instrumento. La matrícula de un alumno en un grupo tiene una fecha de inicio y una fecha estimada de terminación, y puede estar activa, pausada o finalizada.

La empresa quiere poder consultar fácilmente el inventario disponible por sede, el historial de ventas de cada cliente, los grupos activos por sede e instructor, y los ingresos generados tanto por ventas como por matrículas en un período de tiempo dado.

---

*Construye el modelo de datos completo según las instrucciones generales del Evento VI.*

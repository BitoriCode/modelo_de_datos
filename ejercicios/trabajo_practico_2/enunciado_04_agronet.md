# Enunciado 4 — AgroNet
## Evento Evaluativo VI | Modelo de Datos

---

AgroNet es una cooperativa digital que conecta pequeños y medianos productores agrícolas colombianos con compradores mayoristas, supermercados y exportadores. La plataforma centraliza la información de fincas, cultivos, cosechas disponibles y transacciones comerciales, permitiendo a los productores ofrecer sus productos directamente y a los compradores encontrar proveedores certificados.

Los productores son personas naturales o jurídicas con número de identificación, nombre o razón social, municipio de operación, teléfono y correo de contacto. Un productor puede tener varias fincas registradas. Cada finca tiene un nombre, municipio, vereda, área total en hectáreas y altitud sobre el nivel del mar, dato relevante para ciertos cultivos. En una finca pueden llevarse a cabo distintos cultivos simultáneamente o en distintas temporadas.

Cada cultivo registrado en el sistema corresponde a un producto agrícola específico (papa, café, mora, tomate, arroz, etc.) y tiene asociada una variedad cuando aplica. Un cultivo tiene una fecha de siembra, una fecha estimada de cosecha, el área sembrada en esa temporada y la técnica de producción utilizada (tradicional, orgánica certificada, tecnificada). Un cultivo puede producir una o varias cosechas en diferentes fechas.

Cada cosecha registra la cantidad disponible en kilogramos, el precio por kilogramo propuesto por el productor, la fecha en que queda disponible para venta y si cuenta con certificación de calidad o inocuidad. Los compradores pueden ver las cosechas disponibles y realizar pedidos.

Los compradores son empresas o personas registradas con nombre, NIT o cédula, correo y ciudad de operación. Cuando un comprador hace un pedido, el sistema registra la cosecha solicitada, la cantidad pedida, la fecha del pedido y el estado (pendiente, confirmado, despachado, entregado o cancelado). El precio total del pedido se calcula según la cantidad y el precio de la cosecha en el momento de la transacción. Un pedido solo puede hacer referencia a la cosecha de un único productor, pero un comprador puede tener múltiples pedidos activos.

La cooperativa también gestiona técnicos de campo que visitan las fincas para asesoría y control de calidad. Cada técnico tiene nombre, documento, área de especialización y departamentos de cobertura. Las visitas quedan registradas con fecha, finca visitada, técnico responsable y un concepto general de la visita.

---

*Construye el modelo de datos completo según las instrucciones generales del Evento VI.*

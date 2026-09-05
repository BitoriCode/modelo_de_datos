# Enunciado 3 — Construhogar Ltda.
## Evento Evaluativo III | Modelo de Datos

---

Construhogar Ltda. es una constructora colombiana con operaciones en Bogotá, Medellín y Bucaramanga que desarrolla proyectos de vivienda de interés social y proyectos de estrato medio. La empresa necesita centralizar en una base de datos toda la información de sus proyectos, unidades, compradores y aliados comerciales.

De cada proyecto se registra un código, nombre comercial, municipio, estrato socioeconómico, número total de unidades planificadas, fecha de inicio de obra, fecha estimada de entrega y estado actual (en planos, en construcción, finalizado). El número de unidades disponibles —resultado de restar al total planificado las ya prometidas o escrituradas— se calcula automáticamente y no se almacena directamente. Cada proyecto está sujeto a una o varias normativas constructivas vigentes —como la NSR-10 de sismo resistencia, las normas del Plan de Ordenamiento Territorial del municipio o el Código de Construcción Sostenible—, y la empresa registra cuáles aplican a cada proyecto. Cada proyecto tiene además uno o más tipos de uso: residencial, comercial o mixto.

Dentro de cada proyecto existen unidades habitacionales —apartamentos, casas o locales—. El número de unidad identifica a la unidad únicamente dentro de su propio proyecto: la unidad 301 del proyecto Villas del Retiro y la unidad 301 del proyecto Reserva del Bosque son instancias completamente distintas. De cada unidad se registra el tipo (apartamento, casa, local comercial), el área en metros cuadrados, el número de alcobas, el número de baños, el piso, el valor de venta y el estado (disponible, en separación o escriturada). Una unidad no puede existir en el sistema sin estar asignada a un proyecto.

Los compradores se identifican por su número de cédula y se registran con nombre completo —primer nombre y apellidos—, fecha de nacimiento, correo, ciudad de residencia y teléfonos de contacto. La edad del comprador no se almacena; se calcula a partir de su fecha de nacimiento. Un comprador puede tener varios números de teléfono registrados (fijo, celular personal, celular empresarial). Un comprador puede aparecer en el sistema sin haber iniciado ninguna negociación.

Cuando un comprador expresa interés formal por una unidad, se genera una promesa de compraventa que registra la fecha de firma, el valor de separación pagado, el porcentaje de cuota inicial acordado, la forma de financiación (crédito hipotecario, leasing o contado), el plazo de entrega pactado en meses y el estado de la promesa (vigente, rescindida o ejecutada en escritura). Una unidad puede haber tenido varias promesas con distintos compradores a lo largo del tiempo —por cancelaciones anteriores—, y un comprador puede firmar promesas sobre distintas unidades en diferentes proyectos.

Cada promesa de compraventa tiene asociado un plan de pagos por cuotas. El número de cuota identifica al abono únicamente dentro de la promesa a la que pertenece: la cuota número 4 de la promesa P-001 y la cuota número 4 de la promesa P-002 son instancias completamente distintas. De cada cuota se registra la fecha programada de pago, la fecha real de pago —que puede estar vacía si aún no se ha realizado—, el valor pactado y el medio de pago utilizado (transferencia bancaria, consignación o cheque). Una cuota no puede existir en el sistema sin estar asociada a una promesa de compraventa.

Los empleados de Construhogar tienen un código, nombre completo, cargo (asesor comercial, director de proyecto, arquitecto o ingeniero), fecha de ingreso y correo corporativo. La antigüedad de cada empleado se calcula desde su fecha de ingreso y no se almacena directamente.

La empresa trabaja con contratistas externos para ejecutar las obras: empresas de electricidad, plomería, estructura y acabados. De cada contratista se registra su NIT, razón social, especialidad técnica, ciudad, teléfono y correo. Un contratista puede participar en varios proyectos, y en un mismo proyecto intervienen múltiples contratistas; la constructora solo necesita saber quién participa en qué proyecto sin registrar datos adicionales de esa participación.

Construhogar ofrece a sus compradores tres paquetes de acabados con diferente nivel de materialidad: Básico, Estándar y Premium. Cada paquete define el tipo de pisos, enchapes, mesones de cocina y sanitarios que incluye. Una unidad lleva asignado exactamente un paquete de acabados, y un mismo paquete puede aplicarse a múltiples unidades dentro de cualquier proyecto del portafolio.

---

*Construye el modelo E-R completo, el diagrama relacional y documenta cada decisión de diseño según las instrucciones generales del evento.*


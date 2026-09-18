# Reglas de negocio

Planteando las entidades y atributos con sus relaciones es la siguiente:

* **RN.01:** Toda persona registrada en el sistema debe ser cliente o vendedor, **una misma persona no puede ser cliente y vendedor al mismo tiempo (especialización disjunta y total)**.
* **RN.02:** Cada cliente se identifica con su DNI y puede haber realizado una o varias compras a lo largo del tiempo.
* **RN.03:** Cada vendedor se identifica con un único código de vendedor, este puede haber atendido ninguna o varias ventas a lo largo del tiempo.
* **RN.04:** Cada producto se identifica con un único código de producto, este pudo haber participado en cero o más ventas y pudo haber sido integrado en uno o varios pedidos de reabastecimiento.
* **RN.05:** Cada producto que tenga un stock actual del producto de 5 o menos, recién allí se realizará un nuevo pedido de compra del mismo para evitar así la venta de productos vencidos.
* **RN.06:** Cada código de venta identifica a una única venta, en la cual participa un solo cliente y vendedor.
* **RN.07:** Una venta debe incluir uno o varios productos de la misma o diferente categoría.
* **RN.08:** El precio unitario del detalle es el vigente al momento de la venta, sin verse afectado por cambios posteriores en el precio de lista del producto.
* **RN.09:** El número de receta es obligatorio solo si el producto es vendido bajo receta médica; en caso contrario no aplica en la venta del mismo.
* **RN.10:** Cada línea de detalle de venta descuenta el stock actual de un producto específico.
* **RN.11:** El CUIT identifica de manera única a cada proveedor y este puede haber sido objeto de uno o varios pedidos.
* **RN.12:** Cada pedido tiene un código único y también cada pedido de un producto corresponde a un único proveedor.
* **RN.13:** Cada venta se realiza con un método de pago que puede ser (efectivo, débito, crédito o transferencia).
* **RN.14:** Cuando se realiza un pedido de producto, la cantidad solicitada se sumará al stock actual que posee el producto.

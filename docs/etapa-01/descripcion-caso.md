# 🏥 Descripción del Caso: Farmacia Sana-Sana

El presente proyecto aborda el diseño de una base de datos para la **Farmacia Sana-Sana**, ubicada en la ciudad de Corrientes. El sistema administra la comercialización de productos y vencimientos, así como el proceso de reabastecimiento de stock a través de diversos proveedores.

## 👥 Gestión de Usuarios (Personas)
Toda persona registrada en el sistema como cliente o vendedor debe guardar:
* DNI
* Nombre/s y Apellido/s
* Correo electrónico
* Fecha de nacimiento
* Número de teléfono

Una persona **debe ser cliente o vendedor**, pero no puede desempeñar ambos roles simultáneamente.

### Clientes
De un cliente se requiere, además de los datos personales, la **dirección**. Este cliente puede haber realizado una o varias compras a lo largo del tiempo.

### Vendedores
De un vendedor se requiere su propio **código de vendedor** (identificador). Un vendedor puede no haber atendido ninguna venta todavía o puede haber atendido una o varias. Un equipo de vendedores atiende las ventas a los clientes registrados.

## 📦 Gestión de Productos e Inventario
De un producto se requiere saber:
* Código de producto (identificador)
* Nombre y Descripción
* Categoría (medicamentos, cosmética, higiene personal, dietética, entre otras)
* Precio unitario
* Stock
* Lote actual

**Control de Stock:** El stock de cada producto se descuenta (en la venta) y se suma al mismo (si se abastece). Si el stock actual del producto está en **5 o menos**, se realizará un nuevo pedido de compra del mismo para evitar la venta de productos vencidos. Un producto puede haber sido vendido una, varias veces o nunca.

## 🛒 Operaciones de Venta
Cada venta cuenta con:
* Código de venta (identificador)
* Fecha de venta
* Cliente correspondiente y Vendedor que la atiende
* Método de pago (efectivo, débito, crédito o transferencia)
* Indicador de si la venta se realiza bajo receta o no.

La venta la realiza un solo vendedor y le corresponde a un único cliente. Incluye uno o más productos.

### Detalle de Venta
El detalle registra:
* Número de línea
* Nombre del producto y Lote del cual se descuenta la cantidad vendida
* Cantidad y Precio unitario vigente al momento de la operación *(independientemente de cambios posteriores en el precio de lista)*
* Número de receta correspondiente *(dato obligatorio solo si requiere receta médica)*.

## 🚚 Proveedores y Reabastecimiento
Cada proveedor debe tener:
* CUIT (identificador)
* Nombre, Dirección y Teléfono
* Razón social y Tipo de proveedor (ej. droguería, laboratorio, etc.)

La reposición de stock se realiza mediante **Pedidos**. De cada pedido se registra un código (identificador), fecha y cantidad solicitada. Cada pedido corresponde a un único proveedor, el cual puede tener varios pedidos asignados. Un producto puede solicitarse una o varias veces.

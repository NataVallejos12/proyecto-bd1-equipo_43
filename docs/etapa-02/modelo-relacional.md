--- Modelo relacional en 'Notación Textual Estándar'

* Persona (dni, nombre/s, apellido/s, correo, teléfono_persona, fecha_nacimiento)
  * Clave Primaria (PK): dni

* Cliente (dni, dirección)
  * Clave Primaria (PK): dni
  * Clave Única (UQ): dni
  * Clave Foránea (FK): dni referencias persona(dni)

* Vendedor (cod_vendedor, dni)
  * Clave Primaria (PK): cod_vendedor
  * Clave Única (UQ): cod_vendedor
  * Clave Foránea (FK): dni referencias persona(dni)

* Producto (cod_producto, descripción, categoría, precio_producto, nombre_producto, existencia_actual, lote)
  * Clave Primaria (PK): cod_producto
  * Clave Única (UQ): cod_producto

* Proveedor (cuit, nombre, dirección, teléfono_proveedor, razón_social, tipo_proveedor)
  * Clave Primaria (PK): cuit
  * Clave Única (UQ): cuit

* Venta (cod_venta, fecha_venta, precio_total, metodo_pago, receta, cod_vendedor, dni)
  * Clave Primaria (PK): cod_venta
  * Clave Única (UQ): cod_venta
  * Claves Foráneas (FK):
    * cod_vendedor referencias vendedor(cod_vendedor)
    * dni referencias cliente(dni)

* Detalle_venta (cod_venta, cod_producto, cant_comprada, subtotal, precio_unitario)
  * Clave Primaria (PK): cod_venta, cod_producto
  * Claves Foráneas (FK):
    * cod_venta referencias venta(cod_venta)
    * cod_producto referencias producto(cod_producto)

* Pedido (cod_pedido, fecha_pedido, cantidad_entregada, cuit, cod_producto)
  * Clave Primaria (PK): cod_pedido
  * Clave Única (UQ): cod_pedido
  * Claves Foráneas (FK):
    * cuit referencias proveedor(cuit)
    * cod_producto referencias producto(cod_producto)

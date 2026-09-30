--- Modelo relacional en 'Notación Textual Estándar'

* Persona (dni, nombre/s, apellido/s, correo, teléfono_persona, fecha_nacimiento)
  * Clave Primaria (PK): dni

* Cliente (dni, dirección)
  * Clave Primaria (PK): dni
  * Clave Foránea (FK): dni referencias persona(dni)

* Vendedor (cod_vendedor, dni)
  * Clave Primaria (PK): cod_vendedor
  * Clave Foránea (FK): dni referencias persona(dni)

* Producto (cod_producto, descripción, categoría, precio_unitario, nombre_producto, stock, lote)
  * Clave Primaria (PK): cod_producto

* Proveedor (cuit, nombre, dirección, teléfono_proveedor, razón_social, tipo_proveedor)
  * Clave Primaria (PK): cuit

* Venta (cod_venta, fecha_venta, metodo_pago, nro_receta (O), cod_vendedor, dnii)
  * Clave Primaria (PK): cod_venta
  * Claves Foráneas (FK):
    * cod_vendedor referencias vendedor(cod_vendedor)
    * dni referencias cliente(dni)

* Detalle_venta (cod_venta, linea_venta, cod_producto, cant_comprada, precio_unitario)
  * Clave Primaria (PK): cod_venta, linea_venta
  * Claves Foráneas (FK):
    * cod_venta referencias venta(cod_venta)
    * cod_producto referencias producto(cod_producto)

* Pedido (cod_pedido, fecha_pedido, cantidad_entregada, cuit, cod_producto)
  * Clave Primaria (PK): cod_pedido
  * Claves Foráneas (FK):
    * cuit referencias proveedor(cuit)
    * cod_producto referencias producto(cod_producto)

# Restricciones de integridad – Farmacia_SanaSana

Las **restricciones de integridad** son las reglas que garantizan que los datos sean válidos y consistentes:
* **Integridad de entidad:** Dice que cada fila de una tabla tiene que poder identificarse de forma única, y para eso existe la clave primaria: no se puede repetir ni puede ser NULL (PK).
* **Integridad referencial:** Dice que una relación entre tablas tiene que apuntar a algo que existe, y se logra con la clave foránea (FK).
* **Unicidad:** Dice que el valor de una columna (que no es la clave primaria) no puede repetirse entre filas (UNIQUE).
* **Dominio:** Dice qué valores son válidos para una columna (CHECK, más los tipos de dato).
* **Obligatoriedad:** Dice que una columna no puede quedar vacía (NOT NULL).
  
## 1. Integridad de entidad (claves primarias)
| Tabla | Clave primaria | Constraint |
|---|---|---|
| Persona | dni | PK_PERSONA |
| Producto | cod_producto | PK_PRODUCTO |
| Proveedor | cuit | PK_PROVEEDOR |
| Cliente | dni | PK_CLIENTE |
| Vendedor | cod_vendedor | PK_VENDEDOR |
| Venta | cod_venta | PK_VENTA |
| Detalle_venta | (cod_venta, linea_venta) | PK_DETALLE_VENTA |
| Pedido | cod_pedido | PK_PEDIDO |

## 2. Integridad referencial (claves foráneas)
| Constraint | Tabla.columna | Referencia |
|---|---|---|
| FK_CLIENTE_PERSONA | Cliente.dni | Persona.dni |
| FK_VENDEDOR_PERSONA | Vendedor.dni | Persona.dni |
| FK_VENTA_VENDEDOR | Venta.cod_vendedor | Vendedor.cod_vendedor |
| FK_VENTA_CLIENTE | Venta.dni | Cliente.dni |
| FK_DETALLE_VENTA_VENTA | Detalle_venta.cod_venta | Venta.cod_venta |
| FK_DETALLE_VENTA_PRODUCTO | Detalle_venta.cod_producto | Producto.cod_producto |
| FK_PEDIDO_PROVEEDOR | Pedido.cuit | Proveedor.cuit |
| FK_PEDIDO_PRODUCTO | Pedido.cod_producto | Producto.cod_producto |


## 3. Restricciones de unicidad (UNIQUE)

| Constraint | Tabla.columna |
|---|---|
| UQ_correo | Persona.correo |
| UQ_telefono_persona | Persona.telefono_persona |
| UQ_lote | Producto.lote |
| UQ_telefono_proveedor | Proveedor.telefono_proveedor |
| UQ_nro_receta | Venta.nro_receta |

## 4. Restricciones de dominio (CHECK)

| Constraint | Tabla | Regla |
|---|---|---|
| ck_producto_precio | Producto | precio_unitario > 0 |
| ck_producto_stock | Producto | stock >= 0 |
| ck_venta_metodo_pago | Venta | metodo_pago ∈ {Efectivo, Tarjeta de débito, Tarjeta de crédito, Transferencia, Mercado Pago, Código QR, Obra social, Cuenta corriente} |
| ck_detalle_cantidad | Detalle_venta | cant_comprada > 0 |
| ck_detalle_precio | Detalle_venta | precio_unitario > 0 |
| ck_pedido_cantidad | Pedido | cantidad_entregada > 0 |

## 5. Obligatoriedad (NOT NULL)

Todas las columnas son **NOT NULL**, excepto Venta.nro_receta, que admite NULL.

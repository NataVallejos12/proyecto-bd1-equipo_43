# Restricciones de integridad – Farmacia_SanaSana

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

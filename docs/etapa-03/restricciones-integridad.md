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


# Proyecto: Farmacia Sana-Sana (Equipo 43)
**Etapa IV:** Consultas y Casos de Uso  
**Archivo:** [sql/consultas/informe_ventas.sql](sql/consultas/informe_ventas.sql)  
**Objetivo:** Reporte agregado del total de ventas realizadas por cada vendedor y por cada categoría de producto en un rango de fechas (`GROUP BY`, `SUM`, `COUNT`, `AVG`,`MIN` ,`MAX` y `CASE`). 

# Contexto del  Modelo Relacional Utilizado 

El script opera las siguientes relaciones del modelo de la base de datos

* Vendedor (cod_vendedor , dni)
* Persona ( dni, nombre/s, apellido/s, correo, telefono_persona, fecha_nacimiento)
* Venta (cod_venta, fecha_venta, metodo_pago, nro_receta(0), cod_vendedor, dni)
* Detalle_venta (cod_venta, linea_venta , cod_producto , cont_comprada ,precio_unitario)
* Producto (cod_producto , descripcion, categoria, precio_unitario , nombre_producto , stock, lote)

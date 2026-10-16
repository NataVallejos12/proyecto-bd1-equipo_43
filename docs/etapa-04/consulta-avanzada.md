# Etapa 04: Consultas Avanzadas - Farmacia Sana-Sana

Este documento detalla las consultas avanzadas desarrolladas para resolver requerimientos de información complejos del negocio, combinando múltiples tablas y aplicando diversas estrategias de filtrado, agrupación y subconsultas.

## Consulta 3A: Clientes con Gasto Superior al Ticket Promedio
* **Necesidad de información:** Identificar a los clientes más rentables cuyo gasto acumulado histórico supera el importe promedio por venta de toda la farmacia. Esto permite focalizar campañas de fidelización.
* **Estrategia SQL utilizada:** Implementa una combinación (`JOIN`) de 4 tablas (`Cliente`, `Persona`, `Venta`, `Detalle_venta`) agrupadas (`GROUP BY`) por cliente. Utiliza la cláusula `HAVING` para filtrar los grupos comparando la suma de gastos contra una subconsulta mono-registro que, a su vez, calcula el promedio desde una Tabla Derivada en su cláusula `FROM`.
* **Resultado esperado:** Un listado ordenado de mayor a menor gasto con el DNI, nombre completo, dirección, edad aproximada, cantidad de compras realizadas, unidades adquiridas y el monto total gastado por cada uno de estos clientes destacados.

## Consulta 3B: Trazabilidad de Ventas en las 2 Categorías Líderes
* **Necesidad de información:** Conocer en detalle el desglose de ventas asociadas exclusivamente a los productos que pertenecen a las dos categorías más vendidas (mayor volumen de unidades despachadas), para analizar qué productos específicos traccionan esas categorías.
* **Estrategia SQL utilizada:** Emplea el `JOIN` de 5 tablas. El filtrado principal se hace en la cláusula `WHERE` mediante el operador de conjuntos `IN`, el cual evalúa contra una subconsulta multi-registro que utiliza `TOP 2`, `GROUP BY` y `ORDER BY DESC` para obtener dinámicamente las categorías líderes.
* **Resultado esperado:** Un informe detallado con el número de comprobante, fecha, cliente, producto, nombre de la categoría líder, unidades llevadas, precio unitario y subtotal de la línea de venta, ordenado por categoría.

## Consulta 3C.1: Productos vendidos con respaldo de pedido
* **Necesidad de información:** Auditar qué productos de los que actualmente se están comercializando tienen un respaldo de reposición formal mediante pedidos emitidos a los proveedores.
* **Estrategia SQL utilizada:** Realiza un `JOIN` de 3 tablas (`Producto`, `Detalle_venta`, `Venta`) y filtra mediante una subconsulta correlacionada utilizando el operador `EXISTS`, verificando si el producto en cuestión tiene registros coincidentes en la tabla `Pedido` vinculada al `Proveedor`.
* **Resultado esperado:** Una lista de productos seguros indicando su código, nombre, categoría, stock actual, en cuántas ventas participaron, total de unidades despachadas y los ingresos generados.

## Consulta 3C.2: Alerta de productos vendidos SIN pedidos de reposición
* **Necesidad de información:** Detectar de forma temprana aquellos productos que se están vendiendo pero que no tienen ningún pedido de abastecimiento registrado en el sistema, lo que representa un riesgo inminente de quiebre de stock.
* **Estrategia SQL utilizada:** Combina 3 tablas agrupadas y aplica una subconsulta correlacionada en el `WHERE` utilizando el operador `NOT EXISTS` para excluir a aquellos productos que tengan presencia en la tabla de pedidos.
* **Resultado esperado:** Un reporte de alerta con el código, producto, categoría, lote, stock remanente, las unidades que se vendieron sin tener reposición y el monto facturado, para tomar acción de compra inmediata.

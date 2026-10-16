/* =========================================================================
   PROYECTO: Farmacia Sana-Sana (Equipo 43)
   ETAPA IV: Consultas y Casos de Uso
   ARCHIVO:  sql/consultas/consulta_avanzada.sql
   OBJETIVO: Consultas de negocio avanzadas que combinan al menos 3 tablas
             mediante JOIN y aplican filtros condicionales con HAVING y los
             4 tipos de subconsultas de la cátedra.
   ========================================================================= */

USE Farmacia_SanaSana;
GO
/*
====================================================================
CONSULTA AVANZADA 3A: Clientes con Gasto Superior al Ticket Promedio
(JOIN de 4 tablas + GROUP BY + HAVING + Subconsulta Mono-registro + 
Tabla Derivada en cláusula FROM)
Objetivo: Identificar a los clientes cuyo gasto acumulado supera el
importe promedio por venta de toda la farmacia ($10.420,83).
====================================================================
*/

SELECT 
    c.dni                                                       AS [DNI_Cliente],
    p_cli.apellidos + ', ' + p_cli.nombres                      AS [Cliente],
    c.direccion                                                 AS [Direccion],
    DATEDIFF(YEAR, p_cli.fecha_nacimiento, GETDATE())           AS [Edad_Aprox],
    COUNT(DISTINCT v.cod_venta)                                 AS [Compras_Realizadas],
    SUM(dv.cant_comprada)                                       AS [Unidades_Adquiridas],
    ROUND(SUM(dv.cant_comprada * dv.precio_unitario), 2)        AS [Gasto_Total_Acumulado]
FROM Cliente AS c
INNER JOIN Persona AS p_cli 
    ON c.dni = p_cli.dni
INNER JOIN Venta AS v 
    ON c.dni = v.dni
INNER JOIN Detalle_venta AS dv 
    ON v.cod_venta = dv.cod_venta
GROUP BY 
    c.dni,
    p_cli.apellidos,
    p_cli.nombres,
    c.direccion,
    p_cli.fecha_nacimiento
HAVING SUM(dv.cant_comprada * dv.precio_unitario) > (
    -- Subconsulta Mono-registro con operador de comparación (>)
    -- Anida una Tabla Derivada en la cláusula FROM para promediar los totales por venta
    SELECT AVG(ResumenPorVenta.TotalVenta)
    FROM (
        SELECT SUM(dv_int.cant_comprada * dv_int.precio_unitario) AS TotalVenta
        FROM Detalle_venta AS dv_int
        GROUP BY dv_int.cod_venta
    ) AS ResumenPorVenta
)
ORDER BY [Gasto_Total_Acumulado] DESC;
GO
/*
=========================================================================
-- CONSULTA AVANZADA 3B: Trazabilidad de Ventas en las 2 Categorías Líderes
-- (JOIN de 5 tablas + Subconsulta Multi-registro con operador IN y TOP 2)
-- Objetivo: Mostrar las ventas detalladas de aquellos productos que integran
-- las 2 categorías con mayor cantidad de unidades vendidas (Analgésicos e Insumos).
 =========================================================================
*/
SELECT 
    v.cod_venta                                                 AS [Comprobante],
    v.fecha_venta                                               AS [Fecha],
    p_cli.apellidos + ', ' + p_cli.nombres                      AS [Cliente],
    pr.cod_producto                                             AS [Cod_Producto],
    pr.nombre_producto                                          AS [Producto],
    pr.categoria                                                AS [Categoria_Lider],
    dv.cant_comprada                                            AS [Unidades],
    dv.precio_unitario                                          AS [Precio_Unitario],
    ROUND(dv.cant_comprada * dv.precio_unitario, 2)             AS [Subtotal]
FROM Venta AS v
INNER JOIN Cliente AS c 
    ON v.dni = c.dni
INNER JOIN Persona AS p_cli 
    ON c.dni = p_cli.dni
INNER JOIN Detalle_venta AS dv 
    ON v.cod_venta = dv.cod_venta
INNER JOIN Producto AS pr 
    ON dv.cod_producto = pr.cod_producto
WHERE pr.categoria IN (
    -- Subconsulta Multi-registro con operador de conjuntos IN y cláusula TOP
    SELECT TOP 2 pr_sub.categoria
    FROM Detalle_venta AS dv_sub
    INNER JOIN Producto AS pr_sub 
        ON dv_sub.cod_producto = pr_sub.cod_producto
    GROUP BY pr_sub.categoria
    ORDER BY SUM(dv_sub.cant_comprada) DESC
)
ORDER BY pr.categoria ASC, v.cod_venta ASC;
GO

-- =========================================================================
-- CONSULTA AVANZADA 3C: Auditoría de Reposición de Productos Vendidos
-- (JOIN de 3 tablas + Subconsulta Correlacionada con EXISTS y NOT EXISTS)
-- Objetivo 1 (EXISTS): Listar los productos vendidos que registran al menos
-- un pedido de reposición emitido a un proveedor.
-- Objetivo 2 (NOT EXISTS): Detectar productos comercializados que NO poseen
-- ningún pedido de reposición cargado en la tabla Pedido (alerta de stock).
-- =========================================================================

-- 3C.1: Productos vendidos CON respaldo de pedido a proveedor (EXISTS)
SELECT 
    pr.cod_producto                                             AS [Cod_Producto],
    pr.nombre_producto                                          AS [Producto],
    pr.categoria                                                AS [Categoria],
    pr.stock                                                    AS [Stock_Actual],
    COUNT(DISTINCT v.cod_venta)                                 AS [Ventas_Participadas],
    SUM(dv.cant_comprada)                                       AS [Unidades_Despachadas],
    ROUND(SUM(dv.cant_comprada * dv.precio_unitario), 2)        AS [Ingresos_Generados]
FROM Producto AS pr
INNER JOIN Detalle_venta AS dv 
    ON pr.cod_producto = dv.cod_producto
INNER JOIN Venta AS v 
    ON dv.cod_venta = v.cod_venta
WHERE EXISTS (
    SELECT *
    FROM Pedido AS ped
    INNER JOIN Proveedor AS prov 
        ON ped.cuit = prov.cuit
    WHERE ped.cod_producto = pr.cod_producto
)
GROUP BY 
    pr.cod_producto,
    pr.nombre_producto,
    pr.categoria,
    pr.stock
ORDER BY [Unidades_Despachadas] DESC;
GO

-- 3C.2: Alerta de productos vendidos SIN pedidos de reposición (NOT EXISTS)
SELECT 
    pr.cod_producto                                             AS [Cod_Producto],
    pr.nombre_producto                                          AS [Producto],
    pr.categoria                                                AS [Categoria],
    pr.lote                                                     AS [Lote_Actual],
    pr.stock                                                    AS [Stock_Remanente],
    SUM(dv.cant_comprada)                                       AS [Unidades_Vendidas_Sin_Reposicion],
    ROUND(SUM(dv.cant_comprada * dv.precio_unitario), 2)        AS [Monto_Vendido]
FROM Producto AS pr
INNER JOIN Detalle_venta AS dv 
    ON pr.cod_producto = dv.cod_producto
INNER JOIN Venta AS v 
    ON dv.cod_venta = v.cod_venta
WHERE NOT EXISTS (
    SELECT *
    FROM Pedido AS ped
    WHERE ped.cod_producto = pr.cod_producto
)
GROUP BY 
    pr.cod_producto,
    pr.nombre_producto,
    pr.categoria,
    pr.lote,
    pr.stock
ORDER BY pr.cod_producto ASC;
GO

/* 
=========================================================================
--PROYECTO: Farmacia Sana-Sana (Equipo 43)
--ETAPA IV: Consultas y Casos de Uso
--ARCHIVO:  sql/consultas/comprobante_venta.sql
--OBJETIVO: Consolidar el encabezado y detalle de una venta, calculando
             subtotales por renglón y el total acumulado del comprobante.
========================================================================= 
*/

USE Farmacia_SanaSana;
GO

-- =========================================================================
-- CONSULTA 1A: Emisión de Factura / Comprobante Detallado (Estándar ANSI)
-- Combina 7 referencias de tablas mediante INNER JOIN (Venta, Cliente, 
-- Persona para cliente, Vendedor, Persona para vendedor, Detalle_venta y 
-- Producto). Calcula el subtotal por línea con expresiones aritméticas y el
-- total acumulado de la factura mediante una subconsulta escalar.
-- =========================================================================
SELECT 
    -- Datos del Encabezado del Comprobante
    v.cod_venta                                                 AS [Nro_Comprobante],
    v.fecha_venta                                               AS [Fecha_Emision],
    v.metodo_pago                                               AS [Metodo_Pago],
    CASE 
        WHEN v.nro_receta IS NULL THEN 'Venta Libre (S/R)'
        ELSE 'Bajo Receta (' + v.nro_receta + ')'
    END                                                         AS [Condicion_Venta],
    
    -- Datos del Cliente (Persona + Cliente)
    c.dni                                                       AS [DNI_Cliente],
    p_cli.apellidos + ', ' + p_cli.nombres                      AS [Cliente],
    c.direccion                                                 AS [Domicilio_Cliente],
    
    -- Datos del Vendedor (Persona + Vendedor)
    ven.cod_vendedor                                            AS [Legajo_Vendedor],
    p_ven.apellidos + ', ' + p_ven.nombres                      AS [Vendedor],
    
    -- Datos del Detalle (Renglones de la Factura)
    dv.linea_venta                                              AS [Renglon],
    dv.cod_producto                                             AS [Cod_Producto],
    pr.nombre_producto                                          AS [Producto],
    pr.categoria                                                AS [Categoria],
    pr.lote                                                     AS [Lote],
    dv.cant_comprada                                            AS [Cantidad],
    dv.precio_unitario                                          AS [Precio_Unitario_Facturado],
    pr.precio_unitario                                          AS [Precio_Lista_Actual],
    
    -- Expresión Aritmética: Subtotal por Renglón
    ROUND(dv.cant_comprada * dv.precio_unitario, 2)             AS [Subtotal_Renglon],
    
    -- Subconsulta Escalar: Total Acumulado del Comprobante 
    --(Aquí calculamos el total de la factura con los subtotales)
    (
        SELECT ROUND(SUM(dv_sub.cant_comprada * dv_sub.precio_unitario), 2)
        FROM Detalle_venta AS dv_sub
        WHERE dv_sub.cod_venta = v.cod_venta
    )                                                           AS [Total_Acumulado_Comprobante]

FROM Venta AS v 
INNER JOIN Cliente AS c 
    ON v.dni = c.dni
INNER JOIN Persona AS p_cli 
    ON c.dni = p_cli.dni
INNER JOIN Vendedor AS ven 
    ON v.cod_vendedor = ven.cod_vendedor
INNER JOIN Persona AS p_ven 
    ON ven.dni = p_ven.dni
INNER JOIN Detalle_venta AS dv 
    ON v.cod_venta = dv.cod_venta
INNER JOIN Producto AS pr 
    ON dv.cod_producto = pr.cod_producto
WHERE v.cod_venta IN (4,9)
ORDER BY v.cod_venta ASC ;
GO


-- ==================================================================================
-- CONSULTA 1B: Resumen de Pie de Comprobante (Listado General de Facturas)
-- Utiliza funciones de agregado (COUNT, SUM) y GROUP BY para terminar de 
-- consolidar el total acumulado y la cantidad de unidades de todos los comprobantes.
-- ==================================================================================
SELECT 
    v.cod_venta                                                 AS [Nro_Comprobante],
    v.fecha_venta                                               AS [Fecha_Emision],
    p_cli.apellidos + ', ' + p_cli.nombres                      AS [Cliente],
    p_ven.apellidos + ', ' + p_ven.nombres                      AS [Vendedor],
    v.metodo_pago                                               AS [Metodo_Pago],
    ISNULL(v.nro_receta, 'Sin Receta')                          AS [Nro_Receta],
    COUNT(dv.linea_venta)                                       AS [Cant_Renglones],
    SUM(dv.cant_comprada)                                       AS [Total_Unidades],
    ROUND(SUM(dv.cant_comprada * dv.precio_unitario), 2)        AS [Total_Facturado]
FROM Venta AS v
INNER JOIN Cliente AS c 
    ON v.dni = c.dni
INNER JOIN Persona AS p_cli 
    ON c.dni = p_cli.dni
INNER JOIN Vendedor AS ven 
    ON v.cod_vendedor = ven.cod_vendedor
INNER JOIN Persona AS p_ven 
    ON ven.dni = p_ven.dni
INNER JOIN Detalle_venta AS dv 
    ON v.cod_venta = dv.cod_venta
GROUP BY 
    v.cod_venta,
    v.fecha_venta,
    p_cli.apellidos,
    p_cli.nombres,
    p_ven.apellidos,
    p_ven.nombres,
    v.metodo_pago,
    v.nro_receta
ORDER BY v.cod_venta ASC;
GO

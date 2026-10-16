  =========================================================================
--REPORTE AGREGADO 2A: Total de Ventas por Vendedor en Rango de Fechas
-- Combina Vendedor, Persona, Venta y Detalle_venta. Filtra el período con
-- BETWEEN y clasifica el desempeño comercial con la función de fila CASE.
-- =========================================================================
SELECT 
    ven.cod_vendedor                                            AS [Cod_Vendedor],
    p_ven.dni                                                   AS [DNI_Vendedor],
    p_ven.apellidos + ', ' + p_ven.nombres                      AS [Vendedor],
    COUNT(DISTINCT v.cod_venta)                                 AS [Cantidad_Ventas],
    COUNT(dv.linea_venta)                                       AS [Renglones_Facturados],
    SUM(dv.cant_comprada)                                       AS [Unidades_Vendidas],
    ROUND(SUM(dv.cant_comprada * dv.precio_unitario), 2)        AS [Total_Recaudado],
    ROUND(AVG(dv.cant_comprada * dv.precio_unitario), 2)        AS [Promedio_Por_Renglon],
    CASE 
        WHEN SUM(dv.cant_comprada * dv.precio_unitario) >= 20000 THEN 'Desempeño Sobresaliente'
        WHEN SUM(dv.cant_comprada * dv.precio_unitario) >= 10000 THEN 'Desempeño Promedio'
        ELSE 'Desempeño Aceptable'
    END                                                         AS [Categoria_Desempeno]
FROM Vendedor AS ven
INNER JOIN Persona AS p_ven 
    ON ven.dni = p_ven.dni
INNER JOIN Venta AS v 
    ON ven.cod_vendedor = v.cod_vendedor
INNER JOIN Detalle_venta AS dv 
    ON v.cod_venta = dv.cod_venta
WHERE v.fecha_venta BETWEEN '2026-09-01' AND '2026-09-30'
GROUP BY 
    ven.cod_vendedor,
    p_ven.dni,
    p_ven.apellidos,
    p_ven.nombres
ORDER BY [Total_Recaudado] DESC;
GO

-- =========================================================================
-- REPORTE AGREGADO 2B: Total de Ventas por Categoría de Producto en Fechas
-- Agrupa la facturación por categoría en el mes de septiembre de 2026,
-- calculando métricas de volumen e importes con COUNT, SUM, MIN, MAX y AVG.
-- =========================================================================
SELECT 
    pr.categoria                                                AS [Categoria_Producto],
    COUNT(DISTINCT v.cod_venta)                                 AS [Comprobantes_Emitidos],
    COUNT(DISTINCT pr.cod_producto)                             AS [Productos_Distintos_Vendidos],
    SUM(dv.cant_comprada)                                       AS [Total_Unidades_Vendidas],
    MIN(dv.precio_unitario)                                     AS [Precio_Unit_Menor],
    MAX(dv.precio_unitario)                                     AS [Precio_Unit_Mayor],
    ROUND(AVG(dv.precio_unitario), 2)                           AS [Precio_Unit_Promedio],
    ROUND(SUM(dv.cant_comprada * dv.precio_unitario), 2)        AS [Total_Facturado_Categoria]
FROM Producto AS pr
INNER JOIN Detalle_venta AS dv 
    ON pr.cod_producto = dv.cod_producto
INNER JOIN Venta AS v 
    ON dv.cod_venta = v.cod_venta
WHERE v.fecha_venta BETWEEN '2026-09-01' AND '2026-09-30'
GROUP BY pr.categoria
ORDER BY [Total_Facturado_Categoria] DESC;
GO
```
  


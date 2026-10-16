# Proyecto: Farmacia Sana-Sana (Equipo 43)
**Etapa IV:** Consultas y Casos de Uso  
**Archivo:** `sql/consultas/informe_ventas.sql`  
**Objetivo:** Reporte agregado del total de ventas realizadas por cada vendedor y por cada categoría de producto en un rango de fechas (`GROUP BY`, `SUM`, `COUNT`, `AVG`, `MIN`, `MAX` y `CASE`).

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

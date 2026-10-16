# Proyecto:Farmacia Sana_Sana (Equipo 43)
**Etapa IV** : Consultas y Casos de Uso
**Archivo ** : sql/consultas/informe_ventas.sql
**Objetivo:** : Reporte agregado del total de  ventas realizadas por cada vendedor y por cada categoría de producto en un rango de fechas ( GROUP BY, SUM , COUNT , AVG .MIN ,MAX Y CASE ).
  
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

  


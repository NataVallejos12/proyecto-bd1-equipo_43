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

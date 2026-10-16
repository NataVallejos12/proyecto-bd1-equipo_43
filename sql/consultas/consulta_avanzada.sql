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

   
/*
=========================================================================
-- CONSULTA AVANZADA 3D: Ranking de Vendedores con Subconsulta Escalar en SELECT
-- (JOIN de 4 tablas + Subconsulta Escalar en la cláusula SELECT)
-- Objetivo: Mostrar la facturación total de cada vendedor junto con el 
-- promedio global de facturación por vendedor y la diferencia individual.
=========================================================================
*/
SELECT 
    vend.cod_vendedor                                           AS [Cod_Vendedor],
    p_vend.apellidos + ', ' + p_vend.nombres                    AS [Vendedor],
    COUNT(DISTINCT v.cod_venta)                                 AS [Ventas_Atendidas],
    SUM(dv.cant_comprada)                                       AS [Unidades_Vendidas],
    ROUND(SUM(dv.cant_comprada * dv.precio_unitario), 2)        AS [Facturacion_Total],

    -- Subconsulta Escalar en el SELECT para obtener la facturación promedio global por vendedor
    ROUND((
        SELECT SUM(dv_sub.cant_comprada * dv_sub.precio_unitario) / COUNT(DISTINCT v_sub.cod_vendedor)
        FROM Venta AS v_sub
        INNER JOIN Detalle_venta AS dv_sub 
            ON v_sub.cod_venta = dv_sub.cod_venta
    ), 2)                                                       AS [Promedio_Facturacion_Vendedores],

    -- Cálculo de desviación con respecto al promedio
    ROUND(SUM(dv.cant_comprada * dv.precio_unitario) - (
        SELECT SUM(dv_sub.cant_comprada * dv_sub.precio_unitario) / COUNT(DISTINCT v_sub.cod_vendedor)
        FROM Venta AS v_sub
        INNER JOIN Detalle_venta AS dv_sub 
            ON v_sub.cod_venta = dv_sub.cod_venta
    ), 2)                                                       AS [Diferencia_vs_Promedio]

FROM Vendedor AS vend
INNER JOIN Persona AS p_vend 
    ON vend.dni = p_vend.dni
INNER JOIN Venta AS v 
    ON vend.cod_vendedor = v.cod_vendedor
INNER JOIN Detalle_venta AS dv 
    ON v.cod_venta = dv.cod_venta
GROUP BY 
    vend.cod_vendedor,
    p_vend.apellidos,
    p_vend.nombres
ORDER BY [Facturacion_Total] DESC;
GO

   
-- =========================================================================
-- CONSULTA AVANZADA 3E: Pedidos a Proveedores que superan el Monto Promedio
-- (JOIN de 3 tablas + Subconsulta Escalar en cláusula WHERE)
-- Objetivo: Identificar los pedidos de reposición cuyo valor económico 
-- (cantidad entregada * precio de referencia) supera el monto promedio 
-- de todos los pedidos registrados en la farmacia.
-- =========================================================================
SELECT 
    ped.cod_pedido                                              AS [Nro_Pedido],
    ped.fecha_pedido                                            AS [Fecha_Solicitud],
    prov.razon_social                                           AS [Proveedor],
    prov.tipo_proveedor                                         AS [Tipo],
    pr.nombre_producto                                          AS [Producto_Abastecido],
    ped.cantidad_entregada                                      AS [Cantidad],
    ROUND(ped.cantidad_entregada * pr.precio_unitario, 2)       AS [Monto_Total_Pedido]
FROM Pedido AS ped
INNER JOIN Proveedor AS prov 
    ON ped.cuit = prov.cuit
INNER JOIN Producto AS pr 
    ON ped.cod_producto = pr.cod_producto
WHERE (ped.cantidad_entregada * pr.precio_unitario) > (
    -- Subconsulta Escalar: Calcula el valor promedio general de los pedidos
    SELECT AVG(ped_sub.cantidad_entregada * pr_sub.precio_unitario)
    FROM Pedido AS ped_sub
    INNER JOIN Producto AS pr_sub 
        ON ped_sub.cod_producto = pr_sub.cod_producto
)
ORDER BY [Monto_Total_Pedido] DESC;
GO


-- =========================================================================
-- CONSULTA AVANZADA 3F: División Relacional - Clientes Fidelizados (Doble NOT EXISTS)
-- (JOIN de 3 tablas + Subconsulta Correlacionada Anidada con Doble NOT EXISTS)
-- Objetivo: Detectar a los clientes que han comprado TODOS los productos
-- existentes dentro de una categoría específica (ejemplo: 'Analgésicos').
-- =========================================================================
SELECT 
    c.dni                                                       AS [DNI_Cliente],
    p_cli.apellidos + ', ' + p_cli.nombres                      AS [Cliente_Fiel],
    c.direccion                                                 AS [Direccion]
FROM Cliente AS c
INNER JOIN Persona AS p_cli 
    ON c.dni = p_cli.dni
WHERE NOT EXISTS (
    -- Productos de la categoría 'Analgésicos' que NO fueron comprados por el cliente
    SELECT pr.cod_producto
    FROM Producto AS pr
    WHERE pr.categoria = 'Analgésicos'
      AND NOT EXISTS (
        -- Registro de compra del cliente para dicho producto
        SELECT 1
        FROM Venta AS v
        INNER JOIN Detalle_venta AS dv 
            ON v.cod_venta = dv.cod_venta
        WHERE v.dni = c.dni
          AND dv.cod_producto = pr.cod_producto
    )
);
GO
/*
=========================================================================
-- CONSULTA AVANZADA 3G: Métodos de pago que superan al Efectivo
-- (JOIN de 3 tablas + GROUP BY + HAVING con Subconsulta Escalar)
-- Objetivo: Mostrar los métodos de pago que han generado una recaudación total 
-- superior a lo que se recaudó exclusivamente pagando en 'Efectivo'.
=========================================================================
*/
SELECT 
    v.metodo_pago                                           AS [Metodo_de_Pago],
    COUNT(DISTINCT v.cod_venta)                             AS [Cantidad_Ventas],
    COUNT(DISTINCT v.cod_vendedor)                          AS [Vendedores_Involucrados],
    ROUND(SUM(dv.cant_comprada * dv.precio_unitario), 2)    AS [Total_Recaudado]
FROM Venta AS v
INNER JOIN Detalle_venta AS dv 
    ON v.cod_venta = dv.cod_venta
INNER JOIN Vendedor AS vend 
    ON v.cod_vendedor = vend.cod_vendedor
GROUP BY 
    v.metodo_pago
HAVING SUM(dv.cant_comprada * dv.precio_unitario) > (
    -- Subconsulta Escalar: Calcula la recaudación total solo para el método 'Efectivo'
    SELECT SUM(dv_sub.cant_comprada * dv_sub.precio_unitario)
    FROM Venta AS v_sub
    INNER JOIN Detalle_venta AS dv_sub 
        ON v_sub.cod_venta = dv_sub.cod_venta
    WHERE v_sub.metodo_pago = 'Efectivo'
)
ORDER BY [Total_Recaudado] DESC;
GO

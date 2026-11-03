/* =========================================================================
   ETAPA V - TEMA 1: PROCEDIMIENTOS Y FUNCIONES ALMACENADAS
   PARTE A: FUNCIONES - SCRIPT DE DEMOSTRACIÓN
   Requiere: sql/tecnico/funciones/funciones.sql
   Cada prueba indica el resultado esperado en un comentario.
   No modifica datos.
   ========================================================================= */

USE Farmacia_SanaSana;
GO
/* =========================================================================
   1. fn_CalcularEdadExacta
   ========================================================================= */
-- 1.a Edad de todas las personas, usando la función dentro de un SELECT
SELECT dni, nombres, apellidos, fecha_nacimiento,
       dbo.fn_CalcularEdadExacta(dni) AS edad
FROM Persona
ORDER BY edad DESC;

-- 1.b DNI inexistente -> NULL (no se puede calcular)
SELECT dbo.fn_CalcularEdadExacta(99999999) AS edad_dni_inexistente;

-- 1.c Por qué hace falta corregir DATEDIFF: alguien nacido el 20/12/2000,
--     calculado al 15/10/2026, todavía tiene 25 (DATEDIFF da 26).
DECLARE @nac DATE = '2000-12-20', @hoy DATE = '2026-10-15';
SELECT DATEDIFF(YEAR, @nac, @hoy) AS datediff_year,
       DATEDIFF(YEAR, @nac, @hoy)
       - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @nac, @hoy), @nac) > @hoy
              THEN 1 ELSE 0 END AS edad_exacta;      -- 26 y 25
GO

/* =========================================================================
   2. fn_ObtenerStock
   ========================================================================= */
SELECT dbo.fn_ObtenerStock(1)   AS stock_producto_1,       -- 61
       dbo.fn_ObtenerStock(999) AS stock_producto_999;     -- NULL: no existe
GO

/* =========================================================================
   3. fn_CalcularSubtotal
   ========================================================================= */
SELECT dbo.fn_CalcularSubtotal(2, 1500.00) AS caso_normal,        -- 3000.00
       dbo.fn_CalcularSubtotal(3, 2500.50) AS con_decimales,      -- 7501.50
       dbo.fn_CalcularSubtotal(-3, 1500)   AS cantidad_negativa,  -- NULL
       dbo.fn_CalcularSubtotal(2, -10)     AS precio_negativo;    -- NULL

-- Usada sobre la tabla: subtotal de cada línea de la venta 9
SELECT linea_venta, cod_producto, cant_comprada, precio_unitario,
       dbo.fn_CalcularSubtotal(cant_comprada, precio_unitario) AS subtotal
FROM Detalle_venta
WHERE cod_venta = 9;
GO

/* =========================================================================
   4. fn_CalcularDescuentoCliente (como la propone la guía)
   Esperado: 40111004 compró $29.250 -> 10 %; 40111001 compró $18.250 -> 5 %;
   el resto 0 %.
   ========================================================================= */
SELECT p.nombres, p.apellidos,
       dbo.fn_CalcularDescuentoCliente(c.dni) AS descuento_pct
FROM Cliente AS c
INNER JOIN Persona AS p ON p.dni = c.dni
ORDER BY descuento_pct DESC, p.apellidos;
GO


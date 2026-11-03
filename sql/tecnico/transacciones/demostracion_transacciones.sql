/* =========================================================================
   ETAPA V - TEMA 2: MANEJO DE TRANSACCIONES
   SCRIPT DE DEMOSTRACIÓN
   Requiere los scripts de implementación de los Temas 1 y 2 (usa
   fn_CalcularSubtotal). Demuestra la ATOMICIDAD: una venta
   se registra completa o no se registra nada.
   Al final se borran las ventas de prueba y se restaura el stock.
   ========================================================================= */

USE Farmacia_SanaSana;
GO

-- Foto del stock antes de las pruebas, para comparar y para restaurarlo
DROP TABLE IF EXISTS #stock_inicial;
SELECT cod_producto, stock INTO #stock_inicial FROM Producto;

SELECT cod_producto, nombre_producto, stock
FROM Producto WHERE cod_producto IN (2, 6);   -- stock antes de las pruebas
GO

/* =========================================================================
   PRUEBA 1 - CORRECTA: producto con stock suficiente
   Esperado: 'Venta registrada correctamente.'; existe la venta 200, su
   línea 1 y el stock del producto 2 bajó en 3 unidades.
   ========================================================================= */
EXEC dbo.sp_RegistrarVentaCompleta
     @cod_venta = 200, @fecha = '2026-10-30', @metodo_pago = 'Efectivo',
     @nro_receta = NULL, @cod_vendedor = 1, @dni_cliente = 40111002,
     @cod_producto = 2, @cantidad = 3, @precio = 1900.00;

SELECT * FROM Venta         WHERE cod_venta = 200;
SELECT * FROM Detalle_venta WHERE cod_venta = 200;
SELECT p.cod_producto, s.stock AS stock_antes, p.stock AS stock_despues
FROM Producto AS p JOIN #stock_inicial AS s ON s.cod_producto = p.cod_producto
WHERE p.cod_producto = 2;
GO

/* =========================================================================
   PRUEBA 2 - INCORRECTA: stock insuficiente
   El encabezado SE LLEGA A INSERTAR, pero al no alcanzar el stock se
   lanza el error 50026 y el ROLLBACK lo deshace.
   Esperado: error 50026; la venta 201 NO existe, NO hay detalle y el stock
   del producto 6 no cambió. No queda ningún registro parcial.
   ========================================================================= */
BEGIN TRY
    EXEC dbo.sp_RegistrarVentaCompleta 201, '2026-10-30', 'Efectivo', NULL,
         1, 40111003, 6, 9999, 1750.00;
END TRY
BEGIN CATCH
    PRINT 'Prueba 2 - Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;

SELECT (SELECT COUNT(*) FROM Venta         WHERE cod_venta = 201) AS ventas_201,     -- 0
       (SELECT COUNT(*) FROM Detalle_venta WHERE cod_venta = 201) AS detalles_201,   -- 0
       (SELECT stock FROM Producto WHERE cod_producto = 6)        AS stock_actual,
       (SELECT stock FROM #stock_inicial WHERE cod_producto = 6)  AS stock_inicial;  -- iguales
GO

/* =========================================================================
   PRUEBA 3 - Producto inexistente (el error que marcó el profesor)
   Con la versión anterior @stock_actual quedaba NULL, NULL < cantidad no
   era verdadero y se confirmaba la venta. Ahora: error 50026 y nada se
   registra.
   ========================================================================= */
BEGIN TRY
    EXEC dbo.sp_RegistrarVentaCompleta 202, '2026-10-30', 'Efectivo', NULL,
         1, 40111003, 999, 1, 1000.00;
END TRY
BEGIN CATCH
    PRINT 'Prueba 3 - Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
SELECT COUNT(*) AS ventas_202 FROM Venta WHERE cod_venta = 202;   -- 0
GO

/* =========================================================================
   PRUEBA 4 - Validaciones de parámetros (cada una cancela todo)
   ========================================================================= */
BEGIN TRY   -- fecha futura -> 50020
    EXEC dbo.sp_RegistrarVentaCompleta 203, '2099-01-01', 'Efectivo', NULL,
         1, 40111003, 2, 1, 1900.00;
END TRY
BEGIN CATCH
    PRINT 'Prueba 4.a - Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY   -- cliente inexistente -> 50024
    EXEC dbo.sp_RegistrarVentaCompleta 203, '2026-10-30', 'Efectivo', NULL,
         1, 11111111, 2, 1, 1900.00;
END TRY
BEGIN CATCH
    PRINT 'Prueba 4.b - Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY   -- venta repetida -> 50023
    EXEC dbo.sp_RegistrarVentaCompleta 200, '2026-10-30', 'Efectivo', NULL,
         1, 40111002, 2, 1, 1900.00;
END TRY
BEGIN CATCH
    PRINT 'Prueba 4.c - Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY   -- método de pago no permitido: lo rechaza el CHECK de la tabla
            -- (error 547) y THROW lo propaga tal cual
    EXEC dbo.sp_RegistrarVentaCompleta 203, '2026-10-30', 'Cheque', NULL,
         1, 40111003, 2, 1, 1900.00;
END TRY
BEGIN CATCH
    PRINT 'Prueba 4.d - Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;

SELECT COUNT(*) AS ventas_203 FROM Venta WHERE cod_venta = 203;   -- 0
GO

/* =========================================================================
   PRUEBA 5 - Venta con varios productos (sp_AgregarProductoAVenta)
   Esperado: la venta 200 pasa a tener las líneas 1, 2 y 3.
   ========================================================================= */
EXEC dbo.sp_AgregarProductoAVenta @cod_venta = 200, @cod_producto = 6,  @cantidad = 1, @precio = 1750.00;
EXEC dbo.sp_AgregarProductoAVenta @cod_venta = 200, @cod_producto = 11, @cantidad = 2, @precio = 980.00;

-- Si una línea falla, solo se deshace ESA línea: la venta y las líneas ya
-- confirmadas quedan. Esperado: error 50026, la venta sigue con 3 líneas.
BEGIN TRY
    EXEC dbo.sp_AgregarProductoAVenta 200, 3, 9999, 6400.00;
END TRY
BEGIN CATCH
    PRINT 'Prueba 5 - Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;

SELECT dv.linea_venta, p.nombre_producto, dv.cant_comprada, dv.precio_unitario,
       dbo.fn_CalcularSubtotal(dv.cant_comprada, dv.precio_unitario) AS subtotal
FROM Detalle_venta AS dv
JOIN Producto AS p ON p.cod_producto = dv.cod_producto
WHERE dv.cod_venta = 200
ORDER BY dv.linea_venta;
GO

/* =========================================================================
   PRUEBA 6 - CONTRAEJEMPLO: los mismos pasos SIN transacción
   Cada sentencia se confirma sola. Si falla el descuento de stock (viola
   el CHECK stock >= 0), el encabezado ya quedó grabado: venta incompleta.
   ========================================================================= */
BEGIN TRY
    INSERT INTO Venta (cod_venta, fecha_venta, metodo_pago, nro_receta, cod_vendedor, dni)
    VALUES (204, '2026-10-30', 'Efectivo', NULL, 1, 40111005);

    UPDATE Producto SET stock = stock - 9999 WHERE cod_producto = 6;   -- falla

    INSERT INTO Detalle_venta VALUES (204, 1, 6, 9999, 1750.00);
END TRY
BEGIN CATCH
    PRINT 'Prueba 6 - Error: ' + ERROR_MESSAGE();
END CATCH;

SELECT (SELECT COUNT(*) FROM Venta         WHERE cod_venta = 204) AS ventas_204,    -- 1  (!)
       (SELECT COUNT(*) FROM Detalle_venta WHERE cod_venta = 204) AS detalles_204;  -- 0
-- Quedó una venta sin productos: exactamente lo que la transacción evita.
GO

/* =========================================================================
   LIMPIEZA: borrar las ventas de prueba y restaurar el stock.
   El trigger trg_BloquearBorradoVenta (Tema 3) impide borrar ventas, así
   que el ADMINISTRADOR lo deshabilita un momento y lo vuelve a habilitar.
   (Por eso, como dice el profesor, el trigger solo no alcanza: también
   hacen falta permisos, Tema 4, para que nadie más pueda deshabilitarlo.)
   ========================================================================= */
IF OBJECT_ID('dbo.trg_BloquearBorradoVenta') IS NOT NULL
    DISABLE TRIGGER dbo.trg_BloquearBorradoVenta ON dbo.Venta;

DELETE FROM Detalle_venta WHERE cod_venta BETWEEN 200 AND 204;
DELETE FROM Venta         WHERE cod_venta BETWEEN 200 AND 204;

IF OBJECT_ID('dbo.trg_BloquearBorradoVenta') IS NOT NULL
    ENABLE TRIGGER dbo.trg_BloquearBorradoVenta ON dbo.Venta;

UPDATE p SET p.stock = s.stock
FROM Producto AS p JOIN #stock_inicial AS s ON s.cod_producto = p.cod_producto
WHERE p.stock <> s.stock;

DROP TABLE #stock_inicial;
GO

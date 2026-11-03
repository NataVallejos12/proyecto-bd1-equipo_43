/* =========================================================================
   ETAPA V - TEMA 1: PROCEDIMIENTOS Y FUNCIONES ALMACENADAS
   PARTE B: PROCEDIMIENTOS - SCRIPT DE DEMOSTRACIÓN
   Requiere: sql/tecnico/procedimientos/procedimientos.sql
   Cada prueba indica el resultado esperado. Las que deben fallar están
   en TRY/CATCH para que el script siga y muestre el mensaje en la
   pestaña "Mensajes". Al final la base queda como estaba.
   ========================================================================= */

USE Farmacia_SanaSana;
GO

/* =========================================================================
   5. sp_InsertarProducto
   ========================================================================= */
-- 5.a Alta correcta. Esperado: 'Producto registrado correctamente.'
EXEC dbo.sp_InsertarProducto
     @cod = 100, @desc = 'Frasco x 250 ml, alcohol en gel', @cat = 'Higiene',
     @precio = 1500.00, @nombre = 'Alcohol en gel 250 ml', @stock = 20, @lote = 'DEMO-100';

SELECT * FROM Producto WHERE cod_producto = 100;
GO

-- 5.b Precio cero -> error 50001 del procedimiento
BEGIN TRY
    EXEC dbo.sp_InsertarProducto 101, 'Prueba', 'Varios', 0, 'Producto sin precio', 5, 'DEMO-101';
END TRY
BEGIN CATCH
    PRINT '5.b Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- 5.c Nombre vacío -> error 50003
BEGIN TRY
    EXEC dbo.sp_InsertarProducto 101, 'Prueba', 'Varios', 100, '   ', 5, 'DEMO-101';
END TRY
BEGIN CATCH
    PRINT '5.c Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- 5.d Código repetido -> lo rechaza la PRIMARY KEY (error 2627) y el
--     procedimiento propaga el error ORIGINAL con THROW (no un mensaje genérico)
BEGIN TRY
    EXEC dbo.sp_InsertarProducto 100, 'Repetido', 'Higiene', 1500, 'Repetido', 5, 'DEMO-102';
END TRY
BEGIN CATCH
    PRINT '5.d Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

/* =========================================================================
   6. sp_ModificarProducto
   ========================================================================= */
-- 6.a Modificación correcta
EXEC dbo.sp_ModificarProducto @cod = 100, @nuevo_precio = 1650.00, @nuevo_stock = 25;
SELECT cod_producto, nombre_producto, precio_unitario, stock FROM Producto WHERE cod_producto = 100;
GO

-- 6.b Producto inexistente -> error 50006 (antes terminaba sin avisar)
BEGIN TRY
    EXEC dbo.sp_ModificarProducto 999, 1000, 10;
END TRY
BEGIN CATCH
    PRINT '6.b Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- 6.c Stock negativo -> error 50005
BEGIN TRY
    EXEC dbo.sp_ModificarProducto 100, 1650, -5;
END TRY
BEGIN CATCH
    PRINT '6.c Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

/* =========================================================================
   7. sp_BorrarProducto
   ========================================================================= */
-- 7.a Producto con ventas: la clave foránea de Detalle_venta lo impide
--     (error 547). El historial de ventas se conserva.
BEGIN TRY
    EXEC dbo.sp_BorrarProducto @cod = 1;
END TRY
BEGIN CATCH
    PRINT '7.a Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- 7.b Producto inexistente -> error 50007
BEGIN TRY
    EXEC dbo.sp_BorrarProducto @cod = 999;
END TRY
BEGIN CATCH
    PRINT '7.b Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

-- 7.c Producto sin ventas (el 100 de la prueba): se borra.
--     Esto además deja la base como estaba.
EXEC dbo.sp_BorrarProducto @cod = 100;
SELECT COUNT(*) AS queda_el_producto_100 FROM Producto WHERE cod_producto = 100;   -- 0

-- Si el Tema 3 ya está instalado, el cambio de precio de 6.a quedó en la
-- auditoría: se borra para dejar la base limpia.
IF OBJECT_ID('dbo.Auditoria_Producto') IS NOT NULL
    DELETE FROM dbo.Auditoria_Producto WHERE cod_producto = 100;
GO

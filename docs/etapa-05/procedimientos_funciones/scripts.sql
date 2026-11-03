/* =========================================================================
   ETAPA V - TEMA 1: PROCEDIMIENTOS Y FUNCIONES ALMACENADAS
   Proyecto: Farmacia Sana-Sana (Equipo 43)
   SCRIPT DE IMPLEMENTACIÓN

   Contenido:
     Funciones
       1. fn_CalcularEdadExacta        (escalar, consulta Persona)
       2. fn_ObtenerStock              (escalar, consulta Producto)
       3. fn_CalcularSubtotal          (escalar, cálculo)
       4. fn_CalcularDescuentoCliente  (escalar, ejemplo de la guía)
     Procedimientos (ABM de Producto)
       5. sp_InsertarProducto
       6. sp_ModificarProducto   
       7. sp_BorrarProducto

   Se usa CREATE OR ALTER para poder ejecutar el script más de una vez.
   Errores propios: THROW con números 50001 a 50007 (uno por regla).
   ========================================================================= */

USE Farmacia_SanaSana;
GO

-- Si en la base quedaron objetos de una versión anterior de esta etapa
-- (con otros nombres), se eliminan para no mezclar versiones.
DROP PROCEDURE IF EXISTS dbo.sp_Producto_Insertar, dbo.sp_Producto_Modificar,
     dbo.sp_Producto_Eliminar, dbo.sp_Venta_Registrar, dbo.sp_Venta_AgregarLinea,
     dbo.sp_Pedido_Registrar;
DROP FUNCTION IF EXISTS dbo.fn_CalcularEdad, dbo.fn_TotalVenta, dbo.fn_ProductosAReponer;
DROP TRIGGER IF EXISTS dbo.trg_Producto_AuditarUpdate, dbo.trg_Producto_AuditarDelete,
     dbo.trg_Venta_AuditarUpdate, dbo.trg_Venta_ImpedirBorrado,
     dbo.trg_DetalleVenta_ProtegerHistorial;
DROP TABLE IF EXISTS dbo.Auditoria_Venta;
IF COL_LENGTH('dbo.Auditoria_Producto', 'precio_anterior') IS NULL
    DROP TABLE IF EXISTS dbo.Auditoria_Producto;   -- estructura vieja
GO

/* =========================================================================
   1. fn_CalcularEdadExacta
   Recibe un DNI y devuelve la edad exacta de la persona.

   Por qué no alcanza con DATEDIFF(YEAR, ...): DATEDIFF cuenta cuántas
   veces se cruzó el 1 de enero, no los cumpleaños. Nacido el 20/12/2000,
   el 15/10/2026 DATEDIFF devuelve 26, pero la persona tiene 25.
   Solución: si "fecha de nacimiento + @edad años" todavía no llegó,
   todavía no cumplió años este año -> se resta 1.

   Devuelve NULL (no se puede calcular) si:
     - el DNI no existe (la variable queda en NULL), o
     - la fecha de nacimiento es futura (daría una edad negativa).
   ========================================================================= */
CREATE OR ALTER FUNCTION dbo.fn_CalcularEdadExacta (@dni INT)
RETURNS INT
AS
BEGIN
    DECLARE @edad      INT;
    DECLARE @fecha_nac DATE;

    SELECT @fecha_nac = fecha_nacimiento
    FROM Persona
    WHERE dni = @dni;

    IF @fecha_nac IS NULL                      -- DNI inexistente
        RETURN NULL;

    IF @fecha_nac > CAST(GETDATE() AS DATE)    -- fecha futura
        RETURN NULL;

    SET @edad = DATEDIFF(YEAR, @fecha_nac, GETDATE());

    IF DATEADD(YEAR, @edad, @fecha_nac) > CAST(GETDATE() AS DATE)
        SET @edad = @edad - 1;                 -- todavía no cumplió este año

    RETURN @edad;
END;
GO

/* =========================================================================
   2. fn_ObtenerStock
   Devuelve el stock de un producto.
   El profesor la evaluó como correcta y no se modificó: si el producto
   no existe devuelve NULL. NO se reemplaza NULL por 0 a propósito: un 0
   significaría "existe pero no tiene stock", que es otra situación.
   ========================================================================= */
CREATE OR ALTER FUNCTION dbo.fn_ObtenerStock (@cod_producto INT)
RETURNS INT
AS
BEGIN
    DECLARE @stock_actual INT;

    SELECT @stock_actual = stock
    FROM Producto
    WHERE cod_producto = @cod_producto;

    RETURN @stock_actual;
END;
GO

/* =========================================================================
   3. fn_CalcularSubtotal
   Subtotal de una línea de venta = cantidad x precio unitario.
   - Se quitó ROUND: INT x DECIMAL(10,2) ya da un resultado con 2 decimales.
   - Devuelve NULL si la cantidad no es positiva o el precio es negativo
     (se admite precio 0, por ejemplo una muestra gratis).
   ========================================================================= */
CREATE OR ALTER FUNCTION dbo.fn_CalcularSubtotal
(
    @cantidad INT,
    @precio   DECIMAL(10, 2)
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    IF @cantidad IS NULL OR @cantidad <= 0
        RETURN NULL;

    IF @precio IS NULL OR @precio < 0
        RETURN NULL;

    RETURN @cantidad * @precio;
END;
GO

/* =========================================================================
   4. fn_CalcularDescuentoCliente  (ejemplo de la guía de la Etapa V)
   Porcentaje de descuento para clientes frecuentes según el total que
   compró históricamente (suma de cantidad x precio de sus ventas).
   La guía propone $500.000 y $200.000; como el lote de prueba tiene
   montos chicos, los umbrales se ajustaron para que la prueba muestre los
   tres casos:
     más de $25.000  -> 10 %
     más de $15.000  ->  5 %
     resto           ->  0 %
   Usa fn_CalcularSubtotal: una función puede llamar a otra.
   Un cliente sin compras (o inexistente) tiene 0 %.
   ========================================================================= */
CREATE OR ALTER FUNCTION dbo.fn_CalcularDescuentoCliente (@dni_cliente INT)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @acumulado DECIMAL(14, 2);

    SELECT @acumulado = SUM(dbo.fn_CalcularSubtotal(dv.cant_comprada, dv.precio_unitario))
    FROM Venta AS v
    INNER JOIN Detalle_venta AS dv ON dv.cod_venta = v.cod_venta
    WHERE v.dni = @dni_cliente;

    RETURN CASE
               WHEN @acumulado > 25000 THEN 10.00
               WHEN @acumulado > 15000 THEN  5.00
               ELSE 0.00
           END;
END;
GO

/* =========================================================================
   5. sp_InsertarProducto
   Alta de un producto con validación de las reglas de negocio ANTES del
   INSERT, para devolver un mensaje claro en lugar del error genérico de
   la restricción CHECK.
   - El código repetido lo sigue controlando la PRIMARY KEY (y el lote
     repetido, la restricción UNIQUE): si pasa, el CATCH propaga el error
     original del motor con THROW.
   - No hace falta BEGIN TRANSACTION: es un solo INSERT y SQL Server ya
     garantiza que una sentencia sea atómica.
   ========================================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_InsertarProducto
(
    @cod    INT,
    @desc   VARCHAR(250),
    @cat    VARCHAR(50),
    @precio DECIMAL(10, 2),
    @nombre VARCHAR(100),
    @stock  INT,
    @lote   VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @precio IS NULL OR @precio <= 0
            THROW 50001, 'El precio debe ser mayor que cero.', 1;

        IF @stock IS NULL OR @stock < 0
            THROW 50002, 'El stock no puede ser negativo.', 1;

        IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
            THROW 50003, 'El nombre del producto es obligatorio.', 1;

        INSERT INTO Producto (cod_producto, descripcion, categoria, precio_unitario,
                              nombre_producto, stock, lote)
        VALUES (@cod, @desc, @cat, @precio, @nombre, @stock, @lote);

        PRINT 'Producto registrado correctamente.';
    END TRY
    BEGIN CATCH
        THROW;   -- propaga el error original (número y mensaje)
    END CATCH
END;
GO

/* =========================================================================
   6. sp_ModificarProducto
   Modifica precio y stock de un producto existente.
   - Valida los valores nuevos.
   - Si el código no existe el UPDATE no afecta filas: @@ROWCOUNT = 0 y se
     informa el error (antes terminaba "bien" sin hacer nada).
   - No llama al trigger: al hacer UPDATE sobre Producto, SQL Server
     ejecuta AUTOMÁTICAMENTE trg_AuditarPrecioProducto (Tema 3), que
     registra el cambio si el precio realmente cambió.
   ========================================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_ModificarProducto
(
    @cod          INT,
    @nuevo_precio DECIMAL(10, 2),
    @nuevo_stock  INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @nuevo_precio IS NULL OR @nuevo_precio <= 0
        THROW 50004, 'El precio debe ser mayor que cero.', 1;

    IF @nuevo_stock IS NULL OR @nuevo_stock < 0
        THROW 50005, 'El stock no puede ser negativo.', 1;

    UPDATE Producto
    SET precio_unitario = @nuevo_precio,
        stock           = @nuevo_stock
    WHERE cod_producto = @cod;

    IF @@ROWCOUNT = 0
        THROW 50006, 'El producto no existe.', 1;

    PRINT 'Producto modificado correctamente.';
END;
GO

/* =========================================================================
   7. sp_BorrarProducto
   Baja (física) de un producto.
   - Si no existe, lo informa (@@ROWCOUNT = 0).
   - Si el producto figura en ventas o pedidos, la CLAVE FORÁNEA de
     Detalle_venta / Pedido impide borrarlo y SQL Server devuelve su error
     (547). Es lo correcto: no se debe perder el historial de ventas. No se
     borran los detalles para "forzar" la baja.
   ========================================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_BorrarProducto
(
    @cod INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Producto
    WHERE cod_producto = @cod;

    IF @@ROWCOUNT = 0
        THROW 50007, 'El producto no existe.', 1;

    PRINT 'Producto eliminado correctamente.';
END;
GO

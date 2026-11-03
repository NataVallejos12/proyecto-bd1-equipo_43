/* =========================================================================
   ETAPA V - TEMA 2: MANEJO DE TRANSACCIONES
   Proyecto: Farmacia Sana-Sana (Equipo 43)
   Motor: SQL Server 2019 / 2022 (Express)

   SCRIPT DE IMPLEMENTACIÓN. Las pruebas están en demostracion_transacciones.sql.

   Contenido:
     1. sp_RegistrarVentaCompleta  -> encabezado + detalle + stock como UNA
                                      sola unidad de trabajo
     2. sp_AgregarProductoAVenta   -> agrega más productos a una venta ya
                                      registrada (resuelve la "línea fija en 1")
   ========================================================================= */

USE Farmacia_SanaSana;
GO

/* =========================================================================
   1. sp_RegistrarVentaCompleta
   Registra una venta de un producto. Las tres operaciones (Venta,
   Detalle_venta y descuento de stock) se confirman juntas con COMMIT o
   se deshacen juntas con ROLLBACK: nunca queda una venta incompleta.
   El precio unitario se guarda en el detalle: es el PRECIO HISTÓRICO, el
   que se cobró ese día, aunque después cambie el precio del producto.
   ========================================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_RegistrarVentaCompleta
(
    @cod_venta    INT,
    @fecha        DATE,
    @metodo_pago  VARCHAR(50),
    @nro_receta   VARCHAR(50),
    @cod_vendedor INT,
    @dni_cliente  INT,
    @cod_producto INT,
    @cantidad     INT,
    @precio       DECIMAL(10, 2)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Validar fecha (sin ISDATE: @fecha ya es de tipo DATE)
        IF @fecha IS NULL OR @fecha > CAST(GETDATE() AS DATE)
            THROW 50020, 'Fecha de venta inválida: no puede ser nula ni futura.', 1;

        -- 2. Validar cantidad y precio
        IF @cantidad IS NULL OR @cantidad <= 0
            THROW 50021, 'La cantidad debe ser mayor que cero.', 1;

        IF @precio IS NULL OR @precio <= 0
            THROW 50022, 'El precio debe ser mayor que cero.', 1;

        -- 3. Validar existencia (mensajes claros en lugar del error de PK/FK)
        IF EXISTS (SELECT 1 FROM Venta WHERE cod_venta = @cod_venta)
            THROW 50023, 'Ya existe una venta con ese código.', 1;

        IF NOT EXISTS (SELECT 1 FROM Cliente WHERE dni = @dni_cliente)
            THROW 50024, 'El cliente no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM Vendedor WHERE cod_vendedor = @cod_vendedor)
            THROW 50025, 'El vendedor no existe.', 1;

        -- 4. Insertar encabezado
        INSERT INTO Venta (cod_venta, fecha_venta, metodo_pago, nro_receta,
                           cod_vendedor, dni)
        VALUES (@cod_venta, @fecha, @metodo_pago, @nro_receta,
                @cod_vendedor, @dni_cliente);

        -- 5. Verificar y descontar stock EN UNA SOLA SENTENCIA
        UPDATE Producto
        SET stock = stock - @cantidad
        WHERE cod_producto = @cod_producto
          AND stock >= @cantidad;

        IF @@ROWCOUNT = 0
            THROW 50026, 'Producto inexistente o stock insuficiente.', 1;

        -- 6. Insertar detalle (primera línea de la venta)
        INSERT INTO Detalle_venta (cod_venta, linea_venta, cod_producto,
                                   cant_comprada, precio_unitario)
        VALUES (@cod_venta, 1, @cod_producto, @cantidad, @precio);

        -- 7. Confirmar
        COMMIT TRANSACTION;
        PRINT 'Venta registrada correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;   -- deshace encabezado, detalle y stock

        THROW;                      -- propaga el error original
    END CATCH
END;
GO

/* =========================================================================
   2. sp_AgregarProductoAVenta
   El profesor observó que sp_RegistrarVentaCompleta solo admite un
   producto por venta (linea_venta fija en 1). En la farmacia una venta
   tiene varios productos, así que este procedimiento agrega las líneas
   siguientes con el mismo esquema de transacción:
     - el número de línea es el siguiente al último de esa venta (MAX + 1);
       UPDLOCK y HOLDLOCK bloquean esas filas hasta el COMMIT, para que
       dos agregados simultáneos no tomen el mismo número;
     - descuento de stock condicionado, igual que arriba.
   Uso: EXEC sp_RegistrarVentaCompleta ... (primer producto)
        EXEC sp_AgregarProductoAVenta ...  (uno por cada producto extra)
   ========================================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_AgregarProductoAVenta
(
    @cod_venta    INT,
    @cod_producto INT,
    @cantidad     INT,
    @precio       DECIMAL(10, 2)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Venta WHERE cod_venta = @cod_venta)
            THROW 50027, 'La venta no existe.', 1;

        IF @cantidad IS NULL OR @cantidad <= 0
            THROW 50021, 'La cantidad debe ser mayor que cero.', 1;

        IF @precio IS NULL OR @precio <= 0
            THROW 50022, 'El precio debe ser mayor que cero.', 1;

        DECLARE @linea INT;

        SELECT @linea = ISNULL(MAX(linea_venta), 0) + 1
        FROM Detalle_venta WITH (UPDLOCK, HOLDLOCK)
        WHERE cod_venta = @cod_venta;

        UPDATE Producto
        SET stock = stock - @cantidad
        WHERE cod_producto = @cod_producto
          AND stock >= @cantidad;

        IF @@ROWCOUNT = 0
            THROW 50026, 'Producto inexistente o stock insuficiente.', 1;

        INSERT INTO Detalle_venta (cod_venta, linea_venta, cod_producto,
                                   cant_comprada, precio_unitario)
        VALUES (@cod_venta, @linea, @cod_producto, @cantidad, @precio);

        COMMIT TRANSACTION;
        PRINT 'Producto agregado en la línea ' + CAST(@linea AS VARCHAR(10)) + '.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

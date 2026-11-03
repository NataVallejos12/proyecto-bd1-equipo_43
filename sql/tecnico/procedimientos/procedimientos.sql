/* =========================================================================
   ETAPA V - TEMA 1: PROCEDIMIENTOS Y FUNCIONES ALMACENADAS
   PARTE B: PROCEDIMIENTOS - ABM de Producto (script de implementación)
   Proyecto: Farmacia Sana-Sana (Equipo 43)
   Responsable del tema: Vallejos Aquino, Nátaniel Adriel

   Requiere: sql/ddl/crear_bd.sql y sql/dml/datos_prueba.sql.
   (No depende de las funciones; se ejecuta después por orden del tema.)

   Contenido:
     5. sp_InsertarProducto
     6. sp_ModificarProducto   -> su UPDATE dispara el trigger de auditoría
                                  del Tema 3 si está instalado
     7. sp_BorrarProducto

   Correcciones respecto de la entrega anterior (devolución del profesor):
     - Validación de parámetros (NULL, negativos, cero) con THROW.
     - Avisan cuando el producto no existe (@@ROWCOUNT = 0).
     - El CATCH propaga el error original del motor con THROW;
   Errores propios: 50001 a 50007 (uno por regla).

   Se usa CREATE OR ALTER para poder ejecutar el script más de una vez.
   Documentación: docs/etapa-05/procedimientos-funciones.md
   ========================================================================= */

USE Farmacia_SanaSana;
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

CREATE FUNCTION fn_CalcularEdadExacta(@dni INT)
RETURNS INT
AS BEGIN
    DECLARE @edad INT;
    DECLARE @fecha_nac DATE;
    
    SELECT @fecha_nac = fecha_nacimiento FROM Persona WHERE dni = @dni;
    
    SET @edad = DATEDIFF(YEAR, @fecha_nac, GETDATE());
    
    IF (MONTH(@fecha_nac) > MONTH(GETDATE())) 
       OR (MONTH(@fecha_nac) = MONTH(GETDATE()) AND DAY(@fecha_nac) > DAY(GETDATE()))
    BEGIN
        SET @edad = @edad - 1;
    END
    
    RETURN @edad;
END;
GO

-- 2. Función para obtener el stock disponible de un producto específico[cite: 10, 24].
CREATE FUNCTION fn_ObtenerStock(@cod_producto INT)
RETURNS INT
AS BEGIN
    DECLARE @stock_actual INT;
    SELECT @stock_actual = stock 
    FROM Producto 
    WHERE cod_producto = @cod_producto;
    RETURN @stock_actual;
END;
GO

-- 3. Función para calcular el subtotal de una línea de venta[cite: 14, 15].
CREATE FUNCTION fn_CalcularSubtotal(@cantidad INT, @precio DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS BEGIN
    RETURN ROUND(@cantidad * @precio, 2);
END;
GO

-- Procedimiento para INSERTAR un nuevo producto[cite: 8, 10].
CREATE PROCEDURE sp_InsertarProducto (
    @cod INT, 
    @desc VARCHAR(250), 
    @cat VARCHAR(50), 
    @precio DECIMAL(10, 2), 
    @nombre VARCHAR(100), 
    @stock INT, 
    @lote VARCHAR(50)
)
AS BEGIN
    INSERT INTO Producto (cod_producto, descripcion, categoria, precio_unitario, nombre_producto, stock, lote)
    VALUES (@cod, @desc, @cat, @precio, @nombre, @stock, @lote);
END;
GO

-- Procedimiento para MODIFICAR el precio y stock de un producto[cite: 8, 10].
CREATE PROCEDURE sp_ModificarProducto (
    @cod INT, 
    @nuevo_precio DECIMAL(10, 2), 
    @nuevo_stock INT
)
AS BEGIN
    UPDATE Producto 
    SET precio_unitario = @nuevo_precio, stock = @nuevo_stock 
    WHERE cod_producto = @cod;
END;
GO

-- Procedimiento para BORRAR un producto[cite: 8, 10].
CREATE PROCEDURE sp_BorrarProducto (@cod INT)
AS BEGIN
    DELETE FROM Producto WHERE cod_producto = @cod;
END;
GO
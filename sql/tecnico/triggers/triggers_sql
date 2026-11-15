-- 1. Creación de la tabla auxiliar de auditoría.
CREATE TABLE Auditoria_Producto (
    id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
    fecha_hora DATETIME,
    usuario_db VARCHAR(50),
    producto_modificado VARCHAR(100),
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    tipo_operacion VARCHAR(20)
);
GO

-- 2. Definición del trigger sobre la tabla Producto.
CREATE TRIGGER trg_AuditarPrecioProducto
ON Producto
AFTER UPDATE
AS BEGIN
    -- Verifica si la columna fue afectada en la instrucción
    IF UPDATE(precio_unitario)
    BEGIN
        INSERT INTO Auditoria_Producto (fecha_hora, usuario_db, producto_modificado, precio_anterior, precio_nuevo, tipo_operacion)
        SELECT 
            GETDATE(), 
            SYSTEM_USER, 
            inserted.nombre_producto, 
            deleted.precio_unitario, 
            inserted.precio_unitario, 
            'UPDATE PRECIO'
        FROM inserted
        INNER JOIN deleted ON inserted.cod_producto = deleted.cod_producto
        -- Audita si el valor realmente cambió
        WHERE inserted.precio_unitario <> deleted.precio_unitario; 
    END
END;
GO

-- 3. Trigger para impedir el borrado físico de comprobantes emitidos.
CREATE TRIGGER trg_BloquearBorradoVenta
ON Venta
INSTEAD OF DELETE
AS BEGIN
    PRINT 'Violación de seguridad: Está prohibido eliminar comprobantes de venta del sistema.';
    ROLLBACK TRANSACTION;
END;
GO

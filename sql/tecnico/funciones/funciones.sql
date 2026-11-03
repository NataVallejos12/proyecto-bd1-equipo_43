/* =========================================================================
   ETAPA V - TEMA 1: PROCEDIMIENTOS Y FUNCIONES ALMACENADAS
   PARTE A: FUNCIONES (script de implementación)
   Proyecto: Farmacia Sana-Sana (Equipo 43)
   Responsable del tema: Vallejos Aquino, Nátaniel Adriel

   Orden de ejecución del tema:
     1. sql/ddl/crear_bd.sql y sql/dml/datos_prueba.sql (base con datos)
     2. sql/tecnico/funciones/funciones.sql          <- ESTE ARCHIVO
     3. sql/tecnico/procedimientos/procedimientos.sql
     4. sql/tecnico/funciones/demostracion_funciones.sql
     5. sql/tecnico/procedimientos/demostracion_procedimientos.sql

   Contenido:
     1. fn_CalcularEdadExacta        (escalar, consulta Persona)
     2. fn_ObtenerStock              (escalar, consulta Producto)
     3. fn_CalcularSubtotal          (escalar, cálculo)
     4. fn_CalcularDescuentoCliente  (escalar, ejemplo de la guía; usa la 3)

   Correcciones respecto de la entrega anterior (devolución del profesor):
     - fn_CalcularEdadExacta: DNI inexistente y fecha futura devuelven NULL;
       el "ya cumplió años" se resuelve con DATEADD.
     - fn_CalcularSubtotal: sin ROUND (era redundante) y con validaciones.

   Se usa CREATE OR ALTER para poder ejecutar el script más de una vez.
   Documentación: docs/etapa-05/procedimientos-funciones.md
   ========================================================================= */

USE Farmacia_SanaSana;
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

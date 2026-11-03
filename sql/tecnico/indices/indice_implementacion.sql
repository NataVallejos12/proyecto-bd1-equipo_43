 /* =========================================================================
 ETAPA V - TEMA 5: OPTIMIZACIÓN DE CONSULTAS A TRAVÉS DE ÍNDICES
   Proyecto: Farmacia Sana-Sana (Equipo 43)
   Motor: SQL Server 2019 / 2022 (Express)

   SCRIPT DE IMPLEMENTACIÓN
     PARTE A (consigna): tabla de prueba SIN ÍNDICES y procedimiento de
             CARGA MASIVA automatizada (1.000.000 de registros por defecto).
     PARTE B: índices definitivos del modelo, sobre las claves foráneas y
             la fecha de venta, que usan las consultas de la Etapa IV.

   Las mediciones (plan de ejecución y tiempos antes y después de cada
   índice) están en demostracion.sql.
   ========================================================================= */

USE Farmacia_SanaSana;
GO

/* =========================================================================
   PARTE A.1 - TABLA Venta_Historica
   ¿Por qué una tabla aparte y no Venta?
     - Venta ya tiene un índice AGRUPADO: el de su PRIMARY KEY (cod_venta).
       Como solo puede haber UN agrupado por tabla, no podríamos crear el
       agrupado sobre fecha_venta que pide la consigna.
     - Cargar un millón de filas en Venta obligaría a inventar sus detalles
       y a mover el stock real.
   Venta_Historica tiene las mismas columnas que Venta más el importe total
   (como un histórico de ventas de años anteriores) y se crea SIN PRIMARY
   KEY y SIN ÍNDICES: es un "montón" (heap), las filas no tienen orden.
   ========================================================================= */
DROP TABLE IF EXISTS dbo.Venta_Historica;
GO

CREATE TABLE dbo.Venta_Historica (
    cod_venta      INT            NOT NULL,
    fecha_venta    DATE           NOT NULL,   -- el campo fecha a indexar
    metodo_pago    VARCHAR(50)    NOT NULL,
    nro_receta     VARCHAR(50)    NULL,
    cod_vendedor   INT            NOT NULL,
    dni            INT            NOT NULL,
    importe_total  DECIMAL(12, 2) NOT NULL,
    observaciones  VARCHAR(200)   NULL
);
GO

/* =========================================================================
   PARTE A.2 - PROCEDIMIENTO DE CARGA MASIVA
   EXEC dbo.sp_CargaMasiva_VentaHistorica;                       -- 1.000.000
   EXEC dbo.sp_CargaMasiva_VentaHistorica @cantidad = 2000000;   -- 2 millones

   Cómo funciona:
     - Genera las filas por LOTES de 100.000 con un INSERT ... SELECT (una
       sola sentencia por lote). Es mucho más rápido que un WHILE que
       inserta de a una fila: un millón de INSERT individuales tardan
       varios minutos, así tarda segundos.
     - Los números 1..N salen de cruzar una vista del sistema consigo
       misma (sys.all_objects tiene miles de filas) con ROW_NUMBER().
     - La fecha es aleatoria entre 01/01/2017 y 31/12/2026 (3.652 días):
       DATEADD(DAY, número_aleatorio % 3652, '2017-01-01').
       ABS(CHECKSUM(NEWID())) da un número aleatorio distinto por fila.
     - Vendedores y clientes se toman de las tablas reales (Vendedor y
       Cliente), así los datos son coherentes con el modelo. Se eligen
       con el resto de la división (n % cantidad), que los reparte en
       forma pareja. OJO: no se usa NEWID() en las columnas del JOIN,
       porque el motor puede recalcularlo y el JOIN daría filas de más o
       de menos.
     - Cada lote es una transacción: si algo falla, se deshace ese lote.
   ========================================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_CargaMasiva_VentaHistorica
    @cantidad     INT = 1000000,
    @vaciar_antes BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @cantidad IS NULL OR @cantidad <= 0
        THROW 50101, 'La cantidad de registros debe ser mayor a cero.', 1;

    IF @vaciar_antes = 1
        TRUNCATE TABLE dbo.Venta_Historica;

    -- Vendedores y clientes reales, numerados 0..n-1 para elegirlos por resto
    DECLARE @vendedores TABLE (nro INT PRIMARY KEY, cod_vendedor INT);
    DECLARE @clientes   TABLE (nro INT PRIMARY KEY, dni INT);

    INSERT INTO @vendedores
    SELECT ROW_NUMBER() OVER (ORDER BY cod_vendedor) - 1, cod_vendedor FROM dbo.Vendedor;
    INSERT INTO @clientes
    SELECT ROW_NUMBER() OVER (ORDER BY dni) - 1, dni FROM dbo.Cliente;

    DECLARE @cant_vendedores INT = (SELECT COUNT(*) FROM @vendedores);
    DECLARE @cant_clientes   INT = (SELECT COUNT(*) FROM @clientes);

    IF @cant_vendedores = 0 OR @cant_clientes = 0
        THROW 50102, 'Faltan vendedores o clientes: ejecutar antes datos_prueba.sql.', 1;

    DECLARE @inicio    DATETIME2 = SYSDATETIME();
    DECLARE @desde     INT = ISNULL((SELECT MAX(cod_venta) FROM dbo.Venta_Historica), 0);
    DECLARE @cargadas  INT = 0;
    DECLARE @lote      INT;

    WHILE @cargadas < @cantidad
    BEGIN
        SET @lote = CASE WHEN @cantidad - @cargadas < 100000
                         THEN @cantidad - @cargadas ELSE 100000 END;

        BEGIN TRANSACTION;

        WITH numeros AS (
            SELECT TOP (@lote) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
            FROM sys.all_objects AS a CROSS JOIN sys.all_objects AS b
        ),
        filas AS (
            SELECT @desde + @cargadas + n               AS cod_venta,
                   ABS(CHECKSUM(NEWID())) % 3652          AS dias,
                   ABS(CHECKSUM(NEWID())) % 8 + 1         AS pago,
                   n % @cant_vendedores                   AS nro_vend,
                   (n / @cant_vendedores) % @cant_clientes AS nro_cli,
                   ABS(CHECKSUM(NEWID())) % 9500000       AS centavos
            FROM numeros
        )
        INSERT INTO dbo.Venta_Historica WITH (TABLOCK)
               (cod_venta, fecha_venta, metodo_pago, nro_receta,
                cod_vendedor, dni, importe_total, observaciones)
        SELECT f.cod_venta,
               DATEADD(DAY, f.dias, '2017-01-01'),
               CHOOSE(f.pago, 'Efectivo', 'Tarjeta de débito', 'Tarjeta de crédito',
                      'Transferencia', 'Mercado Pago', 'Código QR', 'Obra social',
                      'Cuenta corriente'),
               CASE WHEN f.pago = 7 THEN 'REC-' + CAST(f.cod_venta AS VARCHAR(10)) END,
               v.cod_vendedor,
               c.dni,
               500 + f.centavos / 100.0,
               'Venta histórica generada por carga masiva'
        FROM filas AS f
        JOIN @vendedores AS v ON v.nro = f.nro_vend
        JOIN @clientes   AS c ON c.nro = f.nro_cli;

        COMMIT TRANSACTION;

        SET @cargadas += @lote;
    END;

    SELECT @cargadas AS registros_cargados,
           (SELECT COUNT(*) FROM dbo.Venta_Historica) AS total_en_tabla,
           DATEDIFF(MILLISECOND, @inicio, SYSDATETIME()) AS duracion_ms;
END;
GO

/* =========================================================================
   PARTE B - ÍNDICES DEL MODELO
   Índices que ya existen por el DDL (crear_bd.sql):
     - Un índice AGRUPADO (clustered) por cada PRIMARY KEY.
     - Un índice no agrupado único por cada UNIQUE (correo, teléfono, lote...).
     - UQ_nro_receta_no_nulo: índice único FILTRADO (WHERE nro_receta IS NOT
       NULL), que permite muchas ventas sin receta y ninguna receta repetida.

   Lo que FALTA: SQL Server NO crea índices automáticamente sobre las
   claves foráneas, y las consultas de la Etapa IV y los procedimientos
   de la Etapa V filtran y combinan justamente por esas columnas.
   Cada índice de abajo indica qué consulta u operación acelera.
   ========================================================================= */

/* 1. Ventas por rango de fechas (informe_ventas.sql: WHERE fecha_venta
      BETWEEN ...). INCLUDE agrega columnas a la hoja del índice para que
      la consulta se resuelva sin volver a la tabla (índice de cobertura). */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Venta_fecha_venta')
    CREATE NONCLUSTERED INDEX IX_Venta_fecha_venta
    ON dbo.Venta (fecha_venta)
    INCLUDE (cod_vendedor, dni, metodo_pago);
GO

/* 2. Historial de compras de un cliente (FK Venta.dni):
      fn_CalcularDescuentoCliente, consultas por cliente. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Venta_dni')
    CREATE NONCLUSTERED INDEX IX_Venta_dni
    ON dbo.Venta (dni);
GO

/* 3. Ventas por vendedor (FK Venta.cod_vendedor): informe por vendedor. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Venta_cod_vendedor')
    CREATE NONCLUSTERED INDEX IX_Venta_cod_vendedor
    ON dbo.Venta (cod_vendedor);
GO

/* 4. Ventas de un producto (FK Detalle_venta.cod_producto): informe por
      categoría, sp_Producto_Eliminar (verifica si tiene ventas).
      Incluye cantidad y precio para calcular importes sin ir a la tabla. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Detalle_venta_cod_producto')
    CREATE NONCLUSTERED INDEX IX_Detalle_venta_cod_producto
    ON dbo.Detalle_venta (cod_producto)
    INCLUDE (cant_comprada, precio_unitario);
GO

/* 5. Último pedido de un producto (FK Pedido.cod_producto):
      fn_ProductosAReponer hace TOP 1 ... ORDER BY fecha_pedido DESC.
      El índice compuesto ya está ordenado como lo pide la consulta. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pedido_producto_fecha')
    CREATE NONCLUSTERED INDEX IX_Pedido_producto_fecha
    ON dbo.Pedido (cod_producto, fecha_pedido DESC)
    INCLUDE (cuit, cantidad_entregada);
GO

/* 6. Pedidos por proveedor (FK Pedido.cuit). */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pedido_cuit')
    CREATE NONCLUSTERED INDEX IX_Pedido_cuit
    ON dbo.Pedido (cuit);
GO

/* 7. Búsquedas y agrupamientos por categoría de producto. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Producto_categoria')
    CREATE NONCLUSTERED INDEX IX_Producto_categoria
    ON dbo.Producto (categoria)
    INCLUDE (nombre_producto, precio_unitario, stock);
GO

/* Consulta de verificación: todos los índices del modelo */
SELECT t.name  AS tabla,
       i.name  AS indice,
       i.type_desc AS tipo,
       i.is_unique,
       i.has_filter,
       STUFF((SELECT ', ' + c.name + CASE WHEN ic.is_included_column = 1 THEN ' (incl.)' ELSE '' END
              FROM sys.index_columns ic
              JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
              WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id
              ORDER BY ic.is_included_column, ic.key_ordinal
              FOR XML PATH('')), 1, 2, '') AS columnas
FROM sys.indexes AS i
INNER JOIN sys.tables AS t ON t.object_id = i.object_id
WHERE i.type > 0
  AND t.name NOT LIKE 'Auditoria%'
ORDER BY t.name, i.index_id;
GO

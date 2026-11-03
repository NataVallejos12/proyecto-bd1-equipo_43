/* =========================================================================
   ETAPA V - TEMA 5: OPTIMIZACIÓN DE CONSULTAS A TRAVÉS DE ÍNDICES
   SCRIPT DE DEMOSTRACIÓN (sigue los pasos de la consigna)
   Requiere haber ejecutado scripts.sql (misma carpeta).

     PASO 1. Carga masiva de 1.000.000 de registros (tabla sin índices)
     PASO 2. Búsqueda por período SIN índice       -> plan y tiempos
     PASO 3. Índice AGRUPADO sobre fecha_venta     -> plan y tiempos
     PASO 4. Borrar el índice creado
     PASO 5. Índice sobre fecha_venta que INCLUYE las columnas
             seleccionadas                         -> plan y tiempos
     PASO 6. Resumen comparativo (para las conclusiones)

   CÓMO VER EL PLAN DE EJECUCIÓN EN SSMS
     Activar "Incluir plan de ejecución real" (Ctrl+M) ANTES de ejecutar.
     Aparece la pestaña "Plan de ejecución" con el operador elegido:
       Table Scan            = lee la tabla completa
       Clustered Index Seek  = va directo a las filas en el índice agrupado
       Index Seek            = va directo a las filas en un índice no agrupado
   CÓMO VER LOS TIEMPOS
     SET STATISTICS TIME ON  -> pestaña Mensajes: "tiempo de CPU" y
                                "tiempo transcurrido" en milisegundos.
     SET STATISTICS IO ON    -> pestaña Mensajes: "lecturas lógicas" =
                                páginas de 8 KB que leyó la consulta. Es la
                                medida más estable: no depende de la PC.

   Además de la consulta visible, en cada paso se ejecuta
   dbo.sp_MedirConsultaPeriodo, que guarda plan y tiempos para el resumen.
   Requiere permisos de administrador (DBCC DROPCLEANBUFFERS y las vistas
   sys.dm_exec_*). NO usar DBCC DROPCLEANBUFFERS en un servidor de producción.
   ========================================================================= */

USE Farmacia_SanaSana;
GO

/* =========================================================================
   PREPARACIÓN: procedimiento auxiliar de medición
   El tiempo de UNA ejecución varía según lo que esté haciendo la PC. Para
   comparar con justicia, este procedimiento ejecuta la MISMA consulta por
   período y registra en #Medicion:
     - el operador que eligió el motor en el plan de ejecución y su costo
       estimado (los lee del plan guardado en caché)
     - el tiempo de la 1.ª ejecución "en frío" (caché de datos vacío: las
       páginas se leen del disco)
     - el tiempo promedio de N ejecuciones "en caliente" (páginas en memoria)
     - las lecturas lógicas por ejecución
   Las filas se asignan a variables para que no se dibujen N veces en la
   grilla: el plan y las lecturas son los mismos que los de la consulta
   visible de cada paso.
   ========================================================================= */
DROP TABLE IF EXISTS #Medicion;
CREATE TABLE #Medicion (
    escenario         VARCHAR(60)    NOT NULL,
    operador_del_plan VARCHAR(40)    NULL,
    costo_estimado    DECIMAL(10, 4) NULL,
    ms_en_frio        DECIMAL(10, 2) NOT NULL,
    ms_promedio       DECIMAL(10, 2) NOT NULL,
    repeticiones      INT            NOT NULL,
    lecturas_logicas  BIGINT         NOT NULL
);
GO

CREATE OR ALTER PROCEDURE dbo.sp_MedirConsultaPeriodo
    @escenario    VARCHAR(60),
    @desde        DATE = '2025-01-01',
    @hasta        DATE = '2025-03-31',
    @repeticiones INT  = 10
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @cod INT, @fec DATE, @pago VARCHAR(50), @imp DECIMAL(12, 2);
    DECLARE @i INT = 0, @t0 DATETIME2, @lect0 BIGINT, @lect1 BIGINT,
            @ms_frio DECIMAL(10, 2), @plan XML;

    -- 1) Ejecución en frío: se vacía el caché de datos
    CHECKPOINT;
    DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS;

    SET @t0 = SYSDATETIME();
    SELECT @cod = cod_venta, @fec = fecha_venta, @pago = metodo_pago, @imp = importe_total
    FROM dbo.Venta_Historica
    WHERE fecha_venta BETWEEN @desde AND @hasta;
    SET @ms_frio = DATEDIFF(MICROSECOND, @t0, SYSDATETIME()) / 1000.0;

    -- 2) N ejecuciones en caliente
    SELECT @lect0 = logical_reads FROM sys.dm_exec_requests WHERE session_id = @@SPID;
    SET @t0 = SYSDATETIME();

    WHILE @i < @repeticiones
    BEGIN
        SELECT @cod = cod_venta, @fec = fecha_venta, @pago = metodo_pago, @imp = importe_total
        FROM dbo.Venta_Historica
        WHERE fecha_venta BETWEEN @desde AND @hasta;
        SET @i += 1;
    END;

    DECLARE @ms_prom DECIMAL(10, 2) =
        DATEDIFF(MICROSECOND, @t0, SYSDATETIME()) / 1000.0 / @repeticiones;
    SELECT @lect1 = logical_reads FROM sys.dm_exec_requests WHERE session_id = @@SPID;

    -- 3) Plan de ejecución que usó el motor (el de este procedimiento, en caché).
    --    Cuando se crea o borra un índice, SQL Server recompila solo la consulta.
    SELECT @plan = qp.query_plan
    FROM sys.dm_exec_requests AS r
    CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) AS qp
    WHERE r.session_id = @@SPID;

    WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
    INSERT INTO #Medicion
    SELECT @escenario,
           @plan.value('(//RelOp[*/Object/@Table = "[Venta_Historica]"]/@PhysicalOp)[1]', 'VARCHAR(40)'),
           @plan.value('(//StmtSimple[.//Object/@Table = "[Venta_Historica]"]/@StatementSubTreeCost)[1]', 'FLOAT'),
           @ms_frio,
           @ms_prom,
           @repeticiones,
           (@lect1 - @lect0) / @repeticiones;
END;
GO

/* =========================================================================
   PASO 1. CARGA MASIVA DE 1.000.000 DE REGISTROS
   Se hace con el procedimiento de scripts.sql, así se puede repetir
   (automatizar) cuantas veces se quiera, y con la cantidad que se quiera.
   Tarda entre 5 y 30 segundos según la PC.
   ========================================================================= */
-- Si la demostración ya se ejecutó antes, se quitan los índices de prueba
-- para empezar con la tabla SIN ÍNDICES, como pide la consigna.
DROP INDEX IF EXISTS IX_VentaHistorica_fecha_agrupado ON dbo.Venta_Historica;
DROP INDEX IF EXISTS IX_VentaHistorica_fecha_incluye  ON dbo.Venta_Historica;
GO

EXEC dbo.sp_CargaMasiva_VentaHistorica @cantidad = 1000000;
GO

-- Verificación: la tabla es un HEAP (montón) -> no tiene ningún índice
SELECT OBJECT_NAME(i.object_id) AS tabla,
       i.type_desc              AS tipo,           -- HEAP
       ps.row_count             AS filas,
       ps.used_page_count       AS paginas_8KB
FROM sys.indexes AS i
JOIN sys.dm_db_partition_stats AS ps
     ON ps.object_id = i.object_id AND ps.index_id = i.index_id
WHERE i.object_id = OBJECT_ID('dbo.Venta_Historica');

-- Cuántas filas devuelve la búsqueda por período que vamos a medir
SELECT COUNT(*) AS ventas_primer_trimestre_2025
FROM dbo.Venta_Historica
WHERE fecha_venta BETWEEN '2025-01-01' AND '2025-03-31';
GO

/* =========================================================================
   PASO 2. BÚSQUEDA POR PERÍODO SIN ÍNDICE
   Consulta: ventas del primer trimestre de 2025 (~24.700 filas de 1.000.000)
   Plan esperado: TABLE SCAN. Sin índice, el motor no sabe dónde están las
   fechas buscadas y tiene que leer TODAS las páginas de la tabla.
   ========================================================================= */
CHECKPOINT;
DBCC DROPCLEANBUFFERS;   -- vacía el caché de datos: medición "en frío"
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT cod_venta, fecha_venta, metodo_pago, importe_total
FROM dbo.Venta_Historica
WHERE fecha_venta BETWEEN '2025-01-01' AND '2025-03-31';

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

EXEC dbo.sp_MedirConsultaPeriodo @escenario = 'E1 - Sin índice (heap)';
GO

/* =========================================================================
   PASO 3. ÍNDICE AGRUPADO SOBRE LA COLUMNA FECHA
   CLUSTERED = la tabla se REORDENA físicamente por fecha_venta. Las hojas
   del índice son las filas completas. Solo puede haber UNO por tabla.
   Plan esperado: CLUSTERED INDEX SEEK. El motor baja por el árbol hasta
   el 01/01/2025 y lee hacia adelante hasta el 31/03/2025: todas las
   filas del período están juntas.
   ========================================================================= */
CREATE CLUSTERED INDEX IX_VentaHistorica_fecha_agrupado
ON dbo.Venta_Historica (fecha_venta);
GO

-- Tamaño del índice agrupado (es la tabla completa, ahora ordenada)
SELECT i.name AS indice, i.type_desc AS tipo, ps.used_page_count AS paginas_8KB
FROM sys.indexes AS i
JOIN sys.dm_db_partition_stats AS ps
     ON ps.object_id = i.object_id AND ps.index_id = i.index_id
WHERE i.object_id = OBJECT_ID('dbo.Venta_Historica');
GO

CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT cod_venta, fecha_venta, metodo_pago, importe_total
FROM dbo.Venta_Historica
WHERE fecha_venta BETWEEN '2025-01-01' AND '2025-03-31';

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

EXEC dbo.sp_MedirConsultaPeriodo @escenario = 'E2 - Índice agrupado (fecha)';
GO

/* =========================================================================
   PASO 4. BORRAR EL ÍNDICE CREADO
   Al borrar el agrupado la tabla vuelve a ser un heap.
   ========================================================================= */
DROP INDEX IX_VentaHistorica_fecha_agrupado ON dbo.Venta_Historica;
GO

/* =========================================================================
   PASO 5. ÍNDICE SOBRE LA FECHA QUE INCLUYE LAS COLUMNAS SELECCIONADAS
   La consigna pide un índice "agrupado" que además incluya las columnas.
   En SQL Server la cláusula INCLUDE NO se permite en un índice agrupado,
   porque el agrupado YA contiene todas las columnas en sus hojas. Se
   prueba primero para mostrar el error del motor:
   ========================================================================= */
BEGIN TRY
    EXEC ('CREATE CLUSTERED INDEX IX_prueba_agrupado_include
           ON dbo.Venta_Historica (fecha_venta)
           INCLUDE (cod_venta, metodo_pago, importe_total);');
END TRY
BEGIN CATCH
    PRINT 'Índice AGRUPADO con INCLUDE -> error ' + CAST(ERROR_NUMBER() AS VARCHAR(10))
          + ': ' + ERROR_MESSAGE();
END CATCH;
GO

/* Por eso se define como índice NO AGRUPADO con columnas incluidas
   (índice "de cobertura"): la CLAVE es fecha_venta (ordena y permite el
   Seek) y las columnas del SELECT se guardan en las hojas con INCLUDE.
   La consulta se resuelve leyendo SOLO el índice, sin tocar la tabla.
   Plan esperado: INDEX SEEK (NonClustered), sin RID Lookup. */
   DROP INDEX IF EXISTS IX_VentaHistorica_fecha_incluye ON dbo.Venta_Historica;
GO

CREATE NONCLUSTERED INDEX IX_VentaHistorica_fecha_incluye
ON dbo.Venta_Historica (fecha_venta)
INCLUDE (cod_venta, metodo_pago, importe_total);
GO

-- Tamaño: el índice tiene solo 4 columnas, la tabla tiene 8
SELECT ISNULL(i.name, '(tabla heap)') AS indice, i.type_desc AS tipo,
       ps.used_page_count AS paginas_8KB
FROM sys.indexes AS i
JOIN sys.dm_db_partition_stats AS ps
     ON ps.object_id = i.object_id AND ps.index_id = i.index_id
WHERE i.object_id = OBJECT_ID('dbo.Venta_Historica');
GO

CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT cod_venta, fecha_venta, metodo_pago, importe_total
FROM dbo.Venta_Historica
WHERE fecha_venta BETWEEN '2025-01-01' AND '2025-03-31';

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

EXEC dbo.sp_MedirConsultaPeriodo @escenario = 'E3 - No agrupado con INCLUDE';
GO

/* =========================================================================
   PASO 6. RESUMEN COMPARATIVO
   Operador del plan, costo estimado por el optimizador, tiempos (en frío
   y promedio en caliente) y lecturas lógicas de cada escenario, con el
   porcentaje de mejora respecto de la tabla sin índice.
   ========================================================================= */
SELECT m.escenario,
       m.operador_del_plan,
       m.costo_estimado,
       m.ms_en_frio,
       m.ms_promedio,
       m.lecturas_logicas,
       CAST(100.0 * (1 - m.ms_promedio / NULLIF(e1.ms_promedio, 0)) AS DECIMAL(5, 1))
           AS mejora_tiempo_pct,
       CAST(100.0 * (1 - m.lecturas_logicas * 1.0 / e1.lecturas_logicas) AS DECIMAL(5, 1))
           AS mejora_lecturas_pct
FROM #Medicion AS m
CROSS JOIN (SELECT ms_promedio, lecturas_logicas FROM #Medicion WHERE escenario LIKE 'E1%') AS e1
ORDER BY m.escenario;
GO

/* =========================================================================
   LIMPIEZA (opcional): descomentar para borrar la tabla de prueba.
   El procedimiento de carga queda creado para volver a usarlo.
   ========================================================================= */
-- DROP TABLE IF EXISTS dbo.Venta_Historica;
-- DROP PROCEDURE IF EXISTS dbo.sp_MedirConsultaPeriodo;
GO

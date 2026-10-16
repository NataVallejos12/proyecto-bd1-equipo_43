# Etapa IV: Consultas y Casos de Uso — Farmacia "Sana-Sana"

## 1. Introducción
En esta cuarta etapa del proyecto se desarrollan y documentan las consultas en lenguaje SQL sobre la base de datos **`Farmacia_SanaSana`**, respondiendo a la pregunta guía de la etapa: **«¿Cómo obtenemos información?»**.

A partir del esquema físico hemos diseñado tres casos de uso que cubren las necesidades operativas, gerenciales y de auditoría de stock.
--------------------------------------------------------------------
## 2. Casos de Uso 
| ID | Caso de Uso |Necesidad de Negocio que Resuelve | Script SQL Asociado | Documentación Detallada del Script |
| :--- | :--- | :--- | :--- | :--- |
| **CU-01** | **Factura / Comprobante** | Consolidar el encabezado y los renglones de detalle de una venta, calculando subtotales por línea y el total acumulado de la factura respetando el precio unitario histórico. | [`comprobante_venta.sql`](../../sql/consultas/comprobante_venta.sql) | [`comprobante-venta.md`](./comprobante-venta.md) |
| **CU-02** | **Reporte Agregado** | Obtener indicadores resumidos del total de ventas, unidades y recaudación agrupados por vendedor y por categoría de producto en un rango de fechas. | [`informe_ventas.sql`](../../sql/consultas/informe_ventas.sql) | [`informe-ventas.md`](./informe-ventas.md) |
| **CU-03** | **Consulta de Negocio Avanzada** | Analizar clientes con gasto superior al ticket promedio, auditar ventas en las categorías más demandadas y controlar la reposición de productos con proveedores. | [`consulta_avanzada.sql`](../../sql/consultas/consulta_avanzada.sql) | [`consulta-avanzada.md`](./consulta-avanzada.md) |
--------------------------------------------------------------------
## 3. Estrategias SQL Aplicadas a las Consultas

* **Proyección, Selección y Expresiones (`SELECT`):**
  Uso de alias de columnas e identificadores de tablas, operadores aritméticos (`*`, `-`) para calcular importes, despreciar duplicados con `DISTINCT`, utilizar  `TOP` para mostrar registros en orden de aparición y ordenamiento con `ORDER BY`.
  
* **Funciones de Fila y de Agregado (`GROUP BY` / `HAVING`):**
  Aplicación de predicados `WHERE ... BETWEEN` para rangos de fechas, funciones escalares (`ROUND`, `DATEDIFF`, `GETDATE`, `ISNULL`), expresiones condicionales `CASE ... WHEN ... THEN ... ELSE ... END`, funciones de grupo o en cualquier parte de  la consulta(`SUM`, `COUNT`, `AVG`, `MIN`, `MAX`), agrupamiento con `GROUP BY` y filtrado de grupos con `HAVING`.
  
* **Combinaciones Explícitas (`JOIN`):**
  Uso exclusivo de sintaxis estándar *SQL ANSI* que utilizamos en la materia (`INNER JOIN ... ON`) combinamos al rededor de 3 y 7 referencias de tablas, incluyendo múltiples uniones con respecto a la tabla supertipo `Persona` para determinar los roles de `Cliente` y `Vendedor`. No vimos necesario utilizar los otros tipos de JOIN.
  
* **Subconsultas:**
  Implementación de los cuatro tipos de subconsultas estudiados en la asignatura:
  1. **Mono-registro:** con operadores de comparación (`>`) y como expresión escalar en el `SELECT`.
  2. **Multi-registro:** con operador de conjuntos `IN` combinado con `TOP 2` y `ORDER BY`.
  3. **Correlacionadas:** con pruebas lógicas de existencia `EXISTS` y `NOT EXISTS`.
  4. **Tablas derivadas:** subconsultas con alias en la cláusula `FROM` para anidar funciones agregadas (`AVG` sobre `SUM`).

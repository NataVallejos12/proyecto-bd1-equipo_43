# Etapa V – Tema 5: Optimización de consultas a través de índices

**Proyecto:** Farmacia Sana-Sana – Equipo 43  
**Motor de base de datos:** Microsoft SQL Server Express

## 1. ¿Qué es un índice y para qué sirve?

Un índice es una estructura que SQL Server utiliza para encontrar información más rápidamente dentro de una tabla.

Podemos compararlo con el índice de un libro: si queremos encontrar un tema, no necesitamos leer todas las páginas. Buscamos el tema en el índice y vamos directamente a la página correspondiente.

En una base de datos sucede algo parecido. Cuando una tabla tiene muchos registros, SQL Server puede necesitar recorrer gran parte de ellos para encontrar los datos que buscamos. Un índice permite localizar esos registros de una manera más eficiente.

**El objetivo de esta práctica** es comprobar cómo cambia el rendimiento de una consulta cuando se utilizan índices sobre la fecha de venta.

Para hacerlo, vamos a comparar tres situaciones:

- Una tabla sin índices.
- Una tabla con un índice agrupado sobre la fecha.
- Una tabla con un índice no agrupado que incluye las columnas necesarias para la consulta.

## 2. Ventajas y desventajas de los índices

Los índices ofrecen varias ventajas:

- Permiten encontrar registros más rápidamente.
- Reducen el trabajo que SQL Server necesita realizar para buscar información.
- Pueden disminuir la cantidad de lecturas de datos.
- Mejoran las consultas que buscan información por fechas, clientes, productos o vendedores.

Sin embargo, también tienen algunos costos:

- Ocupan espacio de almacenamiento.
- Cuando se agregan, modifican o eliminan registros, SQL Server también debe mantener actualizados los índices.
- Crear demasiados índices puede perjudicar el rendimiento de algunas operaciones.

Por eso, los índices deben crearse teniendo en cuenta las consultas que utiliza el sistema.

## 3. Implementación en el proyecto

Para realizar esta práctica se utilizan dos archivos SQL:

| Archivo | ¿Qué contiene? |
|---|---|
| [5_indices_implementacion.sql](sql/tecnico/Indices_EtapaV/indice_implementacion.sql) | Crea la tabla de prueba, el procedimiento para cargar registros y los índices que se utilizarán en las tablas reales del sistema. |
| [5_indices_demostracion.sql](sql/tecnico/Indices_EtapaV/indice_demostracion.sql) | Ejecuta la carga de datos y realiza las pruebas para comparar el rendimiento de las consultas. |

### 3.1. Tabla de prueba y carga masiva

Se crea una tabla independiente llamada "Venta_Historica".

Esta tabla se utiliza exclusivamente para las pruebas. De esta manera, podemos trabajar con una gran cantidad de registros sin modificar las ventas reales ni afectar el stock de la farmacia.

Para generar los datos se utiliza un procedimiento almacenado llamado:"dbo.sp_CargaMasiva_VentaHistorica"

Un procedimiento almacenado es un conjunto de instrucciones SQL que queda guardado en la base de datos y puede ejecutarse cuando lo necesitemos.

En este caso, el procedimiento genera registros de ventas históricas por lotes de 100.000 registros, hasta alcanzar la cantidad solicitada.

La siguiente instrucción ejecuta el procedimiento:

```
EXEC dbo.sp_CargaMasiva_VentaHistorica
    @cantidad = 1000000;
```

EXEC es una instrucción de SQL Server que permite ejecutar un procedimiento almacenado.
En nuestro proyecto:

- "sp_CargaMasiva_VentaHistorica" es el nombre del procedimiento.
- "@cantidad = 1000000" indica que queremos generar un millón de registros.

Es decir, no estamos escribiendo manualmente un millón de ventas: estamos solicitando que SQL Server ejecute el procedimiento que se encarga de generarlas.

### 3.2. Índices definitivos del sistema

Además de la tabla de prueba, el archivo de implementación crea índices en algunas tablas reales de Farmacia Sana-Sana.

Estos índices buscan mejorar las consultas que utilizan determinadas columnas:

| Tabla | Columna indexada | ¿Para qué sirve? |
|---|---|---|
| Venta | fecha_venta | Buscar ventas realizadas durante un período. |
| Venta | dni | Buscar ventas de un cliente. |
| Venta | cod_vendedor | Consultar ventas realizadas por un vendedor. |
| Detalle_venta | cod_producto | Buscar detalles de ventas relacionados con un producto. |
| Pedido | cod_producto, fecha_pedido | Buscar pedidos de un producto y consultar los más recientes. |
| Pedido | cuit | Buscar pedidos relacionados con un proveedor. |
| Producto | categoria | Buscar o agrupar productos por categoría. |

Algunos índices utilizan "INCLUDE", que permite guardar columnas adicionales dentro del índice.

Esto puede resultar útil cuando una consulta necesita recuperar información de varias columnas: SQL Server puede encontrar los registros y obtener esos datos directamente desde el índice, sin tener que volver a consultar la tabla.

El script también comprueba si los índices ya existen antes de crearlos. Esto evita intentar crear nuevamente un índice que ya está presente.

## 4. Caso de prueba: comparar consultas con y sin índices

Para comprobar si los índices mejoran el rendimiento, se utiliza una consulta que busca las ventas históricas realizadas durante el primer trimestre de 2025.

```
SELECT
    cod_venta,
    fecha_venta,
    metodo_pago,
    importe_total
FROM dbo.Venta_Historica
WHERE fecha_venta BETWEEN '2025-01-01'
                      AND '2025-03-31';
```

Esta consulta devuelve las ventas cuya fecha se encuentra entre el 1 de enero y el 31 de marzo de 2025.

Se realizan tres pruebas.

### 4.1. Primera prueba: tabla sin índice

Primero se ejecuta la consulta sin tener un índice sobre "fecha_venta".

En este escenario, la tabla está creada como un **heap**.

Un heap es una tabla que no tiene un índice agrupado. Por lo tanto, SQL Server no dispone de ese índice para localizar los registros según la fecha.

Para encontrar las ventas solicitadas puede necesitar recorrer una gran parte de la tabla.

### 4.2. Segunda prueba: índice agrupado (CLUSTERED INDEX)

En la segunda prueba se crea un índice agrupado sobre la columna "fecha_venta".

Un índice "CLUSTERED" organiza físicamente los registros de la tabla según el orden de su clave de índice.

En nuestro caso, esa clave es la fecha de venta.

Esto puede facilitar que SQL Server encuentre las ventas correspondientes a un período sin tener que recorrer todos los registros.

Después de crear el índice, se vuelve a ejecutar la misma consulta y se comparan los resultados.

### 4.3. Tercera prueba: índice no agrupado (NONCLUSTERED INDEX) con INCLUDE

En la última prueba se utiliza un índice no agrupado.

Un "NONCLUSTERED INDEX" es un índice que se almacena separado de la organización física de los registros de la tabla.

Funciona como una estructura adicional que permite localizar registros mediante una o varias columnas.

En nuestro proyecto, se utiliza "fecha_venta" como columna principal del índice.

Además, se utiliza "INCLUDE" para incorporar otras columnas que necesita la consulta.

Por ejemplo:

```
CREATE NONCLUSTERED INDEX IX_VentaHistorica_Fecha_Cobertura
ON dbo.Venta_Historica(fecha_venta)
INCLUDE (metodo_pago, importe_total);
```

**¿Qué hace "INCLUDE"?**

Agrega columnas adicionales al índice sin convertirlas en parte de la clave principal del índice.

Esto permite que SQL Server pueda obtener desde el propio índice los datos que necesita la consulta, cuando todas las columnas requeridas están disponibles allí.

A este tipo de índice se lo conoce como **índice de cobertura**, porque puede cubrir todos los datos solicitados por una consulta.

Una diferencia importante es que SQL Server no permite utilizar "INCLUDE" en índices agrupados ("CLUSTERED"). Por eso, el índice de cobertura de esta prueba debe ser "NONCLUSTERED".

## 5. Instrucciones utilizadas durante las pruebas

Además de crear índices y ejecutar consultas, el script utiliza algunas instrucciones y herramientas de SQL Server para controlar errores y medir el rendimiento.

### 5.1. BEGIN TRY y BEGIN CATCH

Son estructuras que permiten controlar errores durante la ejecución de instrucciones SQL.

- "BEGIN TRY": indica el bloque de instrucciones que SQL Server intentará ejecutar.
- "BEGIN CATCH": contiene las instrucciones que se ejecutan si ocurre un error dentro del bloque TRY.

Ejemplo:

```
BEGIN TRY

    CREATE CLUSTERED INDEX IX_Prueba
    ON dbo.Venta_Historica(fecha_venta);

END TRY
BEGIN CATCH

    SELECT ERROR_MESSAGE() AS MensajeError;

END CATCH;
```

En este ejemplo, SQL Server intenta crear el índice.

Si ocurre un error, en lugar de interrumpir directamente la ejecución sin mostrar información útil, pasa al bloque "CATCH" y devuelve el mensaje del error.

En nuestra práctica se utiliza para intentar demostrar que un índice agrupado no admite la cláusula "INCLUDE" y capturar el mensaje generado por SQL Server.

### 5.2. SET STATISTICS

"SET STATISTICS" permite solicitar información sobre el rendimiento de las consultas.

En nuestra práctica se utilizan principalmente dos opciones:

```
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
```

**SET STATISTICS TIME ON**

Muestra información sobre el tiempo que tarda SQL Server en ejecutar una consulta.

Permite observar:

- Tiempo de CPU: cuánto tiempo utilizó el procesador para ejecutar la consulta.
- Tiempo transcurrido: cuánto tiempo pasó desde que comenzó hasta que terminó la ejecución.

**`SET STATISTICS IO ON`**

Muestra información sobre las operaciones de lectura realizadas durante la consulta.

Una de las métricas más importantes son las **lecturas lógicas**.

Las lecturas lógicas indican cuántas páginas de datos SQL Server tuvo que leer desde su caché de memoria para resolver la consulta.

En general, una menor cantidad de lecturas lógicas puede indicar que la consulta necesitó menos trabajo para recuperar los datos.

Estas estadísticas permiten comparar los tres escenarios y comprobar si los índices ayudaron a mejorar el rendimiento.

### 5.3. DBCC

"DBCC" significa *Database Console Commands*.

Es un conjunto de comandos de SQL Server que permite realizar tareas de mantenimiento, comprobación y administración de la base de datos.

En nuestro script se utiliza:

```
DBCC DROPCLEANBUFFERS;
```

Esta instrucción elimina de la caché de datos las páginas limpias que SQL Server mantiene en memoria.

¿Para qué se utiliza?

Cuando ejecutamos una consulta, SQL Server puede conservar los datos en memoria. Si volvemos a ejecutar la misma consulta, puede responder más rápido porque ya tiene parte de la información disponible.

Para intentar que las pruebas comiencen sin esas páginas almacenadas en caché, se utiliza "DBCC DROPCLEANBUFFERS".

Esto permite realizar mediciones en condiciones de caché fría.

**Importante:** esta instrucción afecta la caché de la instancia de SQL Server, no solamente la tabla de prueba. Puede requerir permisos elevados y no debe utilizarse en un servidor de producción sin autorización.

## 6. Métricas y evidencias que se deben registrar

Para cada uno de los tres escenarios se debe ejecutar la consulta con el plan de ejecución real habilitado.

En SQL Server Management Studio (SSMS), se puede activar con "Ctrl + M".

También deben estar habilitadas las estadísticas de tiempo y lecturas:

```
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
```

Las métricas que se deben registrar son:

- **Tiempo de CPU:** tiempo de procesador utilizado.
- **Tiempo total:** tiempo transcurrido durante la ejecución.
- **Lecturas lógicas:** cantidad de páginas de datos leídas desde la caché.
- **Operador principal:** operación que aparece en el plan de ejecución, por ejemplo, "Table Scan" o "Index Seek".
- **Plan de ejecución:** representación gráfica de cómo SQL Server resolvió la consulta.

### 6.1. Resultados obtenidos

Completar la siguiente tabla después de ejecutar las pruebas.

No colocar valores estimados ni inventados.

| Escenario | Tiempo CPU (ms) | Tiempo total (ms) | Lecturas lógicas | Operador principal |
|---|---|---|---|---|
| Sin índice (heap) | Pendiente | Pendiente | Pendiente | Pendiente |
| Índice agrupado por fecha | Pendiente | Pendiente | Pendiente | Pendiente |
| Índice no agrupado con INCLUDE | Pendiente | Pendiente | Pendiente | Pendiente |

### 6.2. Capturas de pantalla

Guardar en la carpeta "evidencias/" las capturas obtenidas desde SQL Server Management Studio.


[evidencia_sin_indice]( docs/etapa-05/optimizacion de consultas/Evidencias/evidencia_sin_indice.md ): plan de ejecución y mensajes de la consulta sin índice.
[evidencia_indice_agrupado](docs/etapa-05/optimizacion de consultas/Evidencias/evidencia_indice_agrupado.md): plan de ejecución y mensajes con el índice agrupado.
[evidencia_indice_cobertura](docs/etapa-05/optimizacion de consultas/Evidencias/evidencia_indice_cobertura.md): plan de ejecución y mensajes con el índice no agrupado de cobertura.

Las capturas deben permitir identificar el operador utilizado y las métricas obtenidas.

## 7. Conclusión

Esta práctica permite comprender cómo los índices pueden mejorar el rendimiento de las consultas en una base de datos.

Mediante la comparación de una tabla sin índices, otra con un índice agrupado y otra con un índice no agrupado de cobertura, podemos observar cómo cambia la manera en que SQL Server busca y recupera la información.

Las mediciones de tiempo, las lecturas lógicas y los planes de ejecución permiten evaluar si los índices realmente mejoraron la consulta.

La conclusión definitiva debe completarse después de realizar las pruebas y analizar los resultados obtenidos en el equipo.

## 8. Orden de ejecución

Para realizar la demostración correctamente, se deben seguir estos pasos:

1. Ejecutar "5_indices_implementacion.sql".
2. Verificar que esté seleccionada la base de datos "Farmacia_SanaSana".
3. Comprobar que existan las tablas "Vendedor" y "Cliente" y que tengan datos de prueba.
4. Ejecutar "5_indices_demostracion.sql".
5. Activar el plan de ejecución real con "Ctrl + M" antes de ejecutar las consultas.
6. Revisar los mensajes de SQL Server para obtener los tiempos y las lecturas lógicas.
7. Guardar las capturas de cada escenario en la carpeta "evidencias/".
8. Completar la tabla de resultados y el análisis de la investigación.

**Nota:** algunas instrucciones de medición, como "DBCC DROPCLEANBUFFERS" y el acceso a determinadas vistas de administración, pueden requerir permisos elevados. No deben utilizarse para realizar pruebas de este tipo en un servidor de producción sin autorización.


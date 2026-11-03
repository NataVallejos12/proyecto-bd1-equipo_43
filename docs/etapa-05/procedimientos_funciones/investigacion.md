# Tema 1: Procedimientos y funciones almacenadas

**Proyecto:** Farmacia Sana-Sana (Equipo 43) · 
**Responsable del tema:** Vallejos Aquino Nátaniel Adriel

**Scripts del tema**

| Archivo | Para qué sirve |
|---|---|
| [`sql/tecnico/funciones/funciones.sql`](../../sql/tecnico/funciones/funciones.sql) | Implementación: crea las 4 funciones |
| [`sql/tecnico/procedimientos/procedimientos.sql`](../../sql/tecnico/procedimientos/procedimientos.sql) | Implementación: crea los 3 procedimientos (ABM de Producto) |
| [`sql/tecnico/funciones/demostracion_funciones.sql`](../../sql/tecnico/funciones/demostracion_funciones.sql) | Demostración de las funciones (no modifica datos) |
| [`sql/tecnico/procedimientos/demostracion_procedimientos.sql`](../../sql/tecnico/procedimientos/demostracion_procedimientos.sql) | Demostración de los procedimientos (al final deja la base como estaba) |

---

## 1. Definición y objetivo

Un **procedimiento almacenado** (*stored procedure*) es un programa SQL con nombre que se guarda dentro de la base de datos y se ejecuta con `EXEC`. Puede recibir parámetros, ejecutar varias sentencias (`INSERT`, `UPDATE`, `DELETE`, `SELECT`), usar variables, condicionales (`IF`) y manejo de errores (`TRY/CATCH`, `THROW`).

Una **función almacenada** (*user-defined function*) es una rutina que recibe parámetros y **devuelve un valor** (función escalar) o **una tabla** (función con valor de tabla). Se usa **dentro de una consulta**, igual que las funciones propias del motor (`UPPER`, `GETDATE`, `DATEDIFF`...).

**Objetivo:** guardar la lógica de negocio dentro del motor, para que se escriba una sola vez y todas las aplicaciones y usuarios la usen de la misma forma.

### Diferencias entre funciones y procedimientos

| Característica | Funciones | Procedimientos |
|---|---|---|
| Se crean con | `CREATE FUNCTION` | `CREATE PROCEDURE` |
| Reciben parámetros | Sí (solo de entrada) | Sí (de entrada y de salida `OUTPUT`) |
| Devuelven | Un valor (`RETURN`) o una tabla | Resultados con `SELECT`, parámetros `OUTPUT` o un código con `RETURN` |
| Se usan dentro de un `SELECT`, `WHERE`, etc. | Sí | No |
| Pueden modificar tablas (`INSERT`, `UPDATE`, `DELETE`) | **No** | Sí |
| Pueden usar `TRY/CATCH` y `THROW` | No | Sí |
| Se ejecutan con | Invocación: `SELECT dbo.fn_X(...)` | `EXEC dbo.sp_X ...` |

## 2. Ventajas y aplicaciones

**Ventajas**

- **Reutilizan la lógica de negocio y reducen el código repetido:** la regla se escribe una vez y todos la usan igual.
- **Centralizan las validaciones:** precio mayor que cero, stock no negativo, producto existente.
- **Mejoran la mantenibilidad:** si cambia una regla, se modifica un solo objeto y no cada consulta que la usa.
- **Mensajes de error claros:** con `THROW` el procedimiento informa qué regla se violó, en lugar del error genérico de una restricción.
- **Seguridad:** se puede dar permiso para ejecutar un procedimiento sin dar permiso directo sobre la tabla (ver el tema de seguridad, que da `EXECUTE` sobre `sp_InsertarProducto`).
- **Rendimiento:** el plan de ejecución queda guardado en caché y se reutiliza en las siguientes ejecuciones.

**Aplicaciones típicas**

- Altas, bajas y modificaciones (ABM) con validaciones.
- Cálculos que se repiten en muchas consultas (edad, subtotal, descuentos).
- Operaciones de varios pasos, como registrar una venta completa (se desarrolla en el tema de transacciones).

**Una advertencia:** una función escalar que consulta tablas se ejecuta **una vez por fila** del `SELECT` que la usa. En consultas de muchas filas puede ser lenta, y conviene reemplazarla por un `JOIN`.

## 3. Implementación en SQL Server Express

### Sintaxis de una función escalar

```sql
CREATE OR ALTER FUNCTION dbo.nombre_funcion (@parametro TIPO)
RETURNS TIPO_DEL_RESULTADO
AS
BEGIN
    DECLARE @resultado TIPO_DEL_RESULTADO;
    -- cálculo o consulta
    RETURN @resultado;
END;
```

Se usa así: `SELECT dbo.nombre_funcion(columna) FROM tabla;` (el esquema `dbo.` es obligatorio al invocarla).

### Sintaxis de un procedimiento

```sql
CREATE OR ALTER PROCEDURE dbo.nombre_procedimiento
(
    @parametro1 TIPO,
    @parametro2 TIPO
)
AS
BEGIN
    SET NOCOUNT ON;          -- no muestra "(1 fila afectada)"
    BEGIN TRY
        IF <regla no se cumple>
            THROW 50001, 'Mensaje para el usuario.', 1;
        -- INSERT / UPDATE / DELETE
    END TRY
    BEGIN CATCH
        THROW;               -- vuelve a lanzar el error original
    END CATCH
END;
```

Se ejecuta así: `EXEC dbo.nombre_procedimiento @parametro1 = valor, @parametro2 = valor;`

### Conceptos que se usan

- **`CREATE OR ALTER`:** crea el objeto o lo reemplaza si ya existe. Permite ejecutar el script varias veces sin error (SQL Server 2016 SP1 o posterior).
- **Variables locales:** `DECLARE @edad INT;` y asignación con `SELECT @var = columna FROM ...`. Si el `SELECT` no encuentra filas, la variable **queda en NULL**. Por eso hay que controlarlo.
- **`@@ROWCOUNT`:** cantidad de filas que afectó la última sentencia. Si un `UPDATE` o `DELETE` no afectó filas, el registro no existía.
- **`THROW número, 'mensaje', estado`:** genera un error propio (los números de usuario van desde 50000). `THROW;` sin parámetros, dentro de un `CATCH`, **vuelve a lanzar el error original** con su número y mensaje.
- **`DATEDIFF(YEAR, ...)` no da la edad:** cuenta cuántos 1.º de enero pasaron. Nacido el 20/12/2000, el 15/10/2026 devuelve 26, pero la persona tiene 25.
- **No hace falta transacción en un solo `INSERT`:** SQL Server garantiza que una sentencia individual es atómica. Las transacciones se usan cuando hay varias sentencias que deben ir juntas (tema de transacciones).

## 4. Caso concreto aplicado a Farmacia Sana-Sana

### Funciones (`sql/tecnico/funciones/funciones.sql`)

| Objeto | Tipo | Problema de negocio que resuelve |
|---|---|---|
| `fn_CalcularEdadExacta(@dni)` | Escalar, consulta `Persona` | Conocer la edad exacta de un cliente o vendedor. Devuelve `NULL` si el DNI no existe o la fecha de nacimiento es futura |
| `fn_ObtenerStock(@cod_producto)` | Escalar, consulta `Producto` | Consultar el stock antes de vender. Devuelve `NULL` si el producto no existe (0 significa "existe sin stock") |
| `fn_CalcularSubtotal(@cantidad, @precio)` | Escalar, cálculo | Calcular cantidad × precio de una línea de venta. Devuelve `NULL` con cantidad ≤ 0 o precio negativo |
| `fn_CalcularDescuentoCliente(@dni)` | Escalar (ejemplo de la guía de la cátedra) | Descuento para clientes frecuentes según lo que compraron: más de $25.000 → 10 %, más de $15.000 → 5 %, resto 0 %. Usa `fn_CalcularSubtotal` |

> Los umbrales de la guía ($500.000 y $200.000) se ajustaron a $25.000 y $15.000 porque el lote de prueba tiene montos chicos. Así la demostración muestra los tres casos.

### Procedimientos (`sql/tecnico/procedimientos/procedimientos.sql`)

| Objeto | Qué hace | Errores que informa |
|---|---|---|
| `sp_InsertarProducto` | Alta de un producto con validaciones previas | 50001 precio ≤ 0 · 50002 stock negativo · 50003 nombre vacío · código repetido: error original 2627 de la PK |
| `sp_ModificarProducto` | Cambia precio y stock. Su `UPDATE` dispara automáticamente el trigger de auditoría del tema 3 | 50004 precio ≤ 0 · 50005 stock negativo · 50006 producto inexistente |
| `sp_BorrarProducto` | Baja de un producto | 50007 producto inexistente · producto con ventas: error 547 de la FK (no se pierde el historial) |

### Correcciones aplicadas según la devolución del profesor

| Objeto | Observación del profesor | Qué se hizo |
|---|---|---|
| `fn_CalcularEdadExacta` | Mejorable: DNI inexistente y fecha futura | Devuelve `NULL` en los dos casos. El "todavía no cumplió años" se resuelve con `DATEADD(YEAR, @edad, @fecha_nac) > hoy` |
| `fn_ObtenerStock` | Correcta | Sin cambios. No se reemplaza `NULL` por 0, porque 0 significa "existe sin stock" |
| `fn_CalcularSubtotal` | `ROUND` redundante; sin validaciones | Se quitó `ROUND` (INT × DECIMAL(10,2) ya da 2 decimales). Devuelve `NULL` con cantidad ≤ 0 o precio negativo |
| `sp_InsertarProducto` | Faltan validaciones | Valida precio, stock y nombre con `THROW` 50001–50003. El código repetido lo controla la PK y el `CATCH` propaga el error original |
| `sp_ModificarProducto` | No verifica existencia ni valores | Valida precio y stock (50004, 50005). Si `@@ROWCOUNT = 0`, el producto no existe (50006) |
| `sp_BorrarProducto` | No controla existencia | Si `@@ROWCOUNT = 0`, el producto no existe (50007). Si tiene ventas, la FK lo impide (error 547) y no se fuerza la baja |

### Ejemplo: la función de edad exacta

```sql
SET @edad = DATEDIFF(YEAR, @fecha_nac, GETDATE());

IF DATEADD(YEAR, @edad, @fecha_nac) > CAST(GETDATE() AS DATE)
    SET @edad = @edad - 1;        -- todavía no cumplió años este año
```

Si "fecha de nacimiento + @edad años" todavía no llegó, la persona no cumplió años este año y se resta 1.

## 5. Script de demostración y resultados obtenidos

**Cómo ejecutarlo** (en SSMS, sobre una base creada con `sql/ddl/crear_bd.sql` y cargada con `sql/dml/datos_prueba.sql`):

1. `sql/tecnico/funciones/funciones.sql`
2. `sql/tecnico/procedimientos/procedimientos.sql`
3. `sql/tecnico/funciones/demostracion_funciones.sql` → resultados en la pestaña **Resultados**
4. `sql/tecnico/procedimientos/demostracion_procedimientos.sql` → los errores esperados se ven en la pestaña **Mensajes**

Resultados obtenidos en SQL Server 2022:

| # | Prueba | Resultado obtenido |
|---|---|---|
| 1.a | Edad de todas las personas en un `SELECT` | Ej.: Agustina Romero (16/04/1959) → 67; Camila Benítez (18/09/2001) → 25 |
| 1.b | `fn_CalcularEdadExacta(99999999)` | `NULL` |
| 1.c | 20/12/2000 al 15/10/2026 | `DATEDIFF` = 26, edad exacta = 25 |
| 2 | `fn_ObtenerStock(1)` / `(999)` | 61 / `NULL` |
| 3 | `fn_CalcularSubtotal(2, 1500)`, `(3, 2500.50)`, `(-3, 1500)`, `(2, -10)` | 3000.00, 7501.50, `NULL`, `NULL` |
| 4 | Descuento por cliente | Martín Acosta (compró $29.250) → 10 %; María Belén Gómez y Joaquín Villalba → 5 %; resto 0 % |
| 5.a | Alta del producto 100 | *"Producto registrado correctamente."* |
| 5.b / 5.c | Precio 0 / nombre vacío | Error 50001 / 50003 |
| 5.d | Código repetido | Error **2627** de la PK, propagado tal cual por `THROW;` |
| 6.a | Modificar precio y stock del 100 | 1500 → 1650, stock 20 → 25 |
| 6.b / 6.c | Producto 999 / stock negativo | Error 50006 / 50005 |
| 7.a | Borrar el producto 1 (tiene ventas) | Error **547**: la FK de `Detalle_venta` lo impide |
| 7.b | Borrar el producto 999 | Error 50007 |
| 7.c | Borrar el producto 100 | Se elimina. La base queda como estaba |

> Las edades dependen de la fecha en que se ejecuta el script (usa `GETDATE()`). El stock del producto 1 es 61 si se ejecuta antes del tema de transacciones.

### Evidencias

Capturas de la ejecución en SSMS (carpeta [`evidencias/procedimientos-funciones/`](evidencias/procedimientos-funciones/)):

| Prueba | Captura |
|---|---|
| Las 4 funciones y los 3 procedimientos en el Explorador de objetos | ![Las 4 funciones y los 3 procedimientos en el Explorador de objetos](evidencias/procedimientos-funciones/01_objetos_creados.png) |
| 1.a Edad exacta de todas las personas dentro de un SELECT | ![1.a Edad exacta de todas las personas dentro de un SELECT](evidencias/procedimientos-funciones/02a_fn_edad_todas.png) |
| 1.b DNI inexistente: devuelve NULL | ![1.b DNI inexistente: devuelve NULL](evidencias/procedimientos-funciones/02b_fn_edad_dni_inexistente.png) |
| 1.c DATEDIFF da 26 y la edad exacta es 25 | ![1.c DATEDIFF da 26 y la edad exacta es 25](evidencias/procedimientos-funciones/02c_fn_edad_vs_datediff.png) |
| 2. Stock del producto 1 (61) y del 999 (NULL) | ![2. Stock del producto 1 (61) y del 999 (NULL)](evidencias/procedimientos-funciones/03a_fn_stock.png) |
| 3. Subtotal: casos normales y valores inválidos (NULL) | ![3. Subtotal: casos normales y valores inválidos (NULL)](evidencias/procedimientos-funciones/03b_fn_subtotal.png) |
| 3. Subtotal de cada línea de la venta 9 | ![3. Subtotal de cada línea de la venta 9](evidencias/procedimientos-funciones/03c_fn_subtotal_venta9.png) |
| 4. Descuento por cliente: 10 %, 5 % y 0 % | ![4. Descuento por cliente: 10 %, 5 % y 0 %](evidencias/procedimientos-funciones/04_fn_descuento_cliente.png) |
| 5.a Alta correcta del producto 100 | ![5.a Alta correcta del producto 100](evidencias/procedimientos-funciones/05a_sp_insertar_alta.png) |
| 5.b Precio cero: error 50001 | ![5.b Precio cero: error 50001](evidencias/procedimientos-funciones/05b_sp_insertar_precio_cero.png) |
| 5.c Nombre vacío: error 50003 | ![5.c Nombre vacío: error 50003](evidencias/procedimientos-funciones/05c_sp_insertar_nombre_vacio.png) |
| 5.d Código repetido: error 2627 de la PK | ![5.d Código repetido: error 2627 de la PK](evidencias/procedimientos-funciones/05d_sp_insertar_codigo_repetido.png) |
| 6.a Precio 1650.00 y stock 25 | ![6.a Precio 1650.00 y stock 25](evidencias/procedimientos-funciones/06a_sp_modificar_ok.png) |
| 6.b Producto inexistente: error 50006 | ![6.b Producto inexistente: error 50006](evidencias/procedimientos-funciones/06b_sp_modificar_inexistente.png) |
| 6.c Stock negativo: error 50005 | ![6.c Stock negativo: error 50005](evidencias/procedimientos-funciones/06c_sp_modificar_stock_negativo.png) |
| 7.a Producto con ventas: error 547 de la FK | ![7.a Producto con ventas: error 547 de la FK](evidencias/procedimientos-funciones/07a_sp_borrar_con_ventas.png) |
| 7.b Producto inexistente: error 50007 | ![7.b Producto inexistente: error 50007](evidencias/procedimientos-funciones/07b_sp_borrar_inexistente.png) |
| 7.c Baja del producto 100: la base queda como estaba | ![7.c Baja del producto 100: la base queda como estaba](evidencias/procedimientos-funciones/07c_sp_borrar_ok.png) |

## 6. Conclusiones

1. Los procedimientos **centralizan las reglas de negocio**: cualquier alta o modificación de productos pasa por las mismas validaciones.
2. Las funciones **evitan repetir cálculos** en cada consulta y se pueden combinar: `fn_CalcularDescuentoCliente` usa `fn_CalcularSubtotal`.
3. Una variable que no encontró datos queda en **NULL**, y una comparación con NULL nunca es verdadera. Hay que controlar ese caso explícitamente.
4. **Validar en el procedimiento y mantener las restricciones en la tabla se complementan.** El procedimiento da mensajes claros. La PK, las FK y los CHECK siguen protegiendo los datos aunque alguien no use el procedimiento.
5. **`THROW;` en el `CATCH` es mejor que un mensaje genérico**: quien ejecuta sabe exactamente qué falló (2627, 547, 50001...).
6. Los objetos de este tema se reutilizan en los demás: `sp_ModificarProducto` queda auditado por el trigger del tema 3 y `sp_InsertarProducto` se usa en el tema de seguridad.

## Bibliografía

- Microsoft Learn. *CREATE PROCEDURE (Transact-SQL)*. https://learn.microsoft.com/sql/t-sql/statements/create-procedure-transact-sql
- Microsoft Learn. *CREATE FUNCTION (Transact-SQL)*. https://learn.microsoft.com/sql/t-sql/statements/create-function-transact-sql
- Microsoft Learn. *THROW (Transact-SQL)*. https://learn.microsoft.com/sql/t-sql/language-elements/throw-transact-sql
- Cátedra Bases de Datos I (FaCENA - UNNE). *Guía práctica para la implementación de los Temas Técnicos - Etapa V*.

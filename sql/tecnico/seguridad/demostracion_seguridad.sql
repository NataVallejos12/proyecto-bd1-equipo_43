/* =========================================================================
   ETAPA V - TEMA 4: MANEJO DE PERMISOS A NIVEL DE USUARIOS Y ROLES
   SCRIPT DE DEMOSTRACIÓN
   Requiere haber ejecutado seguridad.sql (implementación de este tema) y el Tema 1.

   Se ejecuta conectado como administrador (sa o la cuenta de Windows).
   Para probar a cada usuario SIN desconectarse se usa:
       EXECUTE AS LOGIN = '...'   -> "me hago pasar" por ese login
       REVERT                     -> vuelvo a ser el administrador
   El resultado es el mismo que conectarse en SSMS con ese login y su
   contraseña (Conectar > Autenticación de SQL Server); al final del archivo
   está explicado cómo hacerlo así también.

   Cada intento que debe fallar está dentro de TRY/CATCH para que el script
   se ejecute completo e imprima el mensaje de error del motor.
   Al final se borran los productos de prueba: la base queda como estaba.
   ========================================================================= */

USE Farmacia_SanaSana;
GO

/* =========================================================================
   0. EL SERVIDOR ESTÁ EN MODO MIXTO
   Resultado esperado: 'Modo mixto (Windows + SQL Server)'.
   Si no lo está, los EXECUTE AS LOGIN de abajo igual funcionan (los hace
   el administrador), pero nadie podría CONECTARSE con esos logins.
   ========================================================================= */
SELECT CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
           WHEN 1 THEN 'Solo Windows: cambiar a modo mixto y reiniciar'
           ELSE 'Modo mixto (Windows + SQL Server)'
       END AS modo_autenticacion;
GO

/* =========================================================================
   PARTE 1. PERMISOS A NIVEL DE USUARIOS
   usr_admin  = administrador (db_owner)
   usr_lector = solo lectura (db_datareader) + EXECUTE sobre sp_InsertarProducto
   ========================================================================= */

-- 1.1 Ambos pueden LEER la tabla Producto
EXECUTE AS LOGIN = 'login_admin';
    SELECT USER_NAME() AS usuario, COUNT(*) AS productos_visibles FROM dbo.Producto;
REVERT;

EXECUTE AS LOGIN = 'login_lector';
    SELECT USER_NAME() AS usuario, COUNT(*) AS productos_visibles FROM dbo.Producto;
REVERT;
GO

-- 1.2 INSERT con sentencia SQL directa, usuario ADMINISTRADOR
--     Resultado esperado: se inserta (db_owner puede todo).
EXECUTE AS LOGIN = 'login_admin';
BEGIN TRY
    INSERT INTO dbo.Producto (cod_producto, nombre_producto, descripcion, categoria,
                              precio_unitario, stock, lote)
    VALUES (9001, 'Alcohol en gel 250 ml', 'Prueba de seguridad: INSERT directo del admin',
            'Higiene', 1500.00, 10, 'SEG-9001');
    PRINT '1.2 usr_admin  - INSERT directo:        PERMITIDO (producto 9001 insertado)';
END TRY
BEGIN CATCH
    PRINT '1.2 usr_admin  - INSERT directo:        ERROR -> ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- 1.3 INSERT con sentencia SQL directa, usuario de SOLO LECTURA
--     Resultado esperado: ERROR 229
--     "The INSERT permission was denied on the object 'Producto'..."
EXECUTE AS LOGIN = 'login_lector';
BEGIN TRY
    INSERT INTO dbo.Producto (cod_producto, nombre_producto, descripcion, categoria,
                              precio_unitario, stock, lote)
    VALUES (9002, 'Protector solar FPS 50', 'Prueba de seguridad: INSERT directo del lector',
            'Dermocosmética', 9800.00, 5, 'SEG-9002');
    PRINT '1.3 usr_lector - INSERT directo:        PERMITIDO';
END TRY
BEGIN CATCH
    PRINT '1.3 usr_lector - INSERT directo:        DENEGADO -> error '
          + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- 1.4 INSERT A TRAVÉS DEL PROCEDIMIENTO, usuario de SOLO LECTURA
--     Resultado esperado: se inserta. El usuario tiene EXECUTE sobre el
--     procedimiento y, como el procedimiento y la tabla tienen el mismo
--     dueño (dbo), el motor NO vuelve a revisar el permiso INSERT sobre
--     Producto (encadenamiento de propiedad / ownership chaining).
EXECUTE AS LOGIN = 'login_lector';
BEGIN TRY
    EXEC dbo.sp_InsertarProducto
         @cod    = 9002,
         @desc   = 'Prueba de seguridad: INSERT por procedimiento del lector',
         @cat    = 'Dermocosmética',
         @precio = 9800.00,
         @nombre = 'Protector solar FPS 50',
         @stock  = 5,
         @lote   = 'SEG-9002';
    PRINT '1.4 usr_lector - INSERT por el SP:      PERMITIDO (producto 9002 insertado)';
END TRY
BEGIN CATCH
    PRINT '1.4 usr_lector - INSERT por el SP:      ERROR -> ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- 1.5 El procedimiento sigue aplicando sus reglas de negocio aunque lo use
--     el lector: un precio negativo se rechaza con el error 50001 del SP.
EXECUTE AS LOGIN = 'login_lector';
BEGIN TRY
    EXEC dbo.sp_InsertarProducto 9003, 'Precio negativo', 'Varios', -10.00,
         'Producto inválido', 1, 'SEG-9003';
END TRY
BEGIN CATCH
    PRINT '1.5 usr_lector - SP con precio negativo: RECHAZADO por la regla de negocio -> '
          + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- 1.6 El lector tampoco puede ejecutar OTROS procedimientos (solo se le dio
--     EXECUTE sobre sp_InsertarProducto). Resultado esperado: error 229.
EXECUTE AS LOGIN = 'login_lector';
BEGIN TRY
    EXEC dbo.sp_BorrarProducto @cod = 9002;
END TRY
BEGIN CATCH
    PRINT '1.6 usr_lector - EXEC sp_BorrarProducto: DENEGADO -> ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- Resultado de la parte 1: quedan los productos 9001 (admin, directo) y
-- 9002 (lector, por SP). El 9003 no existe.
SELECT cod_producto, nombre_producto, descripcion
FROM dbo.Producto
WHERE cod_producto BETWEEN 9001 AND 9003;
GO

/* =========================================================================
   PARTE 2. PERMISOS A NIVEL DE ROLES
   rol_consulta_catalogo = SELECT sobre Producto y Proveedor
   usr_consulta_con_rol  = miembro del rol
   usr_consulta_sin_rol  = sin rol ni permisos
   ========================================================================= */

-- 2.1 Usuario CON el rol lee Producto. Resultado esperado: ve los datos.
EXECUTE AS LOGIN = 'login_consulta_con_rol';
BEGIN TRY
    SELECT USER_NAME() AS usuario, cod_producto, nombre_producto, precio_unitario, stock
    FROM dbo.Producto
    WHERE cod_producto <= 5;
    PRINT '2.1 usr_consulta_con_rol - SELECT Producto:  PERMITIDO';
END TRY
BEGIN CATCH
    PRINT '2.1 usr_consulta_con_rol - SELECT Producto:  ERROR -> ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- 2.2 Usuario SIN el rol lee Producto. Resultado esperado: error 229
--     "The SELECT permission was denied on the object 'Producto'..."
EXECUTE AS LOGIN = 'login_consulta_sin_rol';
BEGIN TRY
    SELECT USER_NAME() AS usuario, cod_producto, nombre_producto, precio_unitario, stock
    FROM dbo.Producto
    WHERE cod_producto <= 5;
    PRINT '2.2 usr_consulta_sin_rol - SELECT Producto:  PERMITIDO';
END TRY
BEGIN CATCH
    PRINT '2.2 usr_consulta_sin_rol - SELECT Producto:  DENEGADO -> error '
          + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- 2.3 El rol permite leer SOLO algunas tablas: el usuario con rol intenta
--     leer Venta (no incluida en el rol). Resultado esperado: error 229.
EXECUTE AS LOGIN = 'login_consulta_con_rol';
BEGIN TRY
    SELECT TOP 3 cod_venta, fecha_venta FROM dbo.Venta;
    PRINT '2.3 usr_consulta_con_rol - SELECT Venta:     PERMITIDO';
END TRY
BEGIN CATCH
    PRINT '2.3 usr_consulta_con_rol - SELECT Venta:     DENEGADO -> ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- 2.4 El rol es de SOLO lectura: el usuario con rol intenta modificar un
--     precio. Resultado esperado: error 229 (UPDATE denegado).
EXECUTE AS LOGIN = 'login_consulta_con_rol';
BEGIN TRY
    UPDATE dbo.Producto SET precio_unitario = 1 WHERE cod_producto = 1;
    PRINT '2.4 usr_consulta_con_rol - UPDATE Producto:  PERMITIDO';
END TRY
BEGIN CATCH
    PRINT '2.4 usr_consulta_con_rol - UPDATE Producto:  DENEGADO -> ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- 2.5 Ventaja del rol: para darle el mismo acceso al segundo usuario NO se
--     repiten los GRANT, alcanza con agregarlo al rol. Se prueba y se
--     vuelve atrás para dejar la configuración como pide la consigna.
ALTER ROLE rol_consulta_catalogo ADD MEMBER usr_consulta_sin_rol;

EXECUTE AS LOGIN = 'login_consulta_sin_rol';
BEGIN TRY
    SELECT COUNT(*) AS productos_visibles_tras_agregarlo_al_rol FROM dbo.Producto;
    PRINT '2.5 usr_consulta_sin_rol (agregado al rol) - SELECT Producto: PERMITIDO';
END TRY
BEGIN CATCH
    PRINT '2.5 ERROR -> ' + ERROR_MESSAGE();
END CATCH;
REVERT;

ALTER ROLE rol_consulta_catalogo DROP MEMBER usr_consulta_sin_rol;
GO

/* =========================================================================
   3. RESUMEN DE PERMISOS EFECTIVOS
   fn_my_permissions devuelve lo que un usuario PUEDE hacer realmente sobre
   un objeto, sumando permisos directos y los heredados de sus roles.
   ========================================================================= */
EXECUTE AS LOGIN = 'login_lector';
    SELECT 'usr_lector' AS usuario, 'Producto' AS objeto, permission_name
    FROM fn_my_permissions('dbo.Producto', 'OBJECT') WHERE subentity_name = ''
    UNION ALL
    SELECT 'usr_lector', 'sp_InsertarProducto', permission_name
    FROM fn_my_permissions('dbo.sp_InsertarProducto', 'OBJECT');
REVERT;

EXECUTE AS LOGIN = 'login_consulta_con_rol';
    SELECT 'usr_consulta_con_rol' AS usuario, 'Producto' AS objeto, permission_name
    FROM fn_my_permissions('dbo.Producto', 'OBJECT') WHERE subentity_name = '';
REVERT;

EXECUTE AS LOGIN = 'login_consulta_sin_rol';
    SELECT 'usr_consulta_sin_rol' AS usuario, 'Producto' AS objeto,
           COUNT(*) AS cantidad_de_permisos       -- 0: no tiene ninguno
    FROM fn_my_permissions('dbo.Producto', 'OBJECT');
REVERT;
GO

/* =========================================================================
   LIMPIEZA: se borran los productos de prueba.
   ========================================================================= */
DELETE FROM dbo.Producto WHERE cod_producto IN (9001, 9002, 9003);
GO

/* =========================================================================
   PRUEBA CONECTÁNDOSE DE VERDAD CON CADA LOGIN (opcional, para mostrar en
   la defensa que el modo mixto funciona):
     1. En SSMS: Archivo > Conectar Explorador de objetos.
     2. Autenticación: "Autenticación de SQL Server".
     3. Inicio de sesión: login_lector   Contraseña: Lector#SanaSana2026
     4. Nueva consulta y ejecutar las sentencias de los puntos 1.3 y 1.4
        (sin EXECUTE AS / REVERT).
   Si el servidor está solo en modo Windows, el paso 3 falla con
   "Error de inicio de sesión del usuario 'login_lector'" (error 18456).
   ========================================================================= */

# Etapa V — Tema 3: Triggers de Auditoría y Seguridad

Proyecto Farmacia Sana-Sana — Equipo 43 — Bases de Datos I (UNNE)
Motor: SQL Server Express (T-SQL)

## 1. Definición y objetivo

Un trigger (o disparador) es un tipo especial de procedimiento almacenado que se ejecuta de forma automática y pasiva en respuesta a un evento de modificación de datos (`INSERT`, `UPDATE` o `DELETE`) sobre una tabla específica.

El objetivo en nuestro sistema es establecer "reglas activas" en el backend que vigilen la información crítica sin depender de la aplicación del usuario. Específicamente, buscamos mantener un historial exacto de la variación de precios de los medicamentos y garantizar que el historial contable de facturación sea inmutable.

## 2. Ventajas y aplicaciones

* Permite una trazabilidad perfecta para auditorías: registra quién, cuándo y qué valor se modificó.
* Garantiza políticas de seguridad inviolables, ya que al residir en el motor de la base de datos, intercepta las operaciones incluso si se ejecutan directamente desde una consola SQL.
* Evita la eliminación física de registros críticos (comprobantes de venta).
* Se aplica a toda tabla donde el control de cambios o la restricción de borrado sea una exigencia legal o contable del negocio.

## 3. Implementación en SQL Server Express

Se usan estas herramientas del motor:

* `CREATE TRIGGER`, para definir el disparador asociado a una tabla.
* `AFTER UPDATE`, para que el bloque se ejecute justo después de que se actualicen los datos.
* `INSTEAD OF DELETE`, para interceptar la orden de borrado, cancelarla y ejecutar una lógica alternativa en su lugar.
* Tablas virtuales `inserted` (contiene los valores nuevos) y `deleted` (contiene los valores viejos).
* `UPDATE(columna)`, para verificar si una columna específica fue afectada en la instrucción DML.
* `SYSTEM_USER` y `GETDATE()`, para capturar la huella de auditoría.

**Tablas virtuales en memoria.** Durante la ejecución de un trigger, SQL Server crea las tablas `inserted` y `deleted`. En un `UPDATE`, la fila original se guarda en `deleted` y la fila con los datos nuevos en `inserted`. Cruzando ambas tablas (mediante un `INNER JOIN`), podemos comparar el estado anterior y posterior del registro en la misma transacción.

Script completo: [suspicious link removed]

Define una tabla auxiliar y dos disparadores:

* **Tabla `Auditoria_Producto`:** Almacena el historial de cambios (fecha, usuario, nombre del producto, precio anterior, precio nuevo y tipo de operación).
* **`trg_AuditarPrecioProducto`:** Trigger `AFTER UPDATE` sobre la tabla `Producto`. Detecta si se modificó el `precio_unitario` y guarda el registro del cambio en la tabla de auditoría.
* **`trg_BloquearBorradoVenta`:** Trigger `INSTEAD OF DELETE` sobre la tabla `Venta`. Frena la eliminación, emite un mensaje de violación de seguridad y ejecuta un `ROLLBACK TRANSACTION`.

Decisiones de diseño:

* En el trigger de auditoría, se agregó la condición `WHERE inserted.precio_unitario <> deleted.precio_unitario`. Esto evita registrar "falsos positivos" en la auditoría si un usuario hace un `UPDATE` pero vuelve a guardar exactamente el mismo precio que el producto ya tenía.
* En el trigger restrictivo, se optó por un `INSTEAD OF` en lugar de un `AFTER`, porque es más eficiente y seguro cancelar la operación antes de que ocurra físicamente, en vez de dejar que se borre para luego deshacerla.

## 4. Caso concreto en el sistema de ventas

Un administrador actualiza el precio de lista del "Ibuprofeno 400 mg" de $2850 a $3500. El sistema guarda automáticamente el registro del cambio. Más tarde, un empleado intenta borrar por error la Venta N° 1. El sistema detecta la orden `DELETE`, bloquea la ejecución de inmediato y mantiene la venta intacta.

## 5. Demostración y resultados

Script de pruebas: [suspicious link removed]. Requiere `00_crear_bd_corregido.sql` y `LoteCarga_Farmacia.sql`.

### Prueba 1 — Auditoría de modificación de precios

Producto 1 (Ibuprofeno). Se realiza un `UPDATE` cambiando su precio a 3500.00. Resultado esperado: el precio se actualiza en la tabla `Producto` y se inserta automáticamente una nueva fila en `Auditoria_Producto` reflejando el salto de 2850.00 a 3500.00.

### Prueba 2 — Intento de borrado de venta (Violación de seguridad)

Se ejecuta un `DELETE` sobre la Venta 1. Resultado esperado: La consola devuelve el error "Violación de seguridad: Está prohibido eliminar comprobantes...", la transacción es abortada por el trigger y la venta permanece en la base de datos.

## 6. Conclusiones

1. Los triggers actúan como la última y más robusta línea de defensa de la base de datos, garantizando políticas de seguridad sin importar desde qué interfaz o sistema se ejecute la orden (Prueba 2).
2. El uso de las tablas `inserted` y `deleted` permite un control cruzado perfecto para registrar historiales precisos de variación de datos (Prueba 1).
3. La condición de filtrado (`<>`) dentro del trigger de auditoría demostró ser fundamental para no llenar la tabla auxiliar con operaciones DML redundantes o sin impacto real en el negocio.
4. Al ejecutar los scripts en SQL Server Express, las operaciones de borrado fueron interceptadas con éxito y las auditorías se generaron de forma transparente, coincidiendo con los resultados esperados.

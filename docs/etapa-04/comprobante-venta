# Caso de Uso 1: Factura / Comprobante de Venta

* **Script SQL asociado:** [`sql/consultas/comprobante_venta.sql`](../../sql/consultas/comprobante_venta.sql)

---

## 1. ¿Qué necesidad de información resuelve?
En la facturación del día a día de **Farmacia "Sana-Sana"**, cada vez que se registra una venta es necesario emitir un comprobante o factura que unifique la información que se encuentra distribuida en las distintas tablas normalizadas del modelo relacional:

1. **Encabezado del comprobante:** Número único de venta (`cod_venta`), fecha de operación (`fecha_venta`), medio de pago utilizado (`metodo_pago`), condición de expendio (indicando el número de receta médica si fue cargada en `nro_receta` o especificando que es de venta libre), datos del cliente (`dni`, apellido, nombre y domicilio) y datos del vendedor que efectuó la atención (`cod_vendedor`, apellido y nombre).
2. **Detalle por renglón:** Número de línea (`linea_venta`), código y nombre comercial del producto (`nombre_producto`), categoría farmacológica, código de lote (`lote`), cantidad de unidades adquiridas (`cant_comprada`) y el **precio unitario histórico** al que se cobró el producto (`Detalle_venta.precio_unitario`), contrastándolo con el precio de lista actual (`Producto.precio_unitario`) para verificar que los aumentos de catálogo no alteren facturas pasadas.
3. **Importes calculados:** El **subtotal monetario por cada renglón** y el **total general acumulado** del comprobante.

---

## 2. ¿Qué estrategia SQL utiliza?
El script `comprobante_venta.sql` resuelve dos consultas complementarias escritas bajo el estándar **SQL ANSI**:

### 2.1. Consulta 1A: Comprobante Detallado Renglón por Renglón
* **Combinación interna (`INNER JOIN`) de 7 referencias de tablas:**
  Como los nombres y apellidos tanto de clientes como de vendedores se almacenan en la tabla `Persona`, la consulta realiza **dos uniones independientes hacia `Persona`** diferenciadas mediante alias de tabla:
  * `INNER JOIN Cliente AS c ON v.dni = c.dni` seguido de `INNER JOIN Persona AS p_cli ON c.dni = p_cli.dni` (recupera los datos del comprador).
  * `INNER JOIN Vendedor AS ven ON v.cod_vendedor = ven.cod_vendedor` seguido de `INNER JOIN Persona AS p_ven ON ven.dni = p_ven.dni` (recupera los datos del vendedor).
  * `INNER JOIN Detalle_venta AS dv ON v.cod_venta = dv.cod_venta` e `INNER JOIN Producto AS pr ON dv.cod_producto = pr.cod_producto` (recupera los ítems vendidos y su descripción).
* **Expresiones aritméticas y función matemática `ROUND`:**
  * Se calcula el subtotal de cada renglón multiplicando cantidad por precio histórico: `ROUND(dv.cant_comprada * dv.precio_unitario, 2)`.
* **Expresión condicional `CASE`:**
  Evalúa si la columna `v.nro_receta IS NULL` para mostrar la leyenda `'Venta Libre (S/R)'` o, en caso contrario, concatenar `'Bajo Receta (' + v.nro_receta + ')'`.
* **Subconsulta escalar correlacionada en el `SELECT`:**
  Para mostrar el **total acumulado de la factura** al final de cada renglón sin agrupar ni perder el detalle de las líneas, se incluye una subconsulta correlacionada (`WHERE dv_sub.cod_venta = v.cod_venta`) que calcula `SUM(dv_sub.cant_comprada * dv_sub.precio_unitario)`.

### 2.2. Consulta 1B: Resumen de Pie de Comprobante
* Utiliza la cláusula `GROUP BY` junto con las funciones de agregado `COUNT(dv.linea_venta)`, `SUM(dv.cant_comprada)` y `ROUND(SUM(dv.cant_comprada * dv.precio_unitario), 2)` para emitir un listado consolidado con una única fila resumen por cada una de las 12 facturas registradas en la base de datos.

---

## 3. ¿Qué resultado se espera?

### 3.1. Resultado esperado de la Consulta 1A (para `cod_venta = 9`)
Al ejecutar la primera consulta filtrando por la venta `9`, el motor devuelve los 3 renglones que componen dicha factura con sus respectivos subtotales y el total acumulado de `$19.450,00`:

| Nro_Comprobante | Fecha_Emision | Metodo_Pago | Condicion_Venta | DNI_Cliente | Cliente | Legajo_Vendedor | Vendedor | Renglon | Producto | Lote | Cantidad | Precio_Unitario_Facturado | Precio_Lista_Actual | Dif_Unitaria_Lista | Subtotal_Renglon | Total_Acumulado_Comprobante |
| :---: | :---: | :--- | :--- | :---: | :--- | :---: | :--- | :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `9` | `2026-09-17` | `Obra social` | `Bajo Receta (REC-0003)` | `40111008` | `Villalba, Joaquín` | `3` | `Cabrera, Lucía` | `1` | `Amoxicilina 500 mg` | `L2602A` | `2` | `6200.00` | `6400.00` | `200.00` | `12400.00` | `19450.00` |
| `9` | `2026-09-17` | `Obra social` | `Bajo Receta (REC-0003)` | `40111008` | `Villalba, Joaquín` | `3` | `Cabrera, Lucía` | `2` | `Ibuprofeno 400 mg` | `L2601A` | `1` | `2850.00` | `2850.00` | `0.00` | `2850.00` | `19450.00` |
| `9` | `2026-09-17` | `Obra social` | `Bajo Receta (REC-0003)` | `40111008` | `Villalba, Joaquín` | `3` | `Cabrera, Lucía` | `3` | `Omeprazol 20 mg` | `L2602B` | `1` | `4200.00` | `4200.00` | `0.00` | `4200.00` | `19450.00` |

### 3.2. Resultado esperado de la Consulta 1B (Totales consolidados por comprobante)
Al ejecutar la segunda consulta agrupada, se obtiene el resumen general de las 12 ventas cargadas en el lote de prueba:

| Nro_Comprobante | Fecha_Emision | Cliente | Vendedor | Metodo_Pago | Nro_Receta | Cant_Renglones | Total_Unidades | Total_Facturado |
| :---: | :---: | :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| `1` | `2026-09-01` | `Gómez, María Belén` | `Molina, Carolina` | `Efectivo` | `Sin Receta` | `2` | `3` | `5350.00` |
| `2` | `2026-09-02` | `Fernández, Lucas` | `Pereyra, Federico` | `Tarjeta de débito` | `Sin Receta` | `2` | `4` | `5640.00` |
| `3` | `2026-09-03` | `Romero, Agustina` | `Cabrera, Lucía` | `Obra social` | `REC-0001` | `2` | `2` | `10400.00` |
| `4` | `2026-09-05` | `Ramírez, Sofía` | `Molina, Carolina` | `Tarjeta de crédito` | `Sin Receta` | `2` | `3` | `7700.00` |
| `5` | `2026-09-08` | `Acosta, Martín` | `Núñez, Andrés` | `Mercado Pago` | `Sin Receta` | `2` | `3` | `13300.00` |
| `6` | `2026-09-10` | `Sánchez, Diego` | `Ledesma, Florencia` | `Transferencia` | `REC-0002` | `2` | `3` | `9500.00` |
| `7` | `2026-09-12` | `Benítez, Camila` | `Pereyra, Federico` | `Efectivo` | `Sin Receta` | `2` | `3` | `9700.00` |
| `8` | `2026-09-15` | `Ortiz, Valentina` | `Insaurralde, Gustavo` | `Código QR` | `Sin Receta` | `2` | `3` | `7160.00` |
| `9` | `2026-09-17` | `Villalba, Joaquín` | `Cabrera, Lucía` | `Obra social` | `REC-0003` | `3` | `4` | `19450.00` |
| `10` | `2026-09-20` | `Duarte, Nicolás` | `Medina, Paula` | `Cuenta corriente` | `Sin Receta` | `2` | `4` | `8000.00` |
| `11` | `2026-09-24` | `Gómez, María Belén` | `Godoy, Ramiro` | `Tarjeta de débito` | `Sin Receta` | `2` | `2` | `12900.00` |
| `12` | `2026-09-28` | `Acosta, Martín` | `Molina, Carolina` | `Tarjeta de crédito` | `REC-0004` | `3` | `4` | `15950.00` |

# Decisiones de Diseño

Durante el análisis del caso de estudio, el grupo 43 tomó las siguientes decisiones de diseño para el modelado de la base de datos de Farmacia Sana-Sana.

### 1. Especialización de Persona
Se optó por utilizar una **jerarquía (especialización) total y disjunta** para la entidad "Persona", con los subtipos "Cliente" y "Vendedor".
* **Justificación:** Las reglas de negocio establecen que toda persona registrada tiene atributos comunes (DNI, nombre, apellido, correo electrónico y teléfono), pero obligatoriamente debe asumir el rol de "Cliente" o "Vendedor" (total) y bajo ninguna circunstancia puede ser ambos a la vez (disjunta) (RN.01). Además, cada subtipo tiene atributos propios: el cliente tiene código y dirección, y el vendedor tiene su código.

### 2. Identificadores de Cliente y Vendedor
El identificador del `Cliente` es su propio **DNI**, mientras que el `Vendedor` utiliza un **código de vendedor**.
* **Justificación:** Se corrige la idea de usar un identificador inventado "cod_cliente". La RN.02 es explícita en que cada cliente se identifica directamente con su DNI. Para el vendedor, la RN.03 establece que se identifica con un único código de vendedor.

### 3. Categoría como Atributo
Se decidió mantener `Categoría` como un atributo de la entidad `Producto`.
* **Justificación:** El enunciado define a los productos con atributos básicos como nombre, descripción y categoría. Tratándolo como atributo se simplifica el diagrama y se cumple perfectamente con el alcance solicitado.

### 4. Método de pago en la Venta (Cabecera)
El método de pago se modeló como un atributo de la entidad `Venta`.
* **Justificación:** Se corrige la ubicación errónea del método de pago en el detalle. El caso de estudio indica claramente que "Cada venta cuenta con... método de pago" (RN.13), por lo que aplica a la totalidad de la transacción.

### 5. Atributos de Lote y Stock en Producto
El stock y el "lote actual" se modelaron como atributos de la entidad `Producto`, y el lote se registra en el `Detalle_Venta`.
* **Justificación:** Se descarta crear "Lote" como una entidad separada. El enunciado especifica textualmente: "De un producto se requiere saber... precio unitario, stock y su lote actual". A su vez, el detalle de venta simplemente registra el número de lote del cual se descuenta.

### 6. Reposición mediante Pedidos
La reposición de mercadería se modeló con la entidad `Pedido` asociada a `Proveedor` y `Producto`.
* **Justificación:** Se elimina la entidad inventada "Abastecimiento". El modelo oficial indica que la reposición se realiza mediante operaciones de "Pedido a proveedores". De cada pedido se registra un código, fecha y cantidad solicitada, correspondiendo a un único proveedor (RN.11, RN.12).

### 7. Detalle de Venta como Entidad Débil
`Detalle_Venta` se modeló como una entidad débil de `Venta`, utilizando el `número de línea` como clave parcial.
* **Justificación:** Una línea de detalle no tiene existencia propia sin su cabecera de venta. El número de línea (1, 2, 3...) se repite para diferentes ventas, necesitando el identificador de la Venta para ser único.

### 8. Histórico de Precios en el Detalle
Se agregó el atributo `precio_unitario` en la entidad débil `Detalle_Venta`.
* **Justificación:** El precio en las farmacias fluctúa. Registrar el "precio unitario vigente al momento de la operación" en el detalle garantiza que las consultas históricas no se alteren si el precio de lista del producto cambia (RN.08).

### 9. Manejo de Recetas Médicas Opcional
El atributo `numero_receta` fue ubicado en el `Detalle_Venta` y es opcional.
* **Justificación:** Solo es obligatorio "cuando el producto requiere receta médica" (RN.09). Ubicarlo en la cabecera `Venta` condicionaría toda la compra, impidiendo mezclar productos de venta libre y recetados.

### 10. Cálculo de Totales Derivados
No se almacena un atributo "Total" en la tabla de `Venta`.
* **Justificación:** El total se calcula dinámicamente sumando (cantidad * precio_unitario) de sus líneas. Almacenarlo físicamente generaría datos redundantes.

### 11. Reglas Activas (Triggers / Procedimientos)
Varias reglas de negocio documentadas requerirán la implementación de Triggers en el diseño físico:
* **RN.05:** Generar un nuevo pedido automáticamente si el stock actual es 5 o menos.
* **RN.10 y RN.14:** Actualización de inventario. Descontar del stock al vender (RN.10) y sumar al stock al realizar un pedido (RN.14).
* **Justificación:** El diagrama ER modela la estructura estática. La lógica activa de validación pertenece a la capa de base de datos física.


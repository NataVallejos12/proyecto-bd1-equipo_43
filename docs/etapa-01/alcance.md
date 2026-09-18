# 🎯 Alcance del Proyecto

Este documento define los límites del Sistema de Gestión de Ventas para la Farmacia Sana-Sana en esta primera etapa del proyecto, enfocada en el diseño del modelo conceptual (Diagrama Entidad-Relación).

## 🟢 Incluido en el Alcance
El modelo de base de datos diseñado contempla la gestión de los siguientes dominios:

1. **Gestión de Personas:**
   * Registro y diferenciación de Clientes y Vendedores.
2. **Gestión de Inventario y Catálogo:**
   * Administración de productos clasificados por categorías.
   * Seguimiento de stock, lotes y definición de un punto de reorden (stock <= 5).
3. **Gestión de Ventas:**
   * Registro de transacciones que vinculan clientes, vendedores, productos y métodos de pago.
   * Manejo de la lógica de precios históricos en el detalle de cada venta.
   * Control de ventas de medicamentos bajo receta.
4. **Gestión de Proveedores y Compras:**
   * Mantenimiento de información de proveedores (laboratorios, droguerías).
   * Generación de pedidos de reabastecimiento de productos.

## 🔴 Fuera del Alcance
Para esta iteración, el sistema **no** contempla:
* Integración con sistemas de facturación electrónica (AFIP).
* Gestión contable, financiera o liquidación de sueldos de los vendedores.
* Módulos de envíos a domicilio o logística de distribución a clientes.
* Gestión de obras sociales o descuentos por cobertura médica (se asume el registro del precio unitario final para simplificar el modelo base).
* Autenticación de usuarios y roles de sistema a nivel de base de datos (seguridad de la aplicación).

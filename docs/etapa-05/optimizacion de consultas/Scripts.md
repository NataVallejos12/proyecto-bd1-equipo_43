## Optimización de consultas mediante índices – Etapa V

En esta etapa se trabaja con la optimización de consultas en SQL Server mediante la creación y utilización de índices. Se incluyen dos scripts de la carpeta "sql/tecnico/Indices_EtapaV/" : uno destinado a la implementación de los índices y otro a demostrar y comparar su funcionamiento.

### 1. Implementación de índices

**Archivo:** "indice_implementacion.sql"

Este script prepara una tabla de ventas históricas para realizar pruebas de rendimiento y permite generar una gran cantidad de registros de prueba. También contiene la creación de índices en distintas tablas del sistema, con el objetivo de mejorar el acceso a los datos y optimizar las consultas.

[Acceder al script de implementación](sql/tecnico/Indices_EtapaV/indice_implementacion.sql)

### 2. Demostración de índices

**Archivo:** "indice_demostracion.sql"

Este script permite comprobar cómo influye el uso de índices en el rendimiento de las consultas. Para ello, realiza pruebas sobre la tabla de ventas históricas en distintos escenarios: sin índices, con un índice agrupado (CLUSTERED) y con un índice no agrupado de cobertura (NONCLUSTERED).

Además, permite observar los planes de ejecución y comparar diferentes métricas, como los tiempos de ejecución y las lecturas realizadas por SQL Server.

[Acceder al script de demostración](sql/tecnico/Indices_EtapaV/indice_demostracion.sql)

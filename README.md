# RetailPro Analytics — Sistema Integral de Inteligencia Comercial

Repositorio oficial del proyecto integrador de análisis de datos para la distribuidora de tecnología **RetailPro**. El proyecto abarca desde el diseño e implementación de la arquitectura relacional transaccional hasta la extracción analítica y modelado para Business Intelligence.

---

## Stack Tecnológico y Herramientas
* **RDBMS / Motor de Base de Datos:** Microsoft SQL Server (T-SQL)
* **Entorno de Administración:** SQL Server Management Studio (SSMS)
* **Visualización y Modelado:** Microsoft Power BI (Power Query, VertiPaq, DAX)
* **Control de Versiones:** Git & GitHub

---

## Arquitectura y Modelo Relacional (`Ventas_Tech_DB`)
El ecosistema transaccional se encuentra normalizado en **Tercera Forma Normal (3NF)** y se estructura en un modelo relacional de 4 tablas:
* `categorias`: Maestro dimensional de líneas de producto (PK: `id_categoria`).
* `clientes`: Maestro de cuentas de clientes y procedencia geográfica (PK: `id_cliente`).
* `productos`: Catálogo de hardware y periféricos (PK: `id_producto`, FK: `id_categoria`).
* `ventas`: Tabla de hechos con transacciones operativas (PK: `id_venta`, FK: `id_cliente`, FK: `id_producto`).

---

## Guía de Ejecución de Scripts SQL (SSMS)
Para garantizar la integridad referencial y evitar conflictos de dependencias entre claves foráneas, los scripts deben ejecutarse en el siguiente orden secuencial:

1. **Creación del Esquema y Carga Base (DDL / DML):**
   * Abrir y ejecutar `Modulo_03/ventas_tech_db.sql`.
   * *Acción:* Crea la base `Ventas_Tech_DB`, genera las restricciones de integridad (PK/FK) e inserta los registros iniciales y de prueba.
2. **Consultas de Negocio y Métricas Clave:**
   * Ejecutar `Modulo_04/m4_consultas_negocio.sql`.
   * *Acción:* Calcula facturación mensual, ticket promedio, clientes recurrentes y ranking de artículos sobre la tabla de hechos.
3. **Vistas Multidimensionales y Cruce de Tablas:**
   * Ejecutar `Modulo_05/m5_consultas_joins.sql`.
   * *Acción:* Consolida la vista dimensional base (`INNER JOIN` de 4 tablas) para alimentar el pipeline de Power BI, e identifica clientes y stock sin rotación (`LEFT JOIN ... IS NULL`).

---

## Métricas de Negocio Validadas (Baseline)
* **Facturación Total del Período:** $6.444,00 (10 transacciones en marzo).
* **Ticket Promedio General:** $644,40 por pedido.
* **Concentración Comercial:** La categoría *Computación* (liderada por Laptop Pro 15) concentra el 55,9% de los ingresos totales con solo 3 unidades vendidas.
* **Cartera Activa:** Recurrencia del 100% de los clientes registrados (2 compras por cuenta).

---
**Autor:** Franco Colombo  
**Perfil GitHub:** [@FrancoColombo23](https://github.com/francocolombo23/Coderhouse-Data-Analytics)

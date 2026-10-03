-- =============================================================================
-- PROYECTO: RetailPro - Extrayendo métricas clave con SQL
-- ARCHIVO: m4_consultas_negocio.sql
-- AUTOR: Franco Colombo
-- BASE DE DATOS: Ventas_Tech_DB
-- TABLA: ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta)
-- =============================================================================

USE Ventas_Tech_DB;
GO

-- -----------------------------------------------------------------------------
-- CONSULTA 1: Resumen ejecutivo mensual
-- Objetivo: Total facturado, cantidad de pedidos y ticket promedio por mes.
-- -----------------------------------------------------------------------------
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes ASC;
GO

-- -----------------------------------------------------------------------------
-- CONSULTA 2: Ranking de productos
-- Objetivo: Top 5 de id_producto por facturación total y unidades vendidas.
-- -----------------------------------------------------------------------------
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;
GO

-- -----------------------------------------------------------------------------
-- CONSULTA 3: Clientes recurrentes
-- Objetivo: id_cliente con más de un pedido, con conteo y total gastado.
-- -----------------------------------------------------------------------------
SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC, total_gastado DESC;
GO

-- -----------------------------------------------------------------------------
-- CONSULTA 4: Meses por encima/por debajo del promedio mensual general
-- Objetivo: Total facturado por mes categorizado según la media de facturación mensual.
-- -----------------------------------------------------------------------------

SELECT 
    MONTH(v.fecha_venta) AS mes,
    SUM(v.cantidad * v.precio_unitario) AS total_mes,
    CASE 
        WHEN SUM(v.cantidad * v.precio_unitario) >= (
            -- Subconsulta: promedio mensual general
            SELECT AVG(t.total_mes) 
            FROM (
                SELECT SUM(cantidad * precio_unitario) AS total_mes 
                FROM ventas 
                GROUP BY MONTH(fecha_venta)
            ) t
        ) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS clasificacion_promedio
FROM ventas v
GROUP BY MONTH(v.fecha_venta)
ORDER BY mes ASC;

-- =============================================================================
-- BLOQUE DE CIERRE: 3 Hallazgos concretos del negocio (RetailPro)
-- =============================================================================
/*
HALLAZGO 1 - Concentración en productos de alto valor (Pareto de facturación):
Al analizar el ranking del Top 5 de productos, se observa que el producto id_producto = 1 
(Laptop Pro 15) concentra $3.600,00 de la facturación total ($5.319,00), lo que representa 
más del 67% del ingreso general con apenas 3 unidades vendidas. En contraste, productos 
de alta rotación como el id_producto = 2 (Mouse Inalámbrico) acumulan 13 unidades vendidas 
pero aportan menos del 7% de la facturación ($364,00).

HALLAZGO 2 - Comportamiento de recurrencia en la cartera de clientes:
El 100% de los clientes registrados (IDs 1, 2, 3, 4 y 5) presentan recurrencia al registrar 
exactamente 2 pedidos cada uno dentro del período de datos cargado. El cliente con mayor 
impacto monetario es id_cliente = 1 con $2.640,00 gastados (impulsado por la compra de laptops), 
mientras que el cliente id_cliente = 2 presenta una compra de menor importe promedio ($520,00) 
a pesar de sostener la misma frecuencia de compra.

HALLAZGO 3 - Distribución y corte temporal de la facturación:
Dado que la base actual contiene registros transaccionales concentrados en el mes de marzo 
(mes 3), la facturación mensual observada asciende a $5.319,00 en 10 transacciones con un 
ticket promedio de $531,90 por orden. La clasificación mensual se encuentra en el valor medio 
general de referencia, sirviendo de base comparativa para medir la caída de pedidos proyectada 
en los análisis de evolución temporal posteriores.
*/

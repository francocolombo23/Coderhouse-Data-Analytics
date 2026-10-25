-- =============================================================================
-- PROYECTO: RetailPro - Extrayendo métricas clave con SQL
-- ARCHIVO: m4_consultas_negocio.sql
-- BASE DE DATOS: Ventas_Tech_DB
-- TABLA: ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta)
-- NOTA DE COMPATIBILIDAD: Se utiliza MONTH(fecha_venta) por ser la función nativa
-- de SQL Server (T-SQL). En motores compatibles con ANSI SQL (PostgreSQL, MySQL)
-- la función equivalente solicitada en la consigna es EXTRACT(MONTH FROM fecha_venta).
-- =============================================================================

USE Ventas_Tech_DB;
GO

-- -----------------------------------------------------------------------------
-- CONSULTA 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes.
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
-- Top 5 de id_producto por total facturado, unidades vendidas y total generado.
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
-- id_cliente con más de un pedido, con conteo y total gastado.
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
-- CONSULTA 4: Meses por encima/por debajo del promedio general
-- Total facturado por mes con CASE WHEN evaluando la media mensual global.
-- -----------------------------------------------------------------------------
WITH FacturacionMensual AS (
    SELECT 
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_mes
    FROM ventas
    GROUP BY MONTH(fecha_venta)
),
PromedioGeneral AS (
    SELECT 
        AVG(total_mes) AS promedio_mensual
    FROM FacturacionMensual
)
SELECT 
    f.mes,
    f.total_mes,
    CASE 
        WHEN f.total_mes >= p.promedio_mensual THEN 'Por encima'
        ELSE 'Por debajo'
    END AS clasificacion_promedio
FROM FacturacionMensual f
CROSS JOIN PromedioGeneral p
ORDER BY f.mes ASC;
GO


-- =============================================================================
-- BLOQUE DE CIERRE: 3 Hallazgos concretos del negocio (RetailPro)
-- =============================================================================

-- HALLAZGO 1 - Alta concentración de ingresos en hardware de alta gama:
-- El producto id_producto = 1 (Laptop Pro 15) lidera el ranking comercial con
-- una facturación de $3.600,00 sobre un total general de $6.444,00, concentrando
-- exactamente el 55,9% de los ingresos de la tienda con solo 3 unidades vendidas.
-- Por el contrario, productos como el id_producto = 2 (Mouse Inalámbrico) tienen
-- mayor rotación física (13 unidades), pero solo representan el 5,6% del total ($364,00).

-- HALLAZGO 2 - Recurrencia plena de la cartera de clientes en el período:
-- El 100% de los clientes analizados (los 5 clientes registrados) realizaron más de una
-- compra (exactamente 2 pedidos cada uno en los 10 registros de la base).
-- El cliente id_cliente = 1 es el de mayor valor comercial con $2.640,00 gastados,
-- mientras que el id_cliente = 2 presentó el menor desembolso acumulado con $520,00,
-- evidenciando una amplia disparidad en el poder de compra dentro de la misma frecuencia.

-- HALLAZGO 3 - Nivel basal de facturación mensual y ticket promedio:
-- La actividad registrada se concentra íntegramente en el mes de marzo (mes 3),
-- acumulando un total facturado de $6.444,00 a través de 10 transacciones, lo que
-- arroja un ticket promedio real de $644,40 por pedido. Al existir un único mes con
-- operaciones en esta fase, su total coincide con el promedio mensual general de
-- referencia para ser conectado al modelo analítico de Power BI en M6.
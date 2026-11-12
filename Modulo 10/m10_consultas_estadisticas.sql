-- =============================================================================
-- PROYECTO: RetailPro - Cruzando tablas para enriquecer el análisis
-- ARCHIVO: m10_consultas_estadisticas.sql
-- BASE DE DATOS: Ventas_Tech_DB
-- MOTOR: SQL Server
-- =============================================================================

USE Ventas_Tech_DB;
GO

-- PARTE 1: CASO GUIADO — ESTABILIDAD DE VENTAS POR SUCURSAL

-- 1. Creación de la tabla temporal o de prueba
DROP TABLE IF EXISTS ventas_semana;
GO

CREATE TABLE ventas_semana (
    sucursal VARCHAR(20) NOT NULL,
    venta    DECIMAL(10, 2) NOT NULL
);
GO

-- 2. Carga de los datos de la última semana (5 días por sucursal)
INSERT INTO ventas_semana (sucursal, venta) VALUES
    -- Sucursal Norte
    ('Norte', 500.00),
    ('Norte', 510.00),
    ('Norte', 490.00),
    ('Norte', 505.00),
    ('Norte', 495.00),
    -- Sucursal Sur
    ('Sur', 100.00),
    ('Sur', 900.00),
    ('Sur',  50.00),
    ('Sur', 1200.00),
    ('Sur', 250.00);
GO

-- 3. Cálculo de Media y Rango
SELECT
    sucursal,
    AVG(venta)              AS media,
    MAX(venta) - MIN(venta) AS rango
FROM ventas_semana
GROUP BY sucursal;
GO

-- 4. Cálculo de la Desviación Estándar Muestral
-- NOTA: En SQL Server se usa STDEV (equivale a STDDEV_SAMP en PostgreSQL)
SELECT
    sucursal,
    ROUND(STDEV(venta), 2) AS desvio_muestral
FROM ventas_semana
GROUP BY sucursal;
GO

-- 5. Consulta consolidada (Media, Rango y Desvío en una sola tabla)
SELECT
    sucursal,
    AVG(venta)              AS media,
    MAX(venta) - MIN(venta) AS rango,
    ROUND(STDEV(venta), 2)  AS desvio_muestral
FROM ventas_semana
GROUP BY sucursal;
GO

-- Conclusión: ¿Qué Sucursal preferiría gestionar y por qué?
-- Preferiría gestionar la Sucursal Norte debido a su alta previsibilidad operativa y 
-- baja dispersión (s = 7,91), lo que asegura una demanda constante, facilita la planificación 
-- de inventario y reduce el riesgo de quiebres de stock. En contraste, la Sucursal Sur presenta 
-- una volatilidad extrema (s = 518,41) que complejiza la dotación de personal y distorsiona 
-- el flujo de caja diario


-- =============================================================================
-- PARTE 2a: TICKET PROMEDIO REAL VS. REPRESENTATIVO (MEDIA VS. MEDIANA)
-- =============================================================================

SELECT DISTINCT
    AVG(cantidad * precio_unitario) OVER () AS media_ticket,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (cantidad * precio_unitario)) OVER () AS mediana_ticket
FROM ventas;
GO

-- =============================================================================
-- PARTE 2b: DETECCIÓN DE OUTLIERS CON EL MÉTODO IQR (SQL SERVER)
-- =============================================================================
-- 1. Cálculo de Q1, Q3, IQR y límites de detección
WITH metricas AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY (cantidad * precio_unitario)) OVER () AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY (cantidad * precio_unitario)) OVER () AS q3
    FROM ventas
),
limites AS (
    SELECT 
        q1,
        q3,
        (q3 - q1) AS iqr,
        (q1 - 1.5 * (q3 - q1)) AS limite_inferior,
        (q3 + 1.5 * (q3 - q1)) AS limite_superior
    FROM metricas
)
SELECT * FROM limites;
GO

-- 2. Identificar qué registros específicos caen fuera de los límites
WITH metricas AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY (cantidad * precio_unitario)) OVER () AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY (cantidad * precio_unitario)) OVER () AS q3
    FROM ventas
),
limites AS (
    SELECT 
        (q1 - 1.5 * (q3 - q1)) AS limite_inferior,
        (q3 + 1.5 * (q3 - q1)) AS limite_superior
    FROM metricas
)
SELECT 
    v.*,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
CROSS JOIN limites l
WHERE (v.cantidad * v.precio_unitario) < l.limite_inferior
   OR (v.cantidad * v.precio_unitario) > l.limite_superior;
GO

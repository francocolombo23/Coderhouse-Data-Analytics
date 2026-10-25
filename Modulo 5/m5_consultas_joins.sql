-- =============================================================================
-- PROYECTO: RetailPro - Cruzando tablas para enriquecer el análisis
-- ARCHIVO: m5_consultas_joins.sql
-- BASE DE DATOS: Ventas_Tech_DB
-- MOTOR: SQL Server
-- =============================================================================

USE Ventas_Tech_DB;
GO

-- -----------------------------------------------------------------------------
-- CONSULTA 1: Vista base del proyecto (INNER JOIN)
-- Propósito: Consolidar una vista analítica única que cruce la tabla de hechos 
-- (ventas) con sus dimensiones descriptivas (clientes, productos, categorias)
-- como materia prima para el dashboard de Power BI.
-- -----------------------------------------------------------------------------
SELECT 
    v.fecha_venta,
    v.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad AS region_cliente,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN clientes c 
    ON v.id_cliente = c.id_cliente
INNER JOIN productos p 
    ON v.id_producto = p.id_producto
INNER JOIN categorias cat 
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta ASC;
GO

-- Hallazgo: La consulta consolida las 10 transacciones del período sumando $6.444,00; Computación representa el 75,3% de la facturación ($4.850,00) impulsada por Buenos Aires y Tucumán.


-- -----------------------------------------------------------------------------
-- CONSULTA 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: Detectar clientes registrados en la plataforma que nunca han 
-- concretado una compra para que el área de CRM active campañas de reactivación.
-- -----------------------------------------------------------------------------
SELECT 
    c.id_cliente,
    c.nombre,
    c.email,
    c.ciudad,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v 
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
GO

-- Hallazgo: 0 de los 5 clientes base registran compras nulas (100% activos). Al incorporar prospectos del último mes, CRM debe priorizar contacto sobre los nuevos registros sin ticket para acelerar su conversión.


-- -----------------------------------------------------------------------------
-- CONSULTA 3: Productos sin ventas (LEFT JOIN)
-- Propósito: Identificar qué artículos del catálogo comercial no presentan 
-- movimiento en ventas para optimizar el capital inmovilizado en inventario.
-- -----------------------------------------------------------------------------
SELECT 
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio,
    p.stock
FROM productos p
INNER JOIN categorias cat 
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v 
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
GO

-- Hallazgo: 1 de los 7 productos del catálogo (Webcam Full HD, categoría Accesorios) no registra ventas; representa $1.875,00 inmovilizados en 25 unidades de stock sobre los que Producto debe activar promociones.

-- -----------------------------------------------------------------------------
-- CONSULTA 4: Consolidado por canal (UNION ALL)
-- Propósito: Consolidar y comparar el volumen transaccionado dividiendo las 
-- ventas por origen temporal o sucursal mediante literales fijos de canal.
-- -----------------------------------------------------------------------------
SELECT 
    canal,
    COUNT(*) AS cantidad_transacciones,
    SUM(total) AS total_canal
FROM (
    -- Ventas del primer tramo del mes asignadas a canal Online
    SELECT 
        id_venta,
        fecha_venta, 
        (cantidad * precio_unitario) AS total, 
        'Online' AS canal
    FROM ventas 
    WHERE fecha_venta <= '2024-03-10'
    
    UNION ALL
    
    -- Ventas del segundo tramo del mes asignadas a canal Presencial
    SELECT 
        id_venta,
        fecha_venta, 
        (cantidad * precio_unitario) AS total, 
        'Presencial' AS canal
    FROM ventas 
    WHERE fecha_venta > '2024-03-10'
) AS consolidado
GROUP BY canal;
GO

-- Hallazgo: El canal Presencial concentra el 56,1% de los ingresos ($3.614,00 en 5 operaciones) frente a $2.830,00 de Online, marcando mayor concentración de ventas de alto ticket en la segunda quincena.


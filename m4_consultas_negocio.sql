/* =========================================================
   PROYECTO: Ventas_Tech_DB
   EMPRESA: TechStore
   DESCRIPCIÓN: Base de datos para análisis de ventas
   ========================================================= */


/* =========================================================
   1. SELECCIONAR BASE DE DATOS
   ========================================================= */

USE Ventas_Tech_DB;
GO


/* =========================================================
   2. ELIMINAR TABLAS SI YA EXISTEN
   Orden inverso de dependencias
   ========================================================= */

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;
GO


/* =========================================================
   3. CREAR TABLA CATEGORIAS
   ========================================================= */

CREATE TABLE categorias (
    id_categoria INT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200)
);
GO


/* =========================================================
   4. CREAR TABLA CLIENTES
   ========================================================= */

CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    ciudad VARCHAR(50),
    fecha_registro DATE NOT NULL
);
GO


/* =========================================================
   5. CREAR TABLA PRODUCTOS
   ========================================================= */

CREATE TABLE productos (
    id_producto INT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    id_categoria INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    activo TINYINT DEFAULT 1,

    FOREIGN KEY (id_categoria)
        REFERENCES categorias(id_categoria)
);
GO


/* =========================================================
   6. CREAR TABLA VENTAS
   ========================================================= */

CREATE TABLE ventas (
    id_venta INT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    fecha_venta DATE NOT NULL,

    FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente),

    FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);
GO


/* =========================================================
   7. INSERTAR CATEGORIAS
   ========================================================= */

INSERT INTO categorias
VALUES
(1, 'Computación', 'Laptops, PCs y monitores'),
(2, 'Accesorios', 'Periféricos y complementos'),
(3, 'Audio', 'Auriculares y parlantes'),
(4, 'Almacenamiento', 'Discos y memorias');
GO


/* =========================================================
   8. INSERTAR CLIENTES
   ========================================================= */

INSERT INTO clientes
VALUES
(1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
(2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
(3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
(4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
(5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');
GO


/* =========================================================
   9. INSERTAR PRODUCTOS
   ========================================================= */

INSERT INTO productos
VALUES
(1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
(2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
(3, 'Monitor 4K 27"',     1,  450.00, 12, 1),
(4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
(5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
(6, 'Teclado Mecánico',   2,   95.00, 40, 1);
GO


/* =========================================================
   10. INSERTAR VENTAS
   ========================================================= */

INSERT INTO ventas
VALUES
(1,  1, 1, 2, 1200.00, '2024-03-05'),
(2,  2, 2, 5,   28.00, '2024-03-06'),
(3,  3, 3, 1,  450.00, '2024-03-07'),
(4,  1, 4, 2,  120.00, '2024-03-08'),
(5,  4, 5, 3,  130.00, '2024-03-10'),
(6,  2, 6, 4,   95.00, '2024-03-11'),
(7,  5, 1, 1, 1200.00, '2024-03-12'),
(8,  3, 2, 8,   28.00, '2024-03-13'),
(9,  4, 4, 1,  120.00, '2024-03-14'),
(10, 5, 3, 2, 450.00, '2024-03-15');
GO


/* =========================================================
   11. VERIFICACION DE TABLAS
   ========================================================= */

SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;
GO


/* =========================================================
   12. VERIFICACION DE RELACIONES
   ========================================================= */

SELECT
    v.id_venta,
    c.nombre AS cliente,
    p.nombre_producto AS producto,
    v.cantidad,
    v.precio_unitario,
    v.fecha_venta
FROM ventas v
INNER JOIN clientes c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos p
    ON v.id_producto = p.id_producto;
GO
SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY MONTH(fecha_venta);
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC;
WITH ventas_mensuales AS (
    SELECT
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT
    mes,
    total_facturado,
    AVG(total_facturado) OVER () AS promedio_mensual,
    CASE
        WHEN total_facturado > AVG(total_facturado) OVER ()
            THEN 'Por encima'
        WHEN total_facturado < AVG(total_facturado) OVER ()
            THEN 'Por debajo'
        ELSE 'Igual al promedio'
    END AS comparacion
FROM ventas_mensuales
ORDER BY mes;

-- =========================================================
-- HALLAZGOS
-- =========================================================

-- Hallazgo 1: Durante marzo se registraron 10 pedidos, alcanzando
-- una facturación total de $6.444 y un ticket promedio de $644,40.

-- Hallazgo 2: El producto 1 fue el que más facturó en marzo,
-- con $3.600 generados por la venta de 3 unidades, representando
-- aproximadamente el 55,9% de la facturación total.

-- Hallazgo 3: Los 5 clientes realizaron más de un pedido durante marzo.
-- El cliente 1 fue el que más gastó, con un total de $2.640 en 2 pedidos.
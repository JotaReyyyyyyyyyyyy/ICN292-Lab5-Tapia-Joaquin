DROP DATABASE IF EXISTS andesbike;
CREATE DATABASE andesbike;
USE andesbike;

-- 1. Estructura de la base
CREATE TABLE tiendas (
    id_tienda INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL,
    comuna VARCHAR(50) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE vendedores (
    id_vendedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    id_tienda INT NULL,
    fecha_ingreso DATE NOT NULL,
    CONSTRAINT fk_vendedores_tiendas FOREIGN KEY (id_tienda)
        REFERENCES tiendas (id_tienda)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE bicicletas (
    id_bicicleta INT AUTO_INCREMENT PRIMARY KEY,
    modelo VARCHAR(60) NOT NULL,
    categoria ENUM('Eléctrica', 'Infantil', 'Montaña', 'Ruta', 'Urbana') NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_bicicletas_precio CHECK (precio > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_vendedor INT NOT NULL,
    id_bicicleta INT NOT NULL,
    fecha DATE NOT NULL,
    unidades INT NOT NULL,
    CONSTRAINT chk_ventas_unidades CHECK (unidades > 0),
    CONSTRAINT fk_ventas_vendedores FOREIGN KEY (id_vendedor)
        REFERENCES vendedores (id_vendedor),
    CONSTRAINT fk_ventas_bicicletas FOREIGN KEY (id_bicicleta)
        REFERENCES bicicletas (id_bicicleta)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- 2. Carga oficial
INSERT INTO tiendas (nombre, comuna) VALUES
    ('Andes Providencia', 'Providencia'),
    ('Andes Maipú', 'Maipú'),
    ('Andes Concepción', 'Concepción'),
    ('Andes La Serena', 'La Serena');

INSERT INTO vendedores (nombre, id_tienda, fecha_ingreso) VALUES
    ('Camila Ortiz', 1, '2024-06-20'),
    ('Diego Fuentes', 1, '2024-01-15'),
    ('Javiera Soto', 2, '2023-07-24'),
    ('Matías Herrera', 2, '2024-01-15'),
    ('Paula Riquelme', 3, '2022-11-02'),
    ('Ignacio Vera', 3, '2024-08-19'),
    ('Fernanda Lillo', 1, '2025-02-03'),
    ('Rubén Castro', NULL, '2025-06-10');

INSERT INTO bicicletas (modelo, categoria, precio) VALUES
    ('Cordillera 29', 'Montaña', 549990.00),
    ('Ruta Austral', 'Ruta', 899990.00),
    ('Urbana Pro', 'Urbana', 329990.00),
    ('Pequeño Andes', 'Infantil', 149990.00),
    ('Volt City', 'Eléctrica', 1249990.00),
    ('Trail Master', 'Montaña', 749990.00),
    ('Urbana Lite', 'Urbana', 229990.00),
    ('Sprint R7', 'Ruta', 1099990.00);

INSERT INTO ventas (id_vendedor, id_bicicleta, fecha, unidades) VALUES
    (1, 1, '2025-03-04', 2),
    (1, 3, '2025-03-18', 1),
    (1, 5, '2025-04-02', 1),
    (2, 2, '2025-03-04', 1),
    (2, 1, '2025-04-11', 3),
    (2, 7, '2025-05-06', 2),
    (3, 4, '2025-03-21', 4),
    (3, 3, '2025-04-15', 2),
    (3, 6, '2025-05-20', 1),
    (4, 1, '2025-03-27', 1),
    (4, 5, '2025-05-09', 2),
    (5, 2, '2025-04-08', 1),
    (5, 6, '2025-04-23', 2),
    (5, 4, '2025-06-02', 5),
    (6, 3, '2025-05-13', 3),
    (6, 7, '2025-06-17', 1),
    (6, 1, '2025-06-24', 2),
    (1, 6, '2025-06-30', 1);

-- 3. Consultas

-- Consulta 1
SELECT v.nombre, COUNT(ve.id_venta) AS cantidad_ventas
FROM vendedores AS v
LEFT JOIN ventas AS ve ON ve.id_vendedor = v.id_vendedor
GROUP BY v.id_vendedor, v.nombre
ORDER BY cantidad_ventas DESC, v.nombre;

-- Consulta 2
SELECT t.nombre AS tienda,
       COUNT(ve.id_venta) AS cantidad_ventas,
       COALESCE(SUM(ve.unidades), 0) AS unidades_vendidas
FROM tiendas AS t
LEFT JOIN vendedores AS v ON v.id_tienda = t.id_tienda
LEFT JOIN ventas AS ve ON ve.id_vendedor = v.id_vendedor
GROUP BY t.id_tienda, t.nombre
ORDER BY unidades_vendidas DESC, t.nombre;

-- Consulta 3
SELECT t.nombre, t.comuna
FROM tiendas AS t
LEFT JOIN vendedores AS v ON v.id_tienda = t.id_tienda
WHERE v.id_vendedor IS NULL;

-- Consulta 4
SELECT b.modelo
FROM bicicletas AS b
LEFT JOIN ventas AS ve
       ON ve.id_bicicleta = b.id_bicicleta
      AND ve.fecha >= '2025-06-01' AND ve.fecha < '2025-07-01'
WHERE ve.id_venta IS NULL
ORDER BY b.modelo;

-- Consulta 5
SELECT v.nombre, t.nombre AS tienda
FROM vendedores AS v
LEFT JOIN tiendas AS t ON t.id_tienda = v.id_tienda
LEFT JOIN ventas AS ve ON ve.id_vendedor = v.id_vendedor
WHERE ve.id_venta IS NULL
ORDER BY v.nombre;

-- Consulta 6
SELECT a.nombre AS vendedor_antiguo, a.fecha_ingreso AS ingreso_antiguo,
       b.nombre AS vendedor_nuevo, b.fecha_ingreso AS ingreso_nuevo,
       t.nombre AS tienda
FROM vendedores AS a
JOIN vendedores AS b
  ON b.id_tienda = a.id_tienda
 AND (a.fecha_ingreso < b.fecha_ingreso
      OR (a.fecha_ingreso = b.fecha_ingreso AND a.id_vendedor < b.id_vendedor))
JOIN tiendas AS t ON t.id_tienda = a.id_tienda
ORDER BY t.id_tienda, a.fecha_ingreso, b.fecha_ingreso;

-- Consulta 7
SELECT t.nombre AS tienda, SUM(ve.unidades * b.precio) AS monto_montana_ruta
FROM tiendas AS t
JOIN vendedores AS v ON v.id_tienda = t.id_tienda
JOIN ventas AS ve ON ve.id_vendedor = v.id_vendedor
JOIN bicicletas AS b ON b.id_bicicleta = ve.id_bicicleta
WHERE b.categoria IN ('Montaña', 'Ruta')
GROUP BY t.id_tienda, t.nombre
HAVING SUM(ve.unidades * b.precio) > 2000000
ORDER BY monto_montana_ruta DESC;

-- Consulta 8
SELECT modelo, precio
FROM bicicletas
WHERE precio > (SELECT AVG(precio) FROM bicicletas)
ORDER BY precio DESC;

SELECT AVG(precio) AS promedio_catalogo
FROM bicicletas;

-- Consulta 9
SELECT v.nombre, AVG(ve.unidades) AS promedio_unidades
FROM vendedores AS v
JOIN ventas AS ve ON ve.id_vendedor = v.id_vendedor
GROUP BY v.id_vendedor, v.nombre
HAVING AVG(ve.unidades) > (SELECT AVG(unidades) FROM ventas)
ORDER BY promedio_unidades DESC, v.nombre;

-- Consulta 10
SELECT v.nombre, SUM(ve.unidades * b.precio) AS monto_total
FROM vendedores AS v
LEFT JOIN ventas AS ve ON ve.id_vendedor = v.id_vendedor
LEFT JOIN bicicletas AS b ON b.id_bicicleta = ve.id_bicicleta
GROUP BY v.id_vendedor, v.nombre
ORDER BY monto_total DESC;

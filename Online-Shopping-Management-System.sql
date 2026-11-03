
CREATE DATABASE IF NOT EXISTS shopping;
USE shopping;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(50),
    price DECIMAL(10,2),
    stock INT
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO customers (name, city)
VALUES
('Rahul', 'Kangra'),
('Aman', 'Chandigarh'),
('Priya', 'Delhi'),
('Neha', 'Shimla');

INSERT INTO products (product_name, price, stock)
VALUES
('Laptop', 50000, 10),
('Mobile', 20000, 15),
('Headphones', 1500, 20),
('Keyboard', 800, 25);

INSERT INTO orders (customer_id, product_id, quantity)
VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 1);

-- DASHBOARD

SELECT 'Total Customers' AS Dashboard, COUNT(*) AS Value
FROM customers
UNION ALL
SELECT 'Total Products', COUNT(*)
FROM products
UNION ALL
SELECT 'Total Orders', COUNT(*)
FROM orders;

SELECT SUM(o.quantity * p.price) AS Total_Sales
FROM orders o
JOIN products p ON o.product_id = p.id;

-- COMPLETE ORDER DETAILS

SELECT
    c.name AS Customer,
    p.product_name AS Product,
    p.price AS Price,
    o.quantity AS Quantity,
    p.price * o.quantity AS Total
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id;

-- LOW STOCK PRODUCTS

SELECT *
FROM products
WHERE stock < 15;

-- STORED PROCEDURE

DELIMITER //

CREATE PROCEDURE ShowOrders()
BEGIN
    SELECT
        c.name AS Customer,
        p.product_name AS Product,
        o.quantity AS Quantity,
        p.price * o.quantity AS Total
    FROM orders o
    JOIN customers c ON o.customer_id = c.id
    JOIN products p ON o.product_id = p.id;
END //

DELIMITER ;

CALL ShowOrders();

-- USER-DEFINED FUNCTION

DELIMITER //

CREATE FUNCTION CalculateTotal(
    p_price DECIMAL(10,2),
    p_quantity INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_price * p_quantity;
END //

DELIMITER ;

SELECT
    product_name,
    price,
    CalculateTotal(price, 2) AS Total_For_Two
FROM products;

-- EXPLICIT CURSOR

DELIMITER //

CREATE PROCEDURE ShowProductCursor()
BEGIN
    DECLARE finished INT DEFAULT 0;
    DECLARE p_name VARCHAR(50);
    DECLARE p_price DECIMAL(10,2);

    DECLARE product_cursor CURSOR FOR
        SELECT product_name, price
        FROM products;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET finished = 1;

    DROP TEMPORARY TABLE IF EXISTS cursor_output;

    CREATE TEMPORARY TABLE cursor_output (
        product_name VARCHAR(50),
        price DECIMAL(10,2)
    );

    OPEN product_cursor;

    read_loop: LOOP
        FETCH product_cursor INTO p_name, p_price;

        IF finished = 1 THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO cursor_output
        VALUES (p_name, p_price);
    END LOOP;

    CLOSE product_cursor;

    SELECT * FROM cursor_output;
END //

DELIMITER ;

CALL ShowProductCursor();

-- TOP SELLING PRODUCTS

SELECT
    p.product_name,
    SUM(o.quantity) AS Total_Sold
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY p.id, p.product_name
ORDER BY Total_Sold DESC;
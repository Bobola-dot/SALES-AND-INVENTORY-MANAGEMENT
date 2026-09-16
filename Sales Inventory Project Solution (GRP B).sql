

CREATE DATABASE sales_inventory_system;

USE sales_inventory_system;


-- 1. Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    city VARCHAR(50)
);


-- 2. Suppliers table
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100),
    contact_email VARCHAR(100)
);


-- 3. Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);


-- 4. Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


-- 5. Order details table
CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- 6. Payments table
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


-- ============================================================
-- PART 2: DATA INSERTION
-- ============================================================
-- The project requires:
-- 20 customers
-- 10 suppliers
-- 30 products
-- 40 orders
-- 60 order details
-- 40 payments
--
-- Insert your project data here.
-- ============================================================


-- ============================================================
-- PART 3: SQL QUERY QUESTIONS
-- ============================================================


-- ============================================================
-- QUESTION 1
-- Display all customers and their orders.
-- ============================================================

SELECT
    customers.first_name,
    customers.last_name,
    orders.order_id,
    orders.order_date
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id;


-- ============================================================
-- QUESTION 2
-- List all products with their suppliers.
-- ============================================================

SELECT
    products.product_name,
    products.category,
    products.price,
    suppliers.supplier_name
FROM products
JOIN suppliers
    ON products.supplier_id = suppliers.supplier_id;


-- ============================================================
-- QUESTION 3
-- Show total number of orders made by each customer.
-- ============================================================

SELECT
    customers.first_name,
    customers.last_name,
    COUNT(orders.order_id) AS Total_Orders
FROM customers
LEFT JOIN orders
    ON customers.customer_id = orders.customer_id
GROUP BY
    customers.customer_id,
    customers.first_name,
    customers.last_name;


-- ============================================================
-- QUESTION 4
-- Find the total sales amount per day.
-- ============================================================

SELECT
    orders.order_date,
    SUM(order_details.quantity * products.price) AS Total_Sales
FROM orders
JOIN order_details
    ON orders.order_id = order_details.order_id
JOIN products
    ON order_details.product_id = products.product_id
GROUP BY orders.order_date
ORDER BY orders.order_date;


-- ============================================================
-- QUESTION 5
-- Find the total revenue generated.
-- ============================================================

SELECT
    SUM(order_details.quantity * products.price) AS Total_Revenue
FROM order_details
JOIN products
    ON order_details.product_id = products.product_id;


-- ============================================================
-- QUESTION 6
-- List the top 5 best-selling products.
-- ============================================================

SELECT
    products.product_name,
    SUM(order_details.quantity) AS Total_Quantity_Sold
FROM products
JOIN order_details
    ON products.product_id = order_details.product_id
GROUP BY
    products.product_id,
    products.product_name
ORDER BY Total_Quantity_Sold DESC
LIMIT 5;


-- ============================================================
-- QUESTION 7
-- Show customers who spent more than a specified amount.
-- Change 100000 to the amount you want.
-- ============================================================

SELECT
    customers.first_name,
    customers.last_name,
    SUM(order_details.quantity * products.price) AS Total_Spent
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
JOIN order_details
    ON orders.order_id = order_details.order_id
JOIN products
    ON order_details.product_id = products.product_id
GROUP BY
    customers.customer_id,
    customers.first_name,
    customers.last_name
HAVING Total_Spent > 100000;


-- ============================================================
-- QUESTION 8
-- Find the average order value.
-- ============================================================

SELECT
    AVG(Order_Total) AS Average_Order_Value
FROM
(
    SELECT
        orders.order_id,
        SUM(order_details.quantity * products.price) AS Order_Total
    FROM orders
    JOIN order_details
        ON orders.order_id = order_details.order_id
    JOIN products
        ON order_details.product_id = products.product_id
    GROUP BY orders.order_id
) AS Order_Summary;


-- ============================================================
-- QUESTION 9
-- Display products that have never been sold.
-- ============================================================

SELECT
    products.product_name
FROM products
LEFT JOIN order_details
    ON products.product_id = order_details.product_id
WHERE order_details.product_id IS NULL;


-- ============================================================
-- QUESTION 10
-- Find customers who have never placed an order.
-- ============================================================

SELECT
    customers.first_name,
    customers.last_name
FROM customers
LEFT JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE orders.customer_id IS NULL;


-- ============================================================
-- QUESTION 11
-- Show orders that contain more than 3 products.
-- ============================================================

SELECT
    orders.order_id,
    SUM(order_details.quantity) AS Total_Products
FROM orders
JOIN order_details
    ON orders.order_id = order_details.order_id
GROUP BY orders.order_id
HAVING SUM(order_details.quantity) > 3;


-- ============================================================
-- PART 4: BUSINESS & REPORTING QUESTIONS
-- ============================================================


-- ============================================================
-- QUESTION 12
-- Generate a report showing:
-- customer name, order date, product name,
-- quantity, and amount paid.
-- ============================================================

SELECT
    CONCAT(customers.first_name, ' ', customers.last_name)
        AS Customer_Name,
    orders.order_date,
    products.product_name,
    order_details.quantity,
    payments.amount AS Amount_Paid
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
JOIN order_details
    ON orders.order_id = order_details.order_id
JOIN products
    ON order_details.product_id = products.product_id
JOIN payments
    ON orders.order_id = payments.order_id;


-- ============================================================
-- QUESTION 13
-- Generate a summary report of:
-- total customers, total products,
-- total orders, and total revenue.
-- ============================================================

SELECT
    (SELECT COUNT(customer_id) FROM customers)
        AS Total_Customers,

    (SELECT COUNT(product_id) FROM products)
        AS Total_Products,

    (SELECT COUNT(order_id) FROM orders)
        AS Total_Orders,

    (SELECT SUM(amount) FROM payments)
        AS Total_Revenue;


-- ============================================================
-- QUESTION 14
-- Identify loyal customers
-- (customers with the highest number of orders).
-- ============================================================

SELECT
    customers.first_name,
    customers.last_name,
    COUNT(orders.order_id) AS Total_Orders
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
GROUP BY
    customers.customer_id,
    customers.first_name,
    customers.last_name
ORDER BY Total_Orders DESC
LIMIT 5;


-- ============================================================
-- QUESTION 15
-- Identify slow-moving products
-- (products with very low sales).
-- ============================================================

SELECT
    products.product_name,
    COALESCE(SUM(order_details.quantity), 0)
        AS Total_Quantity_Sold
FROM products
LEFT JOIN order_details
    ON products.product_id = order_details.product_id
GROUP BY
    products.product_id,
    products.product_name
ORDER BY Total_Quantity_Sold ASC;


-- ============================================================
-- QUESTION 16
-- Recommend products that should be restocked based on sales.
-- ============================================================

SELECT
    products.product_name,
    SUM(order_details.quantity) AS Total_Quantity_Sold
FROM products
JOIN order_details
    ON products.product_id = order_details.product_id
GROUP BY
    products.product_id,
    products.product_name
ORDER BY Total_Quantity_Sold DESC
LIMIT 10;


-- ============================================================
-- QUESTION 17
-- Recommend the best performing supplier.
-- ============================================================

SELECT
    suppliers.supplier_name,
    SUM(order_details.quantity * products.price)
        AS Total_Revenue
FROM suppliers
JOIN products
    ON suppliers.supplier_id = products.supplier_id
JOIN order_details
    ON products.product_id = order_details.product_id
GROUP BY
    suppliers.supplier_id,
    suppliers.supplier_name
ORDER BY Total_Revenue DESC
LIMIT 1;



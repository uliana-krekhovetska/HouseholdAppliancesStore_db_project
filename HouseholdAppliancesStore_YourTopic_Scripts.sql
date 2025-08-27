CREATE DATABASE appliances_store;
CREATE SCHEMA store_data;

CREATE TABLE IF NOT EXISTS store_data.categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS store_data.brands (
    brand_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    country VARCHAR(50),
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS store_data.products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    brand_id INT NOT NULL,
    model VARCHAR(50) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL,
    description TEXT,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (brand_id) REFERENCES brands (brand_id),
    FOREIGN KEY (category_id) REFERENCES categories (category_id),
    UNIQUE (brand_id, model)
);

ALTER TABLE store_data.products ADD CONSTRAINT chk_product_price CHECK (price > 0);
ALTER TABLE store_data.products ADD CONSTRAINT chk_product_stock CHECK (stock_quantity >= 0);

CREATE TABLE IF NOT EXISTS store_data.customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(100) GENERATED ALWAYS AS (First_Name || ' ' || Last_Name) STORED NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE store_data.customers ADD CONSTRAINT chk_customer_email CHECK (email LIKE '%@%.%');

CREATE TABLE IF NOT EXISTS store_data.employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(100) GENERATED ALWAYS AS (First_Name || ' ' || Last_Name) STORED NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT null,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE store_data.employees ADD CONSTRAINT chk_employee_email CHECK (email LIKE '%@%.%');

CREATE TABLE IF NOT EXISTS store_data.orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL,
    delivery_date DATE,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees (employee_id)
);

ALTER TABLE store_data.orders ADD CONSTRAINT chk_order_status CHECK (status IN ('pending', 'shipped', 'delivered', 'cancelled'));
ALTER TABLE store_data.orders ADD CONSTRAINT chk_delivery_date CHECK (delivery_date >= order_date);
ALTER TABLE store_data.orders ADD CONSTRAINT chk_total_amount CHECK (total_amount > 0);

CREATE TABLE IF NOT EXISTS store_data.order_details (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders (order_id),
    FOREIGN KEY (product_id) REFERENCES products (product_id)
);

ALTER TABLE store_data.order_details ADD CONSTRAINT chk_order_quantity CHECK (quantity > 0);
ALTER TABLE store_data.order_details ADD CONSTRAINT chk_unit_price CHECK (unit_price > 0);

CREATE TABLE IF NOT EXISTS store_data.suppliers (
    supplier_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL UNIQUE,
    contact_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE store_data.suppliers ADD CONSTRAINT chk_supplier_email CHECK (email LIKE '%@%.%');

CREATE TABLE IF NOT EXISTS store_data.procurement (
    procurement_id SERIAL PRIMARY KEY,
    supplier_id INT NOT NULL,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    delivery_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'ordered',
    total_cost DECIMAL(10,2) NOT NULL,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

ALTER TABLE store_data.procurement ADD CONSTRAINT chk_procurement_status CHECK (status IN ('ordered', 'received', 'cancelled'));
ALTER TABLE store_data.procurement ADD CONSTRAINT chk_procurement_dates CHECK (delivery_date >= order_date);
ALTER TABLE store_data.procurement ADD CONSTRAINT chk_procurement_order_date CHECK (order_date >= '2024-07-01');

CREATE TABLE IF NOT EXISTS store_data.procurement_details (
    procurement_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (procurement_id, product_id),
    FOREIGN KEY (procurement_id) REFERENCES procurement(procurement_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

ALTER TABLE store_data.procurement_details ADD CONSTRAINT chk_procurement_quantity CHECK (quantity > 0);
ALTER TABLE store_data.procurement_details ADD CONSTRAINT chk_procurement_unit_cost CHECK (unit_cost > 0);

--inserting records into categories table

INSERT INTO store_data.categories (name)
VALUES 
    ('Refrigerators'),
    ('Washing Machines'),
    ('Dishwashers'),
    ('Ovens'),
    ('Microwaves'),
    ('Vacuum Cleaners')
ON CONFLICT (name) DO NOTHING
RETURNING category_id;

--inserting records into brands table

INSERT INTO store_data.brands (name, country)
VALUES
    ('Samsung', 'South Korea'),
    ('LG', 'South Korea'),
    ('Whirlpool', 'USA'),
    ('Bosch', 'Germany'),
    ('Electrolux', 'Sweden'),
    ('Dyson', 'UK')
ON CONFLICT (name) DO nothing
RETURNING brand_id;

--inserting records into products table

INSERT INTO store_data.products (name, brand_id, model, category_id, price, stock_quantity, description)
VALUES 
    ('Frost-Free Refrigerator', (SELECT brand_id FROM store_data.brands WHERE UPPER(name) = 'SAMSUNG'), 'RF28', (SELECT category_id FROM store_data.categories WHERE UPPER(name) = 'REFRIGERATORS'), 999.99, 10, 'Large capacity frost-free refrigerator'),
    ('Front Load Washer', (SELECT brand_id FROM store_data.brands WHERE UPPER(name) = 'LG'), 'WM3900', (SELECT category_id FROM store_data.categories WHERE UPPER(name) = 'WASHING MACHINES'), 799.99, 15, 'Energy-efficient front load washer'),
    ('Built-in Dishwasher', (SELECT brand_id FROM store_data.brands WHERE UPPER(name) = 'BOSCH'), 'SHX878', (SELECT category_id FROM store_data.categories WHERE UPPER(name) = 'DISHWASHERS'), 749.99, 8, 'Quiet and efficient built-in dishwasher'),
    ('Electric Range Oven', (SELECT brand_id FROM store_data.brands WHERE UPPER(name) = 'WHIRLPOOL'), 'WFE535', (SELECT category_id FROM store_data.categories WHERE UPPER(name) = 'OVENS'), 649.99, 12, 'Freestanding electric range with oven'),
    ('Countertop Microwave', (SELECT brand_id FROM store_data.brands WHERE UPPER(name) = 'SAMSUNG'), 'MS14K', (SELECT category_id FROM store_data.categories WHERE UPPER(name) = 'MICROWAVES'), 99.99, 20, 'Compact countertop microwave'),
    ('Cordless Stick Vacuum', (SELECT brand_id FROM store_data.brands WHERE UPPER(name) = 'DYSON'), 'V11', (SELECT category_id FROM store_data.categories WHERE UPPER(name) = 'VACUUM CLEANERS'), 499.99, 25, 'Powerful cordless stick vacuum cleaner')
ON CONFLICT (brand_id, model) DO nothing
RETURNING product_id;

--inserting records into employees table

INSERT INTO store_data.employees (first_name, last_name, email, phone, position, hire_date)
VALUES
    ('Michael', 'Scott', 'michael@appliance.com', '+1111222333', 'Manager', '2024-07-15'),
    ('Dwight', 'Schrute', 'dwight@appliance.com', '+1222333444', 'Assistant Manager', '2024-07-20'),
    ('Jim', 'Halpert', 'jim@appliance.com', '+1333444555', 'Sales Assistant', '2024-08-01'),
    ('Pam', 'Beesly', 'pam@appliance.com', '+1444555666', 'Sales Assistant', '2024-08-15'),
    ('Angela', 'Martin', 'angela@appliance.com', '+1555666777', 'Sales Assistant', '2024-09-01'),
    ('Kevin', 'Malone', 'kevin@appliance.com', '+1666777888', 'Accountant', '2024-09-15')
ON CONFLICT (email) DO NOTHING
RETURNING employee_id;

--inserting records into customers table

INSERT INTO store_data.customers (first_name, last_name, email, phone)
VALUES
    ('John', 'Doe', 'john.doe@email.com', '+1111111111'),
    ('Jane', 'Smith', 'jane.smith@email.com', '+2222222222'),
    ('Bob', 'Johnson', 'bob.johnson@email.com', '+3333333333'),
    ('Alice', 'Brown', 'alice.brown@email.com', '+4444444444'),
    ('Charlie', 'Davis', 'charlie.davis@email.com', '+5555555555'),
    ('Eva', 'Wilson', 'eva.wilson@email.com', '+6666666666')
ON CONFLICT (email) DO nothing
RETURNING customer_id;

--inserting records into suppliers table

INSERT INTO store_data.suppliers (company_name, contact_name, email, phone, address)
VALUES
    ('Global Appliances', 'John Doe', 'john@globalappliances.com', '+1234567890', '123 Main St, Texas, USA'),
    ('Tech Distributors', 'Jane Smith', 'jane@techdist.com', '+1987654321', '456 Oak Rd, Texas, USA'),
    ('Home Essentials', 'Bob Johnson', 'bob@homeessentials.com', '+1122334455', '789 Pine Ave, Texas, USA'),
    ('Appliance World', 'Alice Brown', 'alice@applianceworld.com', '+1555666777', '321 Elm St, Texas, USA'),
    ('Kitchen Kings', 'Charlie Davis', 'charlie@kitchenkings.com', '+1777888999', '654 Maple Ln, Texas, USA'),
    ('Electro Supplies', 'Eva Wilson', 'eva@electrosupplies.com', '+1444555666', '987 Birch Rd, Texas, USA')
ON CONFLICT (email) DO NOTHING
RETURNING supplier_id;

--inserting records into order_details table

INSERT INTO store_data.order_details (order_id, product_id, quantity, unit_price)
SELECT ord.order_id, prd.product_id, vir.quantity, vir.unit_price
FROM (
    VALUES
    ('JOHN.DOE@EMAIL.COM', '2024-09-26 22:18:21'::timestamp, 'FROST-FREE REFRIGERATOR', 1, 999.99),
    ('JOHN.DOE@EMAIL.COM', '2024-09-26 22:18:21'::timestamp, 'COUNTERTOP MICROWAVE', 1, 99.99),
    ('JANE.SMITH@EMAIL.COM', '2024-10-15 22:18:21'::timestamp, 'FRONT LOAD WASHER', 1, 799.99),
    ('BOB.JOHNSON@EMAIL.COM', '2024-10-03 22:18:21'::timestamp, 'BUILT-IN DISHWASHER', 1, 749.99),
    ('BOB.JOHNSON@EMAIL.COM', '2024-10-03 22:18:21'::timestamp, 'ELECTRIC RANGE OVEN', 1, 649.99),
    ('ALICE.BROWN@EMAIL.COM', '2024-09-20 22:18:21'::timestamp, 'COUNTERTOP MICROWAVE', 2, 99.99),
    ('ALICE.BROWN@EMAIL.COM', '2024-09-20 22:18:21'::timestamp, 'CORDLESS STICK VACUUM', 1, 499.99)
) AS vir(customer_email, order_date, product_name, quantity, unit_price)
JOIN store_data.customers cst ON UPPER(cst.email) = UPPER(vir.customer_email)
JOIN store_data.orders ord ON ord.customer_id = cst.customer_id AND ord.order_date = vir.order_date
JOIN store_data.products prd ON UPPER(prd.name) = UPPER(vir.product_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM store_data.order_details existing
    WHERE existing.order_id = ord.order_id
    AND existing.product_id = prd.product_id
)
RETURNING order_id, product_id;

--inserting records into orders table

INSERT INTO store_data.orders (customer_id, employee_id, order_date, status, total_amount, delivery_date)
SELECT 
    cst.customer_id,
    emp.employee_id,
    vir.order_date,
    vir.status,
    vir.total_amount,
    vir.delivery_date
FROM (
    VALUES
    ('JOHN.DOE@EMAIL.COM', 'MICHAEL@APPLIANCE.COM', '2024-09-26 22:18:21'::timestamp, 'delivered', 852.05, '2024-10-18'::date),
    ('JANE.SMITH@EMAIL.COM', 'MICHAEL@APPLIANCE.COM', '2024-10-15 22:18:21'::timestamp, 'pending', 971.91, '2024-10-20'::date),
    ('BOB.JOHNSON@EMAIL.COM', 'PAM@APPLIANCE.COM', '2024-10-03 22:18:21'::timestamp, 'delivered', 586.96, '2024-10-26'::date),
    ('ALICE.BROWN@EMAIL.COM', 'KEVIN@APPLIANCE.COM', '2024-09-20 22:18:21'::timestamp, 'shipped', 655.44, '2024-10-22'::date),
    ('CHARLIE.DAVIS@EMAIL.COM', 'JIM@APPLIANCE.COM', '2024-09-22 22:18:21'::timestamp, 'pending', 286.65, '2024-10-26'::date),
    ('EVA.WILSON@EMAIL.COM', 'KEVIN@APPLIANCE.COM', '2024-10-01 22:18:21'::timestamp, 'shipped', 827.27, '2024-10-26'::date)
) AS vir(customer_email, employee_email, order_date, status, total_amount, delivery_date)
JOIN store_data.customers cst ON UPPER(cst.email) = UPPER(vir.customer_email)
JOIN store_data.employees emp ON UPPER(emp.email) = UPPER(vir.employee_email)
WHERE NOT EXISTS (
    SELECT 1
    FROM store_data.orders existing
    WHERE existing.customer_id = cst.customer_id
    AND existing.order_date = vir.order_date
)
RETURNING order_id;

--inserting records into procurement table

INSERT INTO store_data.procurement (supplier_id, order_date, delivery_date, status, total_cost)
SELECT vir.supplier_id, vir.order_date::DATE, vir.delivery_date::DATE, vir.status, vir.total_cost
FROM (VALUES
    ((SELECT supplier_id FROM store_data.suppliers WHERE UPPER(company_name) = 'GLOBAL APPLIANCES'),
     '2024-09-15', '2024-09-25', 'received', 15000.00),
    ((SELECT supplier_id FROM store_data.suppliers WHERE UPPER(company_name) = 'TECH DISTRIBUTORS'),
     '2024-09-20', '2024-10-01', 'received', 22000.50),
    ((SELECT supplier_id FROM store_data.suppliers WHERE UPPER(company_name) = 'HOME ESSENTIALS'),
     '2024-09-25', '2024-10-05', 'ordered', 18500.75),
    ((SELECT supplier_id FROM store_data.suppliers WHERE UPPER(company_name) = 'APPLIANCE WORLD'),
     '2024-10-01', '2024-10-10', 'ordered', 30000.00),
    ((SELECT supplier_id FROM store_data.suppliers WHERE UPPER(company_name) = 'KITCHEN KINGS'),
     '2024-10-05', '2024-10-15', 'ordered', 12500.25),
    ((SELECT supplier_id FROM store_data.suppliers WHERE UPPER(company_name) = 'ELECTRO SUPPLIES'),
     '2024-10-10', '2024-10-20', 'cancelled', 27500.80)
) AS vir(supplier_id, order_date, delivery_date, status, total_cost)
WHERE NOT EXISTS (
    SELECT 1
    FROM store_data.procurement prcm
    WHERE prcm.supplier_id = vir.supplier_id AND prcm.order_date = vir.order_date::DATE
)
returning procurement_id;

--inserting records into procurement_details table

INSERT INTO store_data.procurement_details (procurement_id, product_id, quantity, unit_cost)
SELECT 
    vir.procurement_id,
    vir.product_id,
    vir.quantity,
    vir.unit_cost
FROM (
    VALUES
    ((SELECT procurement_id FROM store_data.procurement WHERE supplier_id = (SELECT supplier_id FROM store_data.suppliers WHERE UPPER(company_name) = 'GLOBAL APPLIANCES') AND order_date = '2024-09-15'::DATE),
     (SELECT product_id FROM store_data.products WHERE UPPER(name) = 'FROST-FREE REFRIGERATOR'),
     10, 800.00),
    ((SELECT procurement_id FROM store_data.procurement WHERE supplier_id = (SELECT supplier_id FROM store_data.suppliers WHERE UPPER(company_name) = 'TECH DISTRIBUTORS') AND order_date = '2024-09-20'::DATE),
     (SELECT product_id FROM store_data.products WHERE UPPER(name) = 'FRONT LOAD WASHER'),
     15, 600.00),
    ((SELECT procurement_id FROM store_data.procurement WHERE supplier_id = (SELECT supplier_id FROM store_data.suppliers WHERE UPPER(company_name) = 'HOME ESSENTIALS') AND order_date = '2024-09-25'::DATE),
     (SELECT product_id FROM store_data.products WHERE UPPER(name) = 'BUILT-IN DISHWASHER'),
     8, 550.00),
    ((SELECT procurement_id FROM store_data.procurement WHERE supplier_id = (SELECT supplier_id FROM store_data.suppliers WHERE UPPER(company_name) = 'APPLIANCE WORLD') AND order_date = '2024-10-01'::DATE),
     (SELECT product_id FROM store_data.products WHERE UPPER(name) = 'ELECTRIC RANGE OVEN'),
     12, 500.00),
    ((SELECT procurement_id FROM store_data.procurement WHERE supplier_id = (SELECT supplier_id FROM store_data.suppliers WHERE UPPER(company_name) = 'KITCHEN KINGS') AND order_date = '2024-10-05'::DATE),
     (SELECT product_id FROM store_data.products WHERE UPPER(name) = 'COUNTERTOP MICROWAVE'),
     20, 75.00),
    ((SELECT procurement_id FROM store_data.procurement WHERE supplier_id = (SELECT supplier_id FROM store_data.suppliers WHERE UPPER(company_name) = 'ELECTRO SUPPLIES') AND order_date = '2024-10-10'::DATE),
     (SELECT product_id FROM store_data.products WHERE UPPER(name) = 'CORDLESS STICK VACUUM'),
     25, 400.00)
) AS vir(procurement_id, product_id, quantity, unit_cost)
WHERE NOT EXISTS (
    SELECT 1
    FROM store_data.procurement_details procdet
    WHERE procdet.procurement_id = vir.procurement_id
    AND procdet.product_id = vir.product_id
)
RETURNING product_id, procurement_id;

-- Function that updates data in suppliers table based on its primary key i.e. supplier_id

CREATE OR REPLACE FUNCTION store_data.update_supplier( 
    p_supplier_id INT,
    p_column_name TEXT,
    p_new_value TEXT
)
RETURNS TABLE (
    company_name VARCHAR(100),
    contact_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT
) AS $$
BEGIN
    IF p_column_name = 'company_name' THEN
        UPDATE store_data.suppliers 
        SET company_name = p_new_value 
        WHERE supplier_id = p_supplier_id;
    ELSIF p_column_name = 'contact_name' THEN
        UPDATE store_data.suppliers 
        SET contact_name = p_new_value 
        WHERE supplier_id = p_supplier_id;
    ELSIF p_column_name = 'email' THEN
        UPDATE store_data.suppliers 
        SET email = p_new_value 
        WHERE supplier_id = p_supplier_id;
    ELSIF p_column_name = 'phone' THEN
        UPDATE store_data.suppliers 
        SET phone = p_new_value 
        WHERE supplier_id = p_supplier_id;
    ELSIF p_column_name = 'address' THEN
        UPDATE store_data.suppliers 
        SET address = p_new_value 
        WHERE supplier_id = p_supplier_id;
    ELSE
        RAISE EXCEPTION 'Invalid column name: %', p_column_name;
    END IF;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No supplier found with ID: %', p_supplier_id;
    END IF;

    RETURN QUERY
    SELECT spl.company_name, 
           spl.contact_name, 
           spl.email, 
           spl.phone, 
           spl.address
    FROM store_data.suppliers spl
    WHERE spl.supplier_id = p_supplier_id;
END;
$$
 LANGUAGE plpgsql; 
 
 SELECT * FROM store_data.update_supplier(1, 'contact_name', 'Adriana Winston');

-- Function that adds a new order to orders table 

CREATE OR REPLACE FUNCTION store_data.add_order(
    p_customer_email VARCHAR(100),
    p_employee_email VARCHAR(100),
    p_total_amount DECIMAL(10, 2),
    p_order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    p_status VARCHAR(20) DEFAULT 'pending'
)
RETURNS VOID AS $$
DECLARE
    v_customer_id INT;
    v_employee_id INT;
BEGIN
    SELECT customer_id INTO v_customer_id
    FROM store_data.customers
    WHERE email = p_customer_email;

    IF v_customer_id IS NULL THEN
        RAISE EXCEPTION 'Customer with email % does not exist', p_customer_email;
    END IF;

    SELECT employee_id INTO v_employee_id
    FROM store_data.employees
    WHERE email = p_employee_email;

    IF v_employee_id IS NULL THEN
        RAISE EXCEPTION 'Employee with email % does not exist', p_employee_email;
    END IF;

    INSERT INTO store_data.orders (customer_id, employee_id, order_date, status, total_amount)
    VALUES (v_customer_id, v_employee_id, p_order_date, p_status, p_total_amount);

    RAISE NOTICE 'Order for customer % added successfully.', p_customer_email;
END;
$$
 LANGUAGE plpgsql; 

SELECT store_data.add_order('john.doe@email.com', 'pam@appliance.com', 199.99); 

-- The view that reflects analytics for orders for the most recently added quarter

CREATE OR REPLACE VIEW store_data.recent_quarter_analytics AS
WITH recent_quarter AS (
    SELECT DATE_TRUNC('quarter', CURRENT_DATE - INTERVAL '3 months') AS start_of_quarter,
           DATE_TRUNC('quarter', CURRENT_DATE) - INTERVAL '1 day' AS end_of_quarter
),
aggregated_orders AS (
    SELECT cst.full_name AS customer_name,
           prd.name AS product_name,
           SUM(ordet.quantity) AS total_quantity,
           SUM(ordet.quantity * ordet.unit_price) AS total_amount
    FROM store_data.orders ord
    JOIN store_data.customers cst ON ord.customer_id = cst.customer_id
    JOIN store_data.order_details ordet ON ord.order_id = ordet.order_id
    JOIN store_data.products prd ON ordet.product_id = prd.product_id
    JOIN recent_quarter recqtr ON ord.order_date >= recqtr.start_of_quarter AND 
         ord.order_date <= recqtr.end_of_quarter
    GROUP BY cst.customer_id, 
             cst.full_name, 
             prd.name
)
SELECT customer_name,
       product_name,
       total_quantity,
       total_amount
FROM aggregated_orders
ORDER BY customer_name, total_amount DESC;

SELECT * FROM recent_quarter_analytics; 

-- A read-only role for the manager 

CREATE ROLE manager WITH LOGIN PASSWORD 'password123';

GRANT CONNECT ON DATABASE appliances_store TO manager;

GRANT USAGE ON SCHEMA store_data TO manager;

ALTER ROLE manager SET default_transaction_read_only = on; --user operates in read-only mode by default

GRANT SELECT ON ALL TABLES IN SCHEMA store_data TO manager;

ALTER DEFAULT PRIVILEGES IN SCHEMA store_data 
GRANT SELECT ON TABLES TO manager; -- all new tables created in the schema "store_data" will automatically grant SELECT permission to the "manager" role

REVOKE ALL ON SCHEMA store_data FROM PUBLIC; -- restrict public access



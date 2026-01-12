-- AIHub Database Schema
-- PostgreSQL Database Setup for Orders System

-- Drop existing objects if they exist
DROP TABLE IF EXISTS orders;

-- Orders table
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  product_name VARCHAR(255) NOT NULL,
  amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT now()
);

-- Insert sample orders
INSERT INTO orders (product_name, amount) VALUES
  ('Premium Plan', 99.99),
  ('Enterprise Support', 149.50),
  ('Custom Integration', 299.00),
  ('Basic Plan', 49.99),
  ('Professional Add-on', 79.99),
  ('API Access', 199.99);

-- Display sample data
SELECT 'Orders created:' as info;
SELECT * FROM orders ORDER BY created_at;

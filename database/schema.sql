-- AIHub Database Schema
-- PostgreSQL Database Setup for Orders System

-- Drop existing objects if they exist
DROP VIEW IF EXISTS user_orders;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS users;

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT now()
);

-- Orders table
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT now()
);

-- Create index for faster lookups
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Create view for row-level security style filtering
-- This view filters orders based on the app.user_id setting
CREATE VIEW user_orders AS
SELECT
  id,
  user_id,
  amount,
  created_at
FROM orders
WHERE user_id = current_setting('app.user_id', true)::uuid;

-- Insert sample users (password is plaintext for demo purposes)
-- In production, use proper password hashing (bcrypt, argon2, etc.)
INSERT INTO users (email, password_hash) VALUES
  ('admin@example.com', 'password123'),
  ('user@example.com', 'password123');

-- Insert sample orders for the users
-- Get the user IDs first
DO $$
DECLARE
  admin_id UUID;
  user_id UUID;
BEGIN
  SELECT id INTO admin_id FROM users WHERE email = 'admin@example.com';
  SELECT id INTO user_id FROM users WHERE email = 'user@example.com';

  -- Insert orders for admin
  INSERT INTO orders (user_id, amount) VALUES
    (admin_id, 99.99),
    (admin_id, 149.50),
    (admin_id, 299.00);

  -- Insert orders for regular user
  INSERT INTO orders (user_id, amount) VALUES
    (user_id, 49.99),
    (user_id, 79.99);
END $$;

-- Display sample data
SELECT 'Users created:' as info;
SELECT email FROM users;

SELECT 'Orders created:' as info;
SELECT o.id, u.email, o.amount, o.created_at
FROM orders o
JOIN users u ON o.user_id = u.id
ORDER BY o.created_at;

-- ecommerce.sql
-- Run: mysql -u root -p < ecommerce.sql
-- This file creates a database, tables, relationships and inserts sample seed data.

DROP DATABASE IF EXISTS azula_db;
CREATE DATABASE azula_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE azula_db;

-- USERS (store owners, customers, affiliates)
CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role ENUM('customer','store_owner','admin','affiliate') NOT NULL DEFAULT 'customer',
  name VARCHAR(120) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  phone VARCHAR(32),
  promo_code VARCHAR(80) UNIQUE, -- affiliate promo code
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- CATEGORIES
CREATE TABLE categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  slug VARCHAR(120) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- PRODUCTS
CREATE TABLE products (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  store_owner_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(200) NOT NULL,
  sku VARCHAR(100) UNIQUE,
  slug VARCHAR(220) NOT NULL UNIQUE,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (store_owner_id) REFERENCES users(id) ON DELETE CASCADE
);

-- PRODUCT - CATEGORY (many-to-many)
CREATE TABLE product_categories (
  product_id BIGINT UNSIGNED NOT NULL,
  category_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (product_id, category_id),
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- ORDERS
CREATE TABLE orders (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL, -- customer
  status ENUM('pending','paid','processing','shipped','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  promo_code VARCHAR(80),
  discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  delivery_cost DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  shipping_address JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ORDER ITEMS (one-to-many with orders)
CREATE TABLE order_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  store_owner_id BIGINT UNSIGNED NOT NULL,
  product_name VARCHAR(200) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  quantity INT UNSIGNED NOT NULL DEFAULT 1,
  line_total DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
);

-- REVIEWS
CREATE TABLE reviews (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  rating TINYINT UNSIGNED NOT NULL CHECK (rating BETWEEN 1 AND 5),
  title VARCHAR(200),
  body TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- PROMO CODES (affiliate/discount)
CREATE TABLE promo_codes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(80) NOT NULL UNIQUE,
  owner_user_id BIGINT UNSIGNED, -- affiliate owner if any
  discount_percent TINYINT UNSIGNED DEFAULT 0,
  discount_flat DECIMAL(10,2) DEFAULT 0.00,
  active TINYINT(1) DEFAULT 1,
  usage_limit INT UNSIGNED,
  used_count INT UNSIGNED DEFAULT 0,
  expires_at DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- PAYMENTS
CREATE TABLE payments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  provider ENUM('mpesa','stripe','paypal','manual') NOT NULL,
  provider_reference VARCHAR(255),
  amount DECIMAL(12,2) NOT NULL,
  status ENUM('pending','completed','failed','refunded') NOT NULL,
  paid_at DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- DELIVERY OPTIONS
CREATE TABLE delivery_options (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  estimated_days VARCHAR(80),
  active TINYINT(1) DEFAULT 1
);

-- AFFILIATE REFERRALS (track orders from a promo code)
CREATE TABLE affiliate_referrals (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  promo_code_id BIGINT UNSIGNED NOT NULL,
  order_id BIGINT UNSIGNED NOT NULL,
  commission_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (promo_code_id) REFERENCES promo_codes(id) ON DELETE CASCADE,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- INDEXES (performance)
CREATE INDEX idx_products_store ON products(store_owner_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);

-- SAMPLE SEED DATA
INSERT INTO users (role, name, email, password_hash, phone, promo_code)
VALUES
('store_owner','Alice Store','alice@store.com','$2y$...','+254700000001','alicestore'),
('customer','Bob Buyer','bob@example.com','$2y$...','+254700000002',NULL),
('affiliate','Cathy Affiliate','cathy@aff.com','$2y$...','+254700000003','cathy10');

INSERT INTO categories (name, slug, description) VALUES
('Clothing','clothing','All clothing items'),
('Electronics','electronics','Gadgets and devices'),
('Home','home','Home & living');

INSERT INTO products (store_owner_id, name, sku, slug, description, price, stock)
VALUES
(1,'Blue T-Shirt','TSHIRT-BLUE','blue-tshirt','Comfortable cotton t-shirt',1200.00,50),
(1,'Phone Charger','CHG-001','phone-charger','Fast charging USB-C charger',800.00,150);

INSERT INTO product_categories (product_id, category_id) VALUES
(1,1),(2,2);

INSERT INTO promo_codes (code, owner_user_id, discount_percent, active)
VALUES
('WELCOME10', NULL, 10, 1),
('CATHY10', 3, 10, 1);

-- sample order
INSERT INTO orders (user_id, subtotal, promo_code, discount_amount, tax_amount, delivery_cost, total, shipping_address, status)
VALUES
(2,2000.00,'WELCOME10',200.00,110.00,150.00,2060.00, JSON_OBJECT('line1','Kasarani, Nairobi','city','Nairobi','country','Kenya'),'paid');

INSERT INTO order_items (order_id, product_id, store_owner_id, product_name, unit_price, quantity, line_total)
VALUES
(1,1,1,'Blue T-Shirt',1200.00,1,1200.00),
(1,2,1,'Phone Charger',800.00,1,800.00);

INSERT INTO payments (order_id, provider, provider_reference, amount, status, paid_at)
VALUES
(1,'mpesa','ABC123XYZ',2060.00,'completed',NOW());


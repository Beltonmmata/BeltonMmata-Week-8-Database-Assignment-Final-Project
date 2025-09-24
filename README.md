# 🛍️ Azula E-commerce Database Management System

## 📖 Project Overview

This project is a **complete relational database design and implementation** for an **E-commerce Store**.

I chose this use case because it demonstrates many real-world database requirements such as:

- Users with different roles (customers, store owners, affiliates, admins).
- Products and categories with a many-to-many relationship.
- Orders with items, payments, delivery options, and promo codes.
- Reviews and affiliate tracking for marketing.

The goal was to design a **normalized relational schema** in MySQL with proper **constraints, relationships, and sample data** to show how a real e-commerce system would be managed at the database level.

---

## 🎯 Objectives Achieved

1. **Designed a relational schema** with clear tables representing business entities.
2. **Enforced data integrity** using constraints:
   - `PRIMARY KEY`
   - `FOREIGN KEY`
   - `NOT NULL`
   - `UNIQUE`
   - `CHECK`
3. **Implemented relationships**:
   - One-to-Many → A user can have many orders.
   - Many-to-Many → Products belong to multiple categories.
   - One-to-One → Each order has a payment record.
4. **Added realistic fields** like `created_at`, `updated_at`, and JSON shipping address.
5. **Seeded sample data** to demonstrate queries and functionality.

---

## 🗄️ Database Schema

Database name: **`azula_db`**

### Entities

- **Users**: Customers, Store Owners, Admins, Affiliates.
- **Products**: Items sold by store owners.
- **Categories**: Product grouping.
- **Orders & Order Items**: Tracks what customers buy.
- **Payments**: Records transactions (M-PESA, Stripe, PayPal, etc.).
- **Promo Codes & Affiliate Referrals**: For discounts and commission tracking.
- **Reviews**: Customer ratings and comments.
- **Delivery Options**: Shipping costs and time estimates.

### Relationships

- A **store owner (user)** → can have many **products**.
- A **product** → can belong to multiple **categories**.
- A **customer (user)** → can place many **orders**.
- An **order** → can have many **order items**.
- An **order** → has associated **payments**.
- An **affiliate (user)** → owns a **promo code** used by customers → generates **referrals**.

This design follows **3rd Normal Form (3NF)** to reduce redundancy and ensure consistency.

---

## 📂 Files in the Repository

- `ecommerce.sql` → The complete SQL script to create the database, tables, constraints, and seed data.
- `README.md` → This documentation file.

---

## ⚙️ How to Run

### Prerequisites

- Install **MySQL 8.x** or compatible version.
- (Optional) Use **Docker** to quickly spin up a MySQL container.

### Running the SQL File

1. Clone this repository:
   ```bash
   git clone https://github.com/<your-username>/azula-ecommerce-db.git
   cd azula-ecommerce-db
   ```

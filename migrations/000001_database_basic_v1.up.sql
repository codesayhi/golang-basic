-- 1. Bảng Users
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    username       VARCHAR(50)  UNIQUE NOT NULL,
    email          VARCHAR(100) UNIQUE NOT NULL,
    password_hash  VARCHAR(255) NOT NULL,
    full_name      VARCHAR(100),
    phone          VARCHAR(20),
    role           VARCHAR(20) DEFAULT 'customer',
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at     TIMESTAMP DEFAULT NULL
    );


-- 2. Bảng Categories
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at  TIMESTAMP DEFAULT NULL
    );


-- 3. Bảng Products
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    name           VARCHAR(200) NOT NULL,
    description    TEXT,
    price          DECIMAL(15, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
    active         BOOLEAN DEFAULT TRUE,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at     TIMESTAMP DEFAULT NULL
    );


-- ==========================================================
-- 4. Bảng Images (Kho ảnh trung tâm)
-- ==========================================================
CREATE TABLE IF NOT EXISTS images (
    id UUID PRIMARY KEY,
    url   TEXT NOT NULL,   -- Link ảnh (S3/Cloudinary)
    type  VARCHAR(20),     -- jpg, png, webp
    width INT,
    height INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- ==========================================================
-- 5. Bảng Product_Images (Quan hệ Nhiều - Nhiều)
-- ==========================================================
CREATE TABLE IF NOT EXISTS product_images (
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    image_id   UUID REFERENCES images(id)   ON DELETE CASCADE,
    is_thumbnail  BOOLEAN DEFAULT FALSE,
    display_order INT     DEFAULT 0,
    PRIMARY KEY (product_id, image_id)
    );


-- 6. Bảng Orders
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    status          VARCHAR(50) DEFAULT 'pending',
    total_amount    DECIMAL(15, 2) NOT NULL CHECK (total_amount >= 0),
    payment_method  VARCHAR(50),
    shipping_address TEXT NOT NULL,
    note            TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );


-- ==========================================================
-- 7. Bảng OrderItems (Snapshot Data - Quan trọng nhất)
-- ==========================================================
CREATE TABLE IF NOT EXISTS order_items (
    d UUID PRIMARY KEY,
    order_id   UUID REFERENCES orders(id)   ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    quantity   INT NOT NULL CHECK (quantity > 0),
    product_name      VARCHAR(200) NOT NULL,  -- Tên lúc mua
    product_image_url TEXT,                   -- Ảnh thumbnail lúc mua
    price_at_purchase DECIMAL(15, 2) NOT NULL CHECK (price_at_purchase >= 0),
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );


-- Indexing
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_product_images_product ON product_images(product_id);
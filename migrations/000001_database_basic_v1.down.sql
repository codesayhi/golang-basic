-- 1. Xóa các bảng "Lá" (Bảng phụ thuộc nhiều nhất) trước
DROP TABLE IF EXISTS order_items;      -- Phụ thuộc vào orders và products
DROP TABLE IF EXISTS product_images;   -- Phụ thuộc vào products và images

-- 2. Xóa các bảng trung tâm
DROP TABLE IF EXISTS orders;           -- Phụ thuộc vào users
DROP TABLE IF EXISTS products;         -- Phụ thuộc vào categories
DROP TABLE IF EXISTS images;           -- Độc lập (sau khi xóa product_images)

-- 3. Xóa các bảng "Gốc" (Bảng cha) sau cùng
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;
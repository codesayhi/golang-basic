package database

import (
	"database/sql"
	"fmt"
	"time"

	// Import driver ở đây. Dấu _ nghĩa là init driver nhưng không gọi hàm trực tiếp
	_ "github.com/lib/pq"
)

// Connect tạo kết nối đến Database
// driverName: "postgres"
// dataSource: chuỗi kết nối URL lấy từ .env
func Connect(dName string, dbUrl string) (*sql.DB, error) {
	// 1. Mở kết nối (Chưa kết nối thật, chỉ validate tham số)
	db, err := sql.Open(dName, dbUrl)
	if err != nil {
		return nil, fmt.Errorf("error opening db: %w", err)
	}

	// 2. Kiểm tra kết nối thật (Ping)
	if err = db.Ping(); err != nil {
		return nil, fmt.Errorf("error pinging db: %w", err)
	}

	// 3. Cấu hình Connection Pool (QUAN TRỌNG)
	// Giới hạn số kết nối tối đa (tránh sập DB)
	db.SetMaxOpenConns(10)
	// Số kết nối rảnh rỗi giữ lại để tái sử dụng
	db.SetMaxIdleConns(5)
	// Thời gian tối đa một kết nối tồn tại (5 phút)
	db.SetConnMaxLifetime(5 * time.Minute)

	return db, nil
}

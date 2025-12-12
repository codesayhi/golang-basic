package utils

import (
	"database/sql/driver"
	"encoding/json"
	"fmt"
)

// Null Null[T] là kiểu dữ liệu đa năng xử lý 3 trạng thái cho API & DB.
// T có thể là: int, string, float64, bool, time.Time...
type Null[T any] struct {
	Data  T    // Giá trị thực tế
	Valid bool // True = Có giá trị (khác null), False = Là null
	Set   bool // True = Client CÓ gửi field này (để phân biệt PATCH)
}

// NewNull tạo nhanh một biến có giá trị
func NewNull[T any](val T) Null[T] {
	return Null[T]{
		Data:  val,
		Valid: true,
		Set:   true,
	}
}

// ------------------------------------------------------------------
// 1. JSON HANDLING (Cho API)
// ------------------------------------------------------------------

// UnmarshalJSON UnmarshalJSON: Tự động bắt tín hiệu từ Client
func (n *Null[T]) UnmarshalJSON(data []byte) error {
	n.Set = true // Đã chạy vào đây nghĩa là JSON có field này

	// 1. Nếu client gửi "null"
	if string(data) == "null" {
		n.Valid = false
		var zero T
		n.Data = zero // Reset về zero value
		return nil
	}

	// 2. Nếu client gửi giá trị thực
	var val T
	if err := json.Unmarshal(data, &val); err != nil {
		return err
	}
	n.Data = val
	n.Valid = true
	return nil
}

// MarshalJSON MarshalJSON: Trả về JSON đẹp cho Frontend
func (n *Null[T]) MarshalJSON() ([]byte, error) {
	// Nếu không Valid -> Trả về chữ "null"
	if !n.Valid {
		return []byte("null"), nil
	}
	// Nếu Valid -> Trả về giá trị
	return json.Marshal(n.Data)
}

// ------------------------------------------------------------------
// 2. DATABASE HANDLING (Cho Repository)
// ------------------------------------------------------------------

// Value Value: Ghi xuống DB (Implement driver.Valuer)
func (n *Null[T]) Value() (driver.Value, error) {
	if !n.Valid {
		return nil, nil // Lưu NULL
	}
	return n.Data, nil // Lưu giá trị
}

// Scan Scan: Đọc từ DB lên (Implement sql.Scanner)
func (n *Null[T]) Scan(value interface{}) error {
	n.Set = true // Mặc định từ DB ra là có set

	if value == nil {
		n.Data, n.Valid = *new(T), false
		return nil
	}

	n.Valid = true

	// Xử lý ép kiểu an toàn từ Driver Postgres
	switch v := value.(type) {
	case T:
		n.Data = v
		return nil
	case []byte:
		// Xử lý trường hợp DB trả về []byte (ví dụ text/jsonb)
		var i interface{} = &n.Data
		if strPtr, ok := i.(*string); ok {
			*strPtr = string(v)
			return nil
		}
		return json.Unmarshal(v, &n.Data)
	default:
		// Cố gắng ép kiểu
		var i interface{} = value
		if casted, ok := i.(T); ok {
			n.Data = casted
			return nil
		}
		return fmt.Errorf("failed to scan type %T into Null[%T]", value, n.Data)
	}
}

// ------------------------------------------------------------------
// 3. SERVICE HELPERS (Để code Service gọn gàng)
// ------------------------------------------------------------------

// ApplyValue ApplyValue: Dùng cho trường bắt buộc có giá trị (VD: Name)
// Logic: Chỉ update khi Client có gửi (Set) và khác null (Valid).
func ApplyValue[T any](input Null[T], target *T) {
	if input.Set && input.Valid {
		*target = input.Data
	}
}

// ApplyPtr ApplyPtr: Dùng cho trường có thể NULL trong DB (VD: Price, Description)
// Logic:
// - Set=true, Valid=true -> Update giá trị mới
// - Set=true, Valid=false -> Set thành nil (Xóa)
func ApplyPtr[T any](input Null[T], target **T) {
	if input.Set {
		if input.Valid {
			val := input.Data
			*target = &val // Trỏ vào giá trị mới
		} else {
			*target = nil // Gán thành nil (NULL trong DB)
		}
	}
}

package utils

import (
	"encoding/json"
	"log"
	"net/http"
)

// ResponseJson định nghĩa cấu trúc JSON chuẩn cho mọi phản hồi API.
//   - Code: Mã trạng thái HTTP (ví dụ: 200, 400, 500).
//   - Data: Dữ liệu trả về (sẽ ẩn đi nếu là nil).
//   - Message: Thông báo mô tả kết quả cho người dùng/dev dễ đọc.
type ResponseJson struct {
	Code    int         `json:"code"`
	Data    interface{} `json:"data,omitempty"`
	Message string      `json:"message"`
}

// writeJson là hàm nội bộ (private) dùng để thiết lập header và ghi dữ liệu JSON.
// Hàm này giúp tránh lặp code ở các hàm public.
func writeJson(w http.ResponseWriter, code int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)

	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Printf("Lỗi encode response: %v", err)
	}
}

// ----------------------------------------------------------------------------------------------------------------------
// CÁC HÀM GỐC (BASE FUNCTIONS) - Dùng khi cần tùy biến cao

// SuccessJson gửi phản hồi thành công với đầy đủ tham số tùy chỉnh.
// Dùng hàm này khi bạn muốn kiểm soát hoàn toàn Code, Data và Message.
//
// Tham số:
//   - w: http.ResponseWriter - Đối tượng để ghi phản hồi.
//   - data: interface{} - Dữ liệu muốn trả về (Struct, Map, Slice...).
//   - code: int - Mã trạng thái HTTP.
//   - message: string - Thông báo thành công tùy chỉnh.
//
// Trả về: Không có.
func SuccessJson(w http.ResponseWriter, data interface{}, code int, message string) {
	resp := ResponseJson{
		Code:    code,
		Data:    data,
		Message: message,
	}
	writeJson(w, code, resp)
}

// FailJson gửi phản hồi lỗi cơ bản (chỉ có thông báo, không có data).
//
// Tham số:
//   - w: http.ResponseWriter
//   - code: int - Mã lỗi HTTP (thường là 4xx hoặc 5xx).
//   - message: string - Mô tả lỗi.
//
// Trả về: Không có.
func FailJson(w http.ResponseWriter, code int, message string) {
	resp := ResponseJson{
		Code:    code,
		Message: message,
	}
	writeJson(w, code, resp)
}

// FailJsonWithDetailErrors gửi phản hồi lỗi kèm theo chi tiết (thường dùng cho Validate).
//
// Tham số:
//   - w: http.ResponseWriter
//   - code: int - Mã lỗi HTTP.
//   - message: string - Thông báo lỗi chung.
//   - details: interface{} - Chi tiết lỗi (thường là Map hoặc Struct liệt kê lỗi từng trường).
//
// Trả về: Không có.
func FailJsonWithDetailErrors(w http.ResponseWriter, code int, message string, details interface{}) {
	resp := ResponseJson{
		Code:    code,
		Data:    details,
		Message: message,
	}
	writeJson(w, code, resp)
}

//-----------------------------------------------------------------------------------------------------------------------
// CÁC HÀM MỞ RỘNG - Gọi theo Status Code

// ResponseOK gửi phản hồi HTTP 200 (Success).
//
// Sử dụng cho: Các request lấy dữ liệu (GET) hoặc cập nhật (PUT) thành công.
// Tham số:
//   - w: http.ResponseWriter
//   - data: interface{} - Dữ liệu kết quả.
func ResponseOK(w http.ResponseWriter, data interface{}) {
	SuccessJson(w, data, http.StatusOK, "Thành công")
}

// ResponseCreated gửi phản hồi HTTP 201 (Created).
//
// Sử dụng cho: Các request tạo mới tài nguyên (POST) thành công.
// Tham số:
//   - w: http.ResponseWriter
//   - data: interface{} - Đối tượng vừa được tạo.
func ResponseCreated(w http.ResponseWriter, data interface{}) {
	SuccessJson(w, data, http.StatusCreated, "Tạo mới thành công")
}

// ResponseDeleted gửi phản hồi HTTP 200 cho thao tác xóa.
//
// Sử dụng cho: Các request xóa (DELETE).
// Lưu ý: Trả về 200 kèm message thay vì 204 (No Content) để Frontend dễ xử lý JSON đồng nhất.
func ResponseDeleted(w http.ResponseWriter) {
	SuccessJson(w, nil, http.StatusOK, "Xóa thành công")
}

// ResponseBadRequest gửi phản hồi HTTP 400 (Bad Request).
//
// Sử dụng cho: Lỗi do Client gửi lên (sai cú pháp, thiếu tham số, logic sai).
// Tham số:
//   - w: http.ResponseWriter
//   - message: string - Lý do lỗi.
func ResponseBadRequest(w http.ResponseWriter, message string) {
	FailJson(w, http.StatusBadRequest, message)
}

// ResponseValidationError gửi phản hồi HTTP 400 kèm chi tiết lỗi Validate.
//
// Sử dụng cho: Lỗi khi validate form (VD: Email sai định dạng, Mật khẩu quá ngắn).
// Tham số:
//   - w: http.ResponseWriter
//   - errors: interface{} - Danh sách lỗi chi tiết (Map/Struct).
func ResponseValidationError(w http.ResponseWriter, errors interface{}) {
	FailJsonWithDetailErrors(w, http.StatusBadRequest, "Dữ liệu không hợp lệ", errors)
}

// ResponseUnauthorized gửi phản hồi HTTP 401 (Unauthorized).
//
// Sử dụng cho: Người dùng chưa đăng nhập hoặc Token hết hạn/không hợp lệ.
func ResponseUnauthorized(w http.ResponseWriter) {
	FailJson(w, http.StatusUnauthorized, "Vui lòng đăng nhập")
}

// ResponseForbidden gửi phản hồi HTTP 403 (Forbidden).
//
// Sử dụng cho: Người dùng đã đăng nhập nhưng không có quyền truy cập tài nguyên này.
func ResponseForbidden(w http.ResponseWriter) {
	FailJson(w, http.StatusForbidden, "Bạn không có quyền truy cập")
}

// ResponseNotFound gửi phản hồi HTTP 404 (Not Found).
//
// Sử dụng cho: Không tìm thấy tài nguyên trong Database.
// Tham số:
//   - w: http.ResponseWriter
//   - message: string - Tên tài nguyên không tìm thấy.
func ResponseNotFound(w http.ResponseWriter, message string) {
	FailJson(w, http.StatusNotFound, message)
}

// ResponseServerError gửi phản hồi HTTP 500 (Internal Server Error).
//
// Sử dụng cho: Lỗi hệ thống không mong muốn (DB sập, Code bị panic...).
func ResponseServerError(w http.ResponseWriter) {
	FailJson(w, http.StatusInternalServerError, "Lỗi hệ thống nội bộ")
}

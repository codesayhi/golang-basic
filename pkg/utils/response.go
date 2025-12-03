package utils

type Response struct {
	Code    int         `json:"code"`
	Data    interface{} `json:"data,omitempty"`
	Message string      `json:"message"`
	Status  bool        `json:"status"`
}

func ResponseSuccess(data interface{}, code int, message string) *Response {
	return &Response{
		Code:    code,
		Data:    data,
		Message: message,
		Status:  true,
	}
}

func ResponseFail(code int, message string) *Response {
	return &Response{
		Code:    code,
		Message: message,
		Status:  false,
	}
}

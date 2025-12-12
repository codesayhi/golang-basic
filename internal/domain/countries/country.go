package countries

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

type Country struct {
	Id        uuid.UUID
	Name      string
	Code      string
	Slug      string
	Position  int
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt time.Time
}

var (
	ErrNotFound    = errors.New("không tìm thấy quốc gia")
	ErrInvalidName = errors.New("tên quốc gia không hợp lệ")
	ErrInvalidSlug = errors.New("slug không hợp lệ")
	ErrSlugExists  = errors.New("slug đã tồn tại")
)

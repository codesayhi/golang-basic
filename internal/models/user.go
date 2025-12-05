package models

import (
	"time"

	"github.com/google/uuid"
)

// entity
type User struct {
	ID           uuid.UUID `json:"id"` // ID do Go tạo và quản lý
	Username     string    `json:"username"`
	Email        string    `json:"email"`
	PasswordHash string    `json:"-"`
	FullName     string    `json:"full_name"`
	Phone        string    `json:"phone"`
	AvatarURL    string    `json:"avatar_url"`
	Role         string    `json:"role"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

// CreateUser
type CreateUserRequest struct {
	Username  string `json:"username"`
	Password  string `json:"password"`
	Email     string `json:"email"`
	FullName  string `json:"full_name"`
	Phone     string `json:"phone"`
	Role      string `json:"role"`
	AvatarURL string `json:"avatar_url,omitempty"` // Link ảnh đã upload trước đó
}

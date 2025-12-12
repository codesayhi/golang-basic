package countries

import (
	"context"

	"github.com/google/uuid"
)

type Repository interface {
	GetByID(ctx context.Context, id uuid.UUID) (*Country, error)
	Create(ctx context.Context, country *Country) error
}

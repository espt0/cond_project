package services

import (
	"context"

	"github.com/espt0/cond_project/internal/models"
)

type CondominiumRepository interface {
	FindAll() ([]models.Condominium, error)
	GetByID(ctx context.Context, id int) (*models.Condominium, error)
	Create(ctx context.Context, cond *models.Condominium) error
}

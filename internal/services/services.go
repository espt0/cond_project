package services

import (
	"context"
	"fmt"

	_ "github.com/espt0/cond_project/internal/dto"
	"github.com/espt0/cond_project/internal/models"
	"github.com/espt0/cond_project/internal/repositories"
)

type CondominiumRepository interface {
	FindAll() ([]models.Condominium, error)
	GetByID(ctx context.Context, id int) (*models.Condominium, error)
	Create(ctx context.Context, cond *models.Condominium) error
	Update(ctx context.Context, cond *models.Condominium) error
	Delete(ctx context.Context, id int) error
	ExistsByName(ctx context.Context, nome string) (bool, error)
}

type CondominiumService struct {
	repo *repositories.PostgresqlRepository
}

func NewCondominiumService(repo *repositories.PostgresqlRepository) *CondominiumService {
	return &CondominiumService{
		repo: repo,
	}
}

func (s *CondominiumService) ListCondominiums(ctx context.Context) ([]models.Condominium, error) {
	condominios, err := s.repo.FindAll(ctx)
	if err != nil {
		return nil, fmt.Errorf("erro ao buscar condomínios: %w", err)
	}

	// Exemplo de lógica de negócio: filtrar apenas ativos
	condAtivos := make([]models.Condominium, 0)
	for _, cond := range condominios {
		if cond.Active {
			condAtivos = append(condAtivos, cond)
		}
	}

	return condAtivos, nil
}

//func (s *CondominiumService) CreateCondominium(ctx context.Context, cond *dto.CreateCondominiumInput) error {

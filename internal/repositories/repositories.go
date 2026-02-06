package repositories

import (
	"fmt"

	"github.com/espt0/cond_project/database"
	"github.com/espt0/cond_project/internal/models"
)

func TodosCond() ([]models.Condominium, error) {
	db := database.GetDB()
	var condominios []models.Condominium

	query := "SELECT * FROM condominios"
	err := db.Select(&condominios, query)
	if err != nil {
		return nil, fmt.Errorf("Erro ao listar condomínios: %w", err)
	}

	return condominios, nil
}

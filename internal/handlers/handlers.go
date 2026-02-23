package handlers

import (
	"fmt"
	"net/http"

	"github.com/espt0/cond_project/internal/models"
	"github.com/espt0/cond_project/internal/repositories"

	"github.com/labstack/echo/v4"
)

type CondominiumHandler struct {
	repo *repositories.PostgresqlRepository
}

func NewCondominiumHandler(repo *repositories.PostgresqlRepository) *CondominiumHandler {
	return &CondominiumHandler{repo: repo}
}

// CONDOMÍNIO
func (h *CondominiumHandler) ListCondominios(c echo.Context) error {

	lista, err := h.repo.FindAll()
	if err != nil {
		return fmt.Errorf("Erro ao listar: %w", err)
	}

	return c.JSON(200, lista)
}
func CreateCondominio(c echo.Context) error {
	var req models.Condominium

	//Conversão de JSON -> Struct
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"erro": "corpo da requisição inválido"})
	}

	//Validação
	if req.Name == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"erro": "nome é obrigatório"})
	}

	return c.String(200, "Criando condomínio")
}
func GetCondominio(c echo.Context) error {

	return c.String(200, "Informação sobre um condomínio")
}
func UpdateCondominio(c echo.Context) error {

	return c.String(200, "Atualizando um condomínio")
}
func DeleteCondominio(c echo.Context) error {

	return c.String(200, "Desativando um condomínio")
}

// BLOCOS

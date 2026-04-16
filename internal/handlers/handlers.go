package handlers

import (
	"fmt"
	"net/http"

	"github.com/espt0/cond_project/internal/dto"
	"github.com/espt0/cond_project/internal/services"

	"github.com/labstack/echo/v5"
)

type CondominiumHandler struct {
	service *services.CondominiumService
}

func NewCondominiumHandler(service *services.CondominiumService) *CondominiumHandler {
	return &CondominiumHandler{service: service}
}

func (h *CondominiumHandler) ListCondominios(c *echo.Context) error {
	ctx := c.Request().Context()

	lista, err := h.service.ListCondominiums(ctx)
	if err != nil {
		return fmt.Errorf("Erro ao listar: %w", err)
	}

	return c.JSON(200, lista)
}
func (h *CondominiumHandler) CreateCondominium(c *echo.Context) error {
	ctx := c.Request().Context()
	var req dto.CreateCondominiumInput

	//Conversão de JSON -> Struct
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"erro": "corpo da requisição inválido"})
	}

	//Validação
	if err := c.Validate(req); err != nil {
		return echo.NewHTTPError(http.StatusUnprocessableEntity, err.Error())
	}

	//Chamar o Service
	err := h.service.CreateCondominium(ctx, &req)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"erro": "erro ao criar condomínio",
		})
	}

	return c.JSON(http.StatusCreated, map[string]string{"mensagem": "Condomínio criado com sucesso"})
}

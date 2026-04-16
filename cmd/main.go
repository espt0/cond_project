package main

import (
	"log"

	"github.com/espt0/cond_project/database"
	"github.com/espt0/cond_project/internal/handlers"
	"github.com/espt0/cond_project/internal/repositories"
	"github.com/espt0/cond_project/internal/routes"
	"github.com/espt0/cond_project/internal/services"
	"github.com/espt0/cond_project/internal/validator"

	"github.com/labstack/echo/v5"
)

func main() {
	//Conecta no banco de dados
	db, err := database.Connect()
	if err != nil {
		log.Fatal("Falha ao conectar no banco:", err)
	}
	defer database.Close()

	//Inicializando instância
	e := echo.New()

	//Valiação
	e.Validator = validator.NewEchoValidator()

	//Injeção de dependencias
	repo := repositories.NewPostgresqlRepository(db)
	service := services.NewCondominiumService(repo)
	handler := handlers.NewCondominiumHandler(service)
	routes.Rotas(e, handler)

	//Inicializando o server
	if err := e.Start(":8080"); err != nil {
		log.Fatal("Erro ao iniciar servidor:", err)
	}
}

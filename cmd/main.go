package main

import (
	"log"

	"github.com/espt0/cond_project/database"
	"github.com/espt0/cond_project/internal/routes"

	"github.com/labstack/echo/v4"
)

func main() {
	//Conecta no banco de dados
	err := database.Connect()
	if err != nil {
		log.Fatal("Falha ao conectar no banco:", err)
	}
	defer database.Close()

	//Inicializando instância
	e := echo.New()

	routes.Rotas(e)

	//Inicializando o server
	e.Logger.Fatal(e.Start(":8080"))
}

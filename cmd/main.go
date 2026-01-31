package main

import (
	"log"
	"net/http"

	"github.com/espt0/cond_project/database"
	"github.com/espt0/cond_project/internal/handlers"

	"github.com/labstack/echo/v4"
)

func main() {
	//Conecta no banco de dados
	err := database.Connect()
	if err != nil {
		log.Fatal("Falha ao conectar no banco:", err)
	}
	defer database.Close()

	//
	e := echo.New()

	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "Boora porraaaa!")
	})
	e.GET("/teste", handlers.PrintText)

	e.Logger.Fatal(e.Start(":8080"))
}

package main

import (
	"net/http"

	"github.com/espt0/cond_project/internal/handlers"

	"github.com/labstack/echo/v4"
)

func main() {
	e := echo.New()

	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "Boora porraaaa!")
	})
	e.GET("/teste", handlers.PrintText)

	e.Logger.Fatal(e.Start(":8080"))
}

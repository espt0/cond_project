package handlers

import (
	"github.com/labstack/echo/v4"
)

func PrintText(c echo.Context) error {

	return c.String(200, "Teste")

}

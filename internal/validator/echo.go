package validator

import (
	"net/http"

	"github.com/labstack/echo/v5"
)

type CustomValidator struct{}

func NewEchoValidator() *CustomValidator {
	return &CustomValidator{}
}

func (cv *CustomValidator) Validate(i interface{}) error {
	if err := Get().Struct(i); err != nil { // usa o singleton
		return echo.NewHTTPError(http.StatusBadRequest, err.Error())
	}
	return nil
}

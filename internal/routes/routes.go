package routes

import (
	"github.com/espt0/cond_project/internal/handlers"
	"github.com/labstack/echo/v5"
)

// Criar, Ler, Atualizar, Excluir (CRUD)
func Rotas(e *echo.Echo, condHandler *handlers.CondominiumHandler) {
	//Rotas das estruturas físicas
	condominios := e.Group("/condominios")
	condominios.GET("", condHandler.ListCondominios) //Lista todos (ADM)

	condominios.POST("", condHandler.CreateCondominium) //Cria um condomínio
	//condominios.GET("/:id", handlers.GetCondominio)       //Detalhes de um condomínio
	//condominios.PUT("/:id", handlers.UpdateCondominio)    //Atualiza
	//condominios.DELETE("/:id", handlers.DeleteCondominio) //Desativa

}

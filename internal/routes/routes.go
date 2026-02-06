package routes

import (
	"github.com/espt0/cond_project/internal/handlers"
	"github.com/labstack/echo/v4"
)

//Criar, Ler, Atualizar, Excluir (CRUD)

func Rotas(e *echo.Echo) {
	//Rotas das estruturas físicas
	condominios := e.Group("/condominios")
	condominios.GET("", handlers.ListCondominios) //Lista todos (ADM)

	condominios.POST("", handlers.CreateCondominio)       //Cria um condomínio
	condominios.GET("/:id", handlers.GetCondominio)       //Detalhes de um condomínio
	condominios.PUT("/:id", handlers.UpdateCondominio)    //Atualiza
	condominios.DELETE("/:id", handlers.DeleteCondominio) //Desativa

}

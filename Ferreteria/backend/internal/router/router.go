package router

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/ferreteria/backend/internal/handler"
)

func SetupRouter(productoHandler *handler.ProductoHandler, ventaHandler *handler.VentaHandler, entradaHandler *handler.EntradaHandler) *gin.Engine {
	r := gin.Default()

	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	})

	api := r.Group("/api/v1")
	{
		productos := api.Group("/productos")
		{
			productos.GET("", productoHandler.GetAll)
			productos.GET("/:id", productoHandler.GetByID)
			productos.POST("", productoHandler.Create)
			productos.PUT("/:id", productoHandler.Update)
			productos.DELETE("/:id", productoHandler.Delete)
		}

		categorias := api.Group("/categorias")
		{
			categorias.GET("", productoHandler.GetCategorias)
			categorias.POST("", productoHandler.CreateCategoria)
		}

		ventas := api.Group("/ventas")
		{
			ventas.GET("", ventaHandler.GetAll)
			ventas.GET("/hoy", ventaHandler.GetHoy)
			ventas.GET("/:id", ventaHandler.GetByID)
			ventas.POST("", ventaHandler.Create)
		}

		entradas := api.Group("/entradas")
		{
			entradas.GET("", entradaHandler.GetAll)
			entradas.GET("/:id", entradaHandler.GetByID)
			entradas.POST("", entradaHandler.Create)
		}
	}

	return r
}
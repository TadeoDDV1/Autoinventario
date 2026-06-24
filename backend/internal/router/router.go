package router

import (
	"crypto/rand"
	"encoding/hex"
	"log/slog"
	"net/http"
	"time"

	"github.com/ferreteria/backend/internal/handler"
	"github.com/ferreteria/backend/internal/ia"
	"github.com/ferreteria/backend/internal/pagos"
	"github.com/gin-gonic/gin"
)

const RequestIDHeader = "X-Request-ID"

func SetupRouter(productoHandler *handler.ProductoHandler, ventaHandler *handler.VentaHandler, entradaHandler *handler.EntradaHandler, iaHandler *ia.Handler, syncHandler *ia.SyncHandler, chatHandler *ia.ChatHandler, pagosHandler *pagos.Handler) *gin.Engine {
	gin.SetMode(gin.ReleaseMode)
	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(requestIDMiddleware())
	r.Use(loggingMiddleware())
	r.Use(corsMiddleware())

	healthHandler := func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "ok",
			"timestamp": time.Now().UTC().Format(time.RFC3339),
		})
	}
	r.GET("/health", healthHandler)

	api := r.Group("/api/v1")
	api.GET("/health", healthHandler)
	{
		productos := api.Group("/productos")
		{
			productos.GET("", productoHandler.GetAll)
			productos.GET("/buscar", productoHandler.BuscarPorCodigo)
			productos.GET("/escanear", productoHandler.Escanear)
			productos.GET("/:id", productoHandler.GetByID)
			productos.POST("", productoHandler.Create)
			productos.PUT("/:id", productoHandler.Update)
			productos.PATCH("/:id/stock", productoHandler.AjustarStock)
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

		// IA: copilot + dashboard
		ia := api.Group("/ia")
		{
			ia.GET("/sugerencias", iaHandler.GetSugerencias)
			ia.GET("/inventario/predicciones", iaHandler.GetPredicciones)

			// Chat IA conversacional
			ia.POST("/chat", chatHandler.Chat)
			ia.POST("/toggle", chatHandler.ToggleIA)
			ia.GET("/estado", chatHandler.GetEstado)

			// Sugeridor de productos nuevos (autocompletado)
			ia.GET("/sugerir-producto", iaHandler.SugerirProducto)
		}

		// Dashboard ejecutivo
		api.GET("/dashboard/resumen", iaHandler.GetDashboard)

		// Sync batch (ventas offline)
		api.POST("/sync/ventas", syncHandler.SyncVentas)

		// Pagos (Stripe Fase 1A + multi-proveedor a futuro)
		// El webhook vive en su propio grupo para que CORS/logging se apliquen igual
		// pero sin requerir auth (los webhooks llegan sin Authorization header).
		pagosGroup := api.Group("/pagos")
		{
			pagosGroup.GET("/providers", pagosHandler.ListProviders)
			pagosGroup.POST("/charges", pagosHandler.CreateCharge)
			pagosGroup.GET("/charges/:referencia", pagosHandler.GetCharge)
			pagosGroup.POST("/charges/:referencia/refund", pagosHandler.Refund)
			pagosGroup.GET("/venta/:venta_id", pagosHandler.ListByVenta)
			pagosGroup.POST("/webhook", pagosHandler.Webhook)
		}
	}

	return r
}

func requestIDMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		rid := c.GetHeader(RequestIDHeader)
		if rid == "" {
			rid = newRequestID()
		}
		c.Set("request_id", rid)
		c.Header(RequestIDHeader, rid)
		c.Next()
	}
}

func loggingMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		c.Next()
		latency := time.Since(start)

		slog.Info("http_request",
			slog.String("method", c.Request.Method),
			slog.String("path", c.Request.URL.Path),
			slog.String("query", c.Request.URL.RawQuery),
			slog.Int("status", c.Writer.Status()),
			slog.Duration("latency", latency),
			slog.String("client_ip", c.ClientIP()),
			slog.String("request_id", c.GetString("request_id")),
		)
	}
}

func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		if origin != "" {
			c.Header("Access-Control-Allow-Origin", origin)
			c.Header("Vary", "Origin")
		} else {
			c.Header("Access-Control-Allow-Origin", "*")
		}
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization, "+RequestIDHeader)
		c.Header("Access-Control-Max-Age", "600")

		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}

func newRequestID() string {
	b := make([]byte, 8)
	if _, err := rand.Read(b); err != nil {
		return "req-unknown"
	}
	return hex.EncodeToString(b)
}

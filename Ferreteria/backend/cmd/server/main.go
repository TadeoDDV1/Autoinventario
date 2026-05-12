package main

import (
	"fmt"
	"log"
	"os"

	"github.com/ferreteria/backend/config"
	"github.com/ferreteria/backend/internal/handler"
	"github.com/ferreteria/backend/internal/repository"
	"github.com/ferreteria/backend/internal/service"
	"github.com/ferreteria/backend/internal/router"
)

func main() {
	db, err := config.ConnectDB()
	if err != nil {
		log.Fatalf("Error conectando a la base de datos: %v", err)
	}
	defer db.Close()

	log.Println("Conexión a MySQL exitosa")

	productoRepo := repository.NewProductoRepository(db)
	productoService := service.NewProductoService(productoRepo)
	productoHandler := handler.NewProductoHandler(productoService)

	ventaRepo := repository.NewVentaRepository(db)
	ventaService := service.NewVentaService(ventaRepo)
	ventaHandler := handler.NewVentaHandler(ventaService)

	entradaRepo := repository.NewEntradaRepository(db)
	entradaService := service.NewEntradaService(entradaRepo)
	entradaHandler := handler.NewEntradaHandler(entradaService)

	r := router.SetupRouter(productoHandler, ventaHandler, entradaHandler)

	port := os.Getenv("SERVER_PORT")
	if port == "" {
		port = "8080"
	}

	addr := fmt.Sprintf(":%s", port)
	log.Printf("Servidor iniciando en http://localhost%s\n", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("Error iniciando servidor: %v", err)
	}
}
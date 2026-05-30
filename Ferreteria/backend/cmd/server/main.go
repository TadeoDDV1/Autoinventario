package main

import (
	"fmt"
	"log"
	"net"
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

	addr := fmt.Sprintf("0.0.0.0:%s", port)
	log.Printf("Servidor iniciando en http://0.0.0.0%s\n", port)

	ln, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatalf("Error iniciando servidor: %v", err)
	}
	defer ln.Close()

	log.Printf("Servidor escuchando en todas las interfaces %s\n", addr)
	if err := r.RunListener(ln); err != nil {
		log.Fatalf("Error iniciando servidor: %v", err)
	}
}
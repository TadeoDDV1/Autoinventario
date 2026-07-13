package main

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/ferreteria/backend/config"
	"github.com/ferreteria/backend/internal/caja"
	"github.com/ferreteria/backend/internal/handler"
	"github.com/ferreteria/backend/internal/ia"
	"github.com/ferreteria/backend/internal/repository"
	"github.com/ferreteria/backend/internal/router"
	"github.com/ferreteria/backend/internal/service"
)

func main() {
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	})))

	db, err := config.ConnectDB()
	if err != nil {
		slog.Error("db_connect_failed", slog.Any("error", err))
		os.Exit(1)
	}
	defer db.Close()
	slog.Info("db_connected")

	productoRepo := repository.NewProductoRepository(db)
	productoService := service.NewProductoService(productoRepo)
	productoHandler := handler.NewProductoHandler(productoService)

	ventaRepo := repository.NewVentaRepository(db)
	ventaService := service.NewVentaService(ventaRepo)
	ventaHandler := handler.NewVentaHandler(ventaService)

	entradaRepo := repository.NewEntradaRepository(db)
	entradaService := service.NewEntradaService(entradaRepo)
	entradaHandler := handler.NewEntradaHandler(entradaService)

	iaHandler := ia.NewHandler(db)
	syncHandler := ia.NewSyncHandler(ventaService)
	chatHandler := ia.NewChatHandler(db)

	ia.SetCopilotGlobal(iaHandler.Copilot())

	go func() {
		time.Sleep(500 * time.Millisecond)
		chatHandler.RefrescarProductos()
	}()

	// Sesi�n de caja compartida (sync multi-dispositivo SSE)
	sesionHub := caja.NewHub()
	sesionRepo := caja.NewSesionRepo(db)
	sesionService := caja.NewSesionService(sesionRepo, sesionHub, productoRepo)
	sesionHandler := caja.NewSesionHandler(sesionService, sesionHub)

	r := router.SetupRouter(
		productoHandler, ventaHandler, entradaHandler,
		iaHandler, syncHandler, chatHandler,
		sesionHandler,
	)

	port := os.Getenv("SERVER_PORT")
	if port == "" {
		port = "8080"
	}

	addr := fmt.Sprintf("0.0.0.0:%s", port)

	srv := &http.Server{
		Handler:           r,
		ReadHeaderTimeout: 30 * time.Second,
		ReadTimeout:       20 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       120 * time.Second,
	}

	ln, err := net.Listen("tcp", addr)
	if err != nil {
		slog.Error("listen_failed", slog.String("addr", addr), slog.Any("error", err))
		os.Exit(1)
	}

	serverErr := make(chan error, 1)
	go func() {
		slog.Info("server_listening", slog.String("addr", ln.Addr().String()))
		if err := srv.Serve(ln); err != nil && !errors.Is(err, http.ErrServerClosed) {
			serverErr <- err
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	select {
	case err := <-serverErr:
		slog.Error("server_error", slog.Any("error", err))
		os.Exit(1)
	case sig := <-quit:
		slog.Info("shutdown_signal", slog.String("signal", sig.String()))
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		slog.Error("shutdown_forced", slog.Any("error", err))
	}
	slog.Info("server_stopped")
}

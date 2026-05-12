package service

import (
	"time"

	"github.com/ferreteria/backend/internal/models"
	"github.com/ferreteria/backend/internal/repository"
)

type VentaService struct {
	repo *repository.VentaRepository
}

func NewVentaService(repo *repository.VentaRepository) *VentaService {
	return &VentaService{repo: repo}
}

func (s *VentaService) Create(venta *models.VentaCreate) (int64, string, error) {
	return s.repo.Create(venta)
}

func (s *VentaService) GetAll(page, pageSize int) ([]models.Venta, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	return s.repo.GetAll(page, pageSize)
}

func (s *VentaService) GetByID(id int) (*models.Venta, error) {
	return s.repo.GetByID(id)
}

func (s *VentaService) GetHoy() ([]models.Venta, error) {
	return s.repo.GetByFecha(time.Now())
}

func (s *VentaService) GetTotalesHoy() (float64, float64, float64, error) {
	return s.repo.GetTotalesFecha(time.Now())
}

type EntradaService struct {
	repo *repository.EntradaRepository
}

func NewEntradaService(repo *repository.EntradaRepository) *EntradaService {
	return &EntradaService{repo: repo}
}

func (s *EntradaService) Create(entrada *models.EntradaCreate) (int64, string, error) {
	return s.repo.Create(entrada)
}

func (s *EntradaService) GetAll(page, pageSize int) ([]models.EntradaInventario, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	return s.repo.GetAll(page, pageSize)
}

func (s *EntradaService) GetByID(id int) (*models.EntradaInventario, error) {
	return s.repo.GetByID(id)
}
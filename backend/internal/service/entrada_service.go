package service

import (
	"github.com/ferreteria/backend/internal/models"
	"github.com/ferreteria/backend/internal/repository"
)

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

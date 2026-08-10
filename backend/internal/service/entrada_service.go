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

// GetByDateRange devuelve entradas filtradas por rango de fechas, proveedor
// y/o búsqueda libre (folio/observaciones). Si desde o hasta están en zero
// value, no se aplica ese límite.
func (s *EntradaService) GetByDateRange(
	filtros repository.FiltrosEntradas,
	page, pageSize int,
) ([]models.EntradaInventario, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	return s.repo.GetByDateRange(filtros, page, pageSize)
}

func (s *EntradaService) GetByID(id int) (*models.EntradaInventario, error) {
	return s.repo.GetByID(id)
}

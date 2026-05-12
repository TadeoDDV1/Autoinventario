package service

import (
	"github.com/ferreteria/backend/internal/models"
	"github.com/ferreteria/backend/internal/repository"
)

type ProductoService struct {
	repo *repository.ProductoRepository
}

func NewProductoService(repo *repository.ProductoRepository) *ProductoService {
	return &ProductoService{repo: repo}
}

func (s *ProductoService) GetAll(page, pageSize int, search string, categoriaID *int) ([]models.Producto, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	return s.repo.GetAll(page, pageSize, search, categoriaID)
}

func (s *ProductoService) GetByID(id int) (*models.Producto, error) {
	return s.repo.GetByID(id)
}

func (s *ProductoService) Create(p *models.ProductoCreate) (int64, error) {
	return s.repo.Create(p)
}

func (s *ProductoService) Update(id int, p *models.ProductoUpdate) error {
	return s.repo.Update(id, p)
}

func (s *ProductoService) Delete(id int) error {
	return s.repo.Delete(id)
}

func (s *ProductoService) GetCategorias() ([]models.Categoria, error) {
	return s.repo.GetCategorias()
}

func (s *ProductoService) CreateCategoria(c *models.CategoriaCreate) (int64, error) {
	return s.repo.CreateCategoria(c)
}

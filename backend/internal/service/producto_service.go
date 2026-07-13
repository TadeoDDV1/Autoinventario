package service

import (
	"errors"
	"strings"

	"github.com/ferreteria/backend/internal/apperrors"
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
	if p.SKU != nil {
		trimmed := strings.TrimSpace(*p.SKU)
		if trimmed != "" {
			exists, err := s.repo.SKUExists(trimmed, 0)
			if err != nil {
				return 0, err
			}
			if exists {
				return 0, apperrors.ErrSKUExiste
			}
			p.SKU = &trimmed
		} else {
			p.SKU = nil
		}
	}
	return s.repo.Create(p)
}

func (s *ProductoService) Update(id int, p *models.ProductoUpdate) error {
	if p.SKU != nil {
		trimmed := strings.TrimSpace(*p.SKU)
		if trimmed != "" {
			exists, err := s.repo.SKUExists(trimmed, id)
			if err != nil {
				return err
			}
			if exists {
				return apperrors.ErrSKUExiste
			}
			p.SKU = &trimmed
		} else {
			p.SKU = nil
		}
	}
	err := s.repo.Update(id, p)
	if err != nil {
		return err
	}
	return nil
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

func (s *ProductoService) BuscarPorCodigo(codigo string) (*models.Producto, error) {
	return s.repo.BuscarPorCodigo(codigo)
}

func (s *ProductoService) AjustarStock(id int, cantidad int) error {
	return s.repo.AjustarStock(id, cantidad)
}

// Compile-time guard: referenciar errors evita imports no usados si en el
// futuro se agregan más tipos de error a la validación.
var _ = errors.Is

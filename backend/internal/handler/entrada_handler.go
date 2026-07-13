package handler

import (
	"errors"
	"net/http"
	"strconv"
	"time"

	"github.com/ferreteria/backend/internal/apperrors"
	"github.com/ferreteria/backend/internal/models"
	"github.com/ferreteria/backend/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
)

type EntradaHandler struct {
	service   *service.EntradaService
	validator *validator.Validate
}

func NewEntradaHandler(service *service.EntradaService) *EntradaHandler {
	return &EntradaHandler{
		service:   service,
		validator: validator.New(),
	}
}

func (h *EntradaHandler) Create(c *gin.Context) {
	var req models.EntradaCreate
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: err.Error()})
		return
	}

	if err := h.validator.Struct(req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "VALIDATION_ERROR", Message: err.Error()})
		return
	}

	id, folio, err := h.service.Create(&req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIError{Error: "INTERNAL_ERROR", Message: "Error al crear entrada"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"id": id, "folio": folio, "message": "Entrada creada exitosamente"})
}

func (h *EntradaHandler) GetAll(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

	entradas, total, err := h.service.GetAll(page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIError{Error: "INTERNAL_ERROR", Message: "Error al obtener entradas"})
		return
	}

	totalPages := int(total) / pageSize
	if int(total)%pageSize > 0 {
		totalPages++
	}

	c.JSON(http.StatusOK, models.PaginatedResponse{
		Data:       entradas,
		Total:      total,
		Page:       page,
		PageSize:   pageSize,
		TotalPages: totalPages,
	})
}

// GetHistorial devuelve entradas filtradas por rango de fechas (YYYY-MM-DD).
// Parámetros opcionales: `desde`, `hasta`. Si faltan, devuelve todas.
func (h *EntradaHandler) GetHistorial(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

	parseDate := func(key string) (time.Time, error) {
		v := c.Query(key)
		if v == "" {
			return time.Time{}, nil
		}
		return time.Parse("2006-01-02", v)
	}

	desde, err := parseDate("desde")
	if err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "desde inválido (YYYY-MM-DD)"})
		return
	}
	hasta, err := parseDate("hasta")
	if err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "hasta inválido (YYYY-MM-DD)"})
		return
	}

	entradas, total, err := h.service.GetByDateRange(desde, hasta, page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIError{Error: "INTERNAL_ERROR", Message: "Error al obtener historial"})
		return
	}

	totalPages := int(total) / pageSize
	if int(total)%pageSize > 0 {
		totalPages++
	}

	c.JSON(http.StatusOK, models.PaginatedResponse{
		Data:       entradas,
		Total:      total,
		Page:       page,
		PageSize:   pageSize,
		TotalPages: totalPages,
	})
}

func (h *EntradaHandler) GetByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "ID inválido"})
		return
	}

	entrada, err := h.service.GetByID(id)
	if err != nil {
		if errors.Is(err, apperrors.ErrNotFound) {
			c.JSON(http.StatusNotFound, models.APIError{Error: "NOT_FOUND", Message: "Entrada no encontrada"})
			return
		}
		c.JSON(http.StatusInternalServerError, models.APIError{Error: "INTERNAL_ERROR", Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, entrada)
}

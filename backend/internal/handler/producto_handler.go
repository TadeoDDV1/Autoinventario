package handler

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"github.com/ferreteria/backend/internal/models"
	"github.com/ferreteria/backend/internal/service"
)

type ProductoHandler struct {
	service   *service.ProductoService
	validator *validator.Validate
}

func NewProductoHandler(service *service.ProductoService) *ProductoHandler {
	return &ProductoHandler{
		service:   service,
		validator: validator.New(),
	}
}

func (h *ProductoHandler) GetAll(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))
	search := c.Query("search")

	var categoriaID *int
	if catStr := c.Query("categoria"); catStr != "" {
		cat, err := strconv.Atoi(catStr)
		if err == nil {
			categoriaID = &cat
		}
	}

	productos, total, err := h.service.GetAll(page, pageSize, search, categoriaID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIError{
			Error:   "INTERNAL_ERROR",
			Message: "Error al obtener productos",
		})
		return
	}

	totalPages := int(total) / pageSize
	if int(total)%pageSize > 0 {
		totalPages++
	}

	c.JSON(http.StatusOK, models.PaginatedResponse{
		Data:       productos,
		Total:      total,
		Page:       page,
		PageSize:   pageSize,
		TotalPages: totalPages,
	})
}

func (h *ProductoHandler) GetByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "ID inválido"})
		return
	}

	producto, err := h.service.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, models.APIError{Error: "NOT_FOUND", Message: "Producto no encontrado"})
		return
	}

	c.JSON(http.StatusOK, producto)
}

func (h *ProductoHandler) Create(c *gin.Context) {
	var req models.ProductoCreate
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: err.Error()})
		return
	}

	if err := h.validator.Struct(req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "VALIDATION_ERROR", Message: err.Error()})
		return
	}

	id, err := h.service.Create(&req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIError{Error: "INTERNAL_ERROR", Message: "Error al crear producto"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"id": id, "message": "Producto creado exitosamente"})
}

func (h *ProductoHandler) Update(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "ID inválido"})
		return
	}

	var req models.ProductoUpdate
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: err.Error()})
		return
	}

	if err := h.service.Update(id, &req); err != nil {
		c.JSON(http.StatusInternalServerError, models.APIError{Error: "INTERNAL_ERROR", Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Producto actualizado exitosamente"})
}

func (h *ProductoHandler) Delete(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "ID inválido"})
		return
	}

	if err := h.service.Delete(id); err != nil {
		c.JSON(http.StatusNotFound, models.APIError{Error: "NOT_FOUND", Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Producto eliminado exitosamente"})
}

func (h *ProductoHandler) GetCategorias(c *gin.Context) {
	categorias, err := h.service.GetCategorias()
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIError{Error: "INTERNAL_ERROR", Message: "Error al obtener categorías"})
		return
	}

	c.JSON(http.StatusOK, categorias)
}

func (h *ProductoHandler) CreateCategoria(c *gin.Context) {
	var req models.CategoriaCreate
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: err.Error()})
		return
	}

	if err := h.validator.Struct(req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "VALIDATION_ERROR", Message: err.Error()})
		return
	}

	id, err := h.service.CreateCategoria(&req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIError{Error: "INTERNAL_ERROR", Message: "Error al crear categoría"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"id": id, "message": "Categoría creada exitosamente"})
}

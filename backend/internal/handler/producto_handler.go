package handler

import (
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/ferreteria/backend/internal/apperrors"
	"github.com/ferreteria/backend/internal/models"
	"github.com/ferreteria/backend/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
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
		respondError(c, err, http.StatusInternalServerError, "INTERNAL_ERROR", "Error al obtener productos")
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
		respondError(c, err, http.StatusNotFound, "NOT_FOUND", "Producto no encontrado")
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
		respondError(c, err, http.StatusInternalServerError, "INTERNAL_ERROR", "Error al crear producto")
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
		if errors.Is(err, apperrors.ErrNoHayCampos) {
			c.JSON(http.StatusBadRequest, models.APIError{Error: "EMPTY_UPDATE", Message: err.Error()})
			return
		}
		respondError(c, err, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
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
		respondError(c, err, http.StatusNotFound, "NOT_FOUND", err.Error())
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Producto eliminado exitosamente"})
}

func (h *ProductoHandler) GetCategorias(c *gin.Context) {
	categorias, err := h.service.GetCategorias()
	if err != nil {
		respondError(c, err, http.StatusInternalServerError, "INTERNAL_ERROR", "Error al obtener categorías")
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
		respondError(c, err, http.StatusInternalServerError, "INTERNAL_ERROR", "Error al crear categoría")
		return
	}

	c.JSON(http.StatusCreated, gin.H{"id": id, "message": "Categoría creada exitosamente"})
}

func (h *ProductoHandler) BuscarPorCodigo(c *gin.Context) {
	codigo := c.Query("codigo")
	if codigo == "" {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "Código requerido"})
		return
	}

	producto, err := h.service.BuscarPorCodigo(codigo)
	if err != nil {
		respondError(c, err, http.StatusNotFound, "NOT_FOUND", "Producto no encontrado")
		return
	}

	c.JSON(http.StatusOK, producto)
}

// Escanear busca un producto por código de barras. Si existe, devuelve el
// producto. Si NO existe, devuelve {existe: false, codigo: XXX} (no 404)
// para que el frontend pueda redirigir al formulario de registro.
//
// GET /api/v1/productos/escanear?codigo=XXX
func (h *ProductoHandler) Escanear(c *gin.Context) {
	codigo := strings.TrimSpace(c.Query("codigo"))
	if codigo == "" {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "Código requerido"})
		return
	}

	producto, err := h.service.BuscarPorCodigo(codigo)
	if err == nil {
		c.JSON(http.StatusOK, gin.H{
			"existe":   true,
			"producto": producto,
		})
		return
	}

	// No existe — devolver señal explícita (no 404)
	c.JSON(http.StatusOK, gin.H{
		"existe": false,
		"codigo": codigo,
		"mensaje": "Producto no registrado. Puedes agregarlo ahora.",
	})
}

func (h *ProductoHandler) AjustarStock(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "ID inválido"})
		return
	}

	var req struct {
		Cantidad int `json:"cantidad" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: err.Error()})
		return
	}

	if err := h.service.AjustarStock(id, req.Cantidad); err != nil {
		respondError(c, err, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Stock actualizado exitosamente"})
}

func respondError(c *gin.Context, err error, defaultStatus int, defaultCode, defaultMessage string) {
	switch {
	case errors.Is(err, apperrors.ErrNotFound):
		c.JSON(http.StatusNotFound, models.APIError{Error: "NOT_FOUND", Message: err.Error()})
	case errors.Is(err, apperrors.ErrStockInsuficiente):
		c.JSON(http.StatusConflict, models.APIError{Error: "STOCK_INSUFICIENTE", Message: err.Error()})
	case errors.Is(err, apperrors.ErrIDInvalido):
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: err.Error()})
	default:
		c.JSON(defaultStatus, models.APIError{Error: defaultCode, Message: defaultMessage})
	}
}

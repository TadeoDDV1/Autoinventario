package handler

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"github.com/ferreteria/backend/internal/models"
	"github.com/ferreteria/backend/internal/service"
)

type VentaHandler struct {
	service   *service.VentaService
	validator *validator.Validate
}

func NewVentaHandler(service *service.VentaService) *VentaHandler {
	return &VentaHandler{
		service:   service,
		validator: validator.New(),
	}
}

func (h *VentaHandler) Create(c *gin.Context) {
	var req models.VentaCreate
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
		c.JSON(http.StatusInternalServerError, models.APIError{Error: "INTERNAL_ERROR", Message: "Error al crear venta"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"id": id, "folio": folio, "message": "Venta creada exitosamente"})
}

func (h *VentaHandler) GetAll(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

	ventas, total, err := h.service.GetAll(page, pageSize)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIError{Error: "INTERNAL_ERROR", Message: "Error al obtener ventas"})
		return
	}

	totalPages := int(total) / pageSize
	if int(total)%pageSize > 0 {
		totalPages++
	}

	c.JSON(http.StatusOK, models.PaginatedResponse{
		Data:       ventas,
		Total:      total,
		Page:       page,
		PageSize:   pageSize,
		TotalPages: totalPages,
	})
}

func (h *VentaHandler) GetByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.APIError{Error: "BAD_REQUEST", Message: "ID inválido"})
		return
	}

	venta, err := h.service.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, models.APIError{Error: "NOT_FOUND", Message: "Venta no encontrada"})
		return
	}

	c.JSON(http.StatusOK, venta)
}

func (h *VentaHandler) GetHoy(c *gin.Context) {
	ventas, err := h.service.GetHoy()
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIError{Error: "INTERNAL_ERROR", Message: "Error al obtener ventas"})
		return
	}

	totalVentas, totalEfectivo, totalTarjeta, err := h.service.GetTotalesHoy()
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.APIError{Error: "INTERNAL_ERROR", Message: "Error al obtener totales"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"ventas":         ventas,
		"total_ventas":   totalVentas,
		"total_efectivo": totalEfectivo,
		"total_tarjeta":  totalTarjeta,
		"fecha":          time.Now().Format("2006-01-02"),
	})
}
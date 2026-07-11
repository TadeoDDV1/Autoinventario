package caja

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/ferreteria/backend/internal/apperrors"
	"github.com/gin-gonic/gin"
)

type SesionHandler struct {
	svc *SesionService
	hub *Hub
}

func NewSesionHandler(svc *SesionService, hub *Hub) *SesionHandler {
	return &SesionHandler{svc: svc, hub: hub}
}

func (h *SesionHandler) ObtenerEstado(c *gin.Context) {
	sesionID := c.Query("sesion_id")
	estado, err := h.svc.ObtenerEstado(sesionID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, estado)
}

func (h *SesionHandler) AgregarItem(c *gin.Context) {
	var req AddItemReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	deviceID := c.GetHeader("X-Device-Id")
	sesionID := c.Query("sesion_id")

	resp, err := h.svc.AgregarItem(sesionID, deviceID, req.ProductoID, req.Cantidad)
	if err != nil {
		if errors.Is(err, apperrors.ErrNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, resp)
}

func (h *SesionHandler) SetCantidad(c *gin.Context) {
	var req SetItemReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	deviceID := c.GetHeader("X-Device-Id")
	sesionID := c.Query("sesion_id")

	resp, err := h.svc.SetCantidad(sesionID, deviceID, req.ProductoID, req.Cantidad)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, resp)
}

func (h *SesionHandler) RemoverItem(c *gin.Context) {
	pidStr := c.Param("producto_id")
	pid, err := strconv.Atoi(pidStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "producto_id invalido"})
		return
	}
	deviceID := c.GetHeader("X-Device-Id")
	sesionID := c.Query("sesion_id")

	resp, err := h.svc.RemoverItem(sesionID, deviceID, pid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, resp)
}

func (h *SesionHandler) Limpiar(c *gin.Context) {
	deviceID := c.GetHeader("X-Device-Id")
	sesionID := c.Query("sesion_id")

	resp, err := h.svc.Limpiar(sesionID, deviceID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, resp)
}

func (h *SesionHandler) StreamSSE(c *gin.Context) {
	sesionID := c.Query("sesion_id")
	clientID := c.GetHeader("X-Device-Id")
	if clientID == "" {
		clientID = "anon-" + c.ClientIP()
	}
	if sesionID == "" {
		sesionID = "caja-principal"
	}

	c.Writer.Header().Set("Content-Type", "text/event-stream")
	c.Writer.Header().Set("Cache-Control", "no-cache")
	c.Writer.Header().Set("Connection", "keep-alive")
	c.Writer.Header().Set("X-Accel-Buffering", "no")

	client := h.hub.Join(sesionID, clientID)
	defer h.hub.Leave(sesionID, clientID)

	ServerSentEvents(c.Writer, c.Writer.Flush, client)
}

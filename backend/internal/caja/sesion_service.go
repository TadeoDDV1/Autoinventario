package caja

import (
	"fmt"

	"github.com/ferreteria/backend/internal/apperrors"
	"github.com/ferreteria/backend/internal/repository"
)

type SesionService struct {
	repo *SesionRepo
	hub  *Hub
	prod *repository.ProductoRepository
}

func NewSesionService(repo *SesionRepo, hub *Hub, prod *repository.ProductoRepository) *SesionService {
	return &SesionService{repo: repo, hub: hub, prod: prod}
}

const defaultSesionID = "caja-principal"

func (s *SesionService) ObtenerEstado(sesionID string) (*CajaSesionEstado, error) {
	if sesionID == "" {
		sesionID = defaultSesionID
	}
	row, err := s.repo.ObtenerOSiNoCrear(sesionID)
	if err != nil {
		return nil, fmt.Errorf("obtener sesion: %w", err)
	}
	items, err := s.repo.ListarItems(sesionID)
	if err != nil {
		return nil, fmt.Errorf("listar items: %w", err)
	}
	return &CajaSesionEstado{
		SesionID: row.ID,
		Version:  row.Version,
		Items:    itemRowsToDTOs(items),
		Devices:  s.hub.RoomCount(sesionID),
	}, nil
}

func (s *SesionService) AgregarItem(sesionID, deviceID string, productoID, cantidad int) (*ModifyResp, error) {
	if sesionID == "" {
		sesionID = defaultSesionID
	}
	if cantidad <= 0 {
		cantidad = 1
	}

	_, err := s.prod.GetByID(productoID)
	if err != nil {
		return nil, apperrors.NewNotFound("producto", productoID)
	}

	_, err = s.repo.ObtenerOSiNoCrear(sesionID)
	if err != nil {
		return nil, err
	}

	newVersion, err := s.repo.IncrementarVersion(sesionID)
	if err != nil {
		return nil, fmt.Errorf("incrementar version: %w", err)
	}

	if err := s.repo.AgregarItem(sesionID, productoID, cantidad, newVersion, deviceID); err != nil {
		return nil, fmt.Errorf("agregar item: %w", err)
	}

	items, err := s.repo.ListarItems(sesionID)
	if err != nil {
		return nil, err
	}

	s.hub.Broadcast(sesionID, ItemEvent{
		Tipo:       "add",
		ProductoID: productoID,
		Cantidad:   cantidad,
		Version:    newVersion,
		UpdatedBy:  deviceID,
	}, "item_added")

	return &ModifyResp{
		Version:   newVersion,
		Items:     itemRowsToDTOs(items),
		Confirmed: true,
	}, nil
}

func (s *SesionService) SetCantidad(sesionID, deviceID string, productoID, cantidad int) (*ModifyResp, error) {
	if sesionID == "" {
		sesionID = defaultSesionID
	}
	_, err := s.repo.ObtenerOSiNoCrear(sesionID)
	if err != nil {
		return nil, err
	}

	newVersion, err := s.repo.IncrementarVersion(sesionID)
	if err != nil {
		return nil, err
	}

	if err := s.repo.SetItemCantidad(sesionID, productoID, cantidad, newVersion, deviceID); err != nil {
		return nil, fmt.Errorf("set cantidad: %w", err)
	}

	items, err := s.repo.ListarItems(sesionID)
	if err != nil {
		return nil, err
	}

	s.hub.Broadcast(sesionID, ItemEvent{
		Tipo:       "set",
		ProductoID: productoID,
		Cantidad:   cantidad,
		Version:    newVersion,
		UpdatedBy:  deviceID,
	}, "item_set")

	return &ModifyResp{
		Version:   newVersion,
		Items:     itemRowsToDTOs(items),
		Confirmed: true,
	}, nil
}

func (s *SesionService) RemoverItem(sesionID, deviceID string, productoID int) (*ModifyResp, error) {
	if sesionID == "" {
		sesionID = defaultSesionID
	}
	_, err := s.repo.ObtenerOSiNoCrear(sesionID)
	if err != nil {
		return nil, err
	}

	newVersion, err := s.repo.IncrementarVersion(sesionID)
	if err != nil {
		return nil, err
	}

	if err := s.repo.RemoverItem(sesionID, productoID); err != nil {
		return nil, fmt.Errorf("remover item: %w", err)
	}

	items, err := s.repo.ListarItems(sesionID)
	if err != nil {
		return nil, err
	}

	s.hub.Broadcast(sesionID, ItemEvent{
		Tipo:       "remove",
		ProductoID: productoID,
		Version:    newVersion,
		UpdatedBy:  deviceID,
	}, "item_removed")

	return &ModifyResp{
		Version:   newVersion,
		Items:     itemRowsToDTOs(items),
		Confirmed: true,
	}, nil
}

func (s *SesionService) Limpiar(sesionID, deviceID string) (*ModifyResp, error) {
	if sesionID == "" {
		sesionID = defaultSesionID
	}
	_, err := s.repo.ObtenerOSiNoCrear(sesionID)
	if err != nil {
		return nil, err
	}

	newVersion, err := s.repo.IncrementarVersion(sesionID)
	if err != nil {
		return nil, err
	}

	if err := s.repo.Limpiar(sesionID); err != nil {
		return nil, fmt.Errorf("limpiar: %w", err)
	}

	s.hub.Broadcast(sesionID, ItemEvent{
		Tipo:    "clear",
		Version: newVersion,
	}, "cleared")

	return &ModifyResp{
		Version:   newVersion,
		Items:     []SesionItemDTO{},
		Confirmed: true,
	}, nil
}

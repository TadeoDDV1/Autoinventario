package caja

type ItemEvent struct {
	Tipo       string `json:"tipo"`
	ProductoID int    `json:"producto_id"`
	Cantidad   int    `json:"cantidad"`
	Version    int64  `json:"version"`
	UpdatedBy  string `json:"updated_by"`
}

type CajaSesionEstado struct {
	SesionID string          `json:"sesion_id"`
	Version  int64           `json:"version"`
	Items    []SesionItemDTO `json:"items"`
	Devices  int             `json:"devices"`
}

type SesionItemDTO struct {
	ProductoID int    `json:"producto_id"`
	Cantidad   int    `json:"cantidad"`
	Version    int64  `json:"version"`
	UpdatedBy  string `json:"updated_by"`
}

type AddItemReq struct {
	ProductoID int    `json:"producto_id"`
	Cantidad   int    `json:"cantidad"`
	ClientOpID string `json:"client_op_id"`
}

type SetItemReq struct {
	ProductoID int    `json:"producto_id"`
	Cantidad   int    `json:"cantidad"`
	ClientOpID string `json:"client_op_id"`
}

type ModifyResp struct {
	Version   int64           `json:"version"`
	Items     []SesionItemDTO `json:"items"`
	Confirmed bool            `json:"confirmed"`
}

type ConflictResp struct {
	Version int64           `json:"version"`
	Items   []SesionItemDTO `json:"items"`
	Message string          `json:"message"`
}

func itemRowToDTO(r SesionItemRow) SesionItemDTO {
	return SesionItemDTO{
		ProductoID: r.ProductoID,
		Cantidad:   r.Cantidad,
		Version:    r.Version,
		UpdatedBy:  r.UpdatedBy,
	}
}

func itemRowsToDTOs(rows []SesionItemRow) []SesionItemDTO {
	dtos := make([]SesionItemDTO, len(rows))
	for i, r := range rows {
		dtos[i] = itemRowToDTO(r)
	}
	return dtos
}

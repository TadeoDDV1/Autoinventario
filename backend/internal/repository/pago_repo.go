package repository

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"time"

	"github.com/ferreteria/backend/internal/apperrors"
	"github.com/ferreteria/backend/internal/models"
	"github.com/jmoiron/sqlx"
)

// Pago es el modelo de lectura/escritura de la tabla `pagos`.
// No se exporta a JSON porque el handler convierte a su propio DTO.
type Pago struct {
	ID             int64           `json:"id" db:"id"`
	VentaID        int64           `json:"venta_id" db:"venta_id"`
	Proveedor      string          `json:"proveedor" db:"proveedor"`
	Referencia     string          `json:"referencia" db:"referencia"`
	MontoCentavos  int64           `json:"monto_centavos" db:"monto_centavos"`
	Moneda         string          `json:"moneda" db:"moneda"`
	Estado         string          `json:"estado" db:"estado"`
	MetodoPago     *string         `json:"metodo_pago,omitempty" db:"metodo_pago"`
	Installments   int             `json:"installments" db:"installments"`
	Ult4           *string         `json:"ult_4,omitempty" db:"ult_4"`
	MetadataJSON   json.RawMessage `json:"metadata_json,omitempty" db:"metadata_json"`
	CreatedAt      time.Time       `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time       `json:"updated_at" db:"updated_at"`
}

// PagoCreate es lo que el handler pasa al repo para registrar un intento de pago.
// El ID y los timestamps los pone la BD.
type PagoCreate struct {
	VentaID       int64
	Proveedor     string
	Referencia    string
	MontoCentavos int64
	Moneda        string
	Estado        string
	MetodoPago    string
	Installments  int
	Ult4          string
	MetadataJSON  json.RawMessage
}

// PagoRepository encapsula el acceso a la tabla `pagos`.
type PagoRepository struct {
	db *sqlx.DB
}

func NewPagoRepository(db *sqlx.DB) *PagoRepository {
	return &PagoRepository{db: db}
}

// Create inserta un nuevo pago en estado "pendiente" (típicamente)
// o "aprobado" si ya tenemos confirmación del provider.
func (r *PagoRepository) Create(p *PagoCreate) (int64, error) {
	if p.Moneda == "" {
		p.Moneda = "MXN"
	}
	if p.Installments == 0 {
		p.Installments = 1
	}
	if p.Estado == "" {
		p.Estado = "pendiente"
	}

	query := `INSERT INTO pagos
		(venta_id, proveedor, referencia, monto_centavos, moneda, estado,
		 metodo_pago, installments, ult_4, metadata_json)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`

	var meta interface{}
	if len(p.MetadataJSON) > 0 {
		meta = []byte(p.MetadataJSON)
	} else {
		meta = nil
	}
	var metodoPago, ult4 interface{}
	if p.MetodoPago != "" {
		metodoPago = p.MetodoPago
	}
	if p.Ult4 != "" {
		ult4 = p.Ult4
	}

	res, err := r.db.Exec(query,
		p.VentaID, p.Proveedor, p.Referencia, p.MontoCentavos, p.Moneda, p.Estado,
		metodoPago, p.Installments, ult4, meta)
	if err != nil {
		return 0, err
	}
	return res.LastInsertId()
}

// UpdateEstado cambia el estado de un pago (pendiente → aprobado / rechazado / reembolsado).
// Devuelve error si el pago no existe.
func (r *PagoRepository) UpdateEstado(referencia, nuevoEstado string) error {
	res, err := r.db.Exec(
		`UPDATE pagos SET estado = ? WHERE referencia = ?`,
		nuevoEstado, referencia)
	if err != nil {
		return err
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return fmt.Errorf("%w: pago con referencia %q", apperrors.ErrNotFound, referencia)
	}
	return nil
}

// GetByReferencia busca un pago por la referencia del provider (ej. ch_xxx de Stripe).
// Útil cuando llega un webhook y queremos cruzar el ID del provider con nuestro registro.
func (r *PagoRepository) GetByReferencia(referencia string) (*Pago, error) {
	var p Pago
	err := r.db.Get(&p,
		`SELECT id, venta_id, proveedor, referencia, monto_centavos, moneda, estado,
		        metodo_pago, installments, ult_4, metadata_json, created_at, updated_at
		 FROM pagos WHERE referencia = ? LIMIT 1`, referencia)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("%w: pago con referencia %q", apperrors.ErrNotFound, referencia)
	}
	if err != nil {
		return nil, err
	}
	return &p, nil
}

// ListByVenta devuelve todos los intentos de pago de una venta (en orden cronológico).
// Una venta puede tener varios intentos (ej. tarjeta declinada → efectivo aprobado).
func (r *PagoRepository) ListByVenta(ventaID int64) ([]Pago, error) {
	pagos := make([]Pago, 0)
	err := r.db.Select(&pagos,
		`SELECT id, venta_id, proveedor, referencia, monto_centavos, moneda, estado,
		        metodo_pago, installments, ult_4, metadata_json, created_at, updated_at
		 FROM pagos WHERE venta_id = ? ORDER BY created_at ASC`, ventaID)
	if err != nil {
		return nil, err
	}
	return pagos, nil
}

// UpdateVentaReferencia graba el ID del cargo aprobado en la venta,
// para que el ticket PDF y el dashboard puedan mostrarlo.
func (r *PagoRepository) UpdateVentaReferencia(ventaID int64, referencia string) error {
	_, err := r.db.Exec(
		`UPDATE ventas SET referencia_pago = ? WHERE id = ?`,
		referencia, ventaID)
	return err
}

// silencia import unused si en el futuro referenciamos models desde acá.
var _ = models.PaginatedResponse{}

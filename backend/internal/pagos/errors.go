package pagos

import (
	"errors"
	"fmt"
)

// PagoError es el error tipado que devuelve cualquier PaymentProvider.
// Permite al handler distinguir entre:
//   - ErrConfig         → problema de configuración (no se reintenta)
//   - ErrCard           → tarjeta rechazada por el banco (mostrar al usuario)
//   - ErrNetwork        → timeout / 5xx del provider (reintentar)
//   - ErrSignature      → webhook con firma inválida (logear, descartar)
//   - ErrNotFound       → referencia no existe en el provider
type PagoError struct {
	Kind    PagoErrorKind
	Code    string // código de error del provider (ej. "card_declined")
	Message string // mensaje legible
	Cause   error  // error original (errors.Is/As compatible)
}

type PagoErrorKind int

const (
	ErrConfig PagoErrorKind = iota + 1
	ErrCard
	ErrNetwork
	ErrSignature
	ErrNotFound
	ErrUnknown
)

func (e *PagoError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("pago %s: %s (cause: %v)", e.KindName(), e.Message, e.Cause)
	}
	return fmt.Sprintf("pago %s: %s", e.KindName(), e.Message)
}

func (e *PagoError) Unwrap() error {
	return e.Cause
}

func (e *PagoError) KindName() string {
	switch e.Kind {
	case ErrConfig:
		return "config"
	case ErrCard:
		return "card_declined"
	case ErrNetwork:
		return "network"
	case ErrSignature:
		return "signature"
	case ErrNotFound:
		return "not_found"
	default:
		return "unknown"
	}
}

// Constructores tipados para que el handler haga errors.As(err, &pagoErr).

func NewConfigError(msg string, cause error) *PagoError {
	return &PagoError{Kind: ErrConfig, Code: "config", Message: msg, Cause: cause}
}

func NewCardError(code, msg string, cause error) *PagoError {
	return &PagoError{Kind: ErrCard, Code: code, Message: msg, Cause: cause}
}

func NewNetworkError(msg string, cause error) *PagoError {
	return &PagoError{Kind: ErrNetwork, Code: "network", Message: msg, Cause: cause}
}

func NewSignatureError(msg string, cause error) *PagoError {
	return &PagoError{Kind: ErrSignature, Code: "invalid_signature", Message: msg, Cause: cause}
}

func NewNotFoundError(ref string, cause error) *PagoError {
	return &PagoError{Kind: ErrNotFound, Code: "not_found", Message: "referencia no encontrada: " + ref, Cause: cause}
}

// IsCardDeclined devuelve true si el error es un rechazo de tarjeta.
// Útil en el handler para responder 402 Payment Required en vez de 500.
func IsCardDeclined(err error) bool {
	var pe *PagoError
	return errors.As(err, &pe) && pe.Kind == ErrCard
}

// IsNetwork devuelve true si el error es de red/timeout del provider.
// Útil para responder 503 Service Unavailable.
func IsNetwork(err error) bool {
	var pe *PagoError
	return errors.As(err, &pe) && pe.Kind == ErrNetwork
}

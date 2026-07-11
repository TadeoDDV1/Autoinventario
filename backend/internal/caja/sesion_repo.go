package caja

import (
	"database/sql"
	"time"

	"github.com/jmoiron/sqlx"
)

type SesionRepo struct {
	db *sqlx.DB
}

func NewSesionRepo(db *sqlx.DB) *SesionRepo {
	return &SesionRepo{db: db}
}

type SesionRow struct {
	ID        string    `db:"id"`
	Version   int64     `db:"version"`
	CreatedAt time.Time `db:"created_at"`
	TouchAt   time.Time `db:"last_touch_at"`
}

type SesionItemRow struct {
	SesionID   string    `db:"sesion_id"`
	ProductoID int       `db:"producto_id"`
	Cantidad   int       `db:"cantidad"`
	Version    int64     `db:"version"`
	UpdatedAt  time.Time `db:"updated_at"`
	UpdatedBy  string    `db:"updated_by"`
}

func (r *SesionRepo) ObtenerOSiNoCrear(id string) (*SesionRow, error) {
	row := &SesionRow{}
	err := r.db.Get(row, `SELECT * FROM caja_sesiones WHERE id = ?`, id)
	if err == sql.ErrNoRows {
		_, err = r.db.Exec(
			`INSERT INTO caja_sesiones (id, version) VALUES (?, 0)`, id,
		)
		if err != nil {
			return nil, err
		}
		return &SesionRow{ID: id, Version: 0}, nil
	}
	if err != nil {
		return nil, err
	}
	return row, nil
}

func (r *SesionRepo) ListarItems(sesionID string) ([]SesionItemRow, error) {
	items := make([]SesionItemRow, 0)
	err := r.db.Select(&items,
		`SELECT * FROM caja_sesion_items WHERE sesion_id = ? ORDER BY producto_id`, sesionID,
	)
	return items, err
}

func (r *SesionRepo) ObtenerVersion(sesionID string) (int64, error) {
	var v int64
	err := r.db.Get(&v, `SELECT version FROM caja_sesiones WHERE id = ?`, sesionID)
	return v, err
}

func (r *SesionRepo) IncrementarVersion(sesionID string) (int64, error) {
	_, err := r.db.Exec(
		`UPDATE caja_sesiones SET version = version + 1 WHERE id = ?`, sesionID,
	)
	if err != nil {
		return 0, err
	}
	return r.ObtenerVersion(sesionID)
}

func (r *SesionRepo) AgregarItem(sesionID string, productoID, cantidad int, version int64, updatedBy string) error {
	_, err := r.db.Exec(
		`INSERT INTO caja_sesion_items (sesion_id, producto_id, cantidad, version, updated_by)
		 VALUES (?, ?, ?, ?, ?)
		 ON DUPLICATE KEY UPDATE cantidad = cantidad + VALUES(cantidad), version = VALUES(version), updated_by = VALUES(updated_by)`,
		sesionID, productoID, cantidad, version, updatedBy,
	)
	return err
}

func (r *SesionRepo) SetItemCantidad(sesionID string, productoID, cantidad int, version int64, updatedBy string) error {
	if cantidad <= 0 {
		_, err := r.db.Exec(
			`DELETE FROM caja_sesion_items WHERE sesion_id = ? AND producto_id = ?`,
			sesionID, productoID,
		)
		return err
	}
	_, err := r.db.Exec(
		`INSERT INTO caja_sesion_items (sesion_id, producto_id, cantidad, version, updated_by)
		 VALUES (?, ?, ?, ?, ?)
		 ON DUPLICATE KEY UPDATE cantidad = VALUES(cantidad), version = VALUES(version), updated_by = VALUES(updated_by)`,
		sesionID, productoID, cantidad, version, updatedBy,
	)
	return err
}

func (r *SesionRepo) RemoverItem(sesionID string, productoID int) error {
	_, err := r.db.Exec(
		`DELETE FROM caja_sesion_items WHERE sesion_id = ? AND producto_id = ?`,
		sesionID, productoID,
	)
	return err
}

func (r *SesionRepo) Limpiar(sesionID string) error {
	_, err := r.db.Exec(
		`DELETE FROM caja_sesion_items WHERE sesion_id = ?`, sesionID,
	)
	return err
}

package models

import (
	"time"
)

type Reservation struct {
	ID           int       `json:"id" db:"id"`
	CommonAreaID int       `json:"common_area_id" db:"area_comum_id"`
	UnitID       int       `json:"unit_id" db:"unidade_id"`
	PersonID     int       `json:"person_id" db:"pessoa_id"`
	StartTime    time.Time `json:"start_time" db:"data_inicio"`
	EndTime      time.Time `json:"end_time" db:"data_fim"`
	Status       string    `json:"status" db:"status"` // confirmed, cancelled, completed
	PaidAmount   *float64  `json:"paid_amount,omitempty" db:"valor_pago"`
	Notes        *string   `json:"notes,omitempty" db:"observacoes"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
}

package models

import (
	"time"
)

// Vehicle represents vehicles registered to units
type Vehicle struct {
	ID        int       `json:"id" db:"id"`
	UnitID    int       `json:"unit_id" db:"unidade_id"`
	Plate     string    `json:"plate" db:"placa"`
	Model     *string   `json:"model,omitempty" db:"modelo"`
	Color     *string   `json:"color,omitempty" db:"cor"`
	Type      *string   `json:"type,omitempty" db:"tipo"` // car, motorcycle, truck
	Active    bool      `json:"active" db:"ativo"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

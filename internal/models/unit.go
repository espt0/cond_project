package models

import (
	"time"
)

type Unit struct {
	ID            int       `json:"id" db:"id"`
	CondominiumID int       `json:"condominium_id" db:"condominio_id"`
	BlockID       *int      `json:"block_id,omitempty" db:"bloco_id"`
	Number        string    `json:"number" db:"numero"`
	Type          *string   `json:"type,omitempty" db:"tipo"`
	AreaM2        *float64  `json:"area_m2,omitempty" db:"area_m2"`
	IdealFraction *float64  `json:"ideal_fraction,omitempty" db:"fracao_ideal"`
	Bedrooms      *int      `json:"bedrooms,omitempty" db:"quartos"`
	Batrooms      *int      `json:"batrooms,omitempty" db:"banheiros"`
	ParkingSpots  *int      `json:"parking_spots,omitempty" db:"vagas_garagem"`
	Active        bool      `json:"active" db:"ativo"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
}

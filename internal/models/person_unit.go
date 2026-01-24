package models

import (
	"time"
)

type PersonUnit struct {
	ID        int        `json:"id" db:"id"`
	PersonID  int        `json:"person_id" db:"pessoa_id"`
	UnitID    int        `json:"unit_id" db:"unidade_id"`
	LinkType  string     `json:"link_type" db:"tipo_vinculo"`
	StartDate time.Time  `json:"start_date" db:"data_inicio"`
	EndDate   *time.Time `json:"end_date,omitempty" db:"data_fim"`
	Active    bool       `json:"active" db:"ativo"`
	CreatedAt time.Time  `json:"created_at" db:"created_at"`
}

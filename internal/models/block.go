package models

import (
	"time"
)

type Block struct {
	ID            int       `json:"id" db:"id"`
	CondominiumID int       `json:"condominium_id" db:"condominio_id"`
	Name          string    `json:"name" db:"nome"`
	Description   *string   `json:"description,omitempty" db:"descricao"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
}

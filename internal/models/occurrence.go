package models

import (
	"time"
)

// Occurrence represents complaints, suggestions, and maintenance requests
type Occurrence struct {
	ID             int        `json:"id" db:"id"`
	CondominiumID  int        `json:"condominium_id" db:"condominio_id"`
	UnitID         *int       `json:"unit_id,omitempty" db:"unidade_id"`
	PersonID       *int       `json:"person_id,omitempty" db:"pessoa_id"`
	Title          string     `json:"title" db:"titulo"`
	Description    string     `json:"description" db:"descricao"`
	Type           *string    `json:"type,omitempty" db:"tipo"` // complaint, suggestion, maintenance, security
	Status         string     `json:"status" db:"status"`       // open, in_progress, resolved, closed
	Priority       string     `json:"priority" db:"prioridade"` // low, normal, high
	OpeningDate    time.Time  `json:"opening_date" db:"data_abertura"`
	CompletionDate *time.Time `json:"completion_date,omitempty" db:"data_conclusao"`
	Response       *string    `json:"response,omitempty" db:"resposta"`
}

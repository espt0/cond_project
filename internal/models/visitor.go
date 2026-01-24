package models

import (
	"time"
)

// Visitor represents external people entering the condominium
type Visitor struct {
	ID           int        `json:"id" db:"id"`
	UnitID       int        `json:"unit_id" db:"unidade_id"`
	Name         string     `json:"name" db:"nome"`
	CPF          *string    `json:"cpf,omitempty" db:"cpf"`
	Phone        *string    `json:"phone,omitempty" db:"telefone"`
	EntryTime    time.Time  `json:"entry_time" db:"data_entrada"`
	ExitTime     *time.Time `json:"exit_time,omitempty" db:"data_saida"`
	VisitType    *string    `json:"visit_type,omitempty" db:"tipo_visita"` // social, service_provider, delivery
	AuthorizedBy *int       `json:"authorized_by,omitempty" db:"autorizado_por"`
	Notes        *string    `json:"notes,omitempty" db:"observacoes"`
	CreatedAt    time.Time  `json:"created_at" db:"created_at"`
}

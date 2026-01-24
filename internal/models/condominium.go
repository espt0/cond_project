package models

import (
	"time"
)

type Condominium struct {
	ID             int        `json:"id" db:"id"`
	Name           string     `json:"name" db:"nome"`
	CNPJ           *string    `json:"cnpj,omitempty" db:"cnpj"`
	Address        *string    `json:"address,omitempty" db:"endereco"`
	CEP            *string    `json:"cep,omitempty" db:"cep"`
	City           *string    `json:"city,omitempty" db:"cidade"`
	State          *string    `json:"state,omitempty" db:"estado"`
	Phone          *string    `json:"phone,omitempty" db:"telefone"`
	Email          *string    `json:"email,omitempty" db:"email"`
	FoundationDate *time.Time `json:"foundation_date,omitempty" db:"data_fundacao"`
	ManagerID      *int       `json:"manager_id,omitempty" db:"sindico_id"`
	Active         bool       `json:"active" db:"ativo"`
	CreatedAt      time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time  `json:"updated_at" db:"updated_at"`
}

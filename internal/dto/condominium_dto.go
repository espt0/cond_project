package dto

import (
	"time"
)

type CreateCondominiumInput struct {
	Name           string     `json:"name" db:"nome" validate:"required,min=3,max=200"`
	CNPJ           *string    `json:"cnpj,omitempty" db:"cnpj" validate:"omitempty,cnpj"` // customizada
	Address        *string    `json:"address,omitempty" db:"endereco" validate:"omitempty,max=500"`
	CEP            *string    `json:"cep,omitempty" db:"cep" validate:"omitempty,len=8"`
	City           *string    `json:"city,omitempty" db:"cidade" validate:"omitempty,max=100"`
	State          *string    `json:"state,omitempty" db:"estado" validate:"omitempty,len=2,uppercase"`
	Phone          *string    `json:"phone,omitempty" db:"telefone" validate:"omitempty,min=10,max=20"`
	Email          *string    `json:"email,omitempty" db:"email" validate:"omitempty,email,max=100"`
	FoundationDate *time.Time `json:"foundation_date,omitempty" db:"data_fundacao"` // não pode ser futura
	ManagerID      *int       `json:"manager_id,omitempty" db:"sindico_id" validate:"omitempty,min=1"`
}

type UpdateCondominiumInput struct {
	Name           *string    `json:"name" db:"nome" validate:"omitempty,min=3,max=200"`
	CNPJ           *string    `json:"cnpj,omitempty" db:"cnpj"` // customizada
	Address        *string    `json:"address,omitempty" db:"endereco" validate:"omitempty,max=500"`
	CEP            *string    `json:"cep,omitempty" db:"cep" validate:"omitempty,len=8"`
	City           *string    `json:"city,omitempty" db:"cidade" validate:"omitempty,max=100"`
	State          *string    `json:"state,omitempty" db:"estado" validate:"omitempty,len=2,uppercase"`
	Phone          *string    `json:"phone,omitempty" db:"telefone" validate:"omitempty,min=10,max=20"`
	Email          *string    `json:"email,omitempty" db:"email" validate:"omitempty,email,max=100"`
	FoundationDate *time.Time `json:"foundation_date,omitempty" db:"data_fundacao"` // não pode ser futura
	ManagerID      *int       `json:"manager_id,omitempty" db:"sindico_id" validate:"omitempty,min=1"`
}

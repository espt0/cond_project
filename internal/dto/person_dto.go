package dto

import (
	"time"
)

type CreatePersonInput struct {
	Name       string     `json:"name" db:"nome" validate:"required,min=2,max=200"`
	CPF        *string    `json:"cpf,omitempty" db:"cpf" validate:"omitempty,cpf"`                   // customizada
	RG         *string    `json:"rg,omitempty" db:"rg" validate:"omitempty,max=20"`                  // customizada
	BirthDate  *time.Time `json:"birth_date,omitempty" db:"data_nascimento" validate:"omitempty,lt"` // deve ser no passado
	Phone      *string    `json:"phone,omitempty" db:"telefone" validate:"omitempty,min=10,max=20"`
	Mobile     *string    `json:"mobile,omitempty" db:"celular" validate:"omitempty,min=10,max=20"`
	Email      *string    `json:"email,omitempty" db:"email" validate:"omitempty,email,max=100"`
	Occupation *string    `json:"occupation,omitempty" db:"profissao" validate:"omitempty,max=100"`
}

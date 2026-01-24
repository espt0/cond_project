package models

import (
	"time"
)

type Person struct {
	ID         int        `json:"id" db:"id"`
	Name       string     `json:"name" db:"nome"`
	CPF        *string    `json:"cpf,omitempty" db:"cpf"`
	RG         *string    `json:"rg,omitempty" db:"rg"`
	BirthDate  *time.Time `json:"birth_date,omitempty" db:"data_nascimento"`
	Phone      *string    `json:"phone,omitempty" db:"telefone"`
	Mobile     *string    `json:"mobile,omitempty" db:"celular"`
	Email      *string    `json:"email,omitempty" db:"email"`
	Occupation *string    `json:"occupation,omitempty" db:"profissao"`
	CreatedAt  time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt  time.Time  `json:"updated_at" db:"updated_at"`
}

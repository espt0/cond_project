package models

import (
	"time"
)

type AccountPayable struct {
	ID            int        `json:"id" db:"id"`
	CondominiumID int        `json:"condominium_id" db:"condominio_id"`
	CategoryID    *int       `json:"category_id,omitempty" db:"categoria_id"`
	SupplierID    *int       `json:"supplier_id,omitempty" db:"fornecedor_id"`
	Description   string     `json:"description" db:"descricao"`
	Amount        float64    `json:"amount" db:"valor"`
	DueDate       time.Time  `json:"due_date" db:"data_vencimento"`
	PaymentDate   *time.Time `json:"payment_date,omitempty" db:"data_pagamento"`
	Status        string     `json:"status" db:"status"`                            // pending, paid, cancelled
	PaymentMethod *string    `json:"payment_method,omitempty" db:"forma_pagamento"` // cash, transfer, check, etc
	Notes         *string    `json:"notes,omitempty" db:"observacoes"`
	CreatedAt     time.Time  `json:"created_at" db:"created_at"`
}

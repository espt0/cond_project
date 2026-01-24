package models

import (
	"time"
)

type AccountReceivable struct {
	ID             int        `json:"id" db:"id"`
	CondominiumID  int        `json:"condominium_id" db:"condominio_id"`
	UnitID         int        `json:"unit_id" db:"unidade_id"`
	CategoryID     *int       `json:"category_id,omitempty" db:"categoria_id"`
	ReferenceMonth time.Time  `json:"reference_month" db:"competencia"` // Month/year reference
	OriginalAmount float64    `json:"original_amount" db:"valor_original"`
	DiscountAmount float64    `json:"discount_amount" db:"valor_desconto"`
	InterestAmount float64    `json:"interest_amount" db:"valor_juros"`
	FineAmount     float64    `json:"fine_amount" db:"valor_multa"`
	PaidAmount     float64    `json:"paid_amount" db:"valor_pago"`
	DueDate        time.Time  `json:"due_date" db:"data_vencimento"`
	PaymentDate    *time.Time `json:"payment_date,omitempty" db:"data_pagamento"`
	Status         string     `json:"status" db:"status"` // pending, paid, overdue, cancelled
	Notes          *string    `json:"notes,omitempty" db:"observacoes"`
	CreatedAt      time.Time  `json:"created_at" db:"created_at"`
}

package models

import (
	"time"
)

type Transaction struct {
	ID                  int       `json:"id" db:"id"`
	CondominiumID       int       `json:"condominium_id" db:"condominio_id"`
	Type                string    `json:"type" db:"tipo"` // income or expense
	Amount              float64   `json:"amount" db:"valor"`
	TransactionDate     time.Time `json:"transaction_date" db:"data_movimentacao"`
	Description         *string   `json:"description,omitempty" db:"descricao"`
	AccountReceivableID *int      `json:"account_receivable_id,omitempty" db:"conta_receber_id"`
	AccountPayableID    *int      `json:"account_payable_id,omitempty" db:"conta_pagar_id"`
	CreatedAt           time.Time `json:"created_at" db:"created_at"`
}

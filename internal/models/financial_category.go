package models

type FinancialCategory struct {
	ID            int     `json:"id" db:"id"`
	CondominiumID int     `json:"condominium_id" db:"condominio_id"`
	Name          string  `json:"name" db:"nome"`
	Type          string  `json:"type" db:"tipo"` // revenue or expense
	Description   *string `json:"description,omitempty" db:"descricao"`
	Active        bool    `json:"active" db:"ativo"`
}

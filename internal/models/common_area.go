package models

import (
	"time"
)

type CommonArea struct {
	ID                 int       `json:"id" db:"id"`
	CondominiumID      int       `json:"condominium_id" db:"condominio_id"`
	Name               string    `json:"name" db:"nome"`
	Description        *string   `json:"description,omitempty" db:"descricao"`
	Capacity           *int      `json:"capacity,omitempty" db:"capacidade_pessoas"`
	ReservationFee     *float64  `json:"reservation_fee,omitempty" db:"valor_reserva"`
	MinReservationTime *int      `json:"min_reservation_time,omitempty" db:"tempo_minimo_reserva"` // In hours
	MaxReservationTime *int      `json:"max_reservation_time,omitempty" db:"tempo_maximo_reserva"` // In hours
	OpeningTime        *string   `json:"opening_time,omitempty" db:"horario_inicio"`               // TIME format
	ClosingTime        *string   `json:"closing_time,omitempty" db:"horario_fim"`                  // TIME format
	Active             bool      `json:"active" db:"ativo"`
	CreatedAt          time.Time `json:"created_at" db:"created_at"`
}

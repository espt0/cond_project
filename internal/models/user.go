package models

import (
	"time"
)

type User struct {
	ID           int        `json:"id" db:"id"`
	PersonID     int        `json:"person_id" db:"pessoa_id"`
	Username     string     `json:"username" db:"username"`
	PasswordHash string     `json:"-" db:"password_hash"`
	Type         string     `json:"type" db:"tipo"` // admin, manager, resident, employee
	Active       bool       `json:"active" db:"ativo"`
	LastAccess   *time.Time `json:"last_access,omitempty" db:"ultimo_acesso"`
	CreatedAt    time.Time  `json:"created_at" db:"created_at"`
}

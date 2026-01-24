package models

import (
	"time"
)

type Announcement struct {
	ID              int        `json:"id" db:"id"`
	CondominiumID   int        `json:"condominium_id" db:"condominio_id"`
	AuthorID        *int       `json:"author_id,omitempty" db:"autor_id"`
	Title           string     `json:"title" db:"titulo"`
	Content         string     `json:"content" db:"conteudo"`
	Type            *string    `json:"type,omitempty" db:"tipo"` // notice, assembly, maintenance, urgent
	Priority        string     `json:"priority" db:"prioridade"` // low, normal, high
	PublicationDate time.Time  `json:"publication_date" db:"data_publicacao"`
	ExpirationDate  *time.Time `json:"expiration_date,omitempty" db:"data_expiracao"`
	Active          bool       `json:"active" db:"ativo"`
}

package repositories

import (
	"context"
	"fmt"
	"time"

	"github.com/espt0/cond_project/internal/models"
	"github.com/jmoiron/sqlx"
)

// CONDOMÍNIO
type PostgresqlRepository struct {
	db *sqlx.DB
}

func NewPostgresqlRepository(db *sqlx.DB) *PostgresqlRepository {
	return &PostgresqlRepository{db: db}
}

// MÉTODOS
func (c *PostgresqlRepository) FindAll(ctx context.Context) ([]models.Condominium, error) {
	condominios := make([]models.Condominium, 0)

	query := "SELECT * FROM condominios"
	err := c.db.Select(&condominios, query)
	if err != nil {
		return nil, fmt.Errorf("erro ao listar condomínios: %w", err)
	}

	return condominios, nil
}

func (c *PostgresqlRepository) Create(ctx context.Context, cond *models.Condominium) error {
	query := `INSERT INTO condominios (nome, cnpj, endereco, cep, cidade, estado, telefone, email, data_fundacao, sindico_id, ativo, created_at, updated_at)
	VALUES (:nome, :cnpj, :endereco, :cep, :cidade, :estado, :telefone, :email, :data_fundacao, :sindico_id, :ativo, :created_at, :updated_at)
	RETURNING id, created_at, updated_at`

	//Deinindo timestamps
	now := time.Now()
	cond.CreatedAt = now
	cond.UpdatedAt = now

	//Executa a query
	rows, err := c.db.NamedQueryContext(ctx, query, cond)
	if err != nil {
		return fmt.Errorf("erro ao executar a query: %w", err)
	}
	defer rows.Close()

	//Valores retornados 'RETURNING'
	if !rows.Next() {
		return fmt.Errorf("nenhuma linha retornada após inserção")
	}
	err = rows.Scan(&cond.ID, &cond.CreatedAt, &cond.UpdatedAt)
	if err != nil {
		return fmt.Errorf("erro ao escanear resultados: %w", err)
	}

	return rows.Err()
}

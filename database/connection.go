package database

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

var DB *sqlx.DB

func Connect() error {
	//Variáveis de ambiente
	host := os.Getenv("DB_HOST")
	port := os.Getenv("DB_PORT")
	user := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASSWORD")
	dbname := os.Getenv("DB_DBNAME")

	if host == "" {
		host = "localhost"
	}
	if port == "" {
		port = "5432"
	}
	if user == "" {
		user = "postgres"
	}
	if dbname == "" {
		dbname = "conddb"
	}
	if password == "" {
		password = "1234"
	}

	//String de conexão
	connStr := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s", host, port, user, password, dbname,
	)

	//Conexão
	var err error
	DB, err = sqlx.Connect("postgres", connStr)
	if err != nil {
		return fmt.Errorf("erro ao conetar no banco de dados: %w", err)
	}

	//Configuração do pool
	DB.SetMaxOpenConns(25)
	DB.SetMaxIdleConns(5)
	DB.SetConnMaxLifetime(5 * time.Minute)

	log.Println("Conexão com o banco de dados (sqlx) estabelecida com sucesso!")
	return nil
}

// Fechando conexão
func Close() error {
	if DB != nil {
		log.Println("Fechando conexão com o banco de dados...")
		return DB.Close()
	}
	return nil
}

// Instância da conexão
func GetDB() *sqlx.DB {
	return DB
}

-- +goose Up
-- +goose StatementBegin
-- MIGRATION 001: MÓDULO DE ESTRUTURA DO CONDOMÍNIO
CREATE TABLE condominios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    cnpj VARCHAR(18) UNIQUE,
    endereco TEXT,
    cep VARCHAR(10),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    telefone VARCHAR(20),
    email VARCHAR(100),
    data_fundacao DATE,
    sindico_id INTEGER, -- FK será adicionada na migration 002
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE condominios IS 'Cadastro principal dos condomínios gerenciados';
COMMENT ON COLUMN condominios.cnpj IS 'CNPJ no formato 00.000.000/0000-00';
COMMENT ON COLUMN condominios.sindico_id IS 'Referência ao síndico atual do condomínio';

CREATE TABLE blocos (
    id SERIAL PRIMARY KEY,
    condominio_id INTEGER NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(condominio_id, nome)
);

COMMENT ON TABLE blocos IS 'Blocos ou torres dentro de cada condomínio';

CREATE TABLE unidades (
    id SERIAL PRIMARY KEY,
    condominio_id INTEGER NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    bloco_id INTEGER REFERENCES blocos(id) ON DELETE SET NULL,
    numero VARCHAR(20) NOT NULL,
    tipo VARCHAR(50) CHECK (tipo IN ('apartamento', 'casa', 'sala_comercial', 'garagem')),
    area_m2 DECIMAL(10,2),
    fracao_ideal DECIMAL(10,6),
    quartos INTEGER,
    banheiros INTEGER,
    vagas_garagem INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(condominio_id, bloco_id, numero)
);

COMMENT ON TABLE unidades IS 'Unidades habitacionais ou comerciais do condomínio';
COMMENT ON COLUMN unidades.fracao_ideal IS 'Porcentagem para rateio de despesas comuns';
COMMENT ON COLUMN unidades.tipo IS 'Tipo: apartamento, casa, sala_comercial ou garagem';

CREATE INDEX idx_unidades_condominio ON unidades(condominio_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- REVERTER MIGRATION 001
DROP INDEX IF EXISTS idx_unidades_condominio;
DROP TABLE IF EXISTS unidades;
DROP TABLE IF EXISTS blocos;
DROP TABLE IF EXISTS condominios;
-- +goose StatementEnd

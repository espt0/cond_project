-- +goose Up
-- +goose StatementBegin
-- MIGRATION 006: MÓDULO DE CONTROLE DE ACESSO
CREATE TABLE visitantes (
    id SERIAL PRIMARY KEY,
    unidade_id INTEGER NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    nome VARCHAR(200) NOT NULL,
    cpf VARCHAR(14),
    telefone VARCHAR(20),
    data_entrada TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_saida TIMESTAMP,
    tipo_visita VARCHAR(50) CHECK (tipo_visita IN ('social', 'prestador_servico', 'entrega')),
    autorizado_por INTEGER REFERENCES pessoas(id) ON DELETE SET NULL,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE visitantes IS 'Registro de entrada e saída de visitantes';
COMMENT ON COLUMN visitantes.tipo_visita IS 'Tipo: social, prestador_servico ou entrega';

-- Índices para consultas frequentes na portaria
-- O primeiro ajuda a ver todos os visitantes de uma unidade
CREATE INDEX idx_visitantes_unidade ON visitantes(unidade_id);
-- O segundo facilita ver quem entrou recentemente
CREATE INDEX idx_visitantes_data_entrada ON visitantes(data_entrada DESC);

-- Cadastro de veículos autorizados dos moradores
-- Facilita a identificação na portaria e controle de vagas
CREATE TABLE veiculos (
    id SERIAL PRIMARY KEY,
    unidade_id INTEGER NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    placa VARCHAR(10) NOT NULL,
    modelo VARCHAR(100),
    cor VARCHAR(50),
    tipo VARCHAR(50) CHECK (tipo IN ('carro', 'moto', 'caminhao')),
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(placa)
);

COMMENT ON TABLE veiculos IS 'Cadastro de veículos dos moradores';
COMMENT ON COLUMN veiculos.tipo IS 'Tipo: carro, moto ou caminhao';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- REVERTER MIGRATION 006
-- Remover índices
DROP INDEX IF EXISTS idx_visitantes_data_entrada;
DROP INDEX IF EXISTS idx_visitantes_unidade;

-- Remover tabelas
DROP TABLE IF EXISTS veiculos;
DROP TABLE IF EXISTS visitantes;
-- +goose StatementEnd

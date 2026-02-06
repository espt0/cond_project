-- +goose Up
-- +goose StatementBegin
-- MIGRATION 005: MÓDULO DE COMUNICAÇÃO
CREATE TABLE comunicados (
    id SERIAL PRIMARY KEY,
    condominio_id INTEGER NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    autor_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
    titulo VARCHAR(200) NOT NULL,
    conteudo TEXT NOT NULL,
    tipo VARCHAR(50) CHECK (tipo IN ('aviso', 'assembleia', 'manutencao', 'urgente')),
    prioridade VARCHAR(20) DEFAULT 'normal' CHECK (prioridade IN ('baixa', 'normal', 'alta')),
    data_publicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_expiracao TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE comunicados IS 'Avisos e comunicados oficiais da administração';
COMMENT ON COLUMN comunicados.tipo IS 'Tipo: aviso, assembleia, manutencao ou urgente';

-- Índice composto para listar comunicados ativos de forma eficiente
-- Este índice é importante porque a consulta mais comum será
-- "mostre-me os comunicados ativos do condomínio X, ordenados por data"
CREATE INDEX idx_comunicados_ativo ON comunicados(condominio_id, ativo, data_publicacao DESC);

-- Ocorrências, reclamações e sugestões dos moradores
-- Esta tabela permite que moradores registrem problemas e
-- que a administração acompanhe o status de resolução
CREATE TABLE ocorrencias (
    id SERIAL PRIMARY KEY,
    condominio_id INTEGER NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    unidade_id INTEGER REFERENCES unidades(id) ON DELETE SET NULL,
    pessoa_id INTEGER REFERENCES pessoas(id) ON DELETE SET NULL,
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT NOT NULL,
    tipo VARCHAR(50) CHECK (tipo IN ('reclamacao', 'sugestao', 'manutencao', 'seguranca')),
    status VARCHAR(20) DEFAULT 'aberta' CHECK (status IN ('aberta', 'em_andamento', 'resolvida', 'fechada')),
    prioridade VARCHAR(20) DEFAULT 'normal' CHECK (prioridade IN ('baixa', 'normal', 'alta', 'urgente')),
    data_abertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_conclusao TIMESTAMP,
    resposta TEXT
);

COMMENT ON TABLE ocorrencias IS 'Ocorrências, reclamações e sugestões dos moradores';
COMMENT ON COLUMN ocorrencias.tipo IS 'Tipo: reclamacao, sugestao, manutencao ou seguranca';
COMMENT ON COLUMN ocorrencias.status IS 'Status: aberta, em_andamento, resolvida ou fechada';

-- Índices para facilitar a gestão de ocorrências
-- O primeiro índice ajuda a listar ocorrências por status e data
CREATE INDEX idx_ocorrencias_status ON ocorrencias(status, data_abertura DESC);
-- O segundo facilita listar todas as ocorrências de um condomínio
CREATE INDEX idx_ocorrencias_condominio ON ocorrencias(condominio_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- REVERTER MIGRATION 005
-- Remover índices
DROP INDEX IF EXISTS idx_ocorrencias_condominio;
DROP INDEX IF EXISTS idx_ocorrencias_status;
DROP INDEX IF EXISTS idx_comunicados_ativo;

-- Remover tabelas
DROP TABLE IF EXISTS ocorrencias;
DROP TABLE IF EXISTS comunicados;
-- +goose StatementEnd

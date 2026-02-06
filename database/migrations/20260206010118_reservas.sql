-- +goose Up
-- +goose StatementBegin
-- MIGRATION 004: MÓDULO DE RESERVAS
CREATE TABLE areas_comuns (
    id SERIAL PRIMARY KEY,
    condominio_id INTEGER NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    capacidade_pessoas INTEGER,
    valor_reserva DECIMAL(10,2) DEFAULT 0,
    tempo_minimo_reserva INTEGER,
    tempo_maximo_reserva INTEGER,
    horario_inicio TIME DEFAULT '08:00',
    horario_fim TIME DEFAULT '22:00',
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE areas_comuns IS 'Áreas comuns disponíveis para reserva pelos moradores';
COMMENT ON COLUMN areas_comuns.tempo_minimo_reserva IS 'Tempo mínimo de reserva em horas';
COMMENT ON COLUMN areas_comuns.tempo_maximo_reserva IS 'Tempo máximo de reserva em horas';

-- Agora criamos a tabela de agendamentos
-- Esta tabela depende de areas_comuns (qual área está sendo reservada),
-- unidades (qual unidade está fazendo a reserva) e pessoas (quem é o responsável)
CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    area_comum_id INTEGER NOT NULL REFERENCES areas_comuns(id) ON DELETE CASCADE,
    unidade_id INTEGER NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    pessoa_id INTEGER NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
    data_inicio TIMESTAMP NOT NULL,
    data_fim TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'confirmada' CHECK (status IN ('confirmada', 'cancelada', 'concluida')),
    valor_pago DECIMAL(10,2) DEFAULT 0,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE reservas IS 'Agendamentos de áreas comuns pelos moradores';
COMMENT ON COLUMN reservas.status IS 'Status: confirmada, cancelada ou concluida';

-- Índices para otimizar consultas de disponibilidade
-- Estes índices são importantes para verificar rapidamente se
-- uma área está disponível em determinado período
CREATE INDEX idx_reservas_area ON reservas(area_comum_id);
CREATE INDEX idx_reservas_data ON reservas(data_inicio, data_fim);
CREATE INDEX idx_reservas_unidade ON reservas(unidade_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- REVERTER MIGRATION 004
-- Remover índices
DROP INDEX IF EXISTS idx_reservas_unidade;
DROP INDEX IF EXISTS idx_reservas_data;
DROP INDEX IF EXISTS idx_reservas_area;

-- Remover tabelas na ordem inversa
DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS areas_comuns;
-- +goose StatementEnd

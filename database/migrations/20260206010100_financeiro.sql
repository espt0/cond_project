-- +goose Up
-- +goose StatementBegin
-- MIGRATION 003: MÓDULO FINANCEIRO
CREATE TABLE categorias_financeiras (
    id SERIAL PRIMARY KEY,
    condominio_id INTEGER NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('receita', 'despesa')),
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    UNIQUE(condominio_id, nome, tipo)
);

COMMENT ON TABLE categorias_financeiras IS 'Categorias para classificação de receitas e despesas';
COMMENT ON COLUMN categorias_financeiras.tipo IS 'Tipo: receita ou despesa';

-- Agora as contas a receber (boletos das unidades)
CREATE TABLE contas_receber (
    id SERIAL PRIMARY KEY,
    condominio_id INTEGER NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    unidade_id INTEGER NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    categoria_id INTEGER REFERENCES categorias_financeiras(id) ON DELETE SET NULL,
    competencia DATE NOT NULL,
    valor_original DECIMAL(10,2) NOT NULL,
    valor_desconto DECIMAL(10,2) DEFAULT 0,
    valor_juros DECIMAL(10,2) DEFAULT 0,
    valor_multa DECIMAL(10,2) DEFAULT 0,
    valor_pago DECIMAL(10,2) DEFAULT 0,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'pago', 'atrasado', 'cancelado')),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE contas_receber IS 'Boletos e taxas a receber das unidades';
COMMENT ON COLUMN contas_receber.competencia IS 'Mês/ano de referência da cobrança';
COMMENT ON COLUMN contas_receber.status IS 'Status: pendente, pago, atrasado ou cancelado';

-- Índices para otimizar consultas financeiras frequentes
CREATE INDEX idx_contas_receber_unidade ON contas_receber(unidade_id);
CREATE INDEX idx_contas_receber_status ON contas_receber(status);
CREATE INDEX idx_contas_receber_competencia ON contas_receber(competencia);
CREATE INDEX idx_contas_receber_vencimento ON contas_receber(data_vencimento);

-- Contas a pagar (despesas do condomínio)
CREATE TABLE contas_pagar (
    id SERIAL PRIMARY KEY,
    condominio_id INTEGER NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    categoria_id INTEGER REFERENCES categorias_financeiras(id) ON DELETE SET NULL,
    fornecedor_id INTEGER REFERENCES pessoas(id) ON DELETE SET NULL,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'pago', 'atrasado', 'cancelado')),
    forma_pagamento VARCHAR(50),
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE contas_pagar IS 'Despesas e contas a pagar do condomínio';
COMMENT ON COLUMN contas_pagar.fornecedor_id IS 'Referência a fornecedores cadastrados na tabela pessoas';
COMMENT ON COLUMN contas_pagar.forma_pagamento IS 'Ex: PIX, TED, Boleto, Dinheiro';

CREATE INDEX idx_contas_pagar_status ON contas_pagar(status);
CREATE INDEX idx_contas_pagar_vencimento ON contas_pagar(data_vencimento);
CREATE INDEX idx_contas_pagar_condominio ON contas_pagar(condominio_id);

-- Livro caixa - registro de todas as movimentações
-- Esta tabela vem por último porque referencia as duas anteriores
CREATE TABLE movimentacoes (
    id SERIAL PRIMARY KEY,
    condominio_id INTEGER NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('entrada', 'saida')),
    valor DECIMAL(10,2) NOT NULL,
    data_movimentacao DATE NOT NULL,
    descricao TEXT,
    conta_receber_id INTEGER REFERENCES contas_receber(id) ON DELETE SET NULL,
    conta_pagar_id INTEGER REFERENCES contas_pagar(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE movimentacoes IS 'Livro caixa - registro de todas as movimentações financeiras';
COMMENT ON COLUMN movimentacoes.tipo IS 'Tipo: entrada ou saida';

CREATE INDEX idx_movimentacoes_condominio_data ON movimentacoes(condominio_id, data_movimentacao DESC);

-- Agora criamos a função que atualiza automaticamente o status
-- baseado nas datas de vencimento e pagamento
CREATE OR REPLACE FUNCTION atualizar_status_financeiro()
RETURNS TRIGGER AS $$
BEGIN
    -- Se foi pago, marca como pago
    IF NEW.data_pagamento IS NOT NULL THEN
        NEW.status = 'pago';
    -- Se passou do vencimento e não foi pago, marca como atrasado
    ELSIF NEW.data_vencimento < CURRENT_DATE AND NEW.data_pagamento IS NULL THEN
        NEW.status = 'atrasado';
    -- Caso contrário, mantém como pendente
    ELSIF NEW.status NOT IN ('cancelado', 'pago') THEN
        NEW.status = 'pendente';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar o trigger em contas a receber
-- Este trigger roda ANTES de inserir ou atualizar, garantindo
-- que o status esteja sempre correto
CREATE TRIGGER trigger_status_conta_receber 
    BEFORE INSERT OR UPDATE ON contas_receber
    FOR EACH ROW 
    EXECUTE FUNCTION atualizar_status_financeiro();

-- Aplicar o mesmo trigger em contas a pagar
CREATE TRIGGER trigger_status_conta_pagar 
    BEFORE INSERT OR UPDATE ON contas_pagar
    FOR EACH ROW 
    EXECUTE FUNCTION atualizar_status_financeiro()
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- REVERTER MIGRATION 003
-- Remover triggers primeiro
DROP TRIGGER IF EXISTS trigger_status_conta_pagar ON contas_pagar;
DROP TRIGGER IF EXISTS trigger_status_conta_receber ON contas_receber;

-- Remover a função agora que nenhum trigger a usa
DROP FUNCTION IF EXISTS atualizar_status_financeiro();

-- Remover índices (opcional, mas deixo explícito para clareza)
DROP INDEX IF EXISTS idx_movimentacoes_condominio_data;
DROP INDEX IF EXISTS idx_contas_pagar_condominio;
DROP INDEX IF EXISTS idx_contas_pagar_vencimento;
DROP INDEX IF EXISTS idx_contas_pagar_status;
DROP INDEX IF EXISTS idx_contas_receber_vencimento;
DROP INDEX IF EXISTS idx_contas_receber_competencia;
DROP INDEX IF EXISTS idx_contas_receber_status;
DROP INDEX IF EXISTS idx_contas_receber_unidade;

-- Remover tabelas na ordem inversa da criação
-- movimentacoes depende de contas_receber e contas_pagar
DROP TABLE IF EXISTS movimentacoes;
-- contas_pagar e contas_receber dependem de categorias_financeiras
DROP TABLE IF EXISTS contas_pagar;
DROP TABLE IF EXISTS contas_receber;
-- categorias_financeiras não depende de nenhuma tabela deste módulo
DROP TABLE IF EXISTS categorias_financeiras;
-- +goose StatementEnd

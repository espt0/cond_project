-- SCHEMA POSTGRESQL - SISTEMA DE CONDOMÍNIOS
-- ========================================
-- MÓDULO: ESTRUTURA DO CONDOMÍNIO
-- ========================================

-- Tabela principal de condomínios
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
    sindico_id INTEGER, -- FK será adicionada depois que a tabela pessoas existir
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE condominios IS 'Cadastro principal dos condomínios gerenciados';
COMMENT ON COLUMN condominios.cnpj IS 'CNPJ no formato 00.000.000/0000-00';
COMMENT ON COLUMN condominios.sindico_id IS 'Referência ao síndico atual do condomínio';

-- Blocos ou torres dentro de cada condomínio
CREATE TABLE blocos (
    id SERIAL PRIMARY KEY,
    condominio_id INTEGER NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(condominio_id, nome)
);

COMMENT ON TABLE blocos IS 'Blocos ou torres dentro de cada condomínio';

-- Unidades habitacionais ou comerciais
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

-- Índice para consultas por condomínio
CREATE INDEX idx_unidades_condominio ON unidades(condominio_id);

-- ========================================
-- MÓDULO: PESSOAS E USUÁRIOS
-- ========================================

-- Cadastro geral de pessoas
CREATE TABLE pessoas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    rg VARCHAR(20),
    data_nascimento DATE,
    telefone VARCHAR(20),
    celular VARCHAR(20),
    email VARCHAR(100),
    profissao VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE pessoas IS 'Cadastro geral de pessoas (proprietários, inquilinos, moradores, fornecedores)';
COMMENT ON COLUMN pessoas.cpf IS 'CPF no formato 000.000.000-00';

-- Índices para buscas frequentes
CREATE INDEX idx_pessoas_cpf ON pessoas(cpf) WHERE cpf IS NOT NULL;
CREATE INDEX idx_pessoas_email ON pessoas(email) WHERE email IS NOT NULL;

-- Relacionamento N:N entre pessoas e unidades com histórico
CREATE TABLE pessoa_unidade (
    id SERIAL PRIMARY KEY,
    pessoa_id INTEGER NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
    unidade_id INTEGER NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    tipo_vinculo VARCHAR(50) NOT NULL CHECK (tipo_vinculo IN ('proprietario', 'inquilino', 'morador')),
    data_inicio DATE NOT NULL DEFAULT CURRENT_DATE,
    data_fim DATE,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(pessoa_id, unidade_id, tipo_vinculo, data_inicio)
);

COMMENT ON TABLE pessoa_unidade IS 'Relacionamento entre pessoas e unidades com histórico temporal';
COMMENT ON COLUMN pessoa_unidade.tipo_vinculo IS 'Tipo: proprietario, inquilino ou morador';

-- Índice para consultas de vínculos ativos
CREATE INDEX idx_pessoa_unidade_ativo ON pessoa_unidade(unidade_id, ativo);
CREATE INDEX idx_pessoa_unidade_pessoa ON pessoa_unidade(pessoa_id);

-- Usuários com acesso ao sistema
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    pessoa_id INTEGER NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('admin', 'sindico', 'morador', 'funcionario')),
    ativo BOOLEAN DEFAULT TRUE,
    ultimo_acesso TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE usuarios IS 'Usuários com acesso ao sistema';
COMMENT ON COLUMN usuarios.password_hash IS 'Hash bcrypt da senha';
COMMENT ON COLUMN usuarios.tipo IS 'Tipo de usuário: admin, sindico, morador ou funcionario';

-- Índice para login
CREATE INDEX idx_usuarios_username ON usuarios(username) WHERE ativo = TRUE;

-- ========================================
-- FOREIGN KEY ADICIONAL
-- ========================================

-- Agora que a tabela pessoas existe, podemos adicionar a FK do síndico
ALTER TABLE condominios 
ADD CONSTRAINT fk_condominios_sindico 
FOREIGN KEY (sindico_id) REFERENCES pessoas(id) ON DELETE SET NULL;

-- ========================================
-- MÓDULO: FINANCEIRO
-- ========================================

-- Categorias para classificação de receitas e despesas
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

-- Contas a receber (boletos e taxas)
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

-- Índices para consultas financeiras
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

-- Índices para gestão de despesas
CREATE INDEX idx_contas_pagar_status ON contas_pagar(status);
CREATE INDEX idx_contas_pagar_vencimento ON contas_pagar(data_vencimento);
CREATE INDEX idx_contas_pagar_condominio ON contas_pagar(condominio_id);

-- Livro caixa - todas as movimentações financeiras
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

-- Índice para relatórios financeiros
CREATE INDEX idx_movimentacoes_condominio_data ON movimentacoes(condominio_id, data_movimentacao DESC);

-- ========================================
-- MÓDULO: RESERVAS DE ÁREAS COMUNS
-- ========================================

-- Áreas comuns disponíveis para reserva
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

-- Agendamentos de áreas comuns
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

-- Índices para consultas de disponibilidade
CREATE INDEX idx_reservas_area ON reservas(area_comum_id);
CREATE INDEX idx_reservas_data ON reservas(data_inicio, data_fim);
CREATE INDEX idx_reservas_unidade ON reservas(unidade_id);

-- ========================================
-- MÓDULO: COMUNICAÇÃO
-- ========================================

-- Avisos e comunicados oficiais
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

-- Índice para listagem de comunicados ativos
CREATE INDEX idx_comunicados_ativo ON comunicados(condominio_id, ativo, data_publicacao DESC);

-- Ocorrências, reclamações e sugestões
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

-- Índices para gestão de ocorrências
CREATE INDEX idx_ocorrencias_status ON ocorrencias(status, data_abertura DESC);
CREATE INDEX idx_ocorrencias_condominio ON ocorrencias(condominio_id);

-- ========================================
-- MÓDULO: CONTROLE DE ACESSO
-- ========================================

-- Registro de entrada e saída de visitantes
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

-- Índice para consultas de visitantes
CREATE INDEX idx_visitantes_unidade ON visitantes(unidade_id);
CREATE INDEX idx_visitantes_data_entrada ON visitantes(data_entrada DESC);

-- Cadastro de veículos dos moradores
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

-- ========================================
-- TRIGGERS E FUNÇÕES
-- ========================================

-- Função para atualizar automaticamente o campo updated_at
CREATE OR REPLACE FUNCTION atualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger nas tabelas que têm updated_at
CREATE TRIGGER trigger_condominios_updated_at 
    BEFORE UPDATE ON condominios
    FOR EACH ROW 
    EXECUTE FUNCTION atualizar_updated_at();

CREATE TRIGGER trigger_pessoas_updated_at 
    BEFORE UPDATE ON pessoas
    FOR EACH ROW 
    EXECUTE FUNCTION atualizar_updated_at();

-- Função para calcular automaticamente o status de contas financeiras
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

-- Aplicar trigger em contas a receber
CREATE TRIGGER trigger_status_conta_receber 
    BEFORE INSERT OR UPDATE ON contas_receber
    FOR EACH ROW 
    EXECUTE FUNCTION atualizar_status_financeiro();

-- Aplicar trigger em contas a pagar
CREATE TRIGGER trigger_status_conta_pagar 
    BEFORE INSERT OR UPDATE ON contas_pagar
    FOR EACH ROW 
    EXECUTE FUNCTION atualizar_status_financeiro();

-- ========================================
-- VIEWS ÚTEIS
-- ========================================

-- View para ver ocupação atual das unidades
CREATE VIEW view_unidades_ocupacao AS
SELECT 
    u.id as unidade_id,
    c.nome as condominio,
    b.nome as bloco,
    u.numero,
    u.tipo,
    p.nome as ocupante,
    pu.tipo_vinculo,
    pu.data_inicio,
    pu.data_fim
FROM unidades u
INNER JOIN condominios c ON u.condominio_id = c.id
LEFT JOIN blocos b ON u.bloco_id = b.id
LEFT JOIN pessoa_unidade pu ON u.id = pu.unidade_id
LEFT JOIN pessoas p ON pu.pessoa_id = p.id
WHERE u.ativo = TRUE
ORDER BY c.nome, b.nome, u.numero;

COMMENT ON VIEW view_unidades_ocupacao IS 'Visualização da ocupação atual de todas as unidades';

-- View para relatório financeiro mensal
CREATE VIEW view_financeiro_mensal AS
SELECT 
    c.id as condominio_id,
    c.nome as condominio,
    DATE_TRUNC('month', cr.competencia) as mes_referencia,
    COUNT(DISTINCT cr.id) as total_boletos,
    SUM(cr.valor_original) as total_previsto,
    SUM(CASE WHEN cr.status = 'pago' THEN cr.valor_pago ELSE 0 END) as total_recebido,
    SUM(CASE WHEN cr.status IN ('pendente', 'atrasado') THEN cr.valor_original ELSE 0 END) as total_pendente
FROM condominios c
LEFT JOIN contas_receber cr ON c.id = cr.condominio_id
GROUP BY c.id, c.nome, DATE_TRUNC('month', cr.competencia)
ORDER BY c.nome, mes_referencia DESC;

COMMENT ON VIEW view_financeiro_mensal IS 'Resumo financeiro mensal por condomínio';

-- ========================================
-- DADOS INICIAIS (OPCIONAL)
-- ========================================

-- Inserir categorias financeiras padrão para facilitar início
-- Você pode executar isso após criar um condomínio

-- INSERT INTO categorias_financeiras (condominio_id, nome, tipo, descricao) VALUES
-- (1, 'Taxa de Condomínio', 'receita', 'Cobrança mensal padrão'),
-- (1, 'Fundo de Reserva', 'receita', 'Contribuição para fundo de reserva'),
-- (1, 'Taxa de Uso - Salão de Festas', 'receita', 'Locação do salão de festas'),
-- (1, 'Água', 'despesa', 'Conta de água'),
-- (1, 'Luz', 'despesa', 'Conta de energia elétrica'),
-- (1, 'Limpeza', 'despesa', 'Serviços de limpeza'),
-- (1, 'Segurança', 'despesa', 'Serviços de segurança/portaria'),
-- (1, 'Manutenção', 'despesa', 'Manutenções diversas'),
-- (1, 'Jardinagem', 'despesa', 'Serviços de jardinagem');

-- ========================================
-- FINALIZANDO
-- ========================================

-- Visualizar todas as tabelas criadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;
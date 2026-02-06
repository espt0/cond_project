-- +goose Up
-- +goose StatementBegin
-- MIGRATION 002: MÓDULO DE PESSOAS
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

CREATE INDEX idx_pessoas_cpf ON pessoas(cpf) WHERE cpf IS NOT NULL;
CREATE INDEX idx_pessoas_email ON pessoas(email) WHERE email IS NOT NULL;

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

CREATE INDEX idx_pessoa_unidade_ativo ON pessoa_unidade(unidade_id, ativo);
CREATE INDEX idx_pessoa_unidade_pessoa ON pessoa_unidade(pessoa_id);

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

CREATE INDEX idx_usuarios_username ON usuarios(username) WHERE ativo = TRUE;

-- a foreign key do síndico que ficou pendente!
ALTER TABLE condominios 
ADD CONSTRAINT fk_condominios_sindico 
FOREIGN KEY (sindico_id) REFERENCES pessoas(id) ON DELETE SET NULL;

-- Criar os triggers para updated_at
CREATE OR REPLACE FUNCTION atualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_condominios_updated_at 
    BEFORE UPDATE ON condominios
    FOR EACH ROW 
    EXECUTE FUNCTION atualizar_updated_at();

CREATE TRIGGER trigger_pessoas_updated_at 
    BEFORE UPDATE ON pessoas
    FOR EACH ROW 
    EXECUTE FUNCTION atualizar_updated_at();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- REVERTER MIGRATION 002
-- Remover a FK do síndico que adicionamos
ALTER TABLE condominios DROP CONSTRAINT IF EXISTS fk_condominios_sindico;

-- Remover os triggers
DROP TRIGGER IF EXISTS trigger_pessoas_updated_at ON pessoas;
DROP TRIGGER IF EXISTS trigger_condominios_updated_at ON condominios;

-- Remover a função (agora que nenhum trigger a usa)
DROP FUNCTION IF EXISTS atualizar_updated_at();

-- Remover os índices (opcional, pois serão removidos com as tabelas)
DROP INDEX IF EXISTS idx_usuarios_username;
DROP INDEX IF EXISTS idx_pessoa_unidade_pessoa;
DROP INDEX IF EXISTS idx_pessoa_unidade_ativo;
DROP INDEX IF EXISTS idx_pessoas_email;
DROP INDEX IF EXISTS idx_pessoas_cpf;

-- Remover as tabelas na ordem inversa da criação
DROP TABLE IF EXISTS usuarios;
DROP TABLE IF EXISTS pessoa_unidade;
DROP TABLE IF EXISTS pessoas;
-- +goose StatementEnd

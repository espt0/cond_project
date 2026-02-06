-- +goose Up
-- +goose StatementBegin
-- MIGRATION 007: VIEWS DE CONSULTA
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
-- Esta view agrega informações financeiras por mês, facilitando
-- a geração de relatórios mensais de arrecadação
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
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- REVERTER MIGRATION 007
DROP VIEW IF EXISTS view_financeiro_mensal;
DROP VIEW IF EXISTS view_unidades_ocupacao;
-- +goose StatementEnd

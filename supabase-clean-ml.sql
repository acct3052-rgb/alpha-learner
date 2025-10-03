-- ============================================
-- LIMPAR DADOS DE ML E SINAIS ANTIGOS
-- ============================================
-- Execute este script no Supabase SQL Editor
-- Isso vai apagar todos os dados antigos do sistema de ML
-- mas manter a estrutura das tabelas intacta
-- ============================================

-- Limpar histórico de evolução dos pesos de ML
TRUNCATE TABLE ml_weights_evolution;

-- Limpar todos os sinais antigos
TRUNCATE TABLE signals CASCADE;

-- Limpar logs de auditoria
TRUNCATE TABLE audit_logs;

-- Limpar estatísticas de performance
TRUNCATE TABLE performance_stats;

-- Resetar sequence IDs (opcional)
-- ALTER SEQUENCE IF EXISTS signals_id_seq RESTART WITH 1;

-- Verificar quantos registros restaram
SELECT
    'ml_weights_evolution' as tabela,
    COUNT(*) as registros
FROM ml_weights_evolution
UNION ALL
SELECT
    'signals' as tabela,
    COUNT(*) as registros
FROM signals
UNION ALL
SELECT
    'audit_logs' as tabela,
    COUNT(*) as registros
FROM audit_logs
UNION ALL
SELECT
    'performance_stats' as tabela,
    COUNT(*) as registros
FROM performance_stats;

-- ============================================
-- RESULTADO ESPERADO: Todas as tabelas com 0 registros
-- A tabela api_connections NÃO foi tocada (mantém suas configurações)
-- ============================================

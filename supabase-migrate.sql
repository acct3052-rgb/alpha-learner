-- =====================================================
-- ALPHA-LEARNER TRADING PLATFORM - SUPABASE MIGRATION
-- =====================================================
-- Este arquivo cria todas as tabelas necessárias para o sistema
-- Execute este SQL no SQL Editor do Supabase após apagar o banco antigo
-- =====================================================

-- =====================================================
-- TABELA 1: API_CONNECTIONS
-- Armazena configurações de conexões com APIs externas
-- =====================================================

CREATE TABLE IF NOT EXISTS api_connections (
    id INTEGER PRIMARY KEY DEFAULT 1,
    connections JSONB NOT NULL DEFAULT '{}'::jsonb,
    active_provider TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT single_row_check CHECK (id = 1)
);

-- Índices para api_connections
CREATE INDEX IF NOT EXISTS idx_api_connections_active ON api_connections(active_provider);

-- Comentários descritivos
COMMENT ON TABLE api_connections IS 'Armazena configurações de APIs (Binance, Alpha Vantage, Polygon, CoinGecko, AwesomeAPI)';
COMMENT ON COLUMN api_connections.connections IS 'Objeto JSON com todas as conexões configuradas';
COMMENT ON COLUMN api_connections.active_provider IS 'Provider atualmente ativo (BINANCE, ALPHA_VANTAGE, etc)';

-- =====================================================
-- TABELA 2: SIGNALS
-- Armazena todos os sinais de trading gerados pelo sistema
-- =====================================================

CREATE TABLE IF NOT EXISTS signals (
    id TEXT PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL,
    symbol TEXT NOT NULL,
    direction TEXT NOT NULL CHECK (direction IN ('BUY', 'SELL')),
    timeframe TEXT NOT NULL,
    score NUMERIC(5,2) NOT NULL,
    price NUMERIC(20,8) NOT NULL,
    stop_loss NUMERIC(20,8) NOT NULL,
    take_profit NUMERIC(20,8) NOT NULL,
    risk_reward NUMERIC(5,2) DEFAULT 2.0,
    status TEXT DEFAULT 'PENDENTE' CHECK (status IN ('PENDENTE', 'ACERTO', 'ERRO', 'EXPIRADO')),
    pnl NUMERIC(20,8) DEFAULT 0,
    final_price NUMERIC(20,8),
    entry_time TIMESTAMPTZ,
    contributors JSONB,
    divergence JSONB,
    features JSONB,
    data_source TEXT DEFAULT 'REAL',
    executed BOOLEAN DEFAULT FALSE,
    execution_details JSONB,
    tpsl_details JSONB,
    saved_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para otimização de queries
CREATE INDEX IF NOT EXISTS idx_signals_timestamp ON signals(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_signals_symbol ON signals(symbol);
CREATE INDEX IF NOT EXISTS idx_signals_direction ON signals(direction);
CREATE INDEX IF NOT EXISTS idx_signals_status ON signals(status);
CREATE INDEX IF NOT EXISTS idx_signals_score ON signals(score DESC);
CREATE INDEX IF NOT EXISTS idx_signals_data_source ON signals(data_source);
CREATE INDEX IF NOT EXISTS idx_signals_executed ON signals(executed);

-- Índices compostos para queries complexas
CREATE INDEX IF NOT EXISTS idx_signals_symbol_timestamp ON signals(symbol, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_signals_status_timestamp ON signals(status, timestamp DESC);

-- Comentários descritivos
COMMENT ON TABLE signals IS 'Sinais de trading gerados pelo Alpha Engine com análise técnica';
COMMENT ON COLUMN signals.id IS 'ID único do sinal (formato: SIG_timestamp_random)';
COMMENT ON COLUMN signals.score IS 'Score de confiança do sinal (0-100)';
COMMENT ON COLUMN signals.contributors IS 'Array de indicadores que contribuíram para o sinal';
COMMENT ON COLUMN signals.divergence IS 'Informações sobre divergências detectadas';
COMMENT ON COLUMN signals.features IS 'Features calculadas para machine learning';
COMMENT ON COLUMN signals.execution_details IS 'Detalhes da execução automática (se aplicável)';
COMMENT ON COLUMN signals.tpsl_details IS 'Detalhes de Take Profit e Stop Loss';

-- =====================================================
-- TABELA 3: ML_WEIGHTS_EVOLUTION
-- Armazena evolução dos pesos do machine learning
-- =====================================================

CREATE TABLE IF NOT EXISTS ml_weights_evolution (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    weights JSONB NOT NULL,
    performance JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_ml_weights_timestamp ON ml_weights_evolution(timestamp DESC);

-- Comentários descritivos
COMMENT ON TABLE ml_weights_evolution IS 'Histórico de evolução dos pesos do machine learning';
COMMENT ON COLUMN ml_weights_evolution.weights IS 'Pesos dos indicadores técnicos';
COMMENT ON COLUMN ml_weights_evolution.performance IS 'Métricas de performance associadas aos pesos';

-- =====================================================
-- TABELA 4: AUDIT_LOGS
-- Armazena logs de auditoria para análise de performance
-- =====================================================

CREATE TABLE IF NOT EXISTS audit_logs (
    signal_id TEXT PRIMARY KEY,
    generated_at TIMESTAMPTZ NOT NULL,
    candle_close_time TIMESTAMPTZ,
    time_difference NUMERIC,
    prices JSONB,
    indicators JSONB,
    score_range TEXT,
    hour_of_day INTEGER CHECK (hour_of_day >= 0 AND hour_of_day <= 23),
    outcome TEXT CHECK (outcome IN ('ACERTO', 'ERRO', 'EXPIRADO', 'PENDENTE')),
    outcome_time TIMESTAMPTZ,
    reason TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_audit_logs_generated_at ON audit_logs(generated_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_outcome ON audit_logs(outcome);
CREATE INDEX IF NOT EXISTS idx_audit_logs_hour ON audit_logs(hour_of_day);
CREATE INDEX IF NOT EXISTS idx_audit_logs_score_range ON audit_logs(score_range);

-- Comentários descritivos
COMMENT ON TABLE audit_logs IS 'Logs detalhados de auditoria para análise de performance dos sinais';
COMMENT ON COLUMN audit_logs.signal_id IS 'Referência ao ID do sinal (FK para signals.id)';
COMMENT ON COLUMN audit_logs.prices IS 'Informações de preços no momento da geração';
COMMENT ON COLUMN audit_logs.indicators IS 'Valores dos indicadores técnicos';
COMMENT ON COLUMN audit_logs.metadata IS 'Dados adicionais para análise';

-- =====================================================
-- TABELA 5: PERFORMANCE_STATS
-- Armazena estatísticas agregadas de performance
-- =====================================================

CREATE TABLE IF NOT EXISTS performance_stats (
    stat_type TEXT NOT NULL,
    stat_key TEXT NOT NULL,
    total INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    expired INTEGER DEFAULT 0,
    total_pnl NUMERIC(20,8) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (stat_type, stat_key)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_performance_stats_type ON performance_stats(stat_type);
CREATE INDEX IF NOT EXISTS idx_performance_stats_key ON performance_stats(stat_key);

-- Comentários descritivos
COMMENT ON TABLE performance_stats IS 'Estatísticas agregadas de performance por hora, score e indicador';
COMMENT ON COLUMN performance_stats.stat_type IS 'Tipo de estatística: by_hour, by_score, by_indicator';
COMMENT ON COLUMN performance_stats.stat_key IS 'Chave específica (ex: 14 para hora, 70-80 para score)';
COMMENT ON COLUMN performance_stats.total_pnl IS 'Profit and Loss total acumulado';

-- =====================================================
-- TRIGGERS PARA UPDATED_AT AUTOMÁTICO
-- =====================================================

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para api_connections
DROP TRIGGER IF EXISTS update_api_connections_updated_at ON api_connections;
CREATE TRIGGER update_api_connections_updated_at
    BEFORE UPDATE ON api_connections
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para signals
DROP TRIGGER IF EXISTS update_signals_updated_at ON signals;
CREATE TRIGGER update_signals_updated_at
    BEFORE UPDATE ON signals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para audit_logs
DROP TRIGGER IF EXISTS update_audit_logs_updated_at ON audit_logs;
CREATE TRIGGER update_audit_logs_updated_at
    BEFORE UPDATE ON audit_logs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para performance_stats
DROP TRIGGER IF EXISTS update_performance_stats_updated_at ON performance_stats;
CREATE TRIGGER update_performance_stats_updated_at
    BEFORE UPDATE ON performance_stats
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- POLÍTICAS RLS (ROW LEVEL SECURITY) - OPCIONAL
-- Descomente se quiser habilitar segurança por linha
-- =====================================================

-- ALTER TABLE api_connections ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE signals ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE ml_weights_evolution ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE performance_stats ENABLE ROW LEVEL SECURITY;

-- Política de acesso total (ajuste conforme necessário)
-- CREATE POLICY "Enable all access for authenticated users" ON api_connections
--     FOR ALL USING (auth.role() = 'authenticated');

-- CREATE POLICY "Enable all access for authenticated users" ON signals
--     FOR ALL USING (auth.role() = 'authenticated');

-- CREATE POLICY "Enable all access for authenticated users" ON ml_weights_evolution
--     FOR ALL USING (auth.role() = 'authenticated');

-- CREATE POLICY "Enable all access for authenticated users" ON audit_logs
--     FOR ALL USING (auth.role() = 'authenticated');

-- CREATE POLICY "Enable all access for authenticated users" ON performance_stats
--     FOR ALL USING (auth.role() = 'authenticated');

-- =====================================================
-- VIEWS ÚTEIS PARA ANÁLISE
-- =====================================================

-- View de performance geral
CREATE OR REPLACE VIEW v_performance_summary AS
SELECT
    COUNT(*) as total_signals,
    SUM(CASE WHEN status = 'ACERTO' THEN 1 ELSE 0 END) as total_wins,
    SUM(CASE WHEN status = 'ERRO' THEN 1 ELSE 0 END) as total_losses,
    SUM(CASE WHEN status = 'EXPIRADO' THEN 1 ELSE 0 END) as total_expired,
    ROUND(AVG(score), 2) as avg_score,
    SUM(pnl) as total_pnl,
    ROUND(
        (SUM(CASE WHEN status = 'ACERTO' THEN 1 ELSE 0 END)::NUMERIC /
         NULLIF(COUNT(*), 0)) * 100, 2
    ) as win_rate
FROM signals
WHERE status != 'PENDENTE';

-- View de performance por símbolo
CREATE OR REPLACE VIEW v_performance_by_symbol AS
SELECT
    symbol,
    COUNT(*) as total,
    SUM(CASE WHEN status = 'ACERTO' THEN 1 ELSE 0 END) as wins,
    SUM(CASE WHEN status = 'ERRO' THEN 1 ELSE 0 END) as losses,
    ROUND(AVG(score), 2) as avg_score,
    SUM(pnl) as total_pnl,
    ROUND(
        (SUM(CASE WHEN status = 'ACERTO' THEN 1 ELSE 0 END)::NUMERIC /
         NULLIF(COUNT(*), 0)) * 100, 2
    ) as win_rate
FROM signals
WHERE status != 'PENDENTE'
GROUP BY symbol
ORDER BY total DESC;

-- View de sinais recentes
CREATE OR REPLACE VIEW v_recent_signals AS
SELECT
    id,
    timestamp,
    symbol,
    direction,
    score,
    price,
    status,
    pnl,
    executed
FROM signals
ORDER BY timestamp DESC
LIMIT 50;

-- =====================================================
-- DADOS INICIAIS (OPCIONAL)
-- =====================================================

-- Inserir linha inicial para api_connections
INSERT INTO api_connections (id, connections, active_provider)
VALUES (1, '{}'::jsonb, NULL)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

-- Contar tabelas criadas
SELECT
    schemaname,
    tablename,
    tableowner
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('api_connections', 'signals', 'ml_weights_evolution', 'audit_logs', 'performance_stats')
ORDER BY tablename;

-- Verificar índices criados
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename IN ('api_connections', 'signals', 'ml_weights_evolution', 'audit_logs', 'performance_stats')
ORDER BY tablename, indexname;

-- =====================================================
-- FIM DA MIGRAÇÃO
-- =====================================================
-- Criado em: 2025-10-03
-- Sistema: Alpha-Learner Trading Platform v2.4
-- =====================================================

-- ================================================================
-- TABELA: futures_executions
-- Descrição: Histórico de execuções de ordens no Binance Futures
-- ================================================================

-- Criar tabela de execuções
CREATE TABLE IF NOT EXISTS futures_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    signal_id TEXT,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    symbol TEXT NOT NULL,
    direction TEXT NOT NULL CHECK (direction IN ('LONG', 'SHORT', 'BUY', 'SELL')),

    -- Preços
    entry_price NUMERIC(20,8) NOT NULL,
    stop_loss NUMERIC(20,8) NOT NULL,
    take_profit NUMERIC(20,8) NOT NULL,
    exit_price NUMERIC(20,8),

    -- Ordens Binance
    order_id TEXT,
    stop_loss_order_id TEXT,
    take_profit_order_id TEXT,

    -- Resultados
    result TEXT CHECK (result IN ('PENDING', 'TAKE_PROFIT', 'STOP_LOSS', 'EXPIRED', 'MANUAL', 'CIRCUIT_BREAKER')),
    pnl NUMERIC(20,8),
    commission NUMERIC(20,8),
    net_profit NUMERIC(20,8),

    -- Gestão de Risco
    risk_amount NUMERIC(20,8),
    quantity NUMERIC(20,8),
    leverage INTEGER,
    margin_mode TEXT CHECK (margin_mode IN ('ISOLATED', 'CROSS')),

    -- Metadados
    execution_time INTEGER, -- Tempo de execução em ms
    confidence_score NUMERIC(5,2), -- Score do ML (0-100)
    simulated BOOLEAN DEFAULT false, -- Se foi ordem simulada

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    closed_at TIMESTAMPTZ,

    -- Informações adicionais (JSON flexível)
    metadata JSONB
);

-- ================================================================
-- ÍNDICES PARA PERFORMANCE
-- ================================================================

CREATE INDEX IF NOT EXISTS idx_futures_executions_symbol
    ON futures_executions(symbol);

CREATE INDEX IF NOT EXISTS idx_futures_executions_result
    ON futures_executions(result);

CREATE INDEX IF NOT EXISTS idx_futures_executions_timestamp
    ON futures_executions(timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_futures_executions_signal_id
    ON futures_executions(signal_id);

CREATE INDEX IF NOT EXISTS idx_futures_executions_created_at
    ON futures_executions(created_at DESC);

-- Índice para buscar posições pendentes
CREATE INDEX IF NOT EXISTS idx_futures_executions_pending
    ON futures_executions(result)
    WHERE result = 'PENDING';

-- Índice composto para análises
CREATE INDEX IF NOT EXISTS idx_futures_executions_analysis
    ON futures_executions(symbol, result, created_at DESC);

-- ================================================================
-- POLÍTICAS RLS (Row Level Security)
-- ================================================================

-- Habilitar RLS
ALTER TABLE futures_executions ENABLE ROW LEVEL SECURITY;

-- Política: Permitir SELECT para todos (leitura pública)
CREATE POLICY "Allow public read access"
    ON futures_executions
    FOR SELECT
    USING (true);

-- Política: Permitir INSERT para todos (escrita pública)
CREATE POLICY "Allow public insert access"
    ON futures_executions
    FOR INSERT
    WITH CHECK (true);

-- Política: Permitir UPDATE para todos (atualização pública)
CREATE POLICY "Allow public update access"
    ON futures_executions
    FOR UPDATE
    USING (true);

-- ================================================================
-- VIEWS ÚTEIS
-- ================================================================

-- View: Estatísticas gerais
CREATE OR REPLACE VIEW futures_execution_stats AS
SELECT
    COUNT(*) as total_executions,
    COUNT(*) FILTER (WHERE result = 'TAKE_PROFIT') as wins,
    COUNT(*) FILTER (WHERE result = 'STOP_LOSS') as losses,
    COUNT(*) FILTER (WHERE result = 'EXPIRED') as expired,
    COUNT(*) FILTER (WHERE result = 'PENDING') as pending,
    ROUND(COUNT(*) FILTER (WHERE result = 'TAKE_PROFIT')::numeric /
          NULLIF(COUNT(*) FILTER (WHERE result IN ('TAKE_PROFIT', 'STOP_LOSS')), 0) * 100, 2) as win_rate,
    SUM(net_profit) as total_pnl,
    AVG(net_profit) as avg_pnl,
    MAX(net_profit) as max_profit,
    MIN(net_profit) as max_loss
FROM futures_executions
WHERE result IN ('TAKE_PROFIT', 'STOP_LOSS', 'EXPIRED');

-- View: Estatísticas por símbolo
CREATE OR REPLACE VIEW futures_stats_by_symbol AS
SELECT
    symbol,
    COUNT(*) as total_trades,
    COUNT(*) FILTER (WHERE result = 'TAKE_PROFIT') as wins,
    COUNT(*) FILTER (WHERE result = 'STOP_LOSS') as losses,
    ROUND(COUNT(*) FILTER (WHERE result = 'TAKE_PROFIT')::numeric /
          NULLIF(COUNT(*) FILTER (WHERE result IN ('TAKE_PROFIT', 'STOP_LOSS')), 0) * 100, 2) as win_rate,
    SUM(net_profit) as total_pnl,
    AVG(net_profit) as avg_pnl
FROM futures_executions
WHERE result IN ('TAKE_PROFIT', 'STOP_LOSS', 'EXPIRED')
GROUP BY symbol
ORDER BY total_pnl DESC;

-- View: Estatísticas por dia
CREATE OR REPLACE VIEW futures_stats_by_day AS
SELECT
    DATE(created_at) as trade_date,
    COUNT(*) as total_trades,
    COUNT(*) FILTER (WHERE result = 'TAKE_PROFIT') as wins,
    COUNT(*) FILTER (WHERE result = 'STOP_LOSS') as losses,
    SUM(net_profit) as daily_pnl
FROM futures_executions
WHERE result IN ('TAKE_PROFIT', 'STOP_LOSS', 'EXPIRED')
GROUP BY DATE(created_at)
ORDER BY trade_date DESC;

-- View: Últimas 100 execuções
CREATE OR REPLACE VIEW futures_recent_executions AS
SELECT
    id,
    signal_id,
    timestamp,
    symbol,
    direction,
    entry_price,
    exit_price,
    result,
    net_profit,
    leverage,
    created_at,
    closed_at
FROM futures_executions
ORDER BY created_at DESC
LIMIT 100;

-- ================================================================
-- FUNÇÕES ÚTEIS
-- ================================================================

-- Função: Calcular lucro líquido automaticamente
CREATE OR REPLACE FUNCTION calculate_net_profit()
RETURNS TRIGGER AS $$
BEGIN
    NEW.net_profit := COALESCE(NEW.pnl, 0) - COALESCE(NEW.commission, 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Atualizar net_profit automaticamente
DROP TRIGGER IF EXISTS trigger_calculate_net_profit ON futures_executions;
CREATE TRIGGER trigger_calculate_net_profit
    BEFORE INSERT OR UPDATE ON futures_executions
    FOR EACH ROW
    EXECUTE FUNCTION calculate_net_profit();

-- ================================================================
-- DADOS DE TESTE (OPCIONAL - COMENTADO)
-- ================================================================

-- Descomente para inserir dados de exemplo:
/*
INSERT INTO futures_executions (
    signal_id, symbol, direction, entry_price, stop_loss, take_profit,
    exit_price, result, pnl, commission, risk_amount, quantity, leverage, margin_mode
) VALUES
    ('SIG-001', 'BTCUSDT', 'LONG', 67500.00, 66150.00, 69525.00, 69525.00, 'TAKE_PROFIT', 300.00, 0.30, 200.00, 0.0029629, 2, 'ISOLATED'),
    ('SIG-002', 'ETHUSDT', 'SHORT', 2500.00, 2550.00, 2425.00, 2550.00, 'STOP_LOSS', -100.00, 0.10, 100.00, 0.04, 2, 'ISOLATED'),
    ('SIG-003', 'BNBUSDT', 'LONG', 300.00, 294.00, 309.00, 305.00, 'EXPIRED', 50.00, 0.05, 150.00, 0.5, 2, 'ISOLATED');
*/

-- ================================================================
-- VERIFICAÇÃO
-- ================================================================

-- Listar tabelas
SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename = 'futures_executions';

-- Listar views
SELECT viewname FROM pg_views WHERE schemaname = 'public' AND viewname LIKE 'futures%';

-- Listar índices
SELECT indexname FROM pg_indexes WHERE tablename = 'futures_executions';

-- Contar registros
SELECT COUNT(*) as total_records FROM futures_executions;

-- ================================================================
-- COMENTÁRIOS
-- ================================================================

COMMENT ON TABLE futures_executions IS 'Histórico completo de execuções de ordens no Binance Futures';
COMMENT ON COLUMN futures_executions.signal_id IS 'ID do sinal que gerou esta execução';
COMMENT ON COLUMN futures_executions.direction IS 'LONG (compra) ou SHORT (venda)';
COMMENT ON COLUMN futures_executions.result IS 'Resultado final: TAKE_PROFIT, STOP_LOSS, EXPIRED, MANUAL, CIRCUIT_BREAKER';
COMMENT ON COLUMN futures_executions.pnl IS 'Profit and Loss (lucro/prejuízo) bruto';
COMMENT ON COLUMN futures_executions.net_profit IS 'Lucro líquido (PnL - comissão)';
COMMENT ON COLUMN futures_executions.leverage IS 'Alavancagem utilizada (1x a 125x)';
COMMENT ON COLUMN futures_executions.margin_mode IS 'ISOLATED ou CROSS';
COMMENT ON COLUMN futures_executions.simulated IS 'Se true, ordem foi simulada (não real)';

-- ================================================================
-- ✅ SCRIPT CONCLUÍDO
-- ================================================================

SELECT
    '✅ Tabela futures_executions criada com sucesso!' as status,
    COUNT(*) as total_indices
FROM pg_indexes
WHERE tablename = 'futures_executions';

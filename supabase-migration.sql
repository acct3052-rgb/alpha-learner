-- ========================================
-- ALPHA-LEARNER TRADING PLATFORM
-- Supabase Database Setup
-- ========================================
--
-- INSTRUCTIONS:
-- 1. Go to your Supabase project dashboard
-- 2. Click on "SQL Editor" in the left sidebar
-- 3. Click "+ New Query"
-- 4. Copy and paste this entire file
-- 5. Click "Run" to execute
--
-- This will create all necessary tables with proper security policies
-- ========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- TABLE: api_connections
-- Stores API connection configurations
-- ========================================
CREATE TABLE IF NOT EXISTS public.api_connections (
    id INTEGER PRIMARY KEY DEFAULT 1,
    connections JSONB NOT NULL DEFAULT '{}',
    active_provider TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    CONSTRAINT single_row CHECK (id = 1)
);

-- ========================================
-- TABLE: signals
-- Stores all generated trading signals
-- ========================================
CREATE TABLE IF NOT EXISTS public.signals (
    id TEXT PRIMARY KEY,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    symbol TEXT NOT NULL,
    direction TEXT NOT NULL,
    timeframe TEXT NOT NULL,
    score INTEGER NOT NULL,
    price DECIMAL(15, 8) NOT NULL,
    stop_loss DECIMAL(15, 8) NOT NULL,
    take_profit DECIMAL(15, 8) NOT NULL,
    risk_reward DECIMAL(5, 2) NOT NULL,
    status TEXT DEFAULT 'PENDENTE',
    pnl DECIMAL(15, 2) DEFAULT 0,
    final_price DECIMAL(15, 8),
    entry_time TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,
    data_source TEXT,
    divergence JSONB,
    contributors JSONB,
    features JSONB,
    executed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ========================================
-- TABLE: ml_weights_evolution
-- Tracks ML weight changes over time
-- ========================================
CREATE TABLE IF NOT EXISTS public.ml_weights_evolution (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    weights JSONB NOT NULL,
    performance JSONB,
    total_signals INTEGER DEFAULT 0,
    win_rate DECIMAL(5, 2) DEFAULT 0,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ========================================
-- TABLE: audit_logs
-- Detailed audit trail for signal generation
-- ========================================
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    signal_id TEXT,
    generated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    candle_close_time TIMESTAMP WITH TIME ZONE,
    time_difference INTEGER,
    prices JSONB,
    indicators JSONB,
    score_range TEXT,
    hour_of_day INTEGER,
    outcome TEXT,
    outcome_time TIMESTAMP WITH TIME ZONE,
    reason TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    FOREIGN KEY (signal_id) REFERENCES public.signals(id) ON DELETE CASCADE
);

-- ========================================
-- TABLE: performance_stats
-- Aggregated performance statistics
-- ========================================
CREATE TABLE IF NOT EXISTS public.performance_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    stat_type TEXT NOT NULL,
    stat_key TEXT NOT NULL,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    expired INTEGER DEFAULT 0,
    total_pnl DECIMAL(15, 2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(stat_type, stat_key)
);

-- ========================================
-- INDEXES FOR PERFORMANCE
-- ========================================
CREATE INDEX IF NOT EXISTS idx_signals_timestamp ON public.signals(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_signals_status ON public.signals(status);
CREATE INDEX IF NOT EXISTS idx_signals_symbol ON public.signals(symbol);
CREATE INDEX IF NOT EXISTS idx_audit_logs_signal_id ON public.audit_logs(signal_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_generated_at ON public.audit_logs(generated_at DESC);
CREATE INDEX IF NOT EXISTS idx_ml_weights_timestamp ON public.ml_weights_evolution(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_performance_stats_type_key ON public.performance_stats(stat_type, stat_key);

-- ========================================
-- TRIGGERS FOR UPDATED_AT
-- ========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_api_connections_updated_at
    BEFORE UPDATE ON public.api_connections
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_signals_updated_at
    BEFORE UPDATE ON public.signals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_performance_stats_updated_at
    BEFORE UPDATE ON public.performance_stats
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- ROW LEVEL SECURITY (RLS)
-- ========================================
-- Note: Since this is a single-user app, we'll allow public access
-- In production, you should enable authentication and restrict access

-- Enable RLS
ALTER TABLE public.api_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.signals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ml_weights_evolution ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.performance_stats ENABLE ROW LEVEL SECURITY;

-- Create policies that allow all operations
-- ⚠️ WARNING: This allows anyone with your API key to access the data
-- For production, implement proper authentication

CREATE POLICY "Allow all on api_connections" ON public.api_connections
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all on signals" ON public.signals
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all on ml_weights_evolution" ON public.ml_weights_evolution
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all on audit_logs" ON public.audit_logs
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all on performance_stats" ON public.performance_stats
    FOR ALL USING (true) WITH CHECK (true);

-- ========================================
-- INITIAL DATA
-- ========================================
-- Insert default api_connections row
INSERT INTO public.api_connections (id, connections, active_provider)
VALUES (1, '{}', NULL)
ON CONFLICT (id) DO NOTHING;

-- ========================================
-- VERIFICATION QUERIES
-- ========================================
-- Run these after the migration to verify everything worked:
--
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = 'public' AND table_name IN
-- ('api_connections', 'signals', 'ml_weights_evolution', 'audit_logs', 'performance_stats');
--
-- SELECT tablename, indexname FROM pg_indexes WHERE schemaname = 'public';
--
-- ========================================
-- SETUP COMPLETE! 🎉
-- ========================================
--
-- Next steps:
-- 1. Copy your Supabase URL from: Settings > API > Project URL
-- 2. Copy your Supabase Anon Key from: Settings > API > Project API keys > anon public
-- 3. Update your alpha-learner index.html with these credentials
--
-- ========================================

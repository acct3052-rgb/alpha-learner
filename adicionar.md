Adicionar Seletor de Tipo de Ativo
O que seu código já tem:

✅ APIs configuradas (CoinGecko, Binance, Alpha Vantage, Polygon)
✅ Sistema de sinais funcionando
✅ Suporte a múltiplos símbolos no backend

O que falta:

❌ Interface para o usuário escolher o tipo de ativo
❌ Campo para digitar o símbolo específico
❌ Filtro de API baseado no tipo escolhido

📝 Código para Adicionar
No componente Dashboard, adicione estes controles:
jsx// Adicione estes estados no início do componente Dashboard
const [assetType, setAssetType] = useState('crypto'); // 'crypto', 'forex', 'stock'
const [symbol, setSymbol] = useState('BTCUSDT');

// Adicione este novo card ANTES do card "Oportunidades de Trading"
<div className="card">
    <h3>🎯 Configuração do Ativo</h3>
    
    <div className="form-group">
        <label className="form-label">Tipo de Ativo</label>
        <select 
            className="form-select"
            value={assetType}
            onChange={(e) => {
                setAssetType(e.target.value);
                // Auto-ajustar símbolo padrão
                if (e.target.value === 'crypto') setSymbol('BTCUSDT');
                else if (e.target.value === 'forex') setSymbol('EURUSD');
                else if (e.target.value === 'stock') setSymbol('AAPL');
            }}
        >
            <option value="crypto">🟡 Criptomoeda</option>
            <option value="forex">💱 Forex (Moedas)</option>
            <option value="stock">📈 Ações</option>
        </select>
    </div>

    <div className="form-group">
        <label className="form-label">Símbolo do Ativo</label>
        <input 
            type="text"
            className="form-input"
            placeholder={
                assetType === 'crypto' ? 'Ex: BTCUSDT, ETHUSDT' :
                assetType === 'forex' ? 'Ex: EURUSD, GBPUSD' :
                'Ex: AAPL, GOOGL, TSLA'
            }
            value={symbol}
            onChange={(e) => setSymbol(e.target.value.toUpperCase())}
        />
        <small style={{color: '#a0a0a0', fontSize: '12px', marginTop: '5px', display: 'block'}}>
            {assetType === 'crypto' && '💡 Binance/CoinGecko: BTCUSDT, ETHUSDT, BNBUSDT'}
            {assetType === 'forex' && '💡 Alpha Vantage: EURUSD, GBPUSD, USDJPY'}
            {assetType === 'stock' && '💡 Alpha Vantage/Polygon: AAPL, GOOGL, MSFT'}
        </small>
    </div>

    <div style={{
        padding: '12px',
        background: 'rgba(0, 255, 136, 0.1)',
        border: '1px solid rgba(0, 255, 136, 0.3)',
        borderRadius: '8px',
        fontSize: '13px'
    }}>
        <strong style={{color: '#00ff88'}}>📡 APIs Compatíveis:</strong>
        <div style={{marginTop: '8px', color: '#c0c0c0'}}>
            {assetType === 'crypto' && '• Binance (tempo real) • CoinGecko'}
            {assetType === 'forex' && '• Alpha Vantage'}
            {assetType === 'stock' && '• Alpha Vantage • Polygon.io'}
        </div>
    </div>
</div>
🔧 Modificação Necessária no Loop Principal
No useEffect que monitora o mercado, modifique a linha do símbolo:
javascript// Linha atual (~linha 1450):
const symbolToFetch = activeConn.provider === 'ALPHA_VANTAGE' ? 'IBM' : 
                      activeConn.provider === 'COINGECKO' ? 'BTC' : 
                      'BTCUSDT';

// SUBSTITUA por:
const symbolToFetch = symbol || 'BTCUSDT'; // Usar o símbolo escolhido pelo usuário
E no generateSignal, mude:
javascript// Linha atual (~linha 900):
symbol: 'BTCUSDT',

// SUBSTITUA por:
symbol: symbol || 'BTCUSDT',
🎨 Resultado Visual
Você terá uma interface assim:
┌─────────────────────────────────────┐
│ 🎯 Configuração do Ativo            │
├─────────────────────────────────────┤
│ Tipo de Ativo:                      │
│ [🟡 Criptomoeda ▼]                  │
│                                     │
│ Símbolo do Ativo:                   │
│ [BTCUSDT          ]                 │
│ 💡 Binance: BTCUSDT, ETHUSDT...     │
│                                     │
│ 📡 APIs Compatíveis:                │
│ • Binance (tempo real) • CoinGecko  │
└─────────────────────────────────────┘
✅ Resumo da Implementação

Adicione os 2 estados (assetType e symbol)
Cole o código do card acima no Dashboard
Modifique 2 linhas no loop de monitoramento
Teste! Mude para "Ações", digite "AAPL" e conecte Alpha Vantage

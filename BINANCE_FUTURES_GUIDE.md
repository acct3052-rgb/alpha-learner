# 🚀 GUIA COMPLETO - ALPHA-LEARNER BINANCE FUTURES

## 📋 ÍNDICE
1. [Visão Geral](#visão-geral)
2. [Funcionalidades Implementadas](#funcionalidades-implementadas)
3. [Configurações do Sistema](#configurações-do-sistema)
4. [Modo Manual vs Automático](#modo-manual-vs-automático)
5. [Como Configurar a Binance](#como-configurar-a-binance)
6. [Fluxo de Operação](#fluxo-de-operação)
7. [Gestão de Risco](#gestão-de-risco)
8. [Exportar Logs](#exportar-logs)
9. [Configuração do Banco de Dados Supabase](#configuração-do-banco-de-dados-supabase) ⭐ **NOVO**
10. [Solução de Problemas](#solução-de-problemas)

---

## 🎯 VISÃO GERAL

O **Alpha-Learner** agora está 100% configurado para operar na **Binance Futures USD-M** com todas as funcionalidades profissionais:

✅ **Binance Futures USD-M** (não Spot)
✅ **Margem Isolada** (Isolated Margin)
✅ **Alavancagem configurável** (padrão: 2x)
✅ **Stop Loss e Take Profit automáticos**
✅ **Fechamento automático após 5 minutos**
✅ **Circuit Breaker** (pausa após 3 perdas seguidas)
✅ **Modo Manual com popup de confirmação**
✅ **Exportação de logs em CSV**
✅ **Gestão de risco avançada**
✅ **Persistência no Supabase** (nunca perde dados) ⭐ **NOVO**

---

## ⚙️ FUNCIONALIDADES IMPLEMENTADAS

### 1️⃣ SISTEMA DE EXECUÇÃO BINANCE FUTURES

**Arquivo:** `index.html` (linhas 1083-1739)

**O que faz:**
- Conecta na API da Binance Futures (não Spot)
- Configura automaticamente:
  - **Alavancagem:** 2x (configurável)
  - **Margem:** ISOLATED (não Cross)
  - **Tipo de ordem:** MARKET (execução imediata)

**Endpoints utilizados:**
```javascript
// Testnet
https://testnet.binancefuture.com/fapi/v1

// Produção
https://fapi.binance.com/fapi/v1
```

### 2️⃣ STOP LOSS E TAKE PROFIT AUTOMÁTICOS

**Como funciona:**

Quando uma posição é aberta, o sistema **automaticamente**:

1. **Abre posição MARKET** (BUY ou SELL)
2. **Define Stop Loss** usando ordem `STOP_MARKET`
3. **Define Take Profit** usando ordem `TAKE_PROFIT_MARKET`

**Valores padrão:**
- Stop Loss: **-2%** do preço de entrada
- Take Profit: **+3%** do preço de entrada

**Código:**
```javascript
// Linhas 1370-1388 (Stop Loss)
// Linhas 1380-1388 (Take Profit)
```

### 3️⃣ TIMER DE FECHAMENTO (5 MINUTOS)

**O que acontece:**

1. Quando posição é aberta → timer de 5 minutos inicia
2. Se SL ou TP não forem atingidos → posição fecha automaticamente
3. Timer é cancelado se SL/TP forem acionados antes

**Código:**
```javascript
// Linha 1567-1577: startPositionTimer()
// Linha 1590-1616: autoClosePosition()
```

### 4️⃣ CIRCUIT BREAKER (PROTEÇÃO)

**Regra:**
- Após **3 perdas consecutivas** → sistema PAUSA automaticamente
- Evita bleeding (sangramento de capital)
- Só reativa com ação manual

**Como reativar:**
```javascript
orderExecutorRef.current.deactivateCircuitBreaker();
```

**Código:** Linhas 1670-1680

### 5️⃣ MODO MANUAL (POPUP DE CONFIRMAÇÃO)

**Quando em modo manual:**

1. Sistema detecta sinal
2. **Popup aparece automaticamente** com:
   - Par (ex: BTCUSDT)
   - Direção (LONG 🟢 ou SHORT 🔴)
   - Preço atual
   - Quantidade calculada
   - Stop Loss e Take Profit
   - Risco e lucro potencial

3. Você escolhe:
   - ✅ **EXECUTAR** → robô abre posição via API
   - 📋 **COPIAR** → copia dados para colar manualmente na Binance
   - ❌ **IGNORAR** → descarta o sinal

**Código:** Linhas 5467-5739

### 6️⃣ EXPORTAR LOGS EM CSV

**Dados salvos:**
- Timestamp da operação
- Símbolo (par)
- Direção (LONG/SHORT)
- Preço de entrada
- Stop Loss e Take Profit
- Resultado (WIN/LOSS/EXPIRED)
- P&L (lucro/perda)
- Taxa da Binance
- Lucro líquido

**Como exportar:**
```javascript
orderExecutorRef.current.exportLogsToCSV();
```

**Código:** Linhas 1732-1763

---

## ⚙️ CONFIGURAÇÕES DO SISTEMA

### 📝 Arquivo: `index.html` (linhas 1086-1099)

```javascript
const FUTURES_CONFIG = {
    exchange: 'binance',
    market: 'futures',
    marginMode: 'ISOLATED',        // ⚠️ IMPORTANTE: Não Cross
    leverage: 2,                   // Alavancagem (1x a 125x)
    timeframe: '5m',               // Candles de 5 minutos
    riskPerTrade: 0.02,            // 2% do capital por trade
    stopLossPercent: 0.02,         // Stop Loss: -2%
    takeProfitPercent: 0.03,       // Take Profit: +3%
    positionDuration: 300000,      // 5 minutos (em ms)
    modoAutomatico: false,         // Inicia em modo MANUAL
    maxPositions: 1,               // Máximo 1 posição simultânea
    circuitBreakerLosses: 3        // Pausa após 3 perdas
};
```

### 🔧 COMO ALTERAR CONFIGURAÇÕES

**1. Mudar alavancagem:**
```javascript
orderExecutorRef.current.config.leverage = 5; // 5x
```

**2. Mudar Stop Loss/Take Profit:**
```javascript
orderExecutorRef.current.config.stopLossPercent = 0.03;   // 3%
orderExecutorRef.current.config.takeProfitPercent = 0.05; // 5%
```

**3. Mudar duração da posição:**
```javascript
// 10 minutos = 600000 ms
orderExecutorRef.current.config.positionDuration = 600000;
```

**4. Ativar modo automático:**
```javascript
setMode('auto'); // Na interface
```

---

## 🔀 MODO MANUAL VS AUTOMÁTICO

### 🖱️ MODO MANUAL (Padrão)

**Como funciona:**
1. Sistema detecta sinal de compra/venda
2. **Popup aparece na tela**
3. Você decide: Executar, Copiar ou Ignorar

**Vantagens:**
- ✅ Controle total
- ✅ Pode copiar sinal para executar manualmente na Binance
- ✅ Aprende com os sinais antes de automatizar

**Desvantagens:**
- ❌ Precisa estar na tela
- ❌ Pode perder sinais se não estiver disponível

### 🤖 MODO AUTOMÁTICO

**Como funciona:**
1. Sistema detecta sinal
2. **Executa automaticamente** via API
3. Você só acompanha resultados

**Vantagens:**
- ✅ Opera 24/7 sem intervenção
- ✅ Execução instantânea

**Desvantagens:**
- ❌ Menos controle
- ⚠️ **USE APENAS APÓS TESTAR EM TESTNET!**

### 🔄 COMO ALTERNAR

**Na interface:**
- Clique no botão "Manual/Auto" no header

**Via código:**
```javascript
setMode('manual'); // Modo manual
setMode('auto');   // Modo automático
```

---

## 🔐 COMO CONFIGURAR A BINANCE

### 1️⃣ CRIAR API KEYS NA BINANCE

1. Acesse: [Binance API Management](https://www.binance.com/en/my/settings/api-management)
2. Clique em **"Create API"**
3. Escolha um nome (ex: "Alpha-Learner-Bot")
4. Complete verificação 2FA
5. **COPIE** e **SALVE**:
   - `API Key` (64 caracteres)
   - `Secret Key` (64 caracteres)

### 2️⃣ CONFIGURAR PERMISSÕES

⚠️ **IMPORTANTE:** Configure APENAS estas permissões:

✅ **Enable Futures** (obrigatório)
✅ **Enable Trading** (obrigatório)
❌ **Enable Withdrawals** (NÃO ativar!)
❌ **Enable Spot & Margin** (NÃO ativar!)

### 3️⃣ RESTRINGIR IP (RECOMENDADO)

1. Em "API restrictions"
2. Adicione seu IP público
3. Salve alterações

### 4️⃣ ADICIONAR KEYS NO ALPHA-LEARNER

1. Vá para **"Conexões"** no menu lateral
2. Clique em **"+ Nova Conexão"**
3. Preencha:
   - **Provider:** BINANCE
   - **Nome:** Binance Futures
   - **API Key:** [cole sua key]
   - **Secret Key:** [cole sua secret]
   - **Testnet:** ☑️ (para testes) ou ☐ (produção)
4. Clique em **"Testar Conexão"**
5. Se sucesso → **"Salvar"**

---

## 🔄 FLUXO DE OPERAÇÃO

### 📊 PASSO A PASSO (MODO AUTOMÁTICO)

```
1. ML detecta padrão de alta (LONG) ou baixa (SHORT)
   ↓
2. Sistema valida:
   - ✅ Saldo disponível?
   - ✅ Dentro do limite de risco (2%)?
   - ✅ Posições simultâneas < 1?
   - ✅ Circuit breaker desativado?
   ↓
3. Conecta na Binance Futures
   ↓
4. Configura alavancagem (2x) e margem (ISOLATED)
   ↓
5. Abre posição MARKET (BUY ou SELL)
   ↓
6. Define Stop Loss (-2%) e Take Profit (+3%)
   ↓
7. Inicia timer de 5 minutos
   ↓
8. Aguarda resultado:
   - 🎯 TP atingido → Lucro!
   - 🛑 SL atingido → Perda controlada
   - ⏰ 5 minutos → Fecha posição
   ↓
9. Registra resultado em logs
   ↓
10. Verifica circuit breaker (se 3 perdas seguidas → PAUSA)
```

### 📊 PASSO A PASSO (MODO MANUAL)

```
1. ML detecta padrão
   ↓
2. Sistema prepara sinal
   ↓
3. 🔔 POPUP APARECE na tela
   ↓
4. VOCÊ DECIDE:

   ✅ EXECUTAR → Segue fluxo automático (passo 3 acima)

   📋 COPIAR → Copia sinal formatado:
       ```
       🤖 SINAL ALPHA-LEARNER
       Par: BTCUSDT
       Direção: LONG 🟢
       Preço: $67,500
       Quantidade: 0.001 BTC
       Stop Loss: $66,150 (-2%)
       Take Profit: $69,525 (+3%)
       ```
       → Cola manualmente na Binance

   ❌ IGNORAR → Descarta sinal
```

---

## 🛡️ GESTÃO DE RISCO

### 📐 CÁLCULOS AUTOMÁTICOS

**1. Risco por trade:**
```javascript
Risco = Saldo Total × 2% (configurável)

Exemplo:
- Saldo: $10.000
- Risco: $10.000 × 0.02 = $200 por trade
```

**2. Quantidade calculada:**
```javascript
Quantidade = (Risco / Preço) / Distância SL

Exemplo:
- Preço BTC: $67.500
- Stop Loss: $66.150 (-2%)
- Distância SL: 2%
- Risco: $200

Quantidade = ($200 / $67.500) / 0.02
          = 0.0029629 / 0.02
          = 0.148 BTC
```

**3. Lucro potencial:**
```javascript
Lucro = Risco × (TP% / SL%)

Exemplo:
- Risco: $200
- TP: 3%
- SL: 2%

Lucro = $200 × (3 / 2) = $300
```

### 🔒 PROTEÇÕES ATIVAS

| Proteção | Descrição | Configurável |
|----------|-----------|--------------|
| **Risco máximo** | 2% por trade | ✅ Sim (`riskPerTrade`) |
| **Posições simultâneas** | 1 posição | ✅ Sim (`maxPositions`) |
| **Circuit Breaker** | Pausa após 3 perdas | ✅ Sim (`circuitBreakerLosses`) |
| **Stop Loss obrigatório** | Sempre configurado | ❌ Não |
| **Take Profit obrigatório** | Sempre configurado | ❌ Não |
| **Timer de expiração** | 5 minutos | ✅ Sim (`positionDuration`) |
| **Margem Isolada** | Protege saldo total | ❌ Não |

---

## 📊 EXPORTAR LOGS

### 🗂️ Como exportar:

**Opção 1: Via Interface** (se implementado)
1. Ir para "Painel do Robô"
2. Clicar em "Exportar Logs CSV"

**Opção 2: Via Console**
```javascript
orderExecutorRef.current.exportLogsToCSV();
```

### 📄 Formato do CSV:

```csv
Timestamp,Símbolo,Direção,Preço Entrada,Stop Loss,Take Profit,Resultado,P&L,Taxa,Lucro Líquido
2025-10-03T14:30:00Z,BTCUSDT,LONG,67500,66150,69525,TAKE_PROFIT,300,0.30,299.70
2025-10-03T15:00:00Z,ETHUSDT,SHORT,2500,2550,2425,STOP_LOSS,-100,0.10,-100.10
```

### 📈 Analisar no Excel/Google Sheets:

1. Abrir arquivo CSV
2. Criar tabela dinâmica
3. Métricas úteis:
   - Taxa de acerto (WIN / TOTAL)
   - Lucro médio por trade
   - Maior sequência de perdas
   - Melhor par (símbolo)
   - Melhor horário

---

## 🗄️ CONFIGURAÇÃO DO BANCO DE DADOS SUPABASE

### ⚠️ **IMPORTANTE: Execute o Script SQL Antes de Usar**

O sistema agora salva o histórico de execuções no **Supabase** para que você nunca perca seus dados.

### 📝 **Passo a Passo:**

1. **Acesse o Supabase:**
   - URL: https://supabase.com/dashboard/project/[seu-projeto]
   - Vá em **SQL Editor** no menu lateral

2. **Execute o Script:**
   - Abra o arquivo: [`supabase-futures-executions.sql`](supabase-futures-executions.sql)
   - **Copie TODO o conteúdo**
   - **Cole no SQL Editor**
   - Clique em **Run** (ou Ctrl+Enter)

3. **Verifique o Sucesso:**
   ```sql
   -- Deve retornar a tabela criada
   SELECT tablename FROM pg_tables WHERE tablename = 'futures_executions';
   ```

### 📊 **O que é criado:**

| Item | Descrição |
|------|-----------|
| **Tabela** `futures_executions` | Histórico completo de todas as execuções |
| **View** `futures_execution_stats` | Estatísticas gerais (win rate, P&L total, etc) |
| **View** `futures_stats_by_symbol` | Performance por par (BTCUSDT, ETHUSDT, etc) |
| **View** `futures_stats_by_day` | Lucro/perda diário |
| **View** `futures_recent_executions` | Últimas 100 execuções |
| **6 índices** | Otimização de performance das consultas |
| **Trigger automático** | Calcula lucro líquido automaticamente |
| **Políticas RLS** | Segurança de acesso aos dados |

### 🔄 **Como funciona a sincronização:**

```
1. Ordem executada → Salva no Supabase + localStorage
2. Posição fechada → Atualiza resultado no Supabase + localStorage
3. Sistema sincroniza automaticamente (não precisa fazer nada!)
```

**Vantagens da sincronização:**
- ✅ **Nunca perde dados** (mesmo limpando cache do navegador)
- ✅ **Histórico ilimitado** (não tem limite de 5-10MB do localStorage)
- ✅ **Acesso de qualquer dispositivo** (dados na nuvem)
- ✅ **Estatísticas em tempo real** via views SQL
- ✅ **Backup automático** sempre disponível
- ✅ **Análises avançadas** com SQL queries

### 📈 **Consultas Úteis:**

```sql
-- Ver estatísticas gerais
SELECT * FROM futures_execution_stats;

-- Ver performance por símbolo
SELECT * FROM futures_stats_by_symbol;

-- Ver lucro diário
SELECT * FROM futures_stats_by_day;

-- Ver últimas execuções
SELECT * FROM futures_recent_executions;

-- Posições ainda abertas
SELECT * FROM futures_executions WHERE result = 'PENDING';

-- Melhores trades (top 10)
SELECT symbol, direction, net_profit, created_at
FROM futures_executions
WHERE result IN ('TAKE_PROFIT', 'STOP_LOSS')
ORDER BY net_profit DESC
LIMIT 10;
```

### 🔍 **Estrutura da Tabela:**

```sql
futures_executions {
  id: UUID (gerado automaticamente)
  signal_id: TEXT
  timestamp: TIMESTAMPTZ
  symbol: TEXT (ex: BTCUSDT)
  direction: TEXT (LONG ou SHORT)

  -- Preços
  entry_price: NUMERIC
  stop_loss: NUMERIC
  take_profit: NUMERIC
  exit_price: NUMERIC

  -- IDs das ordens
  order_id: TEXT
  stop_loss_order_id: TEXT
  take_profit_order_id: TEXT

  -- Resultados
  result: TEXT (PENDING/TAKE_PROFIT/STOP_LOSS/EXPIRED/MANUAL)
  pnl: NUMERIC (lucro/perda bruto)
  commission: NUMERIC (taxa Binance)
  net_profit: NUMERIC (calculado automaticamente)

  -- Gestão
  risk_amount: NUMERIC
  quantity: NUMERIC
  leverage: INTEGER
  margin_mode: TEXT (ISOLATED/CROSS)

  -- Metadados
  confidence_score: NUMERIC (score do ML)
  simulated: BOOLEAN
  created_at: TIMESTAMPTZ
  closed_at: TIMESTAMPTZ
  metadata: JSONB
}
```

---

## 🔧 SOLUÇÃO DE PROBLEMAS

### ❌ ERRO: "Erro ao executar ordem Binance"

**Causas possíveis:**
1. API Keys inválidas
2. Permissões insuficientes
3. IP não autorizado
4. Saldo insuficiente

**Solução:**
```javascript
// 1. Verificar conexão
console.log(apiManagerRef.current.getActiveConnection());

// 2. Testar conexão
const test = await apiManagerRef.current.testConnection();
console.log(test);

// 3. Verificar saldo
// (fazer chamada manual à API Binance)
```

### ❌ ERRO: "Circuit Breaker ativo"

**O que fazer:**
1. Analisar últimas operações
2. Identificar padrão de erro
3. Ajustar configurações se necessário
4. Reativar manualmente:

```javascript
orderExecutorRef.current.deactivateCircuitBreaker();
```

### ❌ ERRO: "Posição não fecha após 5 minutos"

**Verificar:**
1. Timer está rodando?
```javascript
console.log(orderExecutorRef.current.positionTimers);
```

2. Forçar fechamento manual:
```javascript
orderExecutorRef.current.autoClosePosition(signalId, 'MANUAL');
```

### ⚠️ POPUP NÃO APARECE (Modo Manual)

**Verificar:**
1. Modo está em 'manual'?
```javascript
console.log(mode); // deve ser 'manual'
```

2. Há sinal pendente?
```javascript
console.log(orderExecutorRef.current.getPendingSignal());
```

3. Z-index do popup está correto?
```css
zIndex: 10000 /* deve estar acima de tudo */
```

---

## 🧪 TESTAR ANTES DE USAR DINHEIRO REAL

### 🔬 1. TESTNET DA BINANCE

**URL:** https://testnet.binancefuture.com

1. Criar conta na testnet
2. Obter API keys de teste
3. Ativar "Testnet" no Alpha-Learner
4. Testar operações com dinheiro virtual

### 🎮 2. MODO SIMULADO

O sistema já tem fallback para modo simulado se a API falhar.

```javascript
// Forçar modo simulado
const result = await orderExecutorRef.current.executeSimulatedOrder(signal, riskAmount);
```

---

## 📚 ARQUIVOS MODIFICADOS

| Arquivo | Linhas | O que foi feito |
|---------|--------|-----------------|
| `index.html` | 1083-1099 | Configurações Futures |
| `index.html` | 1101-1118 | Constructor do OrderExecutionManager |
| `index.html` | 1163-1323 | Processamento de sinais (manual/auto) |
| `index.html` | 1325-1517 | Execução Binance Futures + SL/TP |
| `index.html` | 1564-1680 | Timer, fechamento auto e circuit breaker |
| `index.html` | 1682-1763 | Métodos manuais e exportação CSV |
| `index.html` | 1765-1784 | closePosition atualizado |
| `index.html` | 5448-5453 | Integração do popup no App |
| `index.html` | 5467-5739 | Componente ManualSignalPopup |

---

## ✅ CHECKLIST DE SEGURANÇA

Antes de operar com dinheiro real:

- [ ] Testei na **Binance Testnet**
- [ ] API keys têm **apenas** permissões Futures + Trading
- [ ] **IP está restrito** nas configurações da API
- [ ] **Margem está em ISOLATED** (não Cross)
- [ ] **Circuit breaker** está ativo (3 perdas)
- [ ] **Risco por trade** está em 1-2%
- [ ] Testei **modo manual** e entendi como funciona
- [ ] Li e entendi a **documentação completa**
- [ ] Tenho **capital que posso perder** (nunca invista mais do que pode perder)

---

## 📞 SUPORTE

Se encontrar problemas:

1. **Console do navegador** (F12) → verificar erros
2. **Logs do sistema:**
```javascript
console.log(orderExecutorRef.current.getSystemLogs());
```

3. **GitHub Issues** (se aplicável)

---

## ⚖️ AVISO LEGAL

⚠️ **IMPORTANTE:**

- Trading de criptomoedas envolve **RISCO ELEVADO**
- Você pode **PERDER TODO SEU CAPITAL**
- Este sistema é **EDUCACIONAL**
- **NÃO É GARANTIA DE LUCRO**
- Use por sua conta e risco
- Teste exaustivamente antes de usar dinheiro real

---

**Desenvolvido com ❤️ para a comunidade de traders**

**Versão:** 2.4 (com Binance Futures completo)
**Data:** Outubro 2025
**Licença:** MIT

🚀 **Bons trades e gestão de risco sempre!**

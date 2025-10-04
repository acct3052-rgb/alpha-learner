# 🚀 Alpha-Learner v2.4

Sistema de Trading Automatizado com Inteligência Artificial e Machine Learning

## 📌 Como Usar

### **Método Atual (Recomendado)**

Simplesmente abra o arquivo no navegador:

```bash
# Abrir index.html diretamente
open index.html

# Ou use um servidor HTTP simples
python -m http.server 8000
# Acesse: http://localhost:8000
```

✅ **Sistema totalmente funcional** - Todas as features implementadas!

## 🎯 Features

- ✅ **Trading Automatizado** (Binance Futures)
- ✅ **Machine Learning** (TensorFlow.js)
- ✅ **Análise Técnica Completa** (15+ indicadores)
- ✅ **Sistema de Watchdog** (Anti-travamento)
- ✅ **Persistência** (Supabase)
- ✅ **Notificações** (Telegram)
- ✅ **Modo Manual/Auto**
- ✅ **Auditoria Completa**

## 📊 **Configuração**

### 1. **Supabase** (Obrigatório)

Edite `config.js`:

```javascript
window.SUPABASE_CONFIG = {
    url: 'https://seu-projeto.supabase.co',
    key: 'sua-chave-anon-aqui'
};
```

Ou use `.env` (se rodar com Vite):

```bash
VITE_SUPABASE_URL=https://seu-projeto.supabase.co
VITE_SUPABASE_ANON_KEY=sua-chave-anon
```

### 2. **Binance API** (Opcional - pode configurar via interface)

Adicione na interface em "Conexões API"

### 3. **Telegram** (Opcional)

Configure via interface em "Configurações"

## 🔧 **Desenvolvimento (Opcional)**

Se quiser usar a infraestrutura moderna preparada:

```bash
# Instalar dependências
npm install

# Modo desenvolvimento (hot reload)
npm run dev

# Build otimizado
npm run build
```

**Nota**: A refatoração completa para módulos ES6 está preparada mas não finalizada.
Veja `REFACTOR_STATUS.md` para detalhes.

## 📂 **Arquivos Importantes**

- `index.html` - Sistema completo (USE ESTE)
- `config.js` - Configuração Supabase
- `REFACTOR_STATUS.md` - Status da modernização
- `SUPABASE_SETUP.md` - Como configurar banco de dados

## 🛡️ **Proteções Anti-Travamento**

O sistema possui:
- ✅ Watchdog (verifica saúde a cada 1min)
- ✅ Limpeza automática de memória
- ✅ Reconexão infinita (WebSocket)
- ✅ Auto-recovery de dados
- ✅ Tratamento de erros robusto

**Pode rodar dias sem supervisão!**

## 📚 **Documentação**

- [Supabase Setup](./SUPABASE_SETUP.md)
- [Binance Futures Guide](./BINANCE_FUTURES_GUIDE.md)
- [Refactor Status](./REFACTOR_STATUS.md)
- [Test Manual Mode](./TESTE_MODO_MANUAL.md)

## 🤝 **Contribuindo**

Este é um projeto pessoal de trading. Se encontrar bugs ou tiver sugestões:

1. Abra uma issue
2. Descreva o problema/sugestão
3. Logs do console ajudam muito!

## ⚠️ **Aviso Legal**

Este sistema é para fins educacionais. Trading envolve riscos. Use por sua conta e risco.

---

**Versão**: 2.4.0
**Última atualização**: 2025-10-04
**Autor**: Alpha-Learner Team

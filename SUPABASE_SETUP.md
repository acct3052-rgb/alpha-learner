# 🗄️ Configuração do Banco de Dados Supabase

Este guia mostra como configurar o banco de dados do Alpha-Learner no Supabase.

## ⚠️ IMPORTANTE - Execute Antes de Usar o Sistema

**Você DEVE executar o script de migração antes de usar o sistema!**

## 📋 Passos para Configuração

### 1. Acessar o SQL Editor do Supabase

1. Acesse: https://supabase.com/dashboard/project/eamgmklplhbbdzflsxji
2. No menu lateral, clique em **SQL Editor**
3. Clique em **New query**

### 2. Executar o Script de Migração

1. Abra o arquivo `supabase-migrate.sql` deste repositório
2. **Copie TODO o conteúdo** (329 linhas)
3. **Cole no SQL Editor** do Supabase
4. Clique em **Run** (ou Ctrl+Enter)

### 3. Verificar Sucesso

Após executar, você verá no final do output:

```
✅ 5 tabelas listadas
✅ Múltiplos índices criados
```

## 🔍 Como Saber se o Erro é Falta do Banco?

Se você vê este erro no console:

```
POST .../rest/v1/signals 400 (Bad Request)
```

E a mensagem diz:
- `"relation "signals" does not exist"` → **Execute o script!**
- `"code": "42P01"` → **Execute o script!**

## ✅ Após Executar o Script

1. Recarregue a página da aplicação
2. O erro 400 deve desaparecer
3. Os sinais serão salvos corretamente

## 📊 Tabelas Criadas

O script cria 5 tabelas:
- `api_connections` - Configurações de APIs
- `signals` - Sinais de trading
- `ml_weights_evolution` - Pesos ML
- `audit_logs` - Logs de auditoria  
- `performance_stats` - Estatísticas

## 🆘 Ainda com Problemas?

Verifique no console (F12) as mensagens:
- Procure por "Detalhes do erro:"
- Procure por "message", "details", "hint"
- Isso mostrará exatamente qual é o problema

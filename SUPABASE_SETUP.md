# Alpha-Learner Supabase Setup Guide

Complete guide to set up your Supabase database for the Alpha-Learner trading platform.

---

## 📋 Prerequisites

- A Supabase account (free tier works fine)
- Your Supabase project created

---

## 🚀 Step-by-Step Setup

### Step 1: Create a New Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign in or create an account
3. Click **"New Project"**
4. Fill in:
   - **Name**: `alpha-learner` (or your preferred name)
   - **Database Password**: Choose a strong password (save it somewhere safe)
   - **Region**: Choose closest to you for better performance
5. Click **"Create new project"**
6. Wait 2-3 minutes for the project to be ready

---

### Step 2: Run the Database Migration

1. In your Supabase project dashboard, click **"SQL Editor"** in the left sidebar
2. Click **"+ New Query"** button
3. Open the file `supabase-migration.sql` from this repository
4. **Copy the entire contents** of the file
5. **Paste** into the SQL Editor
6. Click **"Run"** or press `Ctrl+Enter`
7. You should see: **"Success. No rows returned"** ✅

---

### Step 3: Verify Tables Were Created

1. Click **"Table Editor"** in the left sidebar
2. You should see these 5 tables:
   - ✅ `api_connections`
   - ✅ `signals`
   - ✅ `ml_weights_evolution`
   - ✅ `audit_logs`
   - ✅ `performance_stats`

---

### Step 4: Get Your API Credentials

1. Click **"Settings"** (gear icon) in the left sidebar
2. Click **"API"** in the settings menu
3. Copy these two values:

   **Project URL:**
   ```
   https://your-project-id.supabase.co
   ```

   **Anon (public) key:**
   ```
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

---

### Step 5: Configure Alpha-Learner

You have **3 options** to configure your credentials:

#### Option 1: Create a config.js file (Recommended)

1. Create a new file called `config.js` in the same folder as `index.html`
2. Add this content (replace with your actual values):

```javascript
window.SUPABASE_CONFIG = {
    url: 'https://your-project-id.supabase.co',
    key: 'your-anon-key-here'
};
```

3. Open `index.html` and add this line in the `<head>` section, **before** other scripts:

```html
<script src="config.js"></script>
```

#### Option 2: Use Browser Prompts (Default)

- Just open `index.html` in your browser
- You'll be prompted to enter your URL and Key
- The app will store them in memory for the session

#### Option 3: Hardcode in index.html (Not Recommended)

1. Open `index.html`
2. Find this section (around line 540):

```javascript
let SUPABASE_URL = '';
let SUPABASE_KEY = '';
```

3. Replace with your actual values:

```javascript
let SUPABASE_URL = 'https://your-project-id.supabase.co';
let SUPABASE_KEY = 'your-anon-key-here';
```

⚠️ **Warning**: Never commit hardcoded credentials to a public repository!

---

### Step 6: Test the Connection

1. Open `index.html` in your browser
2. Open the browser console (F12)
3. You should see:
   ```
   ✅ Supabase conectado com sucesso!
   💾 Conexões salvas no Supabase
   ```
4. If you see errors, double-check your URL and API key

---

## 📊 Database Structure

### Tables Overview

| Table | Purpose | Key Fields |
|-------|---------|------------|
| **api_connections** | API provider configs | connections (JSONB), active_provider |
| **signals** | Trading signals history | symbol, direction, score, price, status, pnl, **entry_time**, **executed** |
| **ml_weights_evolution** | ML weight snapshots | weights (JSONB), performance, win_rate, timestamp |
| **audit_logs** | Signal generation audit trail | signal_id, indicators, outcome, **reason** |
| **performance_stats** | Aggregated statistics | stat_type, wins, losses, total_pnl |

### Important Schema Notes

**signals table** includes:
- `entry_time`: Timestamp when the signal was executed/entered
- `executed`: Boolean flag indicating if the signal has been executed
- All fields match the JavaScript code that saves signals (line 1915-1936 in index.html)

**audit_logs table** includes:
- `reason`: Text field for storing the reason for signal outcome
- All fields match the JavaScript code that saves audit logs (line 1427-1439 in index.html)

---

## 🔒 Security Settings

### Current Configuration (Development)

The migration sets up **permissive RLS policies** that allow all operations without authentication:

```sql
CREATE POLICY "Allow all on signals" ON public.signals
    FOR ALL USING (true) WITH CHECK (true);
```

⚠️ **This is fine for personal use but NOT for production!**

### Recommended for Production

1. Enable Supabase Authentication
2. Update RLS policies to require authentication:

```sql
-- Example: Only allow authenticated users
DROP POLICY "Allow all on signals" ON public.signals;

CREATE POLICY "Users can view their own signals" ON public.signals
    FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can insert their own signals" ON public.signals
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
```

3. Add a `user_id` column to all tables
4. Update application code to handle authentication

---

## 🧪 Testing Your Setup

Run these queries in the SQL Editor to verify everything works:

```sql
-- Test 1: Check all tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('api_connections', 'signals', 'ml_weights_evolution', 'audit_logs', 'performance_stats');

-- Test 2: Check indexes were created
SELECT tablename, indexname
FROM pg_indexes
WHERE schemaname = 'public';

-- Test 3: Verify api_connections default row
SELECT * FROM api_connections;

-- Test 4: Check RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';
```

Expected results:
- ✅ Test 1: Should return 5 rows
- ✅ Test 2: Should return multiple indexes
- ✅ Test 3: Should return 1 row with id=1
- ✅ Test 4: All tables should have `rowsecurity = true`

---

## 🛠️ Common Issues & Solutions

### Issue 1: "relation already exists" error

**Solution**: Tables already exist. Either:
- Drop existing tables first (⚠️ deletes all data!)
- Or modify the migration to use `CREATE TABLE IF NOT EXISTS` (already included)

### Issue 2: "permission denied" when running migration

**Solution**:
- Make sure you're using the SQL Editor in your Supabase dashboard
- Don't run this from the API, it needs admin privileges

### Issue 3: Connection works but data doesn't save

**Solution**:
1. Check browser console for errors
2. Verify RLS policies are set correctly
3. Try this in SQL Editor:
   ```sql
   SELECT * FROM signals;
   ```
4. If you see "row-level security policy" error, check policies

### Issue 4: "Failed to fetch" errors in browser

**Solution**:
- Verify your SUPABASE_URL doesn't have trailing slash
- Check that SUPABASE_KEY is the **anon** key, not the **service_role** key
- Make sure your internet connection is working

---

## 📈 Data Management

### View Recent Signals
```sql
SELECT id, symbol, direction, score, status, created_at
FROM signals
ORDER BY created_at DESC
LIMIT 10;
```

### Check ML Performance
```sql
SELECT timestamp, win_rate, total_signals
FROM ml_weights_evolution
ORDER BY timestamp DESC
LIMIT 5;
```

### Performance by Hour
```sql
SELECT
    stat_key as hour,
    wins,
    losses,
    ROUND((wins::decimal / NULLIF(wins + losses, 0) * 100), 2) as win_rate_pct
FROM performance_stats
WHERE stat_type = 'hour'
ORDER BY stat_key::integer;
```

### Clear All Data (⚠️ Use with caution!)
```sql
TRUNCATE TABLE audit_logs, signals, ml_weights_evolution, performance_stats RESTART IDENTITY CASCADE;
```

---

## 🔄 Backup & Restore

### Backup Your Data

1. Go to **Database** > **Backups** in Supabase dashboard
2. Click **"Start a backup"**
3. Download the backup file

### Export Data Manually

```sql
-- Export signals to CSV
COPY (SELECT * FROM signals ORDER BY created_at DESC)
TO '/tmp/signals_backup.csv' WITH CSV HEADER;
```

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [SQL Editor Guide](https://supabase.com/docs/guides/database/overview)
- [API Reference](https://supabase.com/docs/reference/javascript/introduction)

---

## ✅ Setup Checklist

- [ ] Supabase project created
- [ ] Migration SQL executed successfully
- [ ] All 5 tables visible in Table Editor
- [ ] API credentials copied
- [ ] Credentials configured in alpha-learner
- [ ] Connection tested in browser console
- [ ] First signal generated and saved successfully

---

## 🎉 You're All Set!

Your Alpha-Learner platform is now connected to Supabase and ready to:
- 💾 Store trading signals persistently
- 📊 Track ML model evolution
- 📈 Analyze performance statistics
- 🔍 Audit signal generation process
- 🔄 Sync data across devices

Happy Trading! 🚀

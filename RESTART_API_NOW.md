# 🚨 RESTART THE API SERVER!

## The Issue

The WebSocket library is **INSTALLED** ✅ but the server is still running the **OLD VERSION** without it!

**You MUST restart the API server to load the new libraries.**

---

## 📋 Step-by-Step Instructions

### Step 1: Stop the Current API Server

**In your API terminal** (where you ran the uvicorn command):

1. Click on the terminal window
2. Press **`Ctrl+C`** 
3. Wait for it to say "Shutting down"

---

### Step 2: Navigate to the Correct Directory

```bash
cd D:\Projects\yomehe
```

**IMPORTANT**: Make sure you're in `D:\Projects\yomehe` NOT `D:\Projects\yomehe\python_api`

---

### Step 3: Start the API Server Again

```bash
python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

---

## ✅ What You Should See

After restarting, you should see:

```
INFO:     Will watch for changes in these directories: ['D:\\Projects\\yomehe']
INFO:     Uvicorn running on http://0.0.0.0:8080 (Press CTRL+C to quit)
INFO:     Started reloader process [XXXXX] using StatReload
INFO:     Started server process [XXXXX]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

**NO MORE "Unsupported upgrade request" warnings!**

---

## 🧪 Then Test

After the server restarts:

1. **Client App**: Create a new session
2. **Check API terminal**: Should see "Client connected to session X WebSocket" ✅
3. **No more 404 errors!**

---

## 💡 Why This Happens

When you install a new Python package:
- ✅ Package is installed on disk
- ❌ Running process doesn't know about it
- 🔄 **Must restart the process to load the new package**

---

## 🎯 Quick Commands Summary

```bash
# 1. Press Ctrl+C in API terminal to stop

# 2. Navigate to project root
cd D:\Projects\yomehe

# 3. Restart the server
python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

---

**Do these 3 steps now and WebSockets will work!** 🚀

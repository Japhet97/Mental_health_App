# 🚀 How to Start the YONECO API

## Quick Start (Copy & Paste)

### Open PowerShell or Command Prompt

```bash
cd D:\Projects\yomehe\python_api
python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8001
```

That's it! ✅

---

## What You'll See

```
INFO:     Will watch for changes in these directories: ['D:\\Projects\\yomehe\\python_api']
INFO:     Uvicorn running on http://0.0.0.0:8001 (Press CTRL+C to quit)
INFO:     Started reloader process [12345] using StatReload
INFO:     Started server process [67890]
INFO:     Waiting for application startup.
INFO:     Starting YONECO Backend API...
INFO:     Starting session monitor...
INFO:     Session monitor started
INFO:     Application startup complete.
```

When you see "**Application startup complete**" → ✅ **API is running!**

---

## Access Points

Once running:

- **API Base URL**: http://localhost:8001
- **API Documentation**: http://localhost:8001/docs (Swagger UI)
- **Health Check**: http://localhost:8001/health

---

## Common Issues & Solutions

### Issue 1: "python3.13 not found"
**Try**: `python3 -m uvicorn main:app --reload --host 0.0.0.0 --port 8001`

Or: `python -m uvicorn main:app --reload --host 0.0.0.0 --port 8001`

### Issue 2: "Port 8001 already in use"
**Solution**: Use a different port
```bash
python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8002
```
(Then update apps to use 8002)

### Issue 3: "uvicorn not recognized"
**Solution**: Use the `-m` flag (module syntax)
```bash
python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

---

## Stop the API

Press **CTRL + C** in the terminal

---

## Alternative: One-Line Startup Script

Create a file `start_api.bat` in `python_api` folder:

```batch
@echo off
cd D:\Projects\yomehe\python_api
python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8001
pause
```

Then just double-click `start_api.bat` to start!

---

## Verify It's Running

Open browser and go to: **http://localhost:8001/health**

You should see:
```json
{
  "status": "healthy",
  "service": "yoneco-api"
}
```

✅ **Success!**

---

## Full Command Breakdown

```bash
cd D:\Projects\yomehe\python_api    # Navigate to API folder
python3.13                           # Use Python 3.13
-m uvicorn                          # Run uvicorn module
main:app                            # main.py file, app variable
--reload                            # Auto-reload on code changes
--host 0.0.0.0                      # Listen on all interfaces
--port 8001                         # Use port 8001
```

---

## Next Steps After Starting

1. ✅ API is running on port 8001
2. ✅ Client app configured for port 8001
3. ✅ Counsellor app configured for port 8001
4. ✅ Web app configured for port 8001
5. Run client app: `cd yoneco_app && flutter run`
6. Run counsellor app: `cd yoneco_counsellor_app && flutter run`
7. Run web app: `cd yoneco-web && npm run dev`
8. Test the complete flow!

---

**That's all you need!** 🎉

Just copy the command and run it! 🚀

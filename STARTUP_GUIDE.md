# 🚀 YONECO Mental Health App - Complete Startup Guide

## Quick Fix for "Network Error" in Vue Admin Dashboard

The network error occurs because the backend API server is not running or the Vue app is connecting to the wrong port.

### ✅ Solution Steps:

#### 1. Start the Backend API Server
```bash
cd "d:\Work\YONECO Mental Health App\yomehe\python_api"
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8001
```

**OR** double-click: `python_api\start_server.bat`

#### 2. Start the Vue Admin Dashboard
```bash
cd "d:\Work\YONECO Mental Health App\yomehe\admin-dashboard-vue"
npm run dev
```

**OR** double-click: `admin-dashboard-vue\start_admin.bat`

#### 3. Verify Connection
- Backend API: http://localhost:8001/health
- Admin Dashboard: http://localhost:5173

---

## What Was Fixed:

1. **✅ API URL Corrected**: Changed from `localhost:8080` to `localhost:8001`
2. **✅ CORS Updated**: Added proper origins for Vue app
3. **✅ Better Error Messages**: More specific network error feedback
4. **✅ Startup Scripts**: Easy-to-use batch files created

---

## Complete Application Stack:

### 1. Backend API (Port 8001)
- **Location**: `python_api/`
- **Start**: `python -m uvicorn main:app --reload --host 0.0.0.0 --port 8001`
- **Health Check**: http://localhost:8001/health

### 2. Vue Admin Dashboard (Port 5173)
- **Location**: `admin-dashboard-vue/`
- **Start**: `npm run dev`
- **Access**: http://localhost:5173

### 3. Flutter Mobile App
- **Location**: `yoneco_app/`
- **Start**: `flutter run`

### 4. Flutter Counsellor App
- **Location**: `yoneco_counsellor_app/`
- **Start**: `flutter run`

---

## Troubleshooting:

### Issue: "Network error - please check your connection"
**Cause**: Backend API not running
**Solution**: Start the backend API server first

### Issue: "CORS error"
**Cause**: Frontend trying to access API from unauthorized origin
**Solution**: Already fixed in .env file

### Issue: "Port already in use"
**Solution**: 
- For API: Use different port like 8002
- For Vue: Use `npm run dev -- --port 3001`

---

## Database Requirements:

The app uses PostgreSQL with these settings:
- **Host**: localhost
- **Port**: 5432
- **Database**: yonecomentalhealth_postgres_db
- **User**: postgres
- **Password**: Y0n3k0@root

Make sure PostgreSQL is running before starting the API.

---

## Success Indicators:

✅ **Backend Running**: See "Application startup complete" message
✅ **Vue App Running**: See "Local: http://localhost:5173"
✅ **Connection Working**: Can add/edit issues without network errors

---

**That's it! The network error should now be resolved.** 🎉
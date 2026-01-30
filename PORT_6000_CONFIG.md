# 🚀 Tithandizane Helpline - Port 6000 Configuration

## ✅ All Systems Now Use Port 6000

Everything has been updated to communicate on **PORT 6000**:

---

## 📡 API Configuration

**Base URL:** `http://localhost:6000`

### Start API:
```bash
# Option 1: Double-click
START_API.bat

# Option 2: Command line
cd python_api
python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 6000

# Option 3: PowerShell script
.\RESTART_API.ps1
```

### API Endpoints:
- **API Docs:** http://localhost:6000/docs
- **API Root:** http://localhost:6000
- **Admin Dashboard:** http://localhost:6000/admin/dashboard
- **Health Check:** http://localhost:6000/health (if available)

---

## 🖥️ Admin Dashboard Configuration

**Dashboard URL:** `http://localhost:5173`  
**API Connection:** `http://localhost:6000`

### Start Dashboard:
```bash
# Option 1: Double-click
START_DASHBOARD.bat

# Option 2: Command line
cd admin-dashboard-vue
npm run dev
```

---

## 📱 Flutter Apps Configuration

Update these files to use port **6000**:

### Client App (yoneco_app):
```dart
// lib/services/api_service.dart
static const String baseUrl = 'http://localhost:6000';
// Or for mobile: 'http://10.0.2.2:6000' (Android emulator)
// Or for mobile: 'http://YOUR_IP:6000' (Physical device)
```

### Counsellor App (yoneco_counsellor_app):
```dart
// lib/services/api_service.dart
static const String baseUrl = 'http://localhost:6000';
// Or for mobile: 'http://10.0.2.2:6000' (Android emulator)
// Or for mobile: 'http://YOUR_IP:6000' (Physical device)
```

### Web App (yoneco-web):
```javascript
// src/services/api.js
const API_BASE_URL = 'http://localhost:6000';
```

---

## 🔧 Files Updated

✅ `admin-dashboard-vue/src/services/api.js` → Port 6000  
✅ `START_API.bat` → Port 6000  
✅ `RESTART_API.ps1` → Port 6000  

---

## 🚀 Quick Start (2 Steps)

### Step 1: Start API
```bash
cd D:\Projects\yomehe
START_API.bat
```
Wait for: `Application startup complete`

### Step 2: Start Dashboard
```bash
cd D:\Projects\yomehe
START_DASHBOARD.bat
```
Wait for: `ready in XXXms`

### Step 3: Open Browser
Navigate to: **http://localhost:5173**

Login:
- Email: `admin@yoneco.org`
- Password: `Admin@2025`

---

## 🔍 Verify Connection

### Check API is Running:
```bash
# In browser
http://localhost:6000/docs

# In PowerShell
Invoke-WebRequest http://localhost:6000/docs
```

### Check Port is Open:
```bash
netstat -ano | findstr :6000
```

---

## 🌐 Network Access

### For External Access (Mobile Devices):
Find your local IP:
```bash
ipconfig
# Look for IPv4 Address (e.g., 192.168.1.100)
```

Update Flutter apps:
```dart
static const String baseUrl = 'http://192.168.1.100:6000';
```

Make sure firewall allows port 6000!

---

## 🛡️ Firewall Configuration

Allow port 6000:
```powershell
# Run as Administrator
New-NetFirewallRule -DisplayName "Tithandizane API" -Direction Inbound -LocalPort 6000 -Protocol TCP -Action Allow
```

---

## 📊 Port Summary

| Service | Port | URL |
|---------|------|-----|
| **API Server** | 6000 | http://localhost:6000 |
| **Admin Dashboard** | 5173 | http://localhost:5173 |
| **PostgreSQL** | 5432 | localhost:5432 |

---

## ✅ Benefits of Port 6000

- ✅ No conflict with common services
- ✅ Easy to remember
- ✅ Within standard port range
- ✅ Consistent across all apps

---

## 🎯 All Set!

Port 6000 is now your standard API port for the Tithandizane Helpline system! 🚀

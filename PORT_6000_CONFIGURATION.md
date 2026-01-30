# Port 6000 Configuration - Complete

## ✅ All Systems Updated to Port 6000

### Backend API
- **Port:** 6000
- **URL:** http://localhost:6000
- **Docs:** http://localhost:6000/docs
- **Status:** Running ✅

### Frontend Applications

#### 1. Client App (Flutter)
- **Config File:** `yoneco_app/lib/config/app_config.dart`
- **Port:** 6000
- **Android Emulator:** `http://10.0.2.2:6000`
- **Physical Device:** `http://YOUR_IP:6000`

#### 2. Counsellor App (Flutter)
- **Config File:** `yoneco_counsellor_app/lib/config/app_config.dart`
- **Port:** 6000
- **Android Emulator:** `http://10.0.2.2:6000`
- **Physical Device:** `http://YOUR_IP:6000`

#### 3. Admin Dashboard (Vue.js)
- **Config File:** `admin-dashboard-vue/src/services/api.js`
- **Port:** 6000
- **URL:** `http://localhost:6000`
- **Dashboard runs on:** http://localhost:5173

### Start Scripts Updated

#### START_API.ps1
```powershell
# Starts API on port 6000
.\START_API.ps1
```

#### START_API.bat
```batch
# Starts API on port 6000
START_API.bat
```

### WebSocket Configuration
All WebSocket connections also use port 6000:
- Client sessions: `ws://10.0.2.2:6000/ws/session/{session_id}?token={token}`
- Counsellor notifications: `ws://10.0.2.2:6000/ws/counselors?token={token}`

### Testing the Connection

1. **API Health Check:**
   ```powershell
   Invoke-WebRequest http://localhost:6000/docs
   ```

2. **Dashboard Connection:**
   - Open http://localhost:5173
   - Login to admin dashboard
   - Dashboard will communicate with API at http://localhost:6000

3. **Mobile Apps:**
   - Rebuild both Flutter apps after config change
   - Apps will connect to `http://10.0.2.2:6000`

### Next Steps for Mobile Testing

If using physical devices, update the config files to use your computer's IP:

```dart
static const String apiBaseUrl = "http://192.168.1.XXX:6000";
```

Replace `192.168.1.XXX` with your actual computer IP address.

---

**All applications are now synchronized on port 6000! 🎉**

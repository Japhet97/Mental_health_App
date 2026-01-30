# 🔑 ADMIN DASHBOARD - QUICK LOGIN GUIDE

## ✅ WORKING CREDENTIALS

### Admin Account (Recommended)
```
Email:    admin@yoneco.org
Password: Admin@2025
```

### Alternative - Counsellor Accounts
```
Email:    counsellor1@yoneco.org
Password: counsellor123

Email:    counsellor2@yoneco.org
Password: counsellor123
```

## 🚀 Quick Access

1. **Make sure API is running:**
   ```powershell
   .\START_API.ps1
   ```

2. **Open Dashboard:**
   - Go to folder: `admin_dashboard`
   - Double-click: `index.html`

3. **Login:**
   - Use credentials above
   - Click "Login"

## ❓ Troubleshooting

### "Invalid credentials or not an admin account"
Try these solutions:

1. **Use the admin account:**
   - Email: `admin@yoneco.org`
   - Password: `Admin@2025`

2. **Check API is running:**
   - Should see "Uvicorn running on http://0.0.0.0:8001"

3. **Check API URL in dashboard:**
   - Open `admin_dashboard/script.js`
   - Verify: `const API_BASE_URL = 'http://102.223.95.28:8001';`

4. **Check browser console:**
   - Press F12
   - Look for error messages
   - Check Network tab for failed requests

### "Failed to login. Please check API connection"
- API is not running or not accessible
- Start API with: `.\START_API.ps1`
- Check firewall settings

## 🔧 Test API Connection

Open browser and visit:
```
http://102.223.95.28:8001
```

Should see:
```json
{
  "message": "Tithandizane Helpline Mental Health Support API",
  "version": "1.0.0",
  "status": "running"
}
```

## 📝 Notes

- Admin account has full access to all features
- Counsellor accounts currently have admin privileges
- Dashboard auto-refreshes every 30 seconds
- All changes are immediate in the database

---

**If still having issues, check:**
1. API terminal for error messages
2. Browser developer console (F12)
3. Network connectivity
4. Correct IP address in script.js

# 🔐 Admin Dashboard Login Credentials

## Quick Solution for Network Error

The "Network error" when adding issues happens because **you're not logged in**.

### **Login Credentials:**
- **URL**: http://localhost:5173
- **Email**: `admin@yoneco.org`
- **Password**: `Admin@2025`

### **Steps to Fix:**
1. ✅ Make sure backend is running: http://localhost:8001/health
2. ✅ Go to admin dashboard: http://localhost:5173
3. ✅ **Login with the credentials above**
4. ✅ Try adding an issue - it should work now!

### **Why This Happens:**
- The `/admin/issues` POST endpoint requires authentication
- Vue app needs a valid JWT token to create/edit issues
- After login, the token is stored and sent with all requests

### **Verification:**
After login, you should see:
- No more "Connection Error" messages
- "Add Issue" button is enabled
- Issues can be created/edited successfully

---

**That's it! Just log in and everything will work.** 🎉
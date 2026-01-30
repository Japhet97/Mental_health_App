# 👥 YONECO Counsellor Accounts

## Active Counsellor Accounts

### Account 1: Dr. Smith
- **Email**: `dr.smith@yoneco.org`
- **Password**: `counsellor123`
- **Name**: Dr. John Smith
- **Status**: ✅ Active

### Account 2: Dr. Thompson (NEW!)
- **Email**: `dr.thompson@yoneco.org`
- **Password**: `counsellor789`
- **Name**: Dr. Thompson
- **Status**: ✅ Active

---

## All Registered Counsellors

| ID | Email | Name | Notes |
|----|-------|------|-------|
| 1 | dr.smith@yoneco.org | Dr. John Smith | Original account |
| 2 | dr.jones@yoneco.org | Dr. Sarah Jones | Password unknown |
| 3 | dr.wilson@yoneco.org | Dr. Michael Wilson | Password unknown |
| 4 | dr.brown@yoneco.org | Dr. Emily Brown | Password unknown |
| 5 | dr.davis@yoneco.org | Dr. James Davis | Password unknown |
| 6 | counsellor@yoneco.org | Dr. Jane Doe | Password unknown |
| 7 | dr.johnson@yoneco.org | Dr. Johnson | Password unknown |
| 8 | dr.thompson@yoneco.org | Dr. Thompson | **NEW - Password: counsellor789** |

---

## How to Login

### Web App:
1. Navigate to: `http://192.168.21.23:5173` (from mobile) or `http://localhost:5173` (from PC)
2. Enter credentials:
   - Email: `dr.smith@yoneco.org` or `dr.thompson@yoneco.org`
   - Password: `counsellor123` or `counsellor789`
3. Click Login

### Mobile Counsellor App:
1. Run the app: `cd yoneco_counsellor_app && flutter run`
2. Enter same credentials as above
3. Login

---

## Admin Account

- **Email**: `admin@yoneco.com`
- **Password**: `YonecoAdmin2024!`
- **Access**: Full admin dashboard access

---

## Create More Counsellors

To create additional counsellor accounts:

### Method 1: Use the Script
```powershell
cd D:\Projects\yomehe\python_api
```

Edit `create_new_counsellor.py`:
- Change `email` (e.g., `dr.newname@yoneco.org`)
- Change `name` (e.g., `Dr. New Name`)
- Change `pw` (e.g., `password123`)

Then run:
```powershell
python3.13 create_new_counsellor.py
```

### Method 2: Use Interactive Script
```powershell
cd D:\Projects\yomehe\python_api
python3.13 create_counsellor.py
```

Enter details when prompted.

---

## Check Existing Counsellors

```powershell
cd D:\Projects\yomehe\python_api
python3.13 check_counsellors.py
```

---

## Testing the Accounts

1. **Start API** (if not running):
   ```powershell
   cd D:\Projects\yomehe\python_api
   python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8001
   ```

2. **Test Login via API**:
   ```powershell
   curl -X POST http://192.168.21.23:8001/auth/login `
     -H "Content-Type: application/json" `
     -d '{"email":"dr.thompson@yoneco.org","password":"counsellor789"}'
   ```

3. **Run Counsellor App**:
   ```powershell
   cd D:\Projects\yomehe\yoneco_counsellor_app
   flutter run
   ```

---

## Important Notes

⚠️ **Security Reminder**: These are test credentials. In production:
- Use stronger passwords
- Store passwords securely (never in plain text)
- Implement password reset functionality
- Use HTTPS for all connections
- Enable 2FA for counsellor accounts

---

**Last Updated**: 2025-11-04  
**Total Counsellors**: 8  
**Active Accounts with Known Passwords**: 2 (Dr. Smith, Dr. Thompson)

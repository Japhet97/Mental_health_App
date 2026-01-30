# 👥 YONECO Counsellor Accounts

## ✅ Created Counsellors

| ID | Name | Email | Password |
|----|------|-------|----------|
| 3 | Dr. John Smith | dr.smith@yoneco.org | DrSmith123 |
| 4 | Dr. Sarah Jones | dr.jones@yoneco.org | DrJones123 |
| 5 | Dr. Michael Wilson | dr.wilson@yoneco.org | DrWilson123 |
| 6 | Dr. Emily Brown | dr.brown@yoneco.org | DrBrown123 |
| 7 | Dr. James Davis | dr.davis@yoneco.org | DrDavis123 |

---

## 🔐 Login Instructions

### For Counsellor App:

1. Open counsellor app
2. Enter email and password
3. Tap "Login"

**Example Login:**
```
Email: dr.smith@yoneco.org
Password: DrSmith123
```

---

## 🧪 Testing Login

```bash
# Test login via API
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"dr.smith@yoneco.org","password":"DrSmith123"}'
```

Expected response:
```json
{
  "access_token": "eyJ...",
  "token_type": "bearer",
  "user": {
    "id": 3,
    "email": "dr.smith@yoneco.org",
    "name": "Dr. John Smith"
  }
}
```

---

## 📝 Notes

- All passwords are secure (bcrypt hashed)
- Passwords can be changed later
- Email addresses are unique per counsellor
- Counsellors can handle multiple sessions simultaneously

---

## 🔄 Creating More Counsellors

### Method 1: Use the script (bulk create)
```bash
cd python_api
python3.13 create_multiple_counsellors.py
```

### Method 2: Individual creation
```bash
cd python_api
python3.13 create_counsellor.py

# Enter:
# Email: newcounsellor@yoneco.org
# Name: Dr. New Counsellor
# Password: [your password]
```

---

## 🎯 Quick Test Flow

1. **Start API**
   ```bash
   cd python_api
   uvicorn main:app --reload
   ```

2. **Start Counsellor App**
   ```bash
   cd yoneco_counsellor_app
   flutter run
   ```

3. **Login with**:
   - Email: `dr.smith@yoneco.org`
   - Password: `DrSmith123`

4. **You're in!** 🎉

---

## 📊 Database Info

**Table**: `counsellors`

**Fields**:
- `id` - Unique identifier
- `email` - Login email (unique)
- `name` - Display name
- `password_hash` - Bcrypt hashed password
- `is_active` - Account status (default: true)
- `created_at` - Account creation timestamp

**View all counsellors**:
```bash
sqlite3 python_api/yoneco.db
SELECT id, email, name FROM counsellors;
.quit
```

---

## ✅ Status

- **Total Counsellors**: 7 (including 2 test accounts)
- **Active Counsellors**: 7
- **Ready for**: Login, session acceptance, chatting

**All systems ready! 🚀**

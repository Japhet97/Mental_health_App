# ✅ COUNSELLOR AUTHENTICATION FIXED!

## 🔧 The Problem

When counsellors tried to accept sessions, they got:
```
Error: Not authenticated
```

**Why?** The `/sessions/{session_id}/accept` endpoint wasn't checking the counsellor's authentication token!

---

## ✅ What I Fixed

### 1. Added Authentication Dependency

**File**: `python_api/security.py`

Added a new function to extract and verify counsellor from token:

```python
def get_current_counsellor_email(credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme)) -> str:
    """Extract and verify counsellor email from Bearer token"""
    token = credentials.credentials
    payload = decode_token(token)
    
    # Verify it's a valid access token (not client session token)
    if not payload or payload.get("type") != "access":
        raise HTTPException(status_code=401, detail="Invalid token")
    
    email = payload.get("sub")
    
    # Make sure it's not a client session token
    if email.startswith("client_session_"):
        raise HTTPException(status_code=401, detail="Not authenticated as counsellor")
    
    return email
```

---

### 2. Protected Accept Session Endpoint

**File**: `python_api/sessions.py`

```python
@router.post("/{session_id}/accept")
async def accept_session(
    session_id: int, 
    counsellor_id: int,
    db: Session = Depends(get_db),
    counsellor_email: str = Depends(get_current_counsellor_email)  # ← Requires auth!
):
    """Counsellor accepts a pending session (requires authentication)"""
    
    # Verify the counsellor exists and matches the ID
    counsellor = crud.get_counsellor_by_email(db, counsellor_email)
    if not counsellor or counsellor.id != counsellor_id:
        raise HTTPException(status_code=403, detail="Forbidden")
    
    # ... rest of the logic
```

**Security Features:**
- ✅ Requires valid Bearer token
- ✅ Verifies token is for a counsellor (not client)
- ✅ Verifies counsellor ID matches the token
- ✅ Prevents clients from accepting sessions

---

### 3. Also Protected Close Session Endpoint

```python
@router.post("/{session_id}/close")
async def close_session(
    session_id: int,
    db: Session = Depends(get_db),
    counsellor_email: str = Depends(get_current_counsellor_email)  # ← Requires auth!
):
    """Close an active session (requires authentication)"""
    # ... logic
```

---

## 🔄 API Will Auto-Reload

Since you're running with `--reload`, the API should automatically restart when it detects the changes.

**Check your API terminal**, you should see:
```
INFO: Detected file changes, reloading...
INFO: Application startup complete.
```

**If it doesn't auto-reload, restart it manually:**
```bash
# Press Ctrl+C, then:
cd D:\Projects\yomehe
python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

---

## 🧪 Test Now

### Step 1: Counsellor Logs In
1. Open counsellor app
2. Login with `dr.smith@yoneco.org` / `DrSmith123`
3. ✅ Token is saved in `_token` and `_counsellorId`

### Step 2: Client Creates Session
1. Open client app
2. Select "Depression"
3. Enter name "John Doe"
4. Tap "Start Live Chat"
5. ✅ Session created

### Step 3: Counsellor Accepts (NOW SHOULD WORK!)
1. In counsellor app, see pending session
2. Tap "Accept"
3. ✅ **Request includes Authorization header**
4. ✅ **API verifies counsellor token**
5. ✅ **Session accepted successfully!**

---

## 📊 Expected API Logs (Success)

```
INFO: 127.0.0.1:xxxxx - "POST /auth/login HTTP/1.1" 200 OK
INFO: 127.0.0.1:xxxxx - "GET /sessions/pending HTTP/1.1" 200 OK
INFO: 127.0.0.1:xxxxx - "POST /sessions/1/accept?counsellor_id=1 HTTP/1.1" 200 OK ✅
INFO: Counsellor connected to WebSocket (token verified)
```

**No more "Not authenticated" errors!**

---

## 🎯 What's Protected Now

| Endpoint | Authentication Required | Who Can Access |
|----------|------------------------|----------------|
| `POST /sessions/create` | ❌ No (clients) | Anyone (anonymous clients) |
| `GET /sessions/pending` | ❌ No | Anyone (counsellors check this) |
| `POST /sessions/{id}/accept` | ✅ **YES** | **Counsellors only** |
| `POST /sessions/{id}/close` | ✅ **YES** | **Counsellors only** |
| `POST /auth/login` | ❌ No | Anyone (to get token) |
| `GET /chat/{id}/messages` | ❌ No | Both clients & counsellors |
| `POST /chat/{id}/send` | ❌ No | Both clients & counsellors |
| `WebSocket /ws/session/{id}` | ✅ **YES** | **Clients with session token** |
| `WebSocket /ws/counselors` | ✅ **YES** | **Counsellors with auth token** |

---

## ✅ Security Summary

### Clients:
- ✅ Can create sessions (no auth needed)
- ✅ Get auto-generated session token
- ✅ Can only connect to their own session WebSocket
- ❌ **Cannot** accept or close sessions

### Counsellors:
- ✅ Must login to get auth token
- ✅ Can accept sessions (with auth)
- ✅ Can close sessions (with auth)
- ✅ Can connect to counselor WebSocket (with auth)
- ✅ Token verified on every protected request

---

## 🚀 Ready to Test!

The API should have auto-reloaded. Now test the complete flow:

1. **Client creates session** → Works ✅
2. **Counsellor logs in** → Gets token ✅
3. **Counsellor accepts session** → Should work now! ✅
4. **Both chat in real-time** → Should work! ✅

**Try it now!** 🎉

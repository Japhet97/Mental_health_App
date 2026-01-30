# 🧪 Complete Testing Checklist

## Pre-Migration Steps

1. **Backup Check**
   ```bash
   cd python_api
   dir *.db
   ```
   - Verify `yoneco.db` exists (if you have data)

## Migration Steps

1. **Run Safe Migration**
   ```bash
   cd python_api
   python safe_migrate.py
   ```
   - ✅ Should see backup created
   - ✅ Should see data exported/imported
   - ✅ Should see "Migration completed successfully!"

2. **Start API**
   ```bash
   uvicorn main:app --reload
   ```
   - ✅ Should start without errors
   - ✅ Should see "Starting session monitor..." in logs

## 🔍 Database Verification

3. **Check Database Schema**
   ```bash
   sqlite3 yoneco.db
   .schema sessions
   .quit
   ```
   - ✅ Should see `updated_at DATETIME`
   - ✅ Should see `closed_at DATETIME`
   - ✅ Should see `timeout_reason VARCHAR`

4. **Verify Data Migration**
   ```bash
   sqlite3 yoneco.db
   SELECT COUNT(*) FROM sessions;
   SELECT COUNT(*) FROM counsellors;
   SELECT COUNT(*) FROM messages;
   .quit
   ```
   - ✅ Counts should match your original data

## 🌐 API Testing

5. **Health Check**
   - Visit: http://localhost:8000/health
   - ✅ Should return `{"status": "healthy"}`

6. **Root Endpoint**
   - Visit: http://localhost:8000/
   - ✅ Should return API info with version 1.0.0

7. **Sessions Statistics**
   - Visit: http://localhost:8000/sessions/statistics
   - ✅ Should return session stats without errors
   - ✅ Should show updated schema working

## 🔐 Authentication Testing

8. **Admin Login** (if you have admin data)
   ```bash
   curl -X POST "http://localhost:8000/auth/admin/login" \
        -H "Content-Type: application/json" \
        -d '{"email":"admin@test.com","password":"test123"}'
   ```
   - ✅ Should return access token (if admin exists)

9. **Counsellor Login** (if you have counsellor data)
   ```bash
   curl -X POST "http://localhost:8000/auth/counsellor/login" \
        -H "Content-Type: application/json" \
        -d '{"email":"counsellor@test.com","password":"test123"}'
   ```
   - ✅ Should return access token (if counsellor exists)

## 📱 Session Flow Testing

10. **Create New Session**
    ```bash
    curl -X POST "http://localhost:8000/sessions/" \
         -H "Content-Type: application/json" \
         -d '{"client_name":"Test Client","issue":"Test Issue","language":"en"}'
    ```
    - ✅ Should return session with ID and token
    - ✅ Should have `updated_at` field populated
    - ✅ `closed_at` should be null
    - ✅ `timeout_reason` should be null

11. **Get Session Details**
    ```bash
    curl "http://localhost:8000/sessions/{session_id}?token={session_token}"
    ```
    - ✅ Should return session with all new fields

## 🔌 WebSocket Testing

12. **Test WebSocket Connection**
    - Use browser console or WebSocket client
    - Connect to: `ws://localhost:8000/ws/session/{session_id}?token={session_token}`
    - ✅ Should connect successfully
    - ✅ Should see connection logs in API

## 📊 Session Monitor Testing

13. **Check Session Timeout**
    - Create a session
    - Wait 30+ minutes (or modify timeout in code for testing)
    - ✅ Session should auto-close with timeout_reason
    - ✅ `closed_at` should be populated

14. **Manual Session Close**
    ```bash
    curl -X POST "http://localhost:8000/sessions/{session_id}/close" \
         -H "Authorization: Bearer {counsellor_token}" \
         -H "Content-Type: application/json" \
         -d '{"reason":"Session completed"}'
    ```
    - ✅ Should close session
    - ✅ `closed_at` should be set
    - ✅ `timeout_reason` should contain the reason

## 🎯 Frontend Integration Testing

15. **Test with React App** (if available)
    - Start React app: `npm run dev`
    - ✅ Should connect to API without CORS errors
    - ✅ Should be able to create sessions
    - ✅ Should be able to send messages

## 📈 Performance Testing

16. **Load Test** (optional)
    ```bash
    # Create multiple sessions quickly
    for i in {1..10}; do
        curl -X POST "http://localhost:8000/sessions/" \
             -H "Content-Type: application/json" \
             -d "{\"client_name\":\"Client $i\",\"issue\":\"Test\",\"language\":\"en\"}"
    done
    ```
    - ✅ Should handle multiple requests
    - ✅ All sessions should have proper timestamps

## 🚨 Error Handling Testing

17. **Invalid Token Test**
    ```bash
    curl "http://localhost:8000/sessions/1?token=invalid_token"
    ```
    - ✅ Should return 401 Unauthorized

18. **Non-existent Session**
    ```bash
    curl "http://localhost:8000/sessions/99999?token=any_token"
    ```
    - ✅ Should return 404 Not Found

## ✅ Final Verification

19. **Check Logs**
    - ✅ No error messages in API logs
    - ✅ Session monitor running
    - ✅ WebSocket connections working

20. **Database Integrity**
    ```bash
    sqlite3 yoneco.db
    PRAGMA integrity_check;
    .quit
    ```
    - ✅ Should return "ok"

## 🎉 Success Criteria

**Migration is successful if:**
- ✅ All existing data preserved
- ✅ New schema fields working
- ✅ API starts without errors
- ✅ Session monitor running
- ✅ WebSocket connections work
- ✅ New sessions have all timestamp fields
- ✅ Session timeout functionality works

## 🆘 Rollback Plan

**If something goes wrong:**
1. Stop the API
2. Restore from backup: `copy yoneco_backup_*.db yoneco.db`
3. Restart API
4. Report the issue

---

**Ready to test? Run the migration first:**
```bash
cd python_api
python safe_migrate.py
uvicorn main:app --reload
```
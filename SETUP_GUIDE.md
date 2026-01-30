# YONECO Setup and Testing Guide

## Prerequisites Installation

### Python Setup
If Python is not installed, download from: https://www.python.org/downloads/
- Make sure to check "Add Python to PATH" during installation

### Flutter Setup
Follow: https://docs.flutter.dev/get-started/install/windows
- Download Flutter SDK
- Add to PATH
- Run `flutter doctor`

## Initial Setup

### 1. Backend API Setup

```bash
# Navigate to API directory
cd D:\Projects\yomehe\python_api

# Install dependencies
pip install -r requirements.txt

# Create a test counsellor account
python create_counsellor.py
# Enter: Email, Name, Password

# Verify database was created
# yoneco.db should exist in the directory
```

### 2. Client App Setup

```bash
# Navigate to client app
cd D:\Projects\yomehe\yoneco_app

# Install dependencies (already done)
flutter pub get

# Check for issues
flutter doctor
```

## Running the System

### Terminal 1: Start API Server

```bash
cd D:\Projects\yomehe\python_api

# Start server
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# You should see:
# INFO:     Uvicorn running on http://0.0.0.0:8000
# INFO:     Application startup complete.
```

**API Documentation**: Open http://localhost:8000/docs in browser

### Terminal 2: Run Client App

```bash
cd D:\Projects\yomehe\yoneco_app

# For Android emulator
flutter run

# For Chrome (web testing)
flutter run -d chrome

# For specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

## Testing the Flow

### Test 1: Basic Session Creation

1. **Open Client App**
2. **Tap "Get Started"** on welcome screen
3. **Select an issue** (e.g., "Depression")
4. **Chat with bot** (optional)
5. **Tap "Talk to Counsellor"**
6. **Enter your name** (e.g., "John Doe")
7. **Tap "Start Live Chat"**

**Expected Result:**
- You should see chat screen
- Orange banner says "Waiting for counsellor to join..."
- Session created in database

### Test 2: Verify Database

```bash
cd D:\Projects\yomehe\python_api

# Open SQLite database
sqlite3 yoneco.db

# Check sessions
SELECT * FROM sessions;

# Expected output:
# 1|John Doe|Depression|pending|NULL|2025-11-02...

# Check counsellors
SELECT * FROM counsellors;

# Exit sqlite
.exit
```

### Test 3: API Endpoints (Using Browser/Postman)

#### Get Pending Sessions
```
GET http://localhost:8000/sessions/pending
```

**Expected Response:**
```json
[
  {
    "id": 1,
    "client_name": "John Doe",
    "issue": "Depression",
    "status": "pending",
    "created_at": "2025-11-02T12:00:00"
  }
]
```

#### Create Test Session
```
POST http://localhost:8000/sessions/create
Content-Type: application/json

{
  "client_name": "Test Client",
  "issue": "Anxiety"
}
```

#### Accept Session (Simulate Counsellor)
```
POST http://localhost:8000/sessions/1/accept?counsellor_id=1
```

**Expected Response:**
```json
{
  "status": "accepted",
  "session_id": 1
}
```

### Test 4: WebSocket Connection (Advanced)

Using a WebSocket client or browser console:

```javascript
// Connect to counsellor notifications
const ws1 = new WebSocket('ws://localhost:8000/ws/counselors');
ws1.onmessage = (event) => {
  console.log('Counsellor received:', event.data);
};

// Connect to session chat room
const ws2 = new WebSocket('ws://localhost:8000/ws/session/1');
ws2.onmessage = (event) => {
  console.log('Session message:', event.data);
};
```

## Common Issues and Solutions

### Issue 1: Python not found
**Solution:**
```bash
# Check Python installation
where python

# If not found, reinstall Python from python.org
# Make sure to check "Add to PATH"
```

### Issue 2: Module not found errors
**Solution:**
```bash
cd python_api
pip install -r requirements.txt

# Or install individually:
pip install fastapi uvicorn sqlalchemy python-dotenv bcrypt pyjwt
```

### Issue 3: Flutter dependencies error
**Solution:**
```bash
cd yoneco_app
flutter clean
flutter pub get
```

### Issue 4: Android emulator can't connect to API
**Solution:**
- Use `http://10.0.2.2:8000` instead of `localhost` (already configured)
- Make sure API is running on `0.0.0.0` not `127.0.0.1`

### Issue 5: WebSocket connection fails
**Solution:**
- Check if API server is running
- Verify URL format: `ws://` not `http://`
- Check firewall settings

### Issue 6: CORS errors (web app)
**Solution:**
- API already configured for `http://localhost:5174`
- Add your web URL to `origins` list in `main.py`

## Database Management

### View all tables
```bash
cd python_api
sqlite3 yoneco.db

.tables
# Output: counsellors  messages  sessions

.schema sessions
# Shows table structure
```

### Reset database (Start fresh)
```bash
cd python_api

# Delete database
del yoneco.db  # Windows
# rm yoneco.db  # Linux/Mac

# Recreate on next API start
uvicorn main:app --reload
```

### Backup database
```bash
cd python_api
copy yoneco.db yoneco_backup.db
```

## Development Workflow

### Making Changes to API

1. **Edit Python files** (models.py, sessions.py, etc.)
2. **Server auto-reloads** (if using --reload)
3. **Test endpoint** at http://localhost:8000/docs
4. **Verify in database** using sqlite3

### Making Changes to Client App

1. **Edit Dart files**
2. **Hot reload** (press 'r' in terminal or save in IDE)
3. **Full restart** (press 'R' or restart app)
4. **Test on device/emulator**

## Deployment Checklist

### Before Production:

- [ ] Change database from SQLite to PostgreSQL
- [ ] Set up environment variables (.env file)
- [ ] Configure HTTPS (not HTTP)
- [ ] Update API URLs in Flutter app
- [ ] Add error logging (Sentry, etc.)
- [ ] Set up backup system
- [ ] Configure CORS properly
- [ ] Add rate limiting
- [ ] Review security settings
- [ ] Test on multiple devices
- [ ] Set up monitoring/alerts

### Environment Variables (.env file)

```bash
# python_api/.env
DATABASE_URL=postgresql://user:pass@localhost/yoneco
SECRET_KEY=your-super-secret-key-change-this
ENVIRONMENT=production
```

## Monitoring and Logs

### API Logs
```bash
# Uvicorn shows logs in console
# Look for:
# - Connection events
# - WebSocket connections/disconnections
# - Error messages
```

### Client Logs
```bash
# Flutter shows logs in console
# Use print() or debugPrint() for debugging
```

## Performance Tips

1. **Database Indexing** - Already on primary keys and emails
2. **WebSocket Limits** - Monitor open connections
3. **Message Pagination** - Limit messages loaded at once
4. **Image Compression** - If adding file uploads
5. **Caching** - Consider Redis for frequent queries

## Next Steps After Setup

1. ✅ Verify API is running
2. ✅ Create test counsellor account
3. ✅ Test client app can create sessions
4. ✅ Verify database entries
5. 📝 Start building counsellor app (see COUNSELLOR_APP_GUIDE.md)
6. 🧪 Write automated tests
7. 🚀 Plan deployment strategy

## Useful Commands Reference

```bash
# API Server
uvicorn main:app --reload                    # Development
uvicorn main:app --host 0.0.0.0 --port 8000  # Production

# Flutter
flutter run                                   # Run app
flutter build apk                            # Build Android APK
flutter build ios                            # Build iOS
flutter test                                 # Run tests
flutter doctor                               # Check setup

# Database
sqlite3 yoneco.db                            # Open database
.tables                                      # List tables
.schema tablename                            # Show structure
SELECT * FROM sessions;                      # Query data
.quit                                        # Exit

# Git
git status                                   # Check changes
git add .                                    # Stage changes
git commit -m "message"                      # Commit
git push                                     # Push to remote
```

## Support Resources

- **Flutter Docs**: https://docs.flutter.dev
- **FastAPI Docs**: https://fastapi.tiangolo.com
- **WebSocket Guide**: https://developer.mozilla.org/en-US/docs/Web/API/WebSocket
- **SQLAlchemy Docs**: https://docs.sqlalchemy.org

## Troubleshooting Contacts

If stuck:
1. Check API documentation at `/docs`
2. Review error logs in console
3. Search error message online
4. Check GitHub issues (if applicable)
5. Contact development team

---

**Happy Coding! 🚀**

Remember: The client app is complete. Your next goal is building the counsellor app following the COUNSELLOR_APP_GUIDE.md

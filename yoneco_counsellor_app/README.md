# YONECO Counsellor App

Professional mental health counselling application for YONECO counsellors to connect with and support clients in real-time.

## Features

✅ **Secure Authentication** - Login with counsellor credentials  
✅ **Real-time Notifications** - Get instant alerts when clients need help  
✅ **Session Management** - View pending and active sessions  
✅ **Live Chat** - Real-time messaging with WebSocket support  
✅ **Issue Tracking** - See client's mental health concerns upfront  
✅ **Session Control** - Accept, manage, and close sessions

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Configuration

Update API URL in `lib/services/api_service.dart`:
- **Android Emulator**: `http://10.0.2.2:8000`
- **iOS Simulator**: `http://localhost:8000`
- **Physical Device**: `http://YOUR_IP:8000`

## Usage Flow

1. **Login** → Enter counsellor credentials
2. **Dashboard** → View pending/active sessions
3. **Accept Session** → Choose a client to help
4. **Chat** → Converse in real-time
5. **Close Session** → Mark as complete

## Documentation

See parent directory for complete documentation:
- `IMPLEMENTATION_SUMMARY.md`
- `COUNSELLOR_APP_GUIDE.md`
- `SETUP_GUIDE.md`

## Test Credentials

Create a counsellor account using:
```bash
cd ../python_api
python create_counsellor.py
```

---

**YONECO Mental Health Services** | Professional 24/7 Support

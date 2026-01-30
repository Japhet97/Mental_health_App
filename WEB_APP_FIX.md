# ✅ WEB APP FIX - PORT CORRECTED!

## 🔧 The Problem

You're running the Flutter app on **Chrome (web)**, not Android emulator!

### For Web/Browser:
- ❌ **Wrong**: `http://10.0.2.2:8080` (this only works for Android emulator)
- ✅ **Correct**: `http://localhost:8080` (for web browser)

---

## ✅ What I Fixed

Changed **BOTH apps** to use `localhost:8080`:

### Counsellor App
**File**: `yoneco_counsellor_app/lib/services/api_service.dart`
```dart
// Changed from:
final String baseUrl = "http://10.0.2.2:8080";

// To:
final String baseUrl = "http://localhost:8080";
```

### Client App  
**File**: `yoneco_app/lib/services/api_service.dart`
```dart
// Changed from:
final String baseUrl = "http://10.0.2.2:8080";

// To:
final String baseUrl = "http://localhost:8080";
```

---

## 🚀 Next Steps

### 1. Stop the Current App
Press **`q`** in the Flutter terminal to quit

### 2. Run Again
```bash
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run -d chrome
```

Or if it asks which device, just run:
```bash
flutter run
```
And select **Chrome** from the list

---

## 🧪 Test Login

Now try logging in with:
- **Email**: `dr.smith@yoneco.org`
- **Password**: `DrSmith123`

**It should work now!** ✅

---

## 📝 Understanding URLs by Platform

| Platform | API URL to Use |
|----------|----------------|
| **Web (Chrome)** | `http://localhost:8080` ✅ |
| **Android Emulator** | `http://10.0.2.2:8080` |
| **iOS Simulator** | `http://localhost:8080` |
| **Physical Device** | `http://192.168.x.x:8080` (your PC's IP) |

---

## 💡 Pro Tip: Platform-Specific URLs

For production, you'd make this dynamic:

```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

final String baseUrl = kIsWeb 
    ? "http://localhost:8080"  // Web
    : Platform.isAndroid 
        ? "http://10.0.2.2:8080"  // Android
        : "http://localhost:8080";  // iOS
```

But for now, since you're testing on web, `localhost:8080` is perfect!

---

## ✅ Ready!

The app should now connect successfully to your API! 🎉

Try logging in and you should see the request in your API terminal!

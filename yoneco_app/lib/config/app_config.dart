import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // Dynamic API Configuration based on platform
  static String get apiBaseUrl {
    if (kIsWeb) {
      return "http://102.223.95.166";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8080";  // Android emulator
    } else {
      return "http://localhost:8080";  // iOS simulator
    }
  }
  
  static String get httpUrl => apiBaseUrl;
  
  static String get wsBaseUrl => apiBaseUrl.replaceFirst("http", "ws");
  
  static String getWebSocketUrl(int sessionId, String token) {
    return "$wsBaseUrl/ws/session/$sessionId?token=$token";
  }
}

 


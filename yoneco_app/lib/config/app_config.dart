import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // Use the static IP of your server
  static const String serverIp = "102.223.95.166";
  
  // REST API URL
  static const String apiBaseUrl = "http://$serverIp";

  // WebSocket URL (Explicitly use port 80)
  static const String wsBaseUrl = "ws://$serverIp:80";
  
  static String get httpUrl => apiBaseUrl;
  
  static String getWebSocketUrl(int sessionId, String token) {
    return "$wsBaseUrl/ws/session/$sessionId?token=$token";
  }
}

 


class AppConfig {
  // Use the static IP of your server
  static const String serverIp = "102.223.95.166";
  
  // REST API URL
  static const String apiBaseUrl = "http://$serverIp";

  // WebSocket URL (Explicitly use port 80 to prevent the ":0" error)
  static const String wsBaseUrl = "ws://$serverIp:80";

  static String get httpUrl => apiBaseUrl;

  static String getCounsellorWebSocketUrl(String token) {
    // Result: ws://102.223.95.166:80/ws/counselors?token=...
    return "$wsBaseUrl/ws/counselors?token=$token";
  }
  
  static String getSessionWebSocketUrl(int sessionId, String token) {
    // Result: ws://102.223.95.166:80/ws/session/22?token=...
    return "$wsBaseUrl/ws/session/$sessionId?token=$token";
  }
}
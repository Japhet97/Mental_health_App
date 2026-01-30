class AppConfig {
  // API Configuration
  // Change this based on your environment:
  // - For Web: "http://localhost:8080"
  // - For Android Emulator: "http://10.0.2.2:8080"
  // - For iOS Simulator: "http://localhost:8080"
  // - For Physical Device: "http://YOUR_COMPUTER_IP:8080" (e.g., "http://192.168.1.100:8080")

  static const String apiBaseUrl = "http://102.223.95.166";

  // WebSocket Configuration
  static const String wsScheme = "ws";

  static String get httpUrl => apiBaseUrl;

  static String get wsBaseUrl => apiBaseUrl.replaceFirst("http", wsScheme);

  static String getCounsellorWebSocketUrl(String token) {
    return "$wsBaseUrl/ws/counselors?token=$token";
  }
  
  static String getSessionWebSocketUrl(int sessionId, String token) {
    return "$wsBaseUrl/ws/session/$sessionId?token=$token";
  }
}




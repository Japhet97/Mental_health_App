import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class CounsellorApiService {
  // Singleton pattern
  static final CounsellorApiService _instance = CounsellorApiService._internal();
  
  factory CounsellorApiService() {
    return _instance;
  }
  
  CounsellorApiService._internal();
  
  final String baseUrl = AppConfig.httpUrl;
  
  String? _token;
  int? _counsellorId;
  String? _counsellorName;

  void setAuthData(String token, int counsellorId, String counsellorName) {
    _token = token;
    _counsellorId = counsellorId;
    _counsellorName = counsellorName;
  }

  void clearAuthData() {
    _token = null;
    _counsellorId = null;
    _counsellorName = null;
  }

  bool get isAuthenticated => _token != null;
  int? get counsellorId => _counsellorId;
  String? get counsellorName => _counsellorName;

  Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      if (_token != null) "Authorization": "Bearer $_token",
    };
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('Attempting login to: $baseUrl/auth/login');
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setAuthData(
        data['access_token'],
        data['user']['id'],
        data['user']['name'],
      );
      return data;
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  // Sessions
  Future<List<dynamic>> getPendingSessions() async {
    final response = await http.get(
      Uri.parse("$baseUrl/sessions/pending"),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to get pending sessions");
    }
  }

  Future<List<dynamic>> getActiveSessions() async {
    final response = await http.get(
      Uri.parse("$baseUrl/sessions/active"),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to get active sessions");
    }
  }

  Future<Map<String, dynamic>> getSession(int sessionId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/sessions/$sessionId"),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to get session");
    }
  }

  Future<void> acceptSession(int sessionId) async {
    if (_counsellorId == null) {
      throw Exception("Not authenticated");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/sessions/$sessionId/accept?counsellor_id=$_counsellorId"),
      headers: _headers(),
    );

    if (response.statusCode == 401) {
      clearAuthData();
      throw Exception("Session expired. Please login again.");
    }

    if (response.statusCode != 200) {
      throw Exception("Failed to accept session: ${response.body}");
    }
  }

  Future<void> closeSession(int sessionId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/sessions/$sessionId/close"),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to close session");
    }
  }

  // Chat
  Future<List<dynamic>> getSessionMessages(int sessionId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/chat/$sessionId/messages"),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["messages"];
    } else {
      throw Exception("Failed to get messages");
    }
  }

  Future<void> sendMessage(int sessionId, String content) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chat/$sessionId/send"),
      headers: _headers(),
      body: jsonEncode({
        "sender": "counsellor",
        "content": content,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to send message: ${response.body}");
    }
  }

  Future<void> sendTypingIndicator(int sessionId, String sender, bool isTyping) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/chat/$sessionId/typing"),
        headers: _headers(),
        body: jsonEncode({
          "sender": sender,
          "is_typing": isTyping,
        }),
      );
    } catch (e) {
      // Silently fail - typing indicators are not critical
    }
  }

  // WebSocket URLs
  String getWebSocketUrl() {
    if (_token == null) throw Exception("Not authenticated");
    return AppConfig.getCounsellorWebSocketUrl(_token!);
  }

  String getSessionWebSocketUrl(int sessionId) {
    if (_token == null) throw Exception("Not authenticated");
    return AppConfig.getSessionWebSocketUrl(sessionId, _token!);
  }
}

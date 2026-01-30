import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  final String baseUrl = AppConfig.httpUrl;

  Future<List<Map<String, dynamic>>> getIssues() async {
    try {
      print('Fetching issues from: $baseUrl/issues');
      final response = await http.get(
        Uri.parse("$baseUrl/issues"),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 10));
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((issue) => issue as Map<String, dynamic>).toList();
      } else {
        throw Exception("Failed to fetch issues: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching issues: $e");
      return [];
    }
  }

  Future<String> getChatbotGreeting(String issue) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chatbot"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"issue": issue}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["message"];
    } else {
      return "Error contacting chatbot.";
    }
  }

  Future<Map<String, dynamic>> createSession({String? clientName, String? issue, String? language}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/sessions/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "client_name": clientName,
        "issue": issue,
        "language": language,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create session: ${response.body}");
    }
  }

  Future<List<dynamic>> getSessionMessages(int sessionId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/chat/$sessionId/messages"),
      headers: {"Content-Type": "application/json"},
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["messages"];
    } else {
      throw Exception("Failed to get messages");
    }
  }

  Future<void> sendMessage(int sessionId, String sender, String content) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chat/$sessionId/send"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "sender": sender,
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
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sender": sender,
          "is_typing": isTyping,
        }),
      );
    } catch (e) {
      // Silently fail - typing indicators are not critical
    }
  }

  String getWebSocketUrl(int sessionId, String token) {
    return AppConfig.getWebSocketUrl(sessionId, token);
  }

  Future<void> notifyAdminDashboard(Map<String, dynamic> notification) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/notifications"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(notification),
      );
      
      if (response.statusCode != 200) {
        throw Exception("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print("Error sending admin notification: $e");
      rethrow;
    }
  }
}

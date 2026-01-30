import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _counsellorIdKey = 'counsellor_id';
  static const String _counsellorNameKey = 'counsellor_name';
  static const String _counsellorEmailKey = 'counsellor_email';

  Future<void> saveAuthData({
    required String token,
    required int counsellorId,
    required String counsellorName,
    required String counsellorEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_counsellorIdKey, counsellorId);
    await prefs.setString(_counsellorNameKey, counsellorName);
    await prefs.setString(_counsellorEmailKey, counsellorEmail);
  }

  Future<Map<String, dynamic>?> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final counsellorId = prefs.getInt(_counsellorIdKey);
    final counsellorName = prefs.getString(_counsellorNameKey);
    final counsellorEmail = prefs.getString(_counsellorEmailKey);

    if (token == null || counsellorId == null) {
      return null;
    }

    return {
      'token': token,
      'counsellor_id': counsellorId,
      'counsellor_name': counsellorName,
      'counsellor_email': counsellorEmail,
    };
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_counsellorIdKey);
    await prefs.remove(_counsellorNameKey);
    await prefs.remove(_counsellorEmailKey);
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }
}

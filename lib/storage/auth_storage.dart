import 'dart:convert';
import 'package:carteira_core/carteira_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent storage implementation for authentication session and Auth Code (Bearer token)
/// using SharedPreferences, complying with the SessionStorage contract.
class AuthStorage implements SessionStorage {
  const AuthStorage();

  static const String _sessionKey = 'carteira_auth_session';
  static const String _tokenKey = 'carteira_auth_token';

  @override
  Future<Session?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionKey);
    if (jsonString == null) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Session.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(session.toJson());
    await prefs.setString(_sessionKey, jsonString);
    // Explicitly store auth code / token with Bearer scheme convention
    await prefs.setString(_tokenKey, session.authorizationHeader);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_tokenKey);
  }

  /// Helper to read the stored auth code / token directly with Bearer format.
  Future<String?> readAuthCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}

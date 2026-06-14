import 'package:shared_preferences/shared_preferences.dart';

import 'package:crud_withnodejs/models/auth_session.dart';
import 'package:crud_withnodejs/models/auth_user.dart';

class AuthStorage {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _userEmailKey = 'auth_user_email';
  static const _userNameKey = 'auth_user_name';

  static Future<void> saveSession(AuthSession session) async {
    final preferences = await SharedPreferences.getInstance();

    await Future.wait([
      preferences.setString(_tokenKey, session.token),
      preferences.setString(_userIdKey, session.user.id.toString()),
      preferences.setString(_userEmailKey, session.user.email),
      if (session.user.name == null)
        preferences.remove(_userNameKey)
      else
        preferences.setString(_userNameKey, session.user.name!),
    ]);
  }

  static Future<String?> readToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_tokenKey);
  }

  static Future<AuthUser?> readUser() async {
    final preferences = await SharedPreferences.getInstance();
    final id = int.tryParse(preferences.getString(_userIdKey) ?? '');
    final email = preferences.getString(_userEmailKey);

    if (id == null || email == null) return null;

    return AuthUser(
      id: id,
      email: email,
      name: preferences.getString(_userNameKey),
    );
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();

    await Future.wait([
      preferences.remove(_tokenKey),
      preferences.remove(_userIdKey),
      preferences.remove(_userEmailKey),
      preferences.remove(_userNameKey),
    ]);
  }
}

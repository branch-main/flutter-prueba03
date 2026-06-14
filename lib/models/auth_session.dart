import 'package:crud_withnodejs/models/auth_user.dart';

class AuthSession {
  final AuthUser user;
  final String token;

  AuthSession({required this.user, required this.token});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      user: AuthUser.fromJson(Map<String, dynamic>.from(json['user'])),
      token: json['token'],
    );
  }
}

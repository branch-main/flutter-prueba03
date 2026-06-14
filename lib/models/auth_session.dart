class AuthUser {
  final int id;
  final String email;
  final String? name;

  AuthUser({required this.id, required this.email, this.name});

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      AuthUser(id: json['id'], email: json['email'], name: json['name']);
}

class AuthSession {
  final AuthUser user;
  final String token;

  AuthSession({required this.user, required this.token});

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      AuthSession(user: AuthUser.fromJson(json['user']), token: json['token']);
}

class AuthUser {
  final int id;
  final String email;
  final String? name;

  AuthUser({required this.id, required this.email, this.name});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(id: json['id'], email: json['email'], name: json['name']);
  }
}

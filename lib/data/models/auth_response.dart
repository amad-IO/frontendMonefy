class AuthResponse {
  final String token;
  final String username;

  AuthResponse({
    required this.token,
    required this.username,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      username: json['username'],
    );
  }
}
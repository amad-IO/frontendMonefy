class AuthResponse {
  final String token;
  final String username;
  final String? avatar; // URL foto dari Supabase Storage

  AuthResponse({
    required this.token,
    required this.username,
    this.avatar,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      username: json['user']['name'] ?? '',
      avatar: json['user']['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'username': username,
    };
  }
}


class UserModel {
  final String username;

  UserModel({
    required this.username,
  });


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? 'User',
    );
  }

  /// ─────────────────────────────────────────────a
  /// dari response API login di:
  /// lib/ui/pages/dashboard.dart → initState()
  /// Contoh nanti:
  ///   final user = UserModel.fromJson(responseJson);
  /// ─────────────────────────────────────────────
  static UserModel dummy() {
    return UserModel(
      username: 'Mochi',
    );
  }
}
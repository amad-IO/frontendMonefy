
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
  static UserModel dummy() {
    return UserModel(
      username: 'Mochi',
    );
  }
}
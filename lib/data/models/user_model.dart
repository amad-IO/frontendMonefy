
class UserModel {
  final String username;

  UserModel({
    required this.username,
  });


  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Backend mengembalikan 'name' (bukan 'username')
    return UserModel(
      username: json['name']?.toString() ?? 'User',   // ✅ sesuai backend
    );
  }
  static UserModel dummy() {
    return UserModel(
      username: 'Mochi',
    );
  }
}
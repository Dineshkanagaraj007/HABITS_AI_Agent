/// Data model for a user.
class User {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

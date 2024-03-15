/// Represents a user in the Zion Link application.
class User {
  final String id;
  final String email;
  final String username;

  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static set currentUser(User? user) => _currentUser = user;

  User({
    required this.id,
    required this.email,
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
    );
  }
}

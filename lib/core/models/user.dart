enum UserType {
  admin,
  owner,
  mangement,
  tenant,
  routineServiceProvider,
  onCallServiceProvider
}

/// A class to represent a user.
///
/// This class includes all the necessary fields to represent a user entity within the application.
/// It is designed to be compatible across iOS, Android, PC, macOS, and web platforms.
class User {
  final String id;
  final String firstName;
  final String? lastName; // nullable - optional
  final String email;
  final String? phoneNumber;
  final UserType role;
  final String? proffesion;
  final String? profilePictureUrl;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime? updatedOn;

  /// Constructor for creating a [User] instance.
  User({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.proffesion,
    this.profilePictureUrl,
    this.dateOfBirth,
    required this.createdAt,
    this.updatedOn,
  });

  /// Converts a [User] instance to JSON format.
  ///
  /// Returns a map representation of the user, which can be used for JSON serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.index,
      'proffesion': proffesion,
      'profilePictureUrl': profilePictureUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedOn': updatedOn?.toIso8601String(),
    };
  }

  /// Creates a [User] instance from a JSON object.
  ///
  /// Takes a [Map] representation of a user and returns an instance of [User].
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: UserType.values[json['role']],
      proffesion: json['proffesion'],
      profilePictureUrl: json['profilePictureUrl'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedOn:
          json['updatedOn'] != null ? DateTime.parse(json['updatedOn']) : null,
    );
  }
}

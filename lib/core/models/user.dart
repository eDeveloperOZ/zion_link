import 'package:tachles/core/utils/logger.dart';

enum UserType {
  admin,
  company,
  management,
  owner,
  tenant,
  routineServiceProvider,
  onCallServiceProvider
}

/// A class to represent a user.
///
/// This class includes all the necessary fields to represent a user entity within the application.
/// It is designed to be compatible across iOS, Android, PC, macOS, and web platforms.
class User {
  String id;
  String? apartmentId;
  String firstName;
  String? lastName; // nullable - optional
  String email;
  String? phoneNumber;
  final UserType role;
  String? profession; // Changed from proffesion to profession
  String? profilePictureUrl;
  DateTime? dateOfBirth;
  final DateTime createdAt;
  DateTime? updatedOn;

  /// Constructor for creating a [User] instance.
  User({
    required this.id,
    this.apartmentId,
    required this.firstName,
    this.lastName,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.profession,
    this.profilePictureUrl,
    this.dateOfBirth,
    this.updatedOn,
    DateTime? createdAt, // Make createdAt nullable
  }) : this.createdAt = createdAt ?? DateTime.now(); // Initialize here if null

  /// Converts a [User] instance to JSON format.
  ///
  /// Returns a map representation of the user, which can be used for JSON serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartmentId': apartmentId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'profession': profession, // Changed from proffesion to profession
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
    try {
      return User(
        id: json['id'].toString(),
        apartmentId: json['apartmentId'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
        role: _parseRole(json['role']),
        profession: json['profession'],
        profilePictureUrl: json['profilePictureUrl'],
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.parse(json['dateOfBirth'])
            : null,
        createdAt: DateTime.parse(json['createdAt']),
        updatedOn: json['updatedOn'] != null
            ? DateTime.parse(json['updatedOn'])
            : null,
      );
    } catch (error) {
      Logger.critical('user: $json');
      Logger.error('Error creating user from JSON: $error');
      throw error;
    }
  }
  // This function is used to parse the role from the json object
  static UserType _parseRole(dynamic role) {
    switch (role) {
      case 'admin':
        return UserType.admin;
      case 'company':
        return UserType.company;
      case 'management':
        return UserType.management;
      case 'owner':
        return UserType.owner;
      case 'tenant':
        return UserType.tenant;
      case 'routineServiceProvider':
        return UserType.routineServiceProvider;
      case 'onCallServiceProvider':
        return UserType.onCallServiceProvider;
      default:
        throw Exception('Unknown role: $role');
    }
  }

  static User empty({
    String id = '',
    String buildingId = '',
    String? apartmentId,
    String firstName = '',
    String? lastName,
    String email = '',
    String? phoneNumber,
    UserType role = UserType.tenant,
    String? profession,
    String? profilePictureUrl,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? updatedOn,
  }) {
    return User(
      id: id,
      apartmentId: apartmentId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      profession: profession,
      profilePictureUrl: profilePictureUrl,
      dateOfBirth: dateOfBirth,
      createdAt: createdAt ?? DateTime.now(),
      updatedOn: updatedOn,
    );
  }
}

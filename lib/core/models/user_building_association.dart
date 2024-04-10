import 'package:tachles/core/models/user.dart';
import 'package:tachles/core/utils/logger.dart';

/// Represents the association between a user and a building, including the user's role within that building.
///
/// This class holds the information about the association of a user with a building,
/// including a unique identifier for the association (`ubaId`), identifiers for the user (`userId`)
/// and the building (`buildingId`), and the user's role within the building (`role`).
class UserBuildingAssociation {
  /// Unique identifier for the UserBuildingAssociation.
  final String ubaId;

  /// Identifier for the associated user.
  final String userId;

  /// Identifier for the associated building.
  final String buildingId;

  /// The role of the user within the building.
  final UserType role;

  /// Constructs an instance of [UserBuildingAssociation].
  ///
  /// Requires [ubaId], [userId], [buildingId], and [role] to be provided.
  UserBuildingAssociation({
    required this.ubaId,
    required this.userId,
    required this.buildingId,
    required this.role,
  });

  /// Creates an instance of [UserBuildingAssociation] from a JSON map.
  ///
  /// Throws a [FormatException] if required fields are missing.
  /// This method parses the JSON map and creates an instance of [UserBuildingAssociation].
  factory UserBuildingAssociation.fromJson(Map<String, dynamic> json) {
    try {
      return UserBuildingAssociation(
        ubaId: json['id'] as String,
        userId: json['userId'] as String,
        buildingId: json['buildingId'] as String,
        role: UserType.values
            .firstWhere((e) => e.toString() == 'UserType.${json['role']}'),
      );
    } catch (e) {
      Logger.error('Failed to parse UserBuildingAssociation from JSON: $e');
      throw FormatException('Error parsing UserBuildingAssociation: $e');
    }
  }

  /// Converts the [UserBuildingAssociation] instance to a JSON map.
  ///
  /// Returns a map representation of the [UserBuildingAssociation] instance.
  Map<String, dynamic> toJson() {
    return {
      'id': ubaId,
      'userId': userId,
      'buildingId': buildingId,
      'role': role.toString().split('.').last,
    };
  }
}

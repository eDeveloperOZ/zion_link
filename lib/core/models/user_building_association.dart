class UserBuildingAssociation {
  final String userId;
  final String buildingId;
  final String role;

  UserBuildingAssociation({
    required this.userId,
    required this.buildingId,
    required this.role,
  });

  factory UserBuildingAssociation.fromJson(Map<String, dynamic> json) {
    return UserBuildingAssociation(
      userId: json['userId'],
      buildingId: json['buildingId'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'buildingId': buildingId,
      'role': role,
    };
  }
}

import 'package:zion_link/core/models/user_building_association.dart';
import 'package:zion_link/core/services/storage_service.dart';

class UserBuildingAssociationService {
  Future<List<UserBuildingAssociation>> getAllAssociations() async {
    final associationsFromFile =
        await StorageService.readUserBuildingAssociations();
    return associationsFromFile
        .map<UserBuildingAssociation>(
            (item) => UserBuildingAssociation.fromJson(item))
        .toList();
  }

  Future<void> addAssociation(UserBuildingAssociation newAssociation) async {
    await StorageService.addUserBuildingAssociation(newAssociation);
  }

  Future<void> updateAssociation(
      UserBuildingAssociation updatedAssociation) async {
    await StorageService.updateUserBuildingAssociation(updatedAssociation);
  }

  Future<void> deleteAssociation(String userId, String buildingId) async {
    await StorageService.deleteUserBuildingAssociation(userId, buildingId);
  }

  /// Retrieves all associations for a given building ID.
  ///
  /// This method fetches all user-building associations that match the provided building ID.
  /// It ensures compatibility across iOS, Android, PC, macOS, and web platforms.
  ///
  /// Parameters:
  /// - `buildingId`: The ID of the building for which associations are to be retrieved.
  ///
  /// Returns a list of [UserBuildingAssociation] instances that are associated with the given building ID.
  Future<List<UserBuildingAssociation>> getAssociationsByBuildingId(
      String buildingId) async {
    final associations = await getAllAssociations();
    return associations
        .where((association) => association.buildingId == buildingId)
        .toList();
  }
}

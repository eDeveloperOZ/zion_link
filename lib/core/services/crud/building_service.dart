import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/models/user.dart';
import 'package:zion_link/core/services/storage_service.dart';
import 'user_building_association_service.dart';
import 'user_service.dart';

class BuildingService {
  Future<List<Building>> readAllBuildings() async {
    final buildingsFromFile = await StorageService.readAllBuildings();
    return buildingsFromFile;
  }

  Future<Building> readBuildingById(String buildingId) async {
    final Building building = await StorageService.readBuildingById(buildingId);
    return building;
  }

  Future<void> createBuilding(Building newBuilding) async {
    await StorageService.createBuilding(newBuilding);
  }

  Future<void> updateBuilding(Building updatedBuilding) async {
    await StorageService.updateBuilding(updatedBuilding);
  }

  Future<void> deleteBuilding(String buildingId) async {
    await StorageService.deleteBuilding(buildingId);
  }

  Future<List<User>> getUsersForBuilding(String buildingId) async {
    final associationService = UserBuildingAssociationService();
    final associations =
        await associationService.getAssociationsByBuildingId(buildingId);
    final userIds =
        associations.map((association) => association.userId).toList();
    final userService = UserService();
    final users = await Future.wait(
        userIds.map((userId) => userService.getUserById(userId)));
    return users.whereType<User>().toList();
  }
}

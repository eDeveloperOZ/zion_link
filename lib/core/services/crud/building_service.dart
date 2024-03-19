import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/models/expense.dart';
import 'package:zion_link/core/models/user.dart';
import 'package:zion_link/core/services/storage_service.dart';
import 'user_building_association_service.dart';
import 'user_service.dart';

class BuildingService {
  Future<List<Building>> getAllBuildings() async {
    final buildingsFromFile = await StorageService.getAllBuildings();
    return buildingsFromFile
        .map<Building>((item) => Building.fromJson(item))
        .toList();
  }

  Future<Building> getBuildingById(String buildingId) async {
    final buildings = await StorageService.getAllBuildings();
    var buildingMap = buildings.firstWhere(
        (building) => building['id'] == buildingId,
        orElse: () => null);
    if (buildingMap != null) {
      return Building.fromJson(buildingMap);
    } else {
      throw Exception('Building not found');
    }
  }

  Future<void> addBuilding(Building newBuilding) async {
    List existingBuildings = await StorageService.getAllBuildings();
    existingBuildings.add(newBuilding.toJson());
    await StorageService.writeBuildings(existingBuildings);
  }

  Future<void> updateBuilding(Building updatedBuilding) async {
    List<dynamic> buildings = await StorageService.getAllBuildings();
    int index = buildings.indexWhere((b) => b['id'] == updatedBuilding.id);
    if (index != -1) {
      buildings[index] = updatedBuilding.toJson();
      await StorageService.writeBuildings(buildings);
    }
  }

  Future<void> deleteBuilding(String buildingId) async {
    List<dynamic> buildings = await StorageService.getAllBuildings();
    buildings.removeWhere((item) => item['id'] == buildingId);
    await StorageService.writeBuildings(buildings);
  }

  Future<List<Apartment>> getApartmentsForBuilding(String buildingId) async {
    final buildings = await StorageService.getAllBuildings();
    final building = buildings.firstWhere(
        (building) => building['id'] == buildingId,
        orElse: () => null);
    if (building != null) {
      final apartments = building['apartments'];
      return apartments
          .map<Apartment>((item) => Apartment.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<List<Expense>> getExpensesForBuilding(String buildingId) async {
    final buildings = await StorageService.getAllBuildings();
    final building = buildings.firstWhere(
        (building) => building['id'] == buildingId,
        orElse: () => null);
    if (building != null) {
      final expenses = building['expenses'];
      return expenses.map<Expense>((item) => Expense.fromJson(item)).toList();
    }
    return [];
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

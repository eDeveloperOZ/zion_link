import '../models/building.dart';
import 'storage_service.dart';

class BuildingService {
  Future<List<Building>> getAllBuildings() async {
    final buildingsFromFile = await StorageService.getAllBuildings();
    return buildingsFromFile
        .map<Building>((item) => Building.fromJson(item))
        .toList();
  }

  Future<Building> getBuildingById(String buildingId) async {
    final List buildings = await StorageService.getAllBuildings();
    for (var building in buildings) {
      if (building['id'] == buildingId) {
        return Building.fromJson(building);
      }
    }
    throw Exception('Building not found');
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

  Future<double> calculateTotalBalance(String buildingId) async {
    final building = await getBuildingById(buildingId);
    double totalBalance = building.balance;
    for (var apartment in building.apartments) {
      for (var payment in apartment.payments) {
        if (payment.isConfirmed) {
          totalBalance += payment.amount;
        }
      }
    }
    return totalBalance;
  }
}

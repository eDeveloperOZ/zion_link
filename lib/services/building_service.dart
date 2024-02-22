import '../models/building.dart';
import '../utils/file_storage.dart';
import '../models/apartment.dart';

class BuildingService {
  Future<List<Building>> fetchBuildings() async {
    final buildingsFromFile = await LocalStorage.readBuildings();
    return buildingsFromFile
        .map<Building>((item) => Building.fromJson(item))
        .toList();
  }

  Future<Building> fetchBuilding(String buildingId) async {
    final List buildings = await LocalStorage.readBuildings();
    for (var building in buildings) {
      if (building['id'] == buildingId) {
        return Building.fromJson(building);
      }
    }
    throw Exception('Building not found');
  }

  Future<void> updateBuilding(Building updatedBuilding) async {
    List<dynamic> buildings = await LocalStorage.readBuildings();
    int index = buildings.indexWhere((b) => b['id'] == updatedBuilding.id);
    if (index != -1) {
      buildings[index] = updatedBuilding.toJson();
      await LocalStorage.writeBuildings(buildings);
    }
  }

  Future<void> addBuilding(Building newBuilding) async {
    List existingBuildings = await LocalStorage.readBuildings();
    existingBuildings.add(newBuilding.toJson());
    await LocalStorage.writeBuildings(existingBuildings);
  }

  Future<void> deleteBuilding(String buildingId) async {
    List<dynamic> buildings = await LocalStorage.readBuildings();
    buildings.removeWhere((item) => item['id'] == buildingId);
    await LocalStorage.writeBuildings(buildings);
  }

  Future<void> addApartmentToBuilding(
      String buildingId, Apartment newApartment) async {
    final List buildings = await LocalStorage.readBuildings();
    bool found = false;
    for (var building in buildings) {
      if (building['id'] == buildingId) {
        building['apartments'].add(newApartment.toJson());
        found = true;
        break;
      }
    }
    if (!found) {
      print("Building with ID $buildingId not found.");
    } else {
      await LocalStorage.writeBuildings(buildings);
    }
  }
}

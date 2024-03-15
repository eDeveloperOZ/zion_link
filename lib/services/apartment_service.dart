import '../models/apartment.dart';
import 'storage_service.dart';
import '../utils/logger.dart'; // Ensure this import is added at the top

class ApartmentService {
  Future<List<Apartment>> getAllApartmentsForBuilding(String buildingId) async {
    final buildings = await StorageService.getAllBuildings();
    List<Apartment> apartments = [];
    for (var building in buildings) {
      var buildingApartments = building['apartments'] as List;
      apartments
          .addAll(buildingApartments.map((item) => Apartment.fromJson(item)));
    }
    return apartments;
  }

  Future<Apartment?> getApartmentById(String apartmentId) async {
    final buildings = await StorageService.getAllBuildings();
    for (var building in buildings) {
      var buildingApartments = building['apartments'] as List;
      final index = buildingApartments
          .indexWhere((apartment) => apartment['id'] == apartmentId);
      if (index != -1) {
        return Apartment.fromJson(buildingApartments[index]);
      }
    }
    return null;
  }

  Future<void> addApartment(Apartment newApartment) async {
    final buildings = await StorageService.getAllBuildings();
    bool found = false;
    for (var building in buildings) {
      if (building['id'] == newApartment.buildingId) {
        final List apartments = building['apartments'] ?? [];
        apartments.add(newApartment.toJson());
        building['apartments'] = apartments;
        found = true;
        break;
      }
    }
    if (!found) {
      Logger.error("Building with ID ${newApartment.buildingId} not found.");
    } else {
      await StorageService.writeBuildings(buildings);
    }
  }

  Future<void> updateApartment(Apartment updatedApartment) async {
    final buildings = await StorageService.getAllBuildings();
    for (var building in buildings) {
      final List apartments = building['apartments'];
      final int index = apartments
          .indexWhere((apartment) => apartment['id'] == updatedApartment.id);
      if (index != -1) {
        apartments[index] = updatedApartment.toJson();
        await StorageService.writeBuildings(buildings);
        break;
      }
    }
  }

  Future<void> deleteApartment(String apartmentId) async {
    final buildings = await StorageService.getAllBuildings();
    for (var building in buildings) {
      final List apartments = building['apartments'];
      final index =
          apartments.indexWhere((apartment) => apartment['id'] == apartmentId);
      if (index != -1) {
        apartments.removeAt(index);
        await StorageService.writeBuildings(buildings);
        break;
      }
    }
  }
}

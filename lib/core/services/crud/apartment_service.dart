import '../../models/apartment.dart';
import '../storage_service.dart';

class ApartmentService {
  Future<List<Apartment>> readAllApartmentsForBuilding(
      String buildingId) async {
    return await StorageService.readAllApartmentsForBuilding(buildingId);
  }

  Future<Apartment> readApartmentById(String apartmentId) async {
    return await StorageService.readApartmentById(apartmentId);
  }

  Future<void> createApartment(Apartment newApartment) async {
    await StorageService.createApartment(newApartment);
  }

  Future<void> updateApartment(Apartment updatedApartment) async {
    await StorageService.updateApartment(updatedApartment);
  }

  Future<void> deleteApartment(String apartmentId) async {
    await StorageService.deleteApartment(apartmentId);
  }
}

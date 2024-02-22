import '../models/apartment.dart';
import '../utils/file_storage.dart';

class ApartmentService {
  Future<List<Apartment>> fetchApartments() async {
    final buildings = await LocalStorage.readBuildings();
    List<Apartment> apartments = [];
    for (var building in buildings) {
      var buildingApartments = building['apartments'] as List;
      apartments
          .addAll(buildingApartments.map((item) => Apartment.fromJson(item)));
    }
    return apartments;
  }

  Future<void> updateApartment(Apartment updatedApartment) async {
    await LocalStorage.updateApartment(updatedApartment);
  }

  Future<void> addApartment(Apartment newApartment) async {
    // This method would require knowing the building to which the apartment belongs.
    // Assuming an updated method signature or an updated approach to find the correct building.
    // For simplicity, this example does not implement adding an apartment without specifying its building.
  }

  Future<void> deleteApartment(String apartmentId) async {
    // Similar to addApartment, deleting an apartment would require knowing its building or a more complex search mechanism.
    // This example does not implement the deletion logic without specifying its building.
  }
}

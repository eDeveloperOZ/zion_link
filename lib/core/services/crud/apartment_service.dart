import 'package:tachles/core/models/apartment.dart';
import 'package:tachles/core/services/supabase_service.dart';

class ApartmentService {
  final SupabaseService supabaseService = SupabaseService();

  Future<List<Apartment>> readAllApartmentsForBuilding(
      String buildingId) async {
    // Fetch all apartments for a building
    var apartments =
        await supabaseService.readAllForBuilding<Apartment>(buildingId);
    // Enhanced sorting: Handles numeric and alphanumeric apartment numbers
    apartments.sort((a, b) {
      // Attempt to parse numbers from apartment numbers
      var numA = int.tryParse(a.number);
      var numB = int.tryParse(b.number);

      if (numA != null && numB != null) {
        // If both are numbers, compare numerically
        return numA.compareTo(numB);
      } else if (numA != null && numB == null) {
        // If A is a number but B is not, A comes first
        return -1;
      } else if (numA == null && numB != null) {
        // If B is a number but A is not, B comes first
        return 1;
      } else {
        // If both are not numbers, compare alphabetically
        return a.number.compareTo(b.number);
      }
    });
    return apartments;
  }

  Future<Apartment?> readApartmentById(String apartmentId) async {
    return await supabaseService.readById<Apartment>(apartmentId);
  }

  Future<void> createApartment(Apartment newApartment) async {
    await supabaseService.create<Apartment>(newApartment);
  }

  Future<void> updateApartment(Apartment updatedApartment) async {
    await supabaseService.update<Apartment>(updatedApartment);
  }

  Future<void> deleteApartment(String apartmentId) async {
    await supabaseService.delete<Apartment>(apartmentId);
  }
}

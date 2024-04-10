import 'package:tachles/core/models/building.dart';
import 'package:uuid/uuid.dart';
import 'package:tachles/core/models/user.dart';
import 'package:tachles/core/models/user_building_association.dart';
import 'package:tachles/core/services/supabase_service.dart';

class BuildingService {
  final SupabaseService supabaseService = SupabaseService();

  Future<List<Building>> readAllBuildings() async {
    return await supabaseService.readAll<Building>();
  }

  Future<Building?> getBuildingById(String buildingId) async {
    return await supabaseService.readById<Building>(buildingId);
  }

  Future<void> createBuilding(Building newBuilding, String userId) async {
    await supabaseService.create<Building>(newBuilding);
    await supabaseService.create<UserBuildingAssociation>(
        UserBuildingAssociation(
            ubaId: const Uuid().v4(),
            userId: userId,
            buildingId: newBuilding.id,
            role: UserType.management));
  }

  Future<void> updateBuilding(Building updatedBuilding) async {
    await supabaseService.update<Building>(updatedBuilding);
  }

  Future<void> deleteBuilding(String buildingId) async {
    try {
      // Delete associated records in the user_building_associations table
      await supabaseService.deleteWhere<UserBuildingAssociation>(
          'buildingId', buildingId);
      await supabaseService.delete<Building>(buildingId);
    } catch (error) {
      rethrow;
    }
  }
}

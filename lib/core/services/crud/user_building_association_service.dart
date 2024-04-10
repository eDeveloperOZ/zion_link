import 'package:tachles/core/models/user_building_association.dart';
import 'package:tachles/core/services/supabase_service.dart';

class UserBuildingAssociationService {
  final SupabaseService supabaseService = SupabaseService(); // Added instance

  Future<List<UserBuildingAssociation>> getAllAssociations() async {
    return await supabaseService.readAll<UserBuildingAssociation>();
  }

  Future<void> addAssociation(UserBuildingAssociation newAssociation) async {
    await supabaseService.create<UserBuildingAssociation>(newAssociation);
  }

  Future<void> updateAssociation(
      UserBuildingAssociation updatedAssociation) async {
    await supabaseService.update<UserBuildingAssociation>(updatedAssociation);
  }

  Future<void> deleteAssociation(String userId, String buildingId) async {
    // This operation might require custom logic to construct a unique identifier or filter
    // Since SupabaseService doesn't directly support composite keys, you might need to implement a custom method in SupabaseService for this operation
    // For example, you could fetch all associations and manually filter/delete the desired one
    throw UnimplementedError("This operation requires custom implementation.");
  }

  Future<List<UserBuildingAssociation>> getAssociationsByBuildingId(
      String buildingId) async {
    final associations = await getAllAssociations();
    return associations
        .where((association) => association.buildingId == buildingId)
        .toList();
  }

  Future<List<UserBuildingAssociation>> getAssociationsByUserId(
      String userId) async {
    final associations = await getAllAssociations();
    return associations
        .where((association) => association.userId == userId)
        .toList();
  }
}

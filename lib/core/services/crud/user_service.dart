import 'package:tachles/core/models/apartment.dart';
import 'package:tachles/core/models/user.dart';
import 'package:uuid/uuid.dart';
import 'package:tachles/core/models/user_building_association.dart';
import 'package:tachles/core/services/supabase_service.dart';
import 'package:tachles/core/services/crud/apartment_service.dart';

class UserService {
  final SupabaseService supabaseService = SupabaseService();

  // Fetch all users
  Future<List<User>> readAllUsers() async {
    return await supabaseService.readAll<User>();
  }

  // Fetch all users for a specific building
  Future<List<User>> readAllUsersForBuilding(String buildingId) async {
    List<User> users = [];
    List<UserBuildingAssociation> associations =
        await supabaseService.readAll<UserBuildingAssociation>();
    for (UserBuildingAssociation association in associations) {
      if (association.buildingId == buildingId) {
        User? user = await getUserById(association.userId);
        if (user != null) {
          users.add(user);
        }
      }
    }
    return users;
  }

  // Fetch a single user by ID
  Future<User?> getUserById(String userId) async {
    SupabaseService supabaseService = SupabaseService();
    return await supabaseService.readById<User>(userId);
  }

  // Add a new user
  static Future<void> createUser(User newUser, String buildingId) async {
    SupabaseService supabaseService = SupabaseService();
    UserBuildingAssociation userBuildingAssociation = UserBuildingAssociation(
      ubaId: const Uuid().v4(),
      userId: newUser.id,
      buildingId: buildingId,
      role: newUser.role,
    );
    try {
      await supabaseService.create<User>(newUser);
      await supabaseService
          .create<UserBuildingAssociation>(userBuildingAssociation);
    } catch (error) {
      rethrow;
    }
  }

  // Update an existing user
  Future<void> updateUser(User updatedUser) async {
    try {
      await supabaseService.update<User>(updatedUser);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    await supabaseService.delete<User>(userId);
  }

  Future<List<User?>> getAllServiceProvidersForBuliding(
      String buildingId) async {
    List<User> loadedServiceProviders = await readAllUsers();
    List<Apartment> apartments =
        await ApartmentService().readAllApartmentsForBuilding(buildingId);

    List<User> serviceProviders = loadedServiceProviders
        .where((user) =>
            user.role == UserType.routineServiceProvider ||
            user.role == UserType.onCallServiceProvider)
        .toList();
    return serviceProviders.where((user) {
      return apartments.any((apartment) => apartment.id == user.apartmentId);
    }).toList();
  }
}

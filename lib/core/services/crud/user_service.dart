import '../../models/user.dart';
import '../storage_service.dart';

class UserService {
  // Fetch all users
  Future<List<User>> readAllUsers() async {
    return await StorageService.readAllUsers();
  }

  // Fetch a single user by ID
  Future<User?> getUserById(String userId) async {
    return await StorageService.readUserById(userId);
  }

  // Add a new user
  Future<void> addUser(User newUser) async {
    await StorageService.createUser(newUser);
  }

  // Update an existing user
  Future<void> updateUser(User updatedUser) async {
    await StorageService.updateUser(updatedUser);
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    await StorageService.deleteUser(userId);
  }
}

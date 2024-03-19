import '../../models/user.dart';
import '../storage_service.dart';

class UserService {
  // Fetch all users
  Future<List<User>> getAllUsers() async {
    final usersFromFile = await StorageService.readUsers();
    return usersFromFile.map<User>((item) => User.fromJson(item)).toList();
  }

  // Fetch a single user by ID
  Future<User?> getUserById(String userId) async {
    final List users = await StorageService.readUsers();
    for (var user in users) {
      if (user['id'] == userId) {
        return User.fromJson(user);
      }
    }
    return null; // User not found
  }

  // Add a new user
  Future<void> addUser(User newUser) async {
    List existingUsers = await StorageService.readUsers();
    existingUsers.add(newUser.toJson());
    await StorageService.writeUsers(existingUsers);
  }

  // Update an existing user
  Future<void> updateUser(User updatedUser) async {
    List<dynamic> users = await StorageService.readUsers();
    int index = users.indexWhere((u) => u['id'] == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser.toJson();
      await StorageService.writeUsers(users);
    }
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    List<dynamic> users = await StorageService.readUsers();
    users.removeWhere((item) => item['id'] == userId);
    await StorageService.writeUsers(users);
  }
}

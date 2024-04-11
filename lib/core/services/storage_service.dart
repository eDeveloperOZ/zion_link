import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:tachles/core/models/apartment.dart';
import 'package:tachles/core/models/expense.dart';
import 'package:tachles/core/models/payment.dart';
import 'package:tachles/core/models/building.dart';
import 'package:tachles/core/models/user.dart' as User;
import 'package:tachles/core/models/user_building_association.dart';
import 'package:tachles/core/utils/logger.dart';

class StorageService {
  static final supabase = Supabase.instance.client;

  // Buildings
  static Future<List<Building>> readAllBuildings() async {
    try {
      final response = await supabase.from('buildings').select();
      final buildingsJson = response as List<dynamic>;
      return buildingsJson.map((json) => Building.fromJson(json)).toList();
    } catch (error) {
      Logger.error('Error fetching buildings: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return [];
    }
  }

  static Future<List<Building>> readAllBuildingsForUser(String userId) async {
    try {
      final response =
          await supabase.from('buildings').select().eq('userId', userId);
      final buildingsJson = response as List<dynamic>;
      return buildingsJson.map((json) => Building.fromJson(json)).toList();
    } catch (error) {
      Logger.error('Error fetching buildings: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return [];
    }
  }

  static Future<void> createBuilding(Building newBuilding) async {
    try {
      await supabase.from('buildings').insert(newBuilding.toJson());
    } catch (error) {
      Logger.error('Error creating building: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error message: ${error.message}');
      }
      throw error;
    }
  }

  static Future<Building?> readBuildingById(String buildingId) async {
    try {
      final data = await supabase
          .from('buildings')
          .select()
          .eq('id', buildingId)
          .single();
      return Building.fromJson(data);
    } catch (error) {
      Logger.error('Error fetching building: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      throw error;
    }
  }

  static Future<void> updateBuilding(Building updatedBuilding) async {
    try {
      await supabase
          .from('buildings')
          .update(updatedBuilding.toJson())
          .eq('id', updatedBuilding.id);
    } catch (error) {
      Logger.error('Error updating building: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  static Future<void> deleteBuilding(String buildingId) async {
    try {
      deleteApartmentsForBuilding(buildingId);
      await supabase.from('expenses').delete().eq('buildingId', buildingId);
      await supabase.from('buildings').delete().eq('id', buildingId);
      // delete all apartments and expenses associated with the building
    } catch (error) {
      Logger.error('Error deleting building: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  // Apartments
  static Future<List<Apartment>> readAllApartments() async {
    try {
      final response = await supabase.from('apartments').select();
      final apartmentsJson = response as List<dynamic>;
      return apartmentsJson.map((json) => Apartment.fromJson(json)).toList();
    } catch (error) {
      Logger.error('Error fetching apartments: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      throw error;
    }
  }

  static Future<void> createApartment(Apartment newApartment) async {
    try {
      await supabase.from('apartments').insert(newApartment.toJson());
    } catch (error) {
      Logger.error('Error creating apartment: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      throw error;
    }
  }

  static Future<List<Apartment>> readAllApartmentsForBuilding(
      String buildingId) async {
    try {
      final response = await supabase
          .from('apartments')
          .select()
          .eq('buildingId', buildingId);
      final apartmentsJson = response as List<dynamic>;
      apartmentsJson.sort((a, b) {
        int numA = int.tryParse(a['number']) ?? 0;
        int numB = int.tryParse(b['number']) ?? 0;
        return numA.compareTo(numB);
      });
      return apartmentsJson.map((json) => Apartment.fromJson(json)).toList();
    } catch (error) {
      Logger.error('Error fetching apartments for building: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return [];
    }
  }

  static Future<Apartment?> readApartmentById(String apartmentId) async {
    try {
      final data = await supabase
          .from('apartments')
          .select()
          .eq('id', apartmentId)
          .single();
      return Apartment.fromJson(data);
    } catch (error) {
      Logger.error('Error fetching apartment: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return null;
    }
  }

  static Future<void> updateApartment(Apartment updatedApartment) async {
    try {
      await supabase
          .from('apartments')
          .update(updatedApartment.toJson())
          .eq('id', updatedApartment.id);
    } catch (error) {
      Logger.error('Error updating apartment: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  static Future<void> deleteApartment(String apartmentId) async {
    try {
      await supabase.from('apartments').delete().eq('id', apartmentId);
    } catch (error) {
      Logger.error('Error deleting apartment: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  static Future<void> deleteApartmentsForBuilding(String buildingId) async {
    try {
      final apartmentIds = (await readAllApartmentsForBuilding(buildingId))
          .map((apartment) => apartment.id)
          .toList();
      // delete all apartment's payments
      for (var apartmentId in apartmentIds) {
        await supabase.from('payments').delete().eq('apartmentId', apartmentId);
      }
      await supabase.from('apartments').delete().eq('buildingId', buildingId);
    } catch (error) {
      Logger.error('Error deleting apartments for building: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  // Expenses
  static Future<List<Expense>> readAllExpenses() async {
    try {
      final response = await supabase.from('expenses').select();
      final expensesJson = response as List<dynamic>;
      return expensesJson.map((json) => Expense.fromJson(json)).toList();
    } catch (error) {
      Logger.error('Error fetching expenses: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return [];
    }
  }

  static Future<List<Expense>> readAllExpensesForBuilding(
      String buildingId) async {
    try {
      final response =
          await supabase.from('expenses').select().eq('buildingId', buildingId);
      final expensesJson =
          response as List<dynamic>; // Directly cast the response
      return expensesJson.map((json) => Expense.fromJson(json)).toList();
    } catch (error) {
      Logger.error('Error fetching expenses for building: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return [];
    }
  }

  static Future<void> createExpense(Expense newExpense) async {
    try {
      await supabase.from('expenses').insert(newExpense.toJson());
    } catch (error) {
      Logger.error('Error creating expense: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  static Future<Expense?> readExpenseById(String expenseId) async {
    try {
      final data =
          await supabase.from('expenses').select().eq('id', expenseId).single();
      return Expense.fromJson(data);
    } catch (error) {
      Logger.error('Error fetching expense: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return null;
    }
  }

  static Future<void> updateExpense(Expense updatedExpense) async {
    try {
      await supabase
          .from('expenses')
          .update(updatedExpense.toJson())
          .eq('id', updatedExpense.id);
    } catch (error) {
      Logger.error('Error updating expense: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  static Future<void> deleteExpense(String expenseId) async {
    try {
      await supabase.from('expenses').delete().eq('id', expenseId);
    } catch (error) {
      Logger.error('Error deleting expense: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  // Payments
  static Future<List<Payment>> readAllPayments() async {
    try {
      final response = await supabase.from('payments').select();
      final paymentsJson = response as List<dynamic>;
      return paymentsJson.map((json) => Payment.fromJson(json)).toList();
    } catch (error) {
      Logger.error('Error fetching payments: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return [];
    }
  }

  static Future<List<Payment>> readAllPaymentsForApartment(
      String apartmentId) async {
    try {
      final response = await supabase
          .from('payments')
          .select()
          .eq('apartmentId', apartmentId);
      final paymentsJson = response as List<dynamic>;
      return paymentsJson.map((json) => Payment.fromJson(json)).toList();
    } catch (error) {
      Logger.error('Error fetching payments for apartment: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return [];
    }
  }

  static Future<void> createPayment(Payment newPayment) async {
    try {
      await supabase.from('payments').insert(newPayment.toJson());
    } catch (error) {
      Logger.error('Error creating payment: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  static Future<Payment?> readPaymentById(String paymentId) async {
    try {
      final data =
          await supabase.from('payments').select().eq('id', paymentId).single();
      return Payment.fromJson(data);
    } catch (error) {
      Logger.error('Error fetching payment: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return null;
    }
  }

  static Future<void> updatePayment(Payment updatedPayment) async {
    try {
      await supabase
          .from('payments')
          .update(updatedPayment.toJson())
          .eq('id', updatedPayment.id);
    } catch (error) {
      Logger.error('Error updating payment: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  static Future<void> deletePayment(String paymentId) async {
    try {
      await supabase.from('payments').delete().eq('id', paymentId);
    } catch (error) {
      Logger.error('Error deleting payment: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  // Users
  static Future<List<User.User>> readAllUsers() async {
    try {
      final response = await supabase.from('users').select();
      final usersJson = response as List<dynamic>;
      return usersJson.map((json) => User.User.fromJson(json)).toList();
    } catch (error) {
      Logger.error('Error fetching users: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return [];
    }
  }

  static Future<List<User.User>> readAllUsersForBuilding(
      String buildingId) async {
    try {
      final response =
          await supabase.from('users').select().eq('buildingId', buildingId);
      final usersJson = response as List<dynamic>;
      return usersJson.map((json) => User.User.fromJson(json)).toList();
    } catch (error) {
      Logger.error('Error fetching users: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return [];
    }
  }

  static Future<void> createUser(User.User newUser) async {
    try {
      // verify newUser.id is uuid format
      if (!newUser.id.contains('-')) {
        newUser.id = const Uuid().v4().toString();
      }
      await supabase.from('users').insert(newUser.toJson());
    } catch (error) {
      Logger.error('Error creating user: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  static Future<User.User?> readUserById(String userId) async {
    try {
      if (!userId.contains('-')) {
        userId = const Uuid().v4().toString();
      }
      final response =
          await supabase.from('users').select().eq('id', userId).single();
      return User.User.fromJson(response);
    } catch (error) {
      if (error is PostgrestException && error.code == 'PGRST116') {
        Logger.critical('User not found with id: $userId');
        return null;
      } else {
        Logger.error('Error fetching user by id: $error');
        if (error is PostgrestException) {
          Logger.info('Postgrest error: ${error.message}');
        }
      }
      return null;
    }
  }

  static Future<void> updateUser(User.User updatedUser) async {
    try {
      await supabase
          .from('users')
          .update(updatedUser.toJson())
          .eq('id', updatedUser.id);
    } catch (error) {
      Logger.error('Error updating user: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      await supabase.from('users').delete().eq('id', userId);
    } catch (error) {
      Logger.error('Error deleting user: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  // User Building Associations
  static Future<List<UserBuildingAssociation>>
      readAllUserBuildingAssociations() async {
    try {
      final response =
          await supabase.from('user_building_associations').select();
      final associationsJson = response as List<dynamic>;
      return associationsJson
          .map((json) => UserBuildingAssociation.fromJson(json))
          .toList();
    } catch (error) {
      Logger.error('Error fetching user building associations: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return [];
    }
  }

  static Future<void> createUserBuildingAssociation(
      UserBuildingAssociation newAssociation) async {
    try {
      await supabase
          .from('user_building_associations')
          .insert(newAssociation.toJson());
    } catch (error) {
      Logger.error('Error creating user building association: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  static Future<UserBuildingAssociation?> readUserBuildingAssociationById(
      String userId, String buildingId) async {
    try {
      final response = await supabase
          .from('user_building_associations')
          .select()
          .eq('user_id', userId)
          .eq('buildingId', buildingId)
          .single();
      return UserBuildingAssociation.fromJson(response);
    } catch (error) {
      Logger.error('Error fetching user building association: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
      return null;
    }
  }

  static Future<void> updateUserBuildingAssociation(
      UserBuildingAssociation updatedAssociation) async {
    try {
      await supabase
          .from('user_building_associations')
          .update(updatedAssociation.toJson())
          .eq('userId', updatedAssociation.userId)
          .eq('buildingId', updatedAssociation.buildingId);
    } catch (error) {
      Logger.error('Error updating user building association: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }

  static Future<void> deleteUserBuildingAssociation(
      String userId, String buildingId) async {
    try {
      await supabase
          .from('user_building_associations')
          .delete()
          .eq('userId', userId)
          .eq('buildingId', buildingId);
    } catch (error) {
      Logger.error('Error deleting user building association: $error');
      if (error is PostgrestException) {
        Logger.info('Postgrest error: ${error.message}');
      }
    }
  }
}

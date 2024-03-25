import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/models/expense.dart';
import 'package:zion_link/core/models/payment.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/models/user.dart';
import 'package:zion_link/core/models/user_building_association.dart';

class StorageService {
  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Buildings
  static Future<File> get _buildingsFile async {
    final path = await localPath;
    return File('$path/buildings.json');
  }

  static Future<List<Building>> readAllBuildings() async {
    try {
      final file = await _buildingsFile;
      final contents = await file.readAsString();
      final List<dynamic> buildingsJson = json.decode(contents) ?? [];
      return buildingsJson.map((json) => Building.fromJson(json)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  static Future<void> createBuilding(Building newBuilding) async {
    final buildings = await readAllBuildings();
    buildings.add(newBuilding);
    final file = await _buildingsFile;
    await file
        .writeAsString(json.encode(buildings.map((b) => b.toJson()).toList()));
  }

  static Future<Building> readBuildingById(String buildingId) async {
    final buildings = await readAllBuildings();
    return buildings.firstWhere((building) => building.id == buildingId);
  }

  static Future<void> updateBuilding(Building updatedBuilding) async {
    final buildings = await readAllBuildings();
    final index = buildings.indexWhere((b) => b.id == updatedBuilding.id);
    if (index != -1) {
      buildings[index] = updatedBuilding;
      final file = await _buildingsFile;
      await file.writeAsString(
          json.encode(buildings.map((b) => b.toJson()).toList()));
    }
  }

  static Future<void> deleteBuilding(String buildingId) async {
    final buildings = await readAllBuildings();
    buildings.removeWhere((building) => building.id == buildingId);
    final file = await _buildingsFile;
    await file
        .writeAsString(json.encode(buildings.map((b) => b.toJson()).toList()));
  }

  // Apartments
  static Future<File> get _apartmentsFile async {
    final path = await localPath;
    return File('$path/apartments.json');
  }

  static Future<List<Apartment>> readAllApartments() async {
    try {
      final file = await _apartmentsFile;
      final contents = await file.readAsString();
      final List<dynamic> apartmentsJson = json.decode(contents) ?? [];
      return apartmentsJson.map((json) => Apartment.fromJson(json)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  static Future<void> createApartment(Apartment newApartment) async {
    final apartments = await readAllApartments();
    apartments.add(newApartment);
    final file = await _apartmentsFile;
    await file
        .writeAsString(json.encode(apartments.map((a) => a.toJson()).toList()));
  }

  static Future<List<Apartment>> readAllApartmentsForBuilding(
      String buildingId) async {
    List<Apartment> apartments = await readAllApartments();
    return apartments
        .where((apartment) => apartment.buildingId == buildingId)
        .toList();
  }

  static Future<Apartment> readApartmentById(String apartmentId) async {
    final apartments = await readAllApartments();
    try {
      return apartments.firstWhere((apartment) => apartment.id == apartmentId);
    } catch (e) {
      throw Exception('Apartment not found');
    }
  }

  static Future<void> updateApartment(Apartment updatedApartment) async {
    final apartments = await readAllApartments();
    final index = apartments.indexWhere((a) => a.id == updatedApartment.id);
    if (index != -1) {
      apartments[index] = updatedApartment;
      final file = await _apartmentsFile;
      await file.writeAsString(
          json.encode(apartments.map((a) => a.toJson()).toList()));
    }
  }

  static Future<void> deleteApartment(String apartmentId) async {
    final apartments = await readAllApartments();
    apartments.removeWhere((apartment) => apartment.id == apartmentId);
    final file = await _apartmentsFile;
    await file
        .writeAsString(json.encode(apartments.map((a) => a.toJson()).toList()));
  }

  // Expenses
  static Future<File> get _expensesFile async {
    final path = await localPath;
    return File('$path/expenses.json');
  }

  static Future<List<Expense>> readAllExpenses() async {
    try {
      final file = await _expensesFile;
      final contents = await file.readAsString();
      final List<dynamic> expensesJson = json.decode(contents) ?? [];
      return expensesJson.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  static Future<List<Expense>> readAllExpensesForBuilding(
      String buildingId) async {
    final expenses = await readAllExpenses();
    return expenses
        .where((expense) => expense.buildingId == buildingId)
        .toList();
  }

  static Future<void> createExpense(Expense newExpense) async {
    final expenses = await readAllExpenses();
    expenses.add(newExpense);
    final file = await _expensesFile;
    await file
        .writeAsString(json.encode(expenses.map((e) => e.toJson()).toList()));
  }

  static Future<Expense?> readExpenseById(String expenseId) async {
    final expenses = await readAllExpenses();
    try {
      return expenses.firstWhere((expense) => expense.id == expenseId);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateExpense(Expense updatedExpense) async {
    final expenses = await readAllExpenses();
    final index = expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      expenses[index] = updatedExpense;
      final file = await _expensesFile;
      await file
          .writeAsString(json.encode(expenses.map((e) => e.toJson()).toList()));
    }
  }

  static Future<void> deleteExpense(String expenseId) async {
    final expenses = await readAllExpenses();
    expenses.removeWhere((expense) => expense.id == expenseId);
    final file = await _expensesFile;
    await file
        .writeAsString(json.encode(expenses.map((e) => e.toJson()).toList()));
  }

  // Payments
  static Future<File> get _paymentsFile async {
    final path = await localPath;
    return File('$path/payments.json');
  }

  static Future<List<Payment>> readAllPayments() async {
    try {
      final file = await _paymentsFile;
      final contents = await file.readAsString();
      final List<dynamic> paymentsJson = json.decode(contents) ?? [];
      return paymentsJson.map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  static Future<List<Payment>> readAllPaymentsForApartment(
      String apartmentId) async {
    final payments = await readAllPayments();
    return payments
        .where((payment) => payment.apartmentId == apartmentId)
        .toList();
  }

  static Future<void> createPayment(Payment newPayment) async {
    final payments = await readAllPayments();
    payments.add(newPayment);
    final file = await _paymentsFile;
    await file
        .writeAsString(json.encode(payments.map((p) => p.toJson()).toList()));
  }

  static Future<Payment?> readPaymentById(String paymentId) async {
    final payments = await readAllPayments();
    try {
      return payments.firstWhere((payment) => payment.id == paymentId);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updatePayment(Payment updatedPayment) async {
    final payments = await readAllPayments();
    final index = payments.indexWhere((p) => p.id == updatedPayment.id);
    if (index != -1) {
      payments[index] = updatedPayment;
      final file = await _paymentsFile;
      await file
          .writeAsString(json.encode(payments.map((p) => p.toJson()).toList()));
    }
  }

  static Future<void> deletePayment(String paymentId) async {
    final payments = await readAllPayments();
    payments.removeWhere((payment) => payment.id == paymentId);
    final file = await _paymentsFile;
    await file
        .writeAsString(json.encode(payments.map((p) => p.toJson()).toList()));
  }

  // Users
  static Future<File> get _usersFile async {
    final path = await localPath;
    return File('$path/users.json');
  }

  static Future<List<User>> readAllUsers() async {
    try {
      final file = await _usersFile;
      final contents = await file.readAsString();
      final List<dynamic> usersJson = json.decode(contents) ?? [];
      return usersJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  static Future<void> createUser(User newUser) async {
    final users = await readAllUsers();
    users.add(newUser);
    final file = await _usersFile;
    await file
        .writeAsString(json.encode(users.map((u) => u.toJson()).toList()));
  }

  static Future<User?> readUserById(String userId) async {
    final users = await readAllUsers();
    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateUser(User updatedUser) async {
    final users = await readAllUsers();
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
      final file = await _usersFile;
      await file
          .writeAsString(json.encode(users.map((u) => u.toJson()).toList()));
    }
  }

  static Future<void> deleteUser(String userId) async {
    final users = await readAllUsers();
    users.removeWhere((user) => user.id == userId);
    final file = await _usersFile;
    await file
        .writeAsString(json.encode(users.map((u) => u.toJson()).toList()));
  }

  // User Building Associations
  static Future<File> get _userBuildingAssociationsFile async {
    final path = await localPath;
    return File('$path/user_building_associations.json');
  }

  static Future<List<UserBuildingAssociation>>
      readAllUserBuildingAssociations() async {
    try {
      final file = await _userBuildingAssociationsFile;
      final contents = await file.readAsString();
      final List<dynamic> associationsJson = json.decode(contents) ?? [];
      return associationsJson
          .map((json) => UserBuildingAssociation.fromJson(json))
          .toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  static Future<void> createUserBuildingAssociation(
      UserBuildingAssociation newAssociation) async {
    final associations = await readAllUserBuildingAssociations();
    associations.add(newAssociation);
    final file = await _userBuildingAssociationsFile;
    await file.writeAsString(
        json.encode(associations.map((a) => a.toJson()).toList()));
  }

  static Future<UserBuildingAssociation?> readUserBuildingAssociationById(
      String userId, String buildingId) async {
    final associations = await readAllUserBuildingAssociations();
    try {
      return associations.firstWhere((association) =>
          association.userId == userId && association.buildingId == buildingId);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateUserBuildingAssociation(
      UserBuildingAssociation updatedAssociation) async {
    final associations = await readAllUserBuildingAssociations();
    final index = associations.indexWhere((a) =>
        a.userId == updatedAssociation.userId &&
        a.buildingId == updatedAssociation.buildingId);
    if (index != -1) {
      associations[index] = updatedAssociation;
      final file = await _userBuildingAssociationsFile;
      await file.writeAsString(
          json.encode(associations.map((a) => a.toJson()).toList()));
    }
  }

  static Future<void> deleteUserBuildingAssociation(
      String userId, String buildingId) async {
    final associations = await readAllUserBuildingAssociations();
    associations.removeWhere((association) =>
        association.userId == userId && association.buildingId == buildingId);
    final file = await _userBuildingAssociationsFile;
    await file.writeAsString(
        json.encode(associations.map((a) => a.toJson()).toList()));
  }
}

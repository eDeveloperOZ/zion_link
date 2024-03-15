import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/apartment.dart';
import '../models/expense.dart';
import '../models/payment.dart';
import '../utils/logger.dart';

class StorageService {
  // Buildings
  static Future<List> getAllBuildings() async {
    try {
      final response =
          await Supabase.instance.client.from('buildings').select();
      Logger.info('Buildings retrieved from the database: $response');
      return response as List;
    } catch (e) {
      Logger.error('An error occurred: $e');
      return [];
    }
  }

  // write buildings to the database
  static Future<void> writeBuildings(List buildings) async {
    try {
      final response =
          await Supabase.instance.client.from('buildings').upsert(buildings);
      Logger.info('Buildings written to the database: $response');
    } catch (e) {
      Logger.error('An error occurred: $e');
    }
  }

  /// Adds an [Expense] to a building identified by [buildingId].
  ///
  /// Retrieves the list of buildings, finds the one with the matching [buildingId],
  /// and adds the [newExpense] to its list of expenses. If the building is found and
  /// the expense is successfully added, the updated list of buildings is written back
  /// to the database. If the building is not found, a message is printed indicating
  /// the failure.
  ///
  /// Parameters:
  /// - [buildingId]: The unique identifier of the building.
  /// - [newExpense]: The [Expense] object to be added.
  ///
  /// Returns:
  /// - A [Future] that completes with `void`.
  static Future<void> addExpenseToBuilding(
      String buildingId, Expense newExpense) async {
    final List buildings = await getAllBuildings();
    final Map<String, dynamic>? targetBuilding = buildings.firstWhere(
        (building) => building['id'] == buildingId,
        orElse: () => null);
    if (targetBuilding != null) {
      targetBuilding['expenses'] = targetBuilding['expenses'] ?? [];
      targetBuilding['expenses'].add(newExpense.toJson());
      await writeBuildings(buildings);
    } else {
      Logger.error("Building with ID $buildingId not found.");
    }
  }

  /// Adds a [Payment] to an apartment within a building identified by [buildingId].
  ///
  /// This method retrieves the list of buildings, iterates through them to find the
  /// building with the matching [buildingId]. Within the found building, it searches
  /// for the apartment with the ID matching [newPayment.apartmentId] and adds the
  /// [newPayment] to its list of payments. If the building and apartment are found,
  /// the updated list of buildings is written back to the database. If not, a message
  /// is printed indicating the failure.
  ///
  /// Parameters:
  /// - [buildingId]: The unique identifier of the building.
  /// - [newPayment]: The [Payment] object to be added.
  ///
  /// Returns:
  /// - A [Future] that completes with `void`.
  Future<void> addPaymentToBuilding(
      String buildingId, Payment newPayment) async {
    final List buildings = await getAllBuildings();
    Map<String, dynamic>? targetBuilding = buildings.firstWhere(
        (building) => building['id'] == buildingId,
        orElse: () => null);
    if (targetBuilding != null) {
      final List apartments = targetBuilding['apartments'];
      final int apartmentIndex = apartments
          .indexWhere((apartment) => apartment['id'] == newPayment.apartmentId);
      if (apartmentIndex != -1) {
        apartments[apartmentIndex]['payments'] =
            apartments[apartmentIndex]['payments'] ?? [];
        apartments[apartmentIndex]['payments'].add(newPayment.toJson());
        await writeBuildings(buildings);
      } else {
        Logger.warning(
            "Apartment with ID ${newPayment.apartmentId} not found in building ID $buildingId.");
      }
    } else {
      Logger.warning("Building with ID $buildingId not found.");
    }
  }

  // Apartments
  /// Updates the details of an existing apartment within the buildings data.
  ///
  /// This method iterates through the list of buildings to find the apartment
  /// with the matching [updatedApartment.id]. Once found, it updates the apartment's
  /// details with those of [updatedApartment] and writes the updated list of buildings
  /// back to the database. If the apartment is not found, no action is taken.
  ///
  /// Parameters:
  /// - [updatedApartment]: The [Apartment] object containing the updated details.
  ///
  /// Returns:
  /// - A [Future] that completes with `void`.
  ///
  /// This method is compatible across iOS, Android, PC, macOS, and web platforms.
  static Future<void> updateApartment(Apartment updatedApartment) async {
    final List buildings = await getAllBuildings();
    bool isUpdated = false;
    for (var building in buildings) {
      final List apartments = building['apartments'];
      final int apartmentIndex = apartments
          .indexWhere((apartment) => apartment['id'] == updatedApartment.id);
      if (apartmentIndex != -1) {
        apartments[apartmentIndex] = updatedApartment.toJson();
        isUpdated = true;
        break; // Exit the loop once the apartment is updated
      }
    }
    if (isUpdated) {
      await writeBuildings(buildings); // Write only if an update occurred
    }
  }

  /// Writes the updated details of an apartment to the buildings data.
  ///
  /// Iterates through the list of buildings to find and update the apartment
  /// with the matching [apartment.id]. If the apartment is found and updated,
  /// the updated list of buildings is written back to the database. If the
  /// apartment is not found in any building, a message is printed indicating
  /// the apartment was not found.
  ///
  /// Parameters:
  /// - [apartment]: The [Apartment] object containing the updated details.
  ///
  /// Returns:
  /// - A [Future] that completes with `void`.
  ///
  /// This method is compatible across iOS, Android, PC, macOS, and web platforms.
  static Future<void> writeApartment(Apartment apartment) async {
    final List buildings = await getAllBuildings();
    bool isApartmentUpdated = false;
    for (var building in buildings) {
      final List apartments = building['apartments'];
      final int apartmentIndex =
          apartments.indexWhere((a) => a['id'] == apartment.id);
      if (apartmentIndex != -1) {
        apartments[apartmentIndex] = apartment.toJson();
        isApartmentUpdated = true;
        break; // Exit the loop once the apartment is updated
      }
    }
    if (!isApartmentUpdated) {
      // Log a message if the apartment is not found in any building
      Logger.warning("Apartment with ID ${apartment.id} not found.");
    } else {
      // Persist the updated buildings data only if an apartment was updated
      await writeBuildings(buildings);
    }
  }

  static Future<Apartment?> readApartment(String id) async {
    final List buildings = await getAllBuildings();
    for (var building in buildings) {
      final List apartments = building['apartments'];
      final index = apartments.indexWhere((apartment) => apartment['id'] == id);
      if (index != -1) {
        return Apartment.fromJson(apartments[index]);
      }
    }
    return null; // Return null if apartment with given id is not found
  }

  // Expenses
  static Future<void> updateExpense(Expense expense) async {
    final List buildings = await getAllBuildings();
    bool foundExpense = false;
    for (var building in buildings) {
      if (building['expenses'] != null) {
        final List expenses = building['expenses'];
        final int index = expenses.indexWhere((e) => e['id'] == expense.id);
        if (index != -1) {
          expenses[index] = expense.toJson();
          Logger.info("Expense updated: ${expenses[index]}");
          foundExpense = true;
          break;
        }
      }
    }
    if (!foundExpense) {
      Logger.warning("Expense with ID ${expense.id} not found.");
    } else {
      await writeBuildings(buildings);
    }
  }

  static Future<void> deleteExpense(String buildingId, String expenseId) async {
    final List buildings = await getAllBuildings();
    bool foundBuilding = false;
    bool foundExpense = false;
    for (var building in buildings) {
      if (building['id'] == buildingId) {
        foundBuilding = true;
        final List expenses = building['expenses'] ?? [];
        final int index = expenses.indexWhere((e) => e['id'] == expenseId);
        if (index != -1) {
          expenses.removeAt(index);
          foundExpense = true;
          Logger.info("Expense with ID $expenseId removed.");
          break;
        }
      }
    }
    if (!foundBuilding) {
      Logger.warning("Building with ID $buildingId not found.");
    } else if (!foundExpense) {
      Logger.warning(
          "Expense with ID $expenseId not found in building $buildingId.");
    } else {
      await writeBuildings(buildings);
    }
  }

  static Future<List<Expense>> readExpenses(String buildingId) async {
    final List buildings = await getAllBuildings();
    for (var building in buildings) {
      if (building['id'] == buildingId) {
        final List expensesJson = building['expenses'] ?? [];
        return expensesJson
            .map<Expense>((json) => Expense.fromJson(json))
            .toList();
      }
    }
    return []; // Return an empty list if the building or its expenses are not found
  }

  // Payments
  static Future<List<Payment>> readPayments(String buildingId) async {
    final List buildings = await getAllBuildings();
    for (var building in buildings) {
      if (building['id'] == buildingId) {
        final List paymentsJson = building['payments'] ?? [];
        return paymentsJson
            .map<Payment>((json) => Payment.fromJson(json))
            .toList();
      }
    }
    return []; // Return an empty list if the building or its payments are not found
  }

  Future<void> updatePayment(Payment updatedPayment) async {
    final List buildings = await getAllBuildings();
    bool foundPayment = false;
    for (var building in buildings) {
      final List apartments =
          building['apartments']; // Access apartments from building
      for (var apartment in apartments) {
        final List payments =
            apartment['payments'] ?? []; // Ensure payments list exists
        final int index =
            payments.indexWhere((p) => p['id'] == updatedPayment.id);
        if (index != -1) {
          payments[index] = updatedPayment.toJson();
          foundPayment = true;
          break; // Break the inner loop
        }
      }
      if (foundPayment) {
        await writeBuildings(
            buildings); // Save changes if a payment was updated
        break; // Break the outer loop
      }
    }
    if (!foundPayment) {
      Logger.warning("Payment with ID ${updatedPayment.id} not found.");
    }
  }

  Future<void> deletePayment(String buildingId, String paymentId) async {
    final List buildings = await getAllBuildings();
    bool foundBuilding = false;
    bool foundPayment = false;
    for (var building in buildings) {
      if (building['id'] == buildingId) {
        foundBuilding = true;
        final List apartments = building['apartments'] ?? [];
        for (var apartment in apartments) {
          final List payments = apartment['payments'] ?? [];
          final int index = payments.indexWhere((p) => p['id'] == paymentId);
          if (index != -1) {
            payments.removeAt(index);
            foundPayment = true;
            Logger.info("Payment with ID $paymentId removed.");
            break; // Breaks out of the apartments loop once payment is found and removed
          }
        }
        if (foundPayment) {
          break; // Breaks out of the buildings loop if payment is found and removed
        }
      }
    }
    if (!foundBuilding) {
      Logger.warning("Building with ID $buildingId not found.");
    } else if (!foundPayment) {
      Logger.warning(
          "Payment with ID $paymentId not found in building $buildingId.");
    } else {
      await writeBuildings(
          buildings); // Save changes only if a payment was found and removed
    }
  }
}

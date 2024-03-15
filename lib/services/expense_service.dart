import 'package:zion_link/services/building_service.dart';
import '../models/expense.dart';
import 'storage_service.dart';
import 'package:zion_link/utils/logger.dart';

class ExpenseService {
  final BuildingService buildingService = BuildingService();
  Future<List<Expense>> getAllExpensesForBuilding(String buildingId) async {
    final buildings = await buildingService.getAllBuildings();
    List<Expense> expenses = [];
    for (var building in buildings) {
      if (building.id == buildingId) {
        var buildingExpenses = building.expenses as List;
        expenses.addAll(buildingExpenses.map((item) =>
            item is Map<String, dynamic> ? Expense.fromJson(item) : item));
      }
    }
    return expenses;
  }

  Future<Expense?> getExpenseById(String buildingId, String expenseId) async {
    final List<Expense> expenses = await getAllExpensesForBuilding(buildingId);
    return expenses.firstWhere((expense) => expense.id == expenseId);
  }

  Future<void> addExpenseToBuilding(String buildingId, Expense expense) async {
    final List buildings = await buildingService.getAllBuildings();
    bool found = false;
    for (var building in buildings) {
      if (building.id == buildingId) {
        final List<Expense> expenses = building.expenses;
        expenses.add(expense);
        building.expenses = expenses;
        found = true;
        break;
      }
    }
    if (!found) {
      Logger.error("Building with ID $buildingId not found.");
    } else {
      await StorageService.writeBuildings(buildings);
    }
  }

  Future<void> updateExpense(
      String buildingId, String expenseId, Expense updatedExpense) async {
    final List buildings = await buildingService.getAllBuildings();
    for (var building in buildings) {
      if (building['id'] == buildingId) {
        final List expenses = building['expenses'];
        final int index = expenses.indexWhere((e) => e['id'] == expenseId);
        if (index != -1) {
          expenses[index] = updatedExpense.toJson();
          break;
        }
      }
    }
    await StorageService.writeBuildings(buildings);
  }

  Future<void> deleteExpense(String buildingId, String expenseId) async {
    final List buildings = await StorageService.getAllBuildings();
    for (var building in buildings) {
      if (building['id'] == buildingId) {
        final List expenses = building['expenses'];
        final index = expenses.indexWhere((e) => e['id'] == expenseId);
        if (index != -1) {
          expenses.removeAt(index);
          break;
        }
      }
    }
    await StorageService.writeBuildings(buildings);
  }
}

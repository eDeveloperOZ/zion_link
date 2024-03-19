import 'building_service.dart';
import 'package:zion_link/core/models/expense.dart';
import 'package:zion_link/core/services/storage_service.dart';

class ExpenseService {
  final BuildingService buildingService = BuildingService();

  Future<List<Expense>> getAllExpensesForBuilding(String buildingId) async {
    final expenses = await StorageService.readExpenses(buildingId);
    return expenses;
  }

  Future<Expense?> getExpenseById(String expenseId) async {
    final expenses = await StorageService.getAllBuildings();
    for (var building in expenses) {
      final expense = building.expenses
          .firstWhere((expense) => expense.id == expenseId, orElse: () => null);
      if (expense != null) {
        return expense;
      }
    }
    return null;
  }

  Future<void> addExpense(Expense expense) async {
    await StorageService.addExpenseToBuilding(expense.buildingId, expense);
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    await StorageService.updateExpense(updatedExpense);
  }

  Future<void> deleteExpense(String expenseId) async {
    final expenses = await StorageService.getAllBuildings();
    for (var building in expenses) {
      building.expenses.removeWhere((expense) => expense.id == expenseId);
      await StorageService.writeBuildings(expenses);
    }
  }
}

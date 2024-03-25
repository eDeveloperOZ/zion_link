import 'building_service.dart';
import 'package:zion_link/core/models/expense.dart';
import 'package:zion_link/core/services/storage_service.dart';

class ExpenseService {
  final BuildingService buildingService = BuildingService();

  Future<List<Expense>> readAllExpensesForBuilding(String buildingId) async {
    final expenses =
        await StorageService.readAllExpensesForBuilding(buildingId);
    return expenses;
  }

  Future<Expense?> readExpenseById(String expenseId) async {
    final expenses = await StorageService.readAllExpensesForBuilding(expenseId);
    return expenses.firstWhere((expense) => expense.id == expenseId);
  }

  Future<void> createExpense(Expense expense) async {
    await StorageService.createExpense(expense);
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    await StorageService.updateExpense(updatedExpense);
  }

  Future<void> deleteExpense(String expenseId) async {
    await StorageService.deleteExpense(expenseId);
  }
}

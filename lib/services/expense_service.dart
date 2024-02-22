import '../models/expense.dart';
import '../utils/file_storage.dart';

class ExpenseService {
  Future<List<Expense>> fetchExpenses(String buildingId) async {
    return await LocalStorage.readExpenses(buildingId);
  }

  Future<void> addExpense(String buildingId, Expense newExpense) async {
    await LocalStorage.addExpenseToBuilding(buildingId, newExpense);
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    await LocalStorage.updateExpense(updatedExpense);
  }

  Future<void> deleteExpense(String buildingId, String expenseId) async {
    await LocalStorage.deleteExpense(buildingId, expenseId);
  }
}

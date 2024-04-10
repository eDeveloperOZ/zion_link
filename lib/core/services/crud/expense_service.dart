import 'package:tachles/core/models/expense.dart';
import 'package:tachles/core/services/supabase_service.dart';

class ExpenseService {
  final SupabaseService supabaseService = SupabaseService();

  Future<List<Expense>> readAllExpensesForBuilding(String buildingId) async {
    return await supabaseService.readAllForBuilding<Expense>(buildingId);
  }

  Future<Expense?> readExpenseById(String expenseId) async {
    return await supabaseService.readById<Expense>(expenseId);
  }

  Future<void> createExpense(Expense expense) async {
    await supabaseService.create<Expense>(expense);
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    await supabaseService.update<Expense>(updatedExpense);
  }

  Future<void> deleteExpense(String expenseId) async {
    await supabaseService.delete<Expense>(expenseId);
  }
}

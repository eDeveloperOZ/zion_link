import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'edit_expense_view.dart';
import '../services/expense_service.dart'; // Import this to use services for CRUD operations

class AttendantExpensesView extends StatefulWidget {
  const AttendantExpensesView({Key? key, required this.buildingId})
      : super(key: key);
  final String buildingId;

  @override
  _AttendantExpensesViewState createState() => _AttendantExpensesViewState();
}

class _AttendantExpensesViewState extends State<AttendantExpensesView> {
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses(this.widget.buildingId);
  }

  Future<void> _loadExpenses(String buildingId) async {
    ExpenseService expenseService = ExpenseService();
    List<Expense> loadedExpenses =
        await expenseService.getAllExpensesForBuilding(buildingId);
    setState(() {
      expenses = loadedExpenses;
    });
  }

  Widget _buildEmptyMessage() {
    return Center(
      child: Text('אין הוצאות להצגה'),
    );
  }

  Widget _buildExpenseItem(Expense expense, BuildContext context, int index) {
    return Tooltip(
      message: 'לחץ לערוך',
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditExpenseView(
                  payment: expenses[index], buildingId: this.widget.buildingId),
            ),
          );
          _loadExpenses(this.widget.buildingId);
        },
        child: ListTile(
          title: Text('${expense.categoryId} - ₪${expense.amount.toString()}'),
          subtitle: Text(expense.title),
          trailing: Text(expense.date.toString()),
        ),
      ),
    );
  }

  Widget _buildExpensesList() {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildExpenseItem(expense, context, index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('כל ההוצאות'),
      ),
      body: expenses.isEmpty ? _buildEmptyMessage() : _buildExpensesList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:zion_link/core/models/expense.dart';
import 'package:zion_link/core/services/crud/expense_service.dart';
import 'package:zion_link/features/expenses/edit_expense_view.dart';
import 'package:zion_link/shared/widgets/delete_button.dart';
import 'package:zion_link/shared/widgets/display_document_widget.dart';

class AllExpensesView extends StatefulWidget {
  // TODO: change to AllExpensesScreen
  const AllExpensesView({Key? key, required this.buildingId}) : super(key: key);
  final String buildingId;

  @override
  _AllExpensesViewState createState() => _AllExpensesViewState();
}

class _AllExpensesViewState extends State<AllExpensesView> {
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses(this.widget.buildingId);
  }

  Future<void> _loadExpenses(String buildingId) async {
    ExpenseService expenseService = ExpenseService();
    List<Expense> loadedExpenses =
        await expenseService.readAllExpensesForBuilding(buildingId);
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
      child: ListTile(
        title: Text('${expense.categoryId} - ₪${expense.amount.toString()}'),
        subtitle: Text(expense.title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(expense.date.toString()),
            if (expense.filePath != null)
              DisplayDocumentWidget(filePath: expense.filePath),
            DeleteButton(
              onDelete: () async {
                await ExpenseService().deleteExpense(expense.id);
                _loadExpenses(widget.buildingId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('הוצאה נמחקה בהצלחה')),
                );
              },
            ),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditExpenseView(
                  expense: expenses[index], buildingId: widget.buildingId),
            ),
          );
          _loadExpenses(
              widget.buildingId); // Reload expenses after potential edit
        },
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

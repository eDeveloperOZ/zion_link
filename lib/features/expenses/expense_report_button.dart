import 'package:flutter/material.dart';
import 'package:tachles/core/models/expense.dart';

class ExpenseReportButton extends StatelessWidget {
  final List<Expense> expenses;
  final String buildingId;
  final VoidCallback onExpensesUpdated;

  const ExpenseReportButton({
    Key? key,
    required this.expenses,
    required this.buildingId,
    required this.onExpensesUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'כל התשלומים',
      child: GestureDetector(
        onTap: onExpensesUpdated, // Adjust this to trigger the desired action
        child:
            Text('סך ההוצאות: ₪${expenses.fold(0.0, (a, b) => a + b.amount)}'),
      ),
    );
  }
}

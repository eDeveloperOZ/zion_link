import 'package:flutter/material.dart';
import 'package:zion_link/core/models/expense.dart';
import 'package:zion_link/features/expenses/attendant_expenses_view.dart';

class AllExpensesButton extends StatelessWidget {
  final List<Expense> expenses;
  final String buildingId;
  final VoidCallback onExpensesUpdated; // Add this line

  const AllExpensesButton({
    Key? key,
    required this.expenses,
    required this.buildingId,
    required this.onExpensesUpdated, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'כל התשלומים',
      child: GestureDetector(
        onTap: () async {
          final result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AttendantExpensesView(
                buildingId: buildingId,
              );
            },
          );
          if (result == true) {
            onExpensesUpdated();
          }
          // Trigger state update in parent widget if needed
        },
        child:
            Text('סך ההוצאות: ₪${expenses.fold(0.0, (a, b) => a + b.amount)}'),
      ),
    );
  }
}

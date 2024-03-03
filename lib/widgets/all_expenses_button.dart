import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../views/attendant_expenses_view.dart';

class AllExpensesButton extends StatelessWidget {
  final List<Expense> expenses;
  final String buildingId;
  // final Future<void> Function() onExpensesUpdated;

  const AllExpensesButton({
    Key? key,
    required this.expenses,
    required this.buildingId,
    // required this.onExpensesUpdated,
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
            // await onExpensesUpdated(); // Use the callback here
          }
          // Trigger state update in parent widget if needed
        },
        child:
            Text('סך ההוצאות: ₪${expenses.fold(0.0, (a, b) => a + b.amount)}'),
      ),
    );
  }
}

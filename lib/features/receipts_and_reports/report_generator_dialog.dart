import 'package:flutter/material.dart';
import 'package:tachles/core/models/building.dart';
import 'package:tachles/features/receipts_and_reports/report_balance_button.dart';
import 'package:tachles/features/receipts_and_reports/receipt_generator_button.dart';

class ReportGeneratorDialog extends StatelessWidget {
  final Building building;

  const ReportGeneratorDialog({
    Key? key,
    required this.building,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('דוחות')),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            ReceiptGeneratorButton(building: building),
            SizedBox(height: 10), // Spacing between buttons
            ReportBalanceButton.ReportBalanceButton(building: building),
          ],
        ),
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('סגור'),
          ),
        )
      ],
    );
  }
}

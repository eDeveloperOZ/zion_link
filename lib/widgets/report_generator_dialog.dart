import 'package:flutter/material.dart';
import 'receipt_generator_button.dart';
import 'balance_report_button.dart';
import '../models/building.dart'; // Import if you have a Building object to pass

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
            BalanceReportButton(building: building),
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

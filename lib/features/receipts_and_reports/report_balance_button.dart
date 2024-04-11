import 'package:flutter/material.dart';
import 'package:tachles/core/models/building.dart';
import 'package:tachles/features/receipts_and_reports/report_balance_screen.dart';

class ReportBalanceButton extends StatelessWidget {
  final Building building;

  const ReportBalanceButton.ReportBalanceButton({
    Key? key,
    required this.building,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _generateBalanceReport(context),
      child: Text('צור דוח יתרות'),
    );
  }

  void _generateBalanceReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 600),
            child: SingleChildScrollView(
              child: ReportBalanceScreen(building: building),
            ),
          ),
        );
      },
    );
  }
}

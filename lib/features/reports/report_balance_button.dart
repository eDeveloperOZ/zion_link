import 'package:flutter/material.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/features/reports/report_balance_view.dart';

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportBalanceView(building: building),
      ),
    );
  }
}

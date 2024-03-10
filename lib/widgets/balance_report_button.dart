import 'package:flutter/material.dart';
import '../models/building.dart';
import '../views/balance_report_view.dart';

class BalanceReportButton extends StatelessWidget {
  final Building building;

  const BalanceReportButton({
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
        builder: (context) => BalanceReportView(building: building),
      ),
    );
  }
}

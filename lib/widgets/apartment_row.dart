import 'package:flutter/material.dart';
import '../models/apartment.dart';
import 'income_report_dialog.dart';

class ApartmentRow extends StatelessWidget {
  final Apartment apartment;
  final VoidCallback onPaymentReported;
  final VoidCallback onTap;

  const ApartmentRow(
      {Key? key,
      required this.apartment,
      required this.onTap,
      required this.onPaymentReported})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              apartment.attendantName,
              style: TextStyle(fontSize: 25),
            ),
          ),
          Expanded(
            child: Text(' תשלום שנתי ${apartment.yearlyPaymentAmount.toInt()}',
                style: TextStyle(fontSize: 25)),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return IncomeReportDialog(apartmentId: apartment.id);
                },
              ).then((_) => onPaymentReported());
            },
            child: Row(
              children: [
                Icon(Icons.attach_money),
                Text('דווח', style: TextStyle(fontSize: 25)),
              ],
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

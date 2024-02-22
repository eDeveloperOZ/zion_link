import 'package:flutter/material.dart';
import '../models/apartment.dart';
import 'income_report_dialog.dart';

class ApartmentRow extends StatelessWidget {
  final Apartment apartment;
  final VoidCallback onTap;
  final VoidCallback onPaymentReported;

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
            child: Text(apartment.attendantName),
          ),
          Expanded(
            child: Text('${apartment.yearlyPaymentAmount.toInt()} תשלום שנתי'),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ReportIncomeDialog(apartmentId: apartment.id);
                },
              ).then((_) => onPaymentReported());
            },
            child: Row(
              children: [
                Icon(Icons.attach_money),
                Text('דווח'),
              ],
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

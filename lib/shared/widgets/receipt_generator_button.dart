import 'package:flutter/material.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/features/payments/receipt_details_screen.dart';

class ReceiptGeneratorButton extends StatelessWidget {
  final Building building;

  const ReceiptGeneratorButton({
    Key? key,
    required this.building,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _generateReceipt(context),
      child: Text('צור קבלה'),
    );
  }

  void _generateReceipt(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptDetailsScreen(building: building),
      ),
    );
  }
}

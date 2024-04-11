import 'package:flutter/material.dart';
import 'package:tachles/core/models/payment.dart';

class PaymentSummaryWidget extends StatelessWidget {
  final List<Payment> payments;

  const PaymentSummaryWidget({
    Key? key,
    required this.payments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return ListTile(
          title:
              Text('${payment.amount} - ${payment.dateMade.toIso8601String()}'),
          subtitle: Text(payment.reason),
        );
      },
    );
  }
}

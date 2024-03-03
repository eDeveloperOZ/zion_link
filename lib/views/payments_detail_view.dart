import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

class PaymentsDetailView extends StatefulWidget {
  final List<Payment> payments;

  PaymentsDetailView({required this.payments});

  @override
  _PaymentsDetailViewState createState() => _PaymentsDetailViewState();
}

class _PaymentsDetailViewState extends State<PaymentsDetailView> {
  final PaymentService _paymentService = PaymentService();

  @override
  Widget build(BuildContext context) {
    // Check if there are no payments
    if (widget.payments.isEmpty) {
      return Center(
        child: Text('לא נעשו תשלומים עדיין'),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.payments.length,
        itemBuilder: (context, index) {
          final payment = widget.payments[index];
          return Container(
            margin: EdgeInsets.all(8.0), // Add margin around each tile
            decoration: BoxDecoration(
              color:
                  payment.isConfirmed ? Colors.green : Colors.red, // Tile color
              borderRadius: BorderRadius.circular(10.0), // Rounded edges
            ),
            child: ListTile(
              title: Text('${payment.amount}'),
              subtitle: Text('${payment.date} - ${payment.paymentMethod}'),
              tileColor: Colors.transparent,
              trailing: payment.isConfirmed
                  ? Icon(Icons.check, color: Colors.white)
                  : ElevatedButton(
                      child: Text('אשר תשלום'),
                      onPressed: () async {
                        final paymentToUpdate = await _paymentService
                            .getPaymentById(payment.apartmentId, payment.id);
                        paymentToUpdate?.isConfirmed = true;
                        await _paymentService.updatePayment(
                            payment.apartmentId, paymentToUpdate!);
                        setState(() {});
                      },
                    ),
            ),
          );
        },
      );
    }
  }
}

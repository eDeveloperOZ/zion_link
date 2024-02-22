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
        shrinkWrap: true, // Important for embedding within another ListView
        physics: NeverScrollableScrollPhysics(), // Prevents inner scroll issues
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
              tileColor: Colors
                  .transparent, // Make tileColor transparent to show Container color
              trailing: payment.isConfirmed
                  ? Icon(Icons.check, color: Colors.white)
                  : ElevatedButton(
                      child: Text('אשר תשלום'),
                      onPressed: () async {
                        payment.confirm();
                        await _paymentService.updatePayment(
                          payment,
                        );
                        setState(
                            () {}); // Rebuild the widget to reflect changes
                      },
                    ),
            ),
          );
        },
      );
    }
  }
}

import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../models/building.dart';
import '../services/payment_service.dart';
import '../widgets/delete_button.dart';
import '../widgets/success_message_widget.dart';
import 'receipt_view.dart';

class AttendantPaymentsView extends StatefulWidget {
  final Building building;
  final List<Payment> payments;

  AttendantPaymentsView({required this.building, required this.payments});

  @override
  _AttendantPaymentsViewState createState() => _AttendantPaymentsViewState();
}

class _AttendantPaymentsViewState extends State<AttendantPaymentsView> {
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
        itemCount: widget.payments.length,
        itemBuilder: (context, index) {
          final payment = widget.payments[index];
          return Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: payment.isConfirmed
                  ? Colors.greenAccent
                  : Color.fromRGBO(230, 69, 69, 1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              title: Text('${payment.amount}'),
              subtitle: Text('${payment.date} - ${payment.paymentMethod}'),
              tileColor: Colors.transparent,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!payment.isConfirmed)
                    ElevatedButton(
                      child: Text('אשר תשלום'),
                      onPressed: () async {
                        final paymentToUpdate = await _paymentService
                            .getPaymentById(payment.apartmentId, payment.id);
                        if (paymentToUpdate != null) {
                          paymentToUpdate.isConfirmed = true;
                          await _paymentService.updatePayment(
                              payment.apartmentId, paymentToUpdate);
                          // Update the local list of payments to reflect the change
                          setState(() {
                            int indexToUpdate = widget.payments
                                .indexWhere((p) => p.id == payment.id);
                            if (indexToUpdate != -1) {
                              widget.payments[indexToUpdate] = paymentToUpdate;
                            }
                          });
                        }
                      },
                    ),
                  DeleteButton(
                    requirePassword: true,
                    onDelete: () async {
                      await _paymentService.deletePayment(
                          payment.apartmentId, payment.id);
                      setState(() {
                        widget.payments.remove(payment);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: SuccessMessageWidget(
                                message: 'התשלום נמחק בהצלחה')),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.receipt),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ReceiptView(
                            payment: payment,
                            attendantName: widget.building.apartments
                                .firstWhere((a) => a.id == payment.apartmentId)
                                .attendantName,
                            buildingAddress: widget.building.address,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:zion_link/core/models/payment.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/services/crud/apartment_service.dart';
import 'package:zion_link/core/services/crud/payment_service.dart';
import 'package:zion_link/shared/widgets/delete_button.dart';
import 'package:zion_link/shared/widgets/success_message_widget.dart';
import 'package:zion_link/features/payments/receipt_view.dart';
import 'package:zion_link/shared/widgets/error_message_widget.dart';

class AttendantPaymentsView extends StatefulWidget {
  final Building building;
  final List<Payment> payments;

  AttendantPaymentsView({required this.building, required this.payments});

  @override
  _AttendantPaymentsViewState createState() => _AttendantPaymentsViewState();
}

class _AttendantPaymentsViewState extends State<AttendantPaymentsView> {
  final PaymentService _paymentService = PaymentService();
  final ApartmentService _apartmentService = ApartmentService();

  @override
  Widget build(BuildContext context) {
    if (widget.payments.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('תשלומים שנעשו'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.payment,
                size: 80.0,
                color: Colors.grey[300],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'לא נעשו תשלומים עדיין',
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('חזור'),
              ),
            ],
          ),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.payments.length,
        itemBuilder: (context, index) {
          final payment = widget.payments[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('${payment.amount}'),
              subtitle: Text('${payment.dateMade} - ${payment.paymentMethod}'),
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
                        SuccessMessageWidget.create(
                            message: 'התשלום נמחק בהצלחה'),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.receipt),
                    onPressed: () async {
                      // Make the function async
                      Apartment? apartment = await _apartmentService
                          .getApartmentById(payment.apartmentId);
                      final attendantName =
                          apartment?.attendantName ?? 'Unknown';
                      if (apartment != null) {
                        // Check if apartment is not null
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ReceiptView(
                              payment: payment,
                              attendantName: attendantName,
                              buildingAddress: widget.building.address,
                            );
                          },
                        );
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          ErrorMessageWidget.create(
                              message: 'אירעה שגיאה בהצגת הקבלה'),
                        );
                        Navigator.pop(context);
                      }
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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zion_link/core/models/payment.dart';
import 'package:zion_link/shared/widgets/error_message_widget.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/services/crud/payment_service.dart';
import 'package:zion_link/features/payments/income_report_screen.dart';
import 'package:zion_link/features/apartments/edit_apartment_screen.dart';
import 'package:zion_link/features/payments/apartment_payments_view.dart';

// Convert ApartmentRow to StatefulWidget
class ApartmentRow extends StatefulWidget {
  final Apartment apartment;
  final Function(Apartment) onPaymentReported;
  final VoidCallback onTap;
  final Function(Apartment) onApartmentUpdated;

  ApartmentRow({
    Key? key,
    required this.apartment,
    required this.onTap,
    required this.onPaymentReported,
    required this.onApartmentUpdated,
  }) : super(key: key);

  @override
  _ApartmentRowState createState() => _ApartmentRowState();
}

class _ApartmentRowState extends State<ApartmentRow> {
  final PaymentService _paymentService = PaymentService();

  void _showPayments(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.50,
            child: ApartmentPaymentsView(apartment: widget.apartment),
          ),
        );
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              widget.apartment.tenantId,
              style: TextStyle(fontSize: 25),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showPayments(context),
              child: FutureBuilder<List<Payment>>(
                future: _paymentService
                    .readAllPaymentsForApartment(widget.apartment.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final double totalConfirmedPayments = snapshot.data!
                        .where((payment) => payment.isConfirmed)
                        .map((payment) => payment.amount)
                        .fold(0.0, (prev, amount) => prev + amount);
                    return Text(
                      'תשלום שנתי ${totalConfirmedPayments.toStringAsFixed(2)}/${widget.apartment.yearlyPaymentAmount.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 25),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  // Display a loading spinner or any other placeholder widget while the data is being loaded
                  return CircularProgressIndicator();
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Check if Yearly payment amount is not 0
              if (widget.apartment.yearlyPaymentAmount == 0) {
                // show dialog with error message נא לעדכן פרטי דירה
                ScaffoldMessenger.of(context).showSnackBar(
                  ErrorMessageWidget.create(message: 'נא לעדכן פרטי דירה'),
                );

                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => EditApartmentScreen(
                      apartment: widget.apartment,
                      onApartmentUpdated: (updatedApartment) {
                        widget.onApartmentUpdated(updatedApartment);
                      },
                    ),
                  ),
                )
                    .then((updatedApartment) {
                  if (updatedApartment != null &&
                      updatedApartment.yearlyPaymentAmount > 0) {
                    // Use showDialog to display the IncomeReportScreen as a popup
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // Wrap the IncomeReportScreen with a Dialog for proper display
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20.0), // Circular edges
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.50,
                            child: IncomeReportScreen(
                                apartment: widget.apartment,
                                onPaymentReported: widget.onPaymentReported),
                          ),
                        );
                      },
                    ).then((_) => widget.onPaymentReported(updatedApartment));
                  } else {
                    //show dialog with error message "על מנת לדווח תשלום עליך להזין סכום שנתי"
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ErrorMessageWidget.create(
                          message: 'על מנת לדווח תשלום עליך להזין סכום שנתי',
                        );
                      },
                    );
                    // then navigator.pop
                    Navigator.of(context).pop();
                  }
                });
              } else {
                // Use showDialog to display the IncomeReportScreen as a popup
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // Wrap the IncomeReportScreen with a Dialog for proper display
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20.0), // Circular edges
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: IncomeReportScreen(
                            apartment: widget.apartment,
                            onPaymentReported: widget.onPaymentReported),
                      ),
                    );
                  },
                ).then((_) => widget.onPaymentReported(widget.apartment));
              }
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
      onTap: () {
        // Navigate to the EditApartmentScreen with the current apartment
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditApartmentScreen(
              apartment: widget.apartment,
              onApartmentUpdated: (updatedApartment) {
                widget.onApartmentUpdated(updatedApartment);
              },
            ),
          ),
        );
      },
    );
  }
}

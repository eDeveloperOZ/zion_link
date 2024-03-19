import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zion_link/shared/widgets/error_message_widget.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/services/crud/building_service.dart';
import 'package:zion_link/features/payments/income_report_screen.dart';
import 'package:zion_link/features/apartments/edit_apartment_screen.dart';
import 'package:zion_link/features/payments/attendant_payments_view.dart';

class ApartmentRow extends StatelessWidget {
  final Apartment apartment;
  final Function(Apartment) onPaymentReported;
  final VoidCallback onTap;
  final Function(Apartment) onApartmentUpdated;

  const ApartmentRow(
      {Key? key,
      required this.apartment,
      required this.onTap,
      required this.onPaymentReported,
      required this.onApartmentUpdated})
      : super(key: key);

  void _showPayments(BuildContext context, Building building) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: AttendantPaymentsView(
                      building: building, payments: apartment.payments)));
        });
  }

  @override
  Widget build(BuildContext context) {
    final paymentsMadeAndConfirmed = apartment.payments
        .where((payment) => payment.isConfirmed)
        .fold(0.0, (prev, payment) => prev + payment.amount);

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
            child: GestureDetector(
              onTap: () async {
                BuildingService buildingService = BuildingService();
                Building building =
                    await buildingService.getBuildingById(apartment.buildingId);
                _showPayments(context, building);
              },
              child: Text(
                  ' תשלום שנתי ${paymentsMadeAndConfirmed.toInt()}/${apartment.yearlyPaymentAmount.toInt()}',
                  style: TextStyle(fontSize: 25)),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Check if Yearly payment amount is not 0
              if (apartment.yearlyPaymentAmount == 0) {
                // show dialog with error message נא לעדכן פרטי דירה
                ScaffoldMessenger.of(context).showSnackBar(
                  ErrorMessageWidget.create(message: 'נא לעדכן פרטי דירה'),
                );

                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => EditApartmentScreen(
                      apartment: apartment,
                      onApartmentUpdated: (updatedApartment) {
                        onApartmentUpdated(updatedApartment);
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
                                apartment: apartment,
                                onPaymentReported: onPaymentReported),
                          ),
                        );
                      },
                    ).then((_) => onPaymentReported(updatedApartment));
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
                            apartment: apartment,
                            onPaymentReported: onPaymentReported),
                      ),
                    );
                  },
                ).then((_) => onPaymentReported(apartment));
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
              apartment: apartment,
              onApartmentUpdated: (updatedApartment) {
                onApartmentUpdated(updatedApartment);
              },
            ),
          ),
        );
      },
    );
  }
}

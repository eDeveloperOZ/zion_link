import 'package:flutter/material.dart';
import 'package:tachles/core/models/building.dart';
import 'package:tachles/core/models/apartment.dart';
import 'package:tachles/core/models/payment.dart'; // Import Payment model
import 'package:tachles/core/services/crud/apartment_service.dart';
import 'package:tachles/core/services/crud/payment_service.dart'; // Assuming this service exists
import 'package:tachles/features/receipts_and_reports/receipt_view.dart'; // Import ReceiptView
import 'package:intl/intl.dart';

class ReceiptGeneratorButton extends StatelessWidget {
  final Building building;
  final ApartmentService _apartmentService = ApartmentService();
  final PaymentService _paymentService =
      PaymentService(); // Assuming this service exists

  ReceiptGeneratorButton({
    Key? key,
    required this.building,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showApartmentSelection(context),
      child: Text('צור קבלה'),
    );
  }

  void _showApartmentSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('בחר דירה'),
          content: FutureBuilder<List<Apartment>>(
            future: _apartmentService.readAllApartmentsForBuilding(building.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                List<Apartment> apartments = snapshot.data!;
                return Container(
                  height: 200, // Set a fixed height for the list
                  width: double.maxFinite, // Set the width to match the dialog
                  child: ListView.builder(
                    itemCount: apartments.length,
                    itemBuilder: (context, index) {
                      Apartment apartment = apartments[index];
                      return ListTile(
                        title:
                            Text('${apartment.number} - ${apartment.tenantId}'),
                        onTap: () {
                          Navigator.of(context).pop(); // Close the dialog
                          _showPaymentSelection(context, apartment);
                        },
                      );
                    },
                  ),
                );
              } else {
                return Text('No apartments found');
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('סגור'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPaymentSelection(BuildContext context, Apartment apartment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('בחר תשלום'),
          content: FutureBuilder<List<Payment>>(
            future: _paymentService.readAllPaymentsForApartment(apartment.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                List<Payment> payments = snapshot.data!;
                return Container(
                  height: 200, // Set a fixed height for the list
                  width: double.maxFinite, // Set the width to match the dialog
                  child: ListView.builder(
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      Payment payment = payments[index];
                      return ListTile(
                        title: Text(
                          '${DateFormat('MMMM', 'he').format(DateTime.parse(payment.periodCoverageStart))} - ${payment.amount.toStringAsFixed(2)}₪',
                        ),
                        onTap: () {
                          Navigator.of(context).pop(); // Close the dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ReceiptView(
                                payment: payment,
                                tenantName: apartment.tenantId,
                                buildingAddress: building.address,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              } else {
                return Text('No payments found');
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('סגור'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

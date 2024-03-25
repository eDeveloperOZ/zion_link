import 'package:flutter/material.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/models/payment.dart'; // Import Payment model
import 'package:zion_link/core/services/crud/apartment_service.dart';
import 'package:zion_link/core/services/crud/payment_service.dart'; // Assuming this service exists
import 'package:zion_link/features/payments/receipt_view.dart'; // Import ReceiptView
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
        Apartment? _selectedApartment;
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
                return DropdownButton<Apartment>(
                  isExpanded: true,
                  value: _selectedApartment,
                  hint: Text('בחר דירה'),
                  onChanged: (Apartment? apartment) {
                    _selectedApartment = apartment;
                    if (apartment != null) {
                      _showPaymentSelection(context, apartment);
                    }
                  },
                  items: apartments.map((apartment) {
                    return DropdownMenuItem<Apartment>(
                      value: apartment,
                      child: Text(
                          '${apartment.number} - ${apartment.attendantName}'),
                    );
                  }).toList(),
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
        Payment? _selectedPayment;
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
                return DropdownButton<Payment>(
                  isExpanded: true,
                  value: _selectedPayment,
                  hint: Text('בחר תשלום'),
                  onChanged: (Payment? payment) {
                    Navigator.of(context).pop(); // Close the dialog
                    if (payment != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ReceiptView(
                            payment: payment,
                            attendantName: apartment.attendantName,
                            buildingAddress: building.address,
                          ),
                        ),
                      );
                    }
                  },
                  items: payments.map((payment) {
                    return DropdownMenuItem<Payment>(
                      value: payment,
                      child: Text(
                          '${DateFormat('MMMM', 'he').format(DateTime.parse(payment.periodCoverageStart))} - ${payment.amount}₪'),
                    );
                  }).toList(),
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

import 'package:flutter/material.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/models/payment.dart';
import 'package:zion_link/features/payments/receipt_view.dart';
import 'package:zion_link/core/services/crud/apartment_service.dart';

/// A widget that displays the details of a receipt for a specific building.
///
/// This screen takes a [Building] object as a parameter and displays its details,
/// including the apartments and their payments. Clicking on a payment will display
/// the receipt details in a dialog.
class ReceiptDetailsScreen extends StatelessWidget {
  final Building building;
  final _apartmentService = ApartmentService();

  ReceiptDetailsScreen({
    Key? key,
    required this.building,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('פרטי קבלה'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Apartment>>(
          future: _apartmentService.getAllApartmentsForBuilding(building.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              List<Apartment> apartments = snapshot.data!;
              return ListView.builder(
                itemCount: apartments.length,
                itemBuilder: (context, apartmentIndex) {
                  Apartment apartment = apartments[apartmentIndex];
                  return ExpansionTile(
                    title: Text('הדירה של ${apartment.attendantName}'),
                    children: apartment.payments.map((payment) {
                      return ListTile(
                        title: Text('סכום: ${payment.amount}'),
                        onTap: () => _showReceiptDetails(context, payment,
                            apartment.attendantName, building.address),
                      );
                    }).toList(),
                  );
                },
              );
            } else {
              return Center(child: Text('No data'));
            }
          },
        ),
      ),
    );
  }

  /// Shows the receipt details in a dialog instead of navigating to a new screen.
  void _showReceiptDetails(BuildContext context, Payment payment,
      String attendantName, String buildingAddress) {
    showDialog(
      context: context,
      builder: (BuildContext context) => ReceiptView(
        payment: payment,
        attendantName: attendantName,
        buildingAddress: buildingAddress,
      ),
    );
  }
}

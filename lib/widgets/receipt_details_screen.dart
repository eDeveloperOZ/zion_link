import 'package:flutter/material.dart';
import '../models/building.dart';
import '../models/apartment.dart'; // Assuming you have this model
import '../models/payment.dart'; // Assuming you have this model
import '../views/receipt_view.dart'; // Assuming you have this screen

/// A widget that displays the details of a receipt for a specific building.
///
/// This screen takes a [Building] object as a parameter and displays its details,
/// including the apartments and their payments. Clicking on a payment will display
/// the receipt details in a dialog.
class ReceiptDetailsScreen extends StatelessWidget {
  final Building building;

  const ReceiptDetailsScreen({
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
        child: ListView.builder(
          itemCount: building.apartments.length,
          itemBuilder: (context, apartmentIndex) {
            Apartment apartment = building.apartments[apartmentIndex];
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

import 'package:flutter/material.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/models/payment.dart';
import 'package:zion_link/features/receipts_and_reports/receipt_view.dart';
import 'package:zion_link/core/services/crud/apartment_service.dart';
import 'package:zion_link/core/services/crud/payment_service.dart';

class ReceiptDetailsScreen extends StatefulWidget {
  final Building building;

  ReceiptDetailsScreen({
    Key? key,
    required this.building,
  }) : super(key: key);

  @override
  _ReceiptDetailsScreenState createState() => _ReceiptDetailsScreenState();
}

class _ReceiptDetailsScreenState extends State<ReceiptDetailsScreen> {
  final _apartmentService = ApartmentService();
  final _paymentService = PaymentService();

  Apartment? _selectedApartment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('פרטי קבלה'),
      ),
      body: Column(
        children: [
          FutureBuilder<List<Apartment>>(
            future: _apartmentService
                .readAllApartmentsForBuilding(widget.building.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                List<Apartment> apartments = snapshot.data!;
                return DropdownButton<Apartment>(
                  value: _selectedApartment,
                  hint: Text('בחר דירה'),
                  onChanged: (Apartment? apartment) {
                    setState(() {
                      _selectedApartment = apartment;
                    });
                  },
                  items: apartments.map((apartment) {
                    return DropdownMenuItem<Apartment>(
                      value: apartment,
                      child:
                          Text('${apartment.number} - ${apartment.tenantId}'),
                    );
                  }).toList(),
                );
              } else {
                return Text('No apartments found');
              }
            },
          ),
          if (_selectedApartment != null)
            Expanded(
              child: FutureBuilder<List<Payment>>(
                future: _paymentService
                    .readAllPaymentsForApartment(_selectedApartment!.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    List<Payment> payments = snapshot.data!;
                    return ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        Payment payment = payments[index];
                        return ListTile(
                          title: Text('סכום: ${payment.amount}'),
                          onTap: () => _showReceiptDetails(
                              context,
                              payment,
                              _selectedApartment!.tenantId,
                              widget.building.address),
                        );
                      },
                    );
                  } else {
                    return Text('No payments found');
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showReceiptDetails(BuildContext context, Payment payment,
      String tenantName, String buildingAddress) {
    showDialog(
      context: context,
      builder: (BuildContext context) => ReceiptView(
        payment: payment,
        tenantName: tenantName,
        buildingAddress: buildingAddress,
      ),
    );
  }
}

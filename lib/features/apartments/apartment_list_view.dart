import 'package:flutter/material.dart';
import 'package:zion_link/core/models/apartment.dart';

class ApartmentListView extends StatelessWidget {
  final List<Apartment> apartments;

  ApartmentListView({required this.apartments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apartment Listings'),
      ),
      body: ListView.builder(
        itemCount: apartments.length,
        itemBuilder: (context, index) {
          final apartment = apartments[index];
          return ListTile(
            title: Text(apartment.attendantName),
            subtitle: Text(apartment.yearlyPaymentAmount.toString()),
            onTap: () {
              // Navigate to apartment details page
            },
          );
        },
      ),
    );
  }
}

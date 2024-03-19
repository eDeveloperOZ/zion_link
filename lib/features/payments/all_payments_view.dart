import 'package:flutter/material.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/services/crud/apartment_service.dart';

class AllPaymentsView extends StatefulWidget {
  final Building building;

  const AllPaymentsView({Key? key, required this.building}) : super(key: key);

  @override
  _AllPaymentsViewState createState() => _AllPaymentsViewState();
}

class _AllPaymentsViewState extends State<AllPaymentsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.manage_accounts, size: 24),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return BuildingPaymentsView(building: widget.building);
              },
            );
          },
        ),
        Text('כל התשלומים'),
      ],
    );
  }
}

class BuildingPaymentsView extends StatefulWidget {
  final Building building;

  const BuildingPaymentsView({Key? key, required this.building})
      : super(key: key);

  @override
  _BuildingPaymentsViewState createState() => _BuildingPaymentsViewState();
}

class _BuildingPaymentsViewState extends State<BuildingPaymentsView> {
  String? selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    ApartmentService apartmentService = ApartmentService();
    return FutureBuilder(
      future: apartmentService.getAllApartmentsForBuilding(widget.building.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator while waiting for data
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Apartment> apartments = snapshot.data as List<Apartment>;
          return ListView.builder(
            itemCount: apartments.length,
            itemBuilder: (context, index) {
              final apartment = apartments[index];
              return ListTile(
                title: Text(apartment.attendantName),
                subtitle: Text('Apartment ID: ${apartment.id}'),
                onTap: () {
                  // Handle tap if necessary
                },
              );
            },
          );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../models/building.dart'; // Import the Building model

class BalanceReportView extends StatelessWidget {
  final Building building; // Add a final Building field

  const BalanceReportView({Key? key, required this.building})
      : super(key: key); // Update constructor to accept a Building object

  @override
  Widget build(BuildContext context) {
    // Use the building object as needed, for example, to display building information
    return Scaffold(
      appBar: AppBar(
        title: Text(building.name), // Example usage of the building object
      ),
      body: Container(
          // Your widget code that uses the building object
          ),
    );
  }
}

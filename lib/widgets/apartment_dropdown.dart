import 'package:flutter/material.dart';
import '../models/apartment.dart';

class ApartmentDropdown extends StatelessWidget {
  final List<Apartment> apartments;
  final String selectedApartmentId;
  final Function(String?) onApartmentChanged;

  const ApartmentDropdown({
    Key? key,
    required this.apartments,
    required this.selectedApartmentId,
    required this.onApartmentChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedApartmentId.isNotEmpty
          ? apartments
              .firstWhere((apartment) => apartment.id == selectedApartmentId)
              .attendantName
          : null,
      onChanged: onApartmentChanged,
      hint: Text("בחר דייר"),
      items: apartments.map<DropdownMenuItem<String>>((Apartment apartment) {
        return DropdownMenuItem<String>(
          value: apartment.attendantName,
          child: Text(apartment.attendantName),
        );
      }).toList(),
    );
  }
}

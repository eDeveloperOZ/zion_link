import 'package:flutter/material.dart';
import 'package:zion_link/core/models/apartment.dart';

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
    // Check if the selectedApartmentId exists in the list of apartments
    bool isValidId =
        apartments.any((apartment) => apartment.id == selectedApartmentId);

    return DropdownButton<String>(
      value: isValidId ? selectedApartmentId : null,
      onChanged: onApartmentChanged,
      hint: Text("בחר דייר"),
      items: apartments.map<DropdownMenuItem<String>>((Apartment apartment) {
        String displayText =
            "דירה ${apartment.number} - ${apartment.tenantId.isNotEmpty ? apartment.tenantId : 'מי גר פה?'}";
        return DropdownMenuItem<String>(
          value: apartment.id,
          child: Text(displayText),
        );
      }).toList(),
    );
  }
}

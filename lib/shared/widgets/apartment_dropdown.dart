import 'package:flutter/material.dart';
import 'package:tachles/core/models/apartment.dart';
import 'package:tachles/core/models/user.dart';
import 'package:tachles/core/services/crud/apartment_service.dart';
import 'package:tachles/core/services/crud/user_service.dart';

class ApartmentDropdown extends StatefulWidget {
  final String? selectedApartmentId;
  final String buildingId;
  final Function(String?) onApartmentChanged;

  const ApartmentDropdown({
    Key? key,
    required this.selectedApartmentId,
    required this.buildingId,
    required this.onApartmentChanged,
  }) : super(key: key);

  @override
  _ApartmentDropdownState createState() => _ApartmentDropdownState();
}

class _ApartmentDropdownState extends State<ApartmentDropdown> {
  final UserService _userService = UserService();
  late Future<List<Apartment>> apartmentsFuture;
  late Future<List<User>> tenantsFuture;
  late Future<List<User>> ownersFuture;

  @override
  void initState() {
    super.initState();
    apartmentsFuture =
        ApartmentService().readAllApartmentsForBuilding(widget.buildingId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Apartment>>(
      future: apartmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Assuming data is now available
          List<Apartment> apartments = snapshot.data ?? [];
          // Check if the selectedApartmentId exists in the list of apartments
          bool isValidId = apartments
              .any((apartment) => apartment.id == widget.selectedApartmentId);

          return Center(
            child: DropdownButton<String>(
              value: isValidId ? widget.selectedApartmentId : null,
              onChanged: widget.onApartmentChanged,
              hint: Text("בחר דייר"),
              items: apartments
                  .map<DropdownMenuItem<String>>((Apartment apartment) {
                String displayText = 'דירה ${apartment.number} - ריקה';
                if (apartment.tenantId.isNotEmpty) {
                  _userService
                      .getUserById(apartment.tenantId)
                      .then((User? tenant) {
                    displayText =
                        "דירה ${apartment.number} - ${tenant?.firstName ?? 'מי גר פה?'}";
                  });
                } else if (apartment.ownerId.isNotEmpty) {
                  _userService
                      .getUserById(apartment.ownerId)
                      .then((User? owner) {
                    displayText =
                        "דירה ${apartment.number} - ${owner?.firstName ?? 'מי גר פה?'} (בעלים)";
                  });
                }
                return DropdownMenuItem<String>(
                  value: apartment.id,
                  child: FutureBuilder<User?>(
                    future: _userService.getUserById(apartment.tenantId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('טוען...');
                      } else if (snapshot.hasError) {
                        return Text('אחרים: ${snapshot.error}');
                      } else {
                        User? user = snapshot.data;
                        String displayText = user != null
                            ? "דירה ${apartment.number} - ${user.firstName}"
                            : 'מי גר פה?';
                        return Text(displayText);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}

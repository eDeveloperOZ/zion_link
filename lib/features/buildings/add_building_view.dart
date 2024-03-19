import 'package:flutter/material.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/services/crud/building_service.dart';
import 'package:zion_link/core/services/crud/apartment_service.dart';

class AddBuildingView extends StatelessWidget {
  final Function addBuildingCallback;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController numberOfApartmentsController =
      TextEditingController(); // Controller for number of apartments

  AddBuildingView({required this.addBuildingCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('הוסף בניין'),
      ),
      body: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'שם הבניין'),
          ),
          TextField(
            controller: addressController,
            decoration: InputDecoration(labelText: 'כתובת'),
          ),
          TextField(
            controller:
                numberOfApartmentsController, // Use the new controller here
            decoration: InputDecoration(labelText: 'מספר דירות'),
            keyboardType: TextInputType.number,
          ),
          ElevatedButton(
            onPressed: () async {
              // Create a new building object without apartments
              final newBuilding = Building(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                address: addressController.text,
              );

              // Use BuildingService to add the new building
              await BuildingService().addBuilding(newBuilding);

              // After the building is created, generate the apartments
              final int numberOfApartments =
                  int.tryParse(numberOfApartmentsController.text) ?? 0;
              List<Apartment> apartments =
                  List.generate(numberOfApartments, (index) {
                return Apartment(
                  id: DateTime.now().millisecondsSinceEpoch.toString() +
                      "_$index",
                  buildingId:
                      newBuilding.id, // Assign the newly created building's ID
                  number: "${index + 1}",
                  ownerName: "",
                  attendantName: "",
                  yearlyPaymentAmount: 0,
                  payments: [],
                );
              });

              for (var apartment in apartments) {
                await ApartmentService().addApartment(apartment);
              }

              // Callback and navigation remain the same
              addBuildingCallback(newBuilding);
              Navigator.pop(context, true);
            },
            child: Text('הוסף'),
          ),
        ],
      ),
    );
  }
}

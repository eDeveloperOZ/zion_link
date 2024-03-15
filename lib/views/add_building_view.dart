import 'package:flutter/material.dart';
import '../models/building.dart';
import '../services/building_service.dart';

class AddBuildingView extends StatelessWidget {
  final Function addBuildingCallback;
  final String userId;

  AddBuildingView({required this.addBuildingCallback, required this.userId});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final BuildingService buildingService = BuildingService();

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
          ElevatedButton(
            onPressed: () async {
              final newBuilding = Building(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: userId,
                name: nameController.text,
                address: addressController.text,
                apartments: [],
                expenses: [],
              );
              addBuildingCallback(newBuilding);

              // Use BuildingService to add the new building
              await buildingService.updateBuilding(newBuilding);

              Navigator.pop(context, true);
            },
            child: Text('הוסף'),
          ),
        ],
      ),
    );
  }
}

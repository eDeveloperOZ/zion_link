import 'package:flutter/material.dart';
import '../models/building.dart';
import '../utils/file_storage.dart';

class AddBuildingView extends StatelessWidget {
  final Function addBuildingCallback;

  AddBuildingView({required this.addBuildingCallback});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

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
                name: nameController.text,
                address: addressController.text,
                apartments: [],
                expenses: [],
              );
              addBuildingCallback(newBuilding);

              // Read existing buildings, add the new one, then save
              List existingBuildings = await LocalStorage.readBuildings();
              existingBuildings.add(newBuilding.toJson());
              await LocalStorage.writeBuildings(existingBuildings);

              Navigator.pop(context, true);
            },
            child: Text('הוסף'),
          ),
        ],
      ),
    );
  }
}

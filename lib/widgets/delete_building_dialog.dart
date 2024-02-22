// lib/widgets/delete_building_dialog.dart
import 'package:flutter/material.dart';
import '../utils/file_storage.dart';

class DeleteBuildingDialog extends StatelessWidget {
  final String buildingName;
  final Function onBuildingDeleted;

  const DeleteBuildingDialog({
    Key? key,
    required this.buildingName,
    required this.onBuildingDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.delete_sharp, size: 24),
          onPressed: () async {
            bool shouldDelete =
                await showDeleteBuildingDialog(context, buildingName);
            if (shouldDelete) {
              List<dynamic> buildings = await LocalStorage.readBuildings();
              buildings.removeWhere((item) => item['name'] == buildingName);
              await LocalStorage.writeBuildings(buildings);
              Navigator.pop(context); // Go back to dashboard
              onBuildingDeleted();
            }
          },
        ),
        Text('מחק בניין'), // Text under the icon
      ],
    );
  }
}

Future<bool> showDeleteBuildingDialog(
    BuildContext context, String buildingName) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('מחיקת בניין'),
        content: Text('האם אתה בטוח שברצונך למחוק את הבניין?'),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            child: Text('X', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style:
                TextButton.styleFrom(backgroundColor: Colors.lightGreenAccent),
            child: Text('V', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
  return shouldDelete ?? false;
}

import 'package:flutter/material.dart';
import 'confirm_dialog_widget.dart'; // Import the ConfirmDialog widget
import '../services/building_service.dart'; // Import BuildingService

class DeleteBuildingDialog extends StatelessWidget {
  final String buildingID;
  final Function onBuildingDeleted;

  const DeleteBuildingDialog({
    Key? key,
    required this.buildingID,
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
            bool? shouldDelete = await ConfirmDialog.display(
              context,
              message: 'האם אתה בטוח שברצונך למחוק את הבניין?',
              onConfirm: (bool result) {
                return result; // This will be passed as the result of showDialog
              },
            );
            if (shouldDelete == true) {
              await BuildingService().deleteBuilding(buildingID);
              onBuildingDeleted(); // Invoke the callback to handle post-deletion logic
            }
          },
        ),
        Text('מחק בניין'), // Text under the icon
      ],
    );
  }
}

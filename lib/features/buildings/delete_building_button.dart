import 'package:flutter/material.dart';
import 'package:zion_link/shared/widgets/confirm_dialog_widget.dart';
import 'package:zion_link/core/services/crud/building_service.dart';

class DeleteBuildingButton extends StatelessWidget {
  final String buildingID;

  const DeleteBuildingButton({
    Key? key,
    required this.buildingID,
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
              requiredPassword: true,
              onConfirm: (bool result) {
                return result; // This will be passed as the result of showDialog
              },
            );
            if (shouldDelete == true) {
              BuildingService buildingService = BuildingService();
              await buildingService.deleteBuilding(buildingID);
              // Pop back to DashboardScreen with a result indicating a building was deleted
              Navigator.pop(
                  context, true); // true indicates a building was deleted
            }
          },
        ),
        Text('מחק בניין'),
      ],
    );
  }
}

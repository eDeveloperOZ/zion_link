import 'package:flutter/material.dart';
import 'package:zion_link/shared/widgets/confirm_dialog_widget.dart';

class DeleteBuildingButton extends StatelessWidget {
  final String buildingID;
  final Function onBuildingDeleted;

  const DeleteBuildingButton({
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
              requiredPassword: true,
              onConfirm: (bool result) {
                return result; // This will be passed as the result of showDialog
              },
            );
            if (shouldDelete == true) {
              onBuildingDeleted(); // Invoke the callback to handle post-deletion logic
            }
          },
        ),
        Text('מחק בניין'), // Text under the icon
      ],
    );
  }
}

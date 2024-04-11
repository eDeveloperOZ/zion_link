import 'package:flutter/material.dart';
import 'package:tachles/shared/widgets/confirm_dialog_widget.dart';
import 'package:tachles/core/services/crud/building_service.dart';
import 'package:tachles/shared/widgets/success_message_widget.dart';
import 'package:tachles/shared/widgets/error_message_widget.dart';

class DeleteBuildingButton extends StatelessWidget {
  final String buildingID;

  const DeleteBuildingButton({
    Key? key,
    required this.buildingID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          icon: Icon(Icons.delete_sharp, size: 24),
          onPressed: () async {
            bool? shouldDelete = await ConfirmDialogWidget.display(
              context,
              message: 'האם אתה בטוח שברצונך למחוק את הבניין?',
              requiredPassword: true,
              onConfirm: (bool result) {
                return result; // This will be passed as the result of showDialog
              },
            );
            if (shouldDelete == true) {
              try {
                BuildingService buildingService = BuildingService();
                await buildingService.deleteBuilding(buildingID);
                // Pop back to DashboardScreen with a result indicating a building was deleted
                ScaffoldMessenger.of(context).showSnackBar(
                  SuccessMessageWidget.create(message: 'הבניין נמחק בהצלחה'),
                );
                Navigator.pop(context, true);
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  ErrorMessageWidget.create(
                    message: 'שגיאה במחיקת הבניין: $error',
                  ),
                );
                return;
              }
              // true indicates a building was deleted
            }
          },
        ),
        Text(' מחק בניין'),
      ],
    );
  }
}

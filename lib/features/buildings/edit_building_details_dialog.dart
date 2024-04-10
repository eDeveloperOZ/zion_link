// lib/widgets/edit_building_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:tachles/core/models/building.dart';

class EditBuildingDetailsDialog extends StatelessWidget {
  final Building building;
  final Function(String) onNameChanged;

  const EditBuildingDetailsDialog({
    Key? key,
    required this.building,
    required this.onNameChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          icon: Icon(Icons.home, size: 24),
          onPressed: () async {
            final newName = await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                String tempName = building.name;
                return AlertDialog(
                  title: Text(
                    ' עריכת פרטי בניין',
                    textAlign: TextAlign.center,
                  ),
                  content: TextField(
                    onChanged: (value) {
                      tempName = value;
                    },
                    controller: TextEditingController(text: building.name),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(tempName),
                      child: Center(child: Text('שמור')),
                    ),
                  ],
                );
              },
            );

            if (newName != null) {
              onNameChanged(newName);
            }
          },
        ),
        Text('עריכת פרטי בניין'), // Added text under the icon
      ],
    );
  }
}

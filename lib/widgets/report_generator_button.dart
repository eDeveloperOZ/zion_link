import 'package:flutter/material.dart';
import 'report_generator_dialog.dart';
import '../models/building.dart';

class ReportGeneratorButton extends StatelessWidget {
  final Building building;
  ReportGeneratorButton({Key? key, required this.building}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.bar_chart, size: 24),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ReportGeneratorDialog(building: building);
              },
            );
          },
        ),
        Text('צור דוח'), // Text under the icon
      ],
    ); // Add a semicolon here
  }
}

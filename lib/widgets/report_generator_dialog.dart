import 'package:flutter/material.dart';

class ReportGeneratorDialog extends StatelessWidget {
  const ReportGeneratorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('צור דוח')),
      content: Text('כאן יוצג הדוח'),
      actions: [
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('סגור'),
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String message;
  final Function(bool) onConfirm;

  const ConfirmDialog({
    Key? key,
    this.message = "האם אתה בטוח?",
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(message),
      actions: <Widget>[
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => onConfirm(true),
                child: const Text('כן'),
              ),
              TextButton(
                onPressed: () => onConfirm(false),
                child: const Text('לא'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Future<bool?> display(
    BuildContext context, {
    required Function(bool) onConfirm,
    String message = "האם אתה בטוח?",
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return ConfirmDialog(
          message: message,
          onConfirm: (bool result) {
            Navigator.of(context).pop(result); // Pop with result
          },
        );
      },
    );
  }
}

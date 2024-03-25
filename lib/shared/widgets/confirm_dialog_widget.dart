import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String message;
  final bool requiredPassword;
  final Function(bool) onConfirm;

  const ConfirmDialog({
    Key? key,
    this.message = "האם אתה בטוח?",
    required this.onConfirm,
    this.requiredPassword = false,
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
                onPressed: () => requiredPassword
                    ? _promptPassword(context)
                    : onConfirm(true),
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

  void _promptPassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController passwordController = TextEditingController();
        return AlertDialog(
          title: const Text('הזן סיסמא'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'סיסמא',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (passwordController.text == '2020') {
                  Navigator.of(context).pop(); // Close the password dialog
                  onConfirm(true);
                } else {
                  Navigator.of(context).pop(); // Close the password dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('סיסמא שגויה')),
                  );
                  onConfirm(false);
                }
              },
              child: const Center(
                child: Text('אשר',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                    )),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> display(
    BuildContext context, {
    required Function(bool) onConfirm,
    String message = "האם אתה בטוח?",
    bool requiredPassword = false,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return ConfirmDialog(
          message: message,
          onConfirm: (bool result) {
            Navigator.of(context).pop(result); // Pop with result
          },
          requiredPassword: requiredPassword,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

/// A reusable delete button widget that optionally requires a password confirmation.
///
/// This widget is designed to be used across the application to provide a consistent
/// delete button. It takes a callback function [onDelete] which is executed when
/// the button is pressed. Optionally, it can require the user to input a password
/// before proceeding with the delete action.
///
/// Parameters:
/// - [onDelete]: A callback function that is called when the button is pressed.
/// - [requirePassword]: A boolean indicating whether a password is required to confirm the delete action.
///
/// Usage example:
/// ```dart
/// DeleteButton(
///   onDelete: () {
///     // Implement your delete functionality here
///   },
///   requirePassword: true, // Set to false or omit if password confirmation is not needed.
/// )
/// ```
class DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;
  final bool requirePassword;

  /// Creates a DeleteButton widget.
  ///
  /// The [onDelete] parameter must not be null and is required to perform the delete action.
  /// The [requirePassword] parameter indicates whether a password confirmation is required.
  const DeleteButton(
      {Key? key, required this.onDelete, this.requirePassword = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete, color: Colors.grey.shade700, size: 30),
      onPressed: () => requirePassword ? _promptPassword(context) : onDelete(),
      tooltip: 'מחק',
    );
  }

  /// Prompts the user to enter a password before proceeding with the delete action.
  ///
  /// If the password is correct, the [onDelete] callback is executed.
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
              hintText: 'סיסמא: 2020',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (passwordController.text == '2020') {
                  // Consider using a more secure password validation method.
                  Navigator.of(context).pop(); // Close the password dialog
                  onDelete();
                } else {
                  Navigator.of(context).pop(); // Close the password dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('סיסמא שגויה')),
                  );
                }
              },
              child: const Text('אשר'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ביטול'),
            ),
          ],
        );
      },
    );
  }
}

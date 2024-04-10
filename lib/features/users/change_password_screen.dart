import 'package:flutter/material.dart';
import 'package:tachles/core/services/sign_in_service.dart';
import 'package:tachles/shared/widgets/error_message_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final SignInService _signInService = SignInService();

  void _changePassword() async {
    final newPassword = _newPasswordController.text;
    final success = await _signInService.changePassword(newPassword);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('הסיסמא שונתה בהצלחה!'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(ErrorMessageWidget.create(
        message: 'הייתה לנו בעיה, הסיסמא יותר מ6 תווים? נסה שוב בבקשה',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}

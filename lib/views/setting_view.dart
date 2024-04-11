import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tachles/features/users/change_password_screen.dart';

import 'package:tachles/shared/widgets/notifier_widget.dart';

class SettingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('הגדרות'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('הגרסה הזו פועלת כעת באופן מקוון'),
            ElevatedButton(
              onPressed: () {
                // Here you can add functionality to direct the user to the online version
                // For example, opening a web page or redirecting to a different view in the app
                // Assuming you have a URL to the online version:
                const String onlineVersionUrl =
                    'https://your-online-version-link.com';
                launchUrl(Uri.parse(onlineVersionUrl));
              },
              child: Text('עבור לגרסה המקוונת'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen()),
                );
              },
              child: Text('שינוי סיסמה'),
            ),
          ],
        ),
      ),
    );
  }
}

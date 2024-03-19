import 'package:flutter/material.dart';
import 'package:zion_link/core/services/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('הגדרות'),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future:
              StorageService().getFilePath(), // This is your async operation
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // If the Future is complete and has no errors, display the result
                return Tooltip(
                  message: snapshot.data, // Use the data from the snapshot here
                  child: ElevatedButton(
                    onPressed: () {
                      final String? filePath = snapshot.data;
                      if (filePath != null) {
                        // Assuming LocalStorage().getFilePath() returns a path to a directory
                        // and using a method to open the directory
                        openDirectory(filePath);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('לא נמצא נתיב לפתיחה')),
                        );
                      }
                    },
                    child: Text('פתח מיקום קבצים'),
                  ),
                );
              }
            } else {
              // While the Future is not complete, show a loading spinner
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

Future<void> openDirectory(String filePath) async {
  final Uri uri = Uri.file(filePath);
  if (!await launchUrl(uri)) {
    throw 'Could not open $filePath';
  }
}

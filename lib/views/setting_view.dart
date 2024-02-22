import 'package:flutter/material.dart';
import '../utils/file_storage.dart';

class SettingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('הגדרות'),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: LocalStorage().getFilePath(), // This is your async operation
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
                      // Placeholder for opening file location
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

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget to display a document file.
///
/// Opens the file using the URL launcher if the file path is provided.
class DisplayDocumentWidget extends StatelessWidget {
  final String? filePath;

  const DisplayDocumentWidget({Key? key, this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: filePath != null,
      child: IconButton(
        icon: Icon(Icons.attach_file),
        onPressed: () async {
          final String formattedFilePath = 'file://$filePath';
          final Uri? fileUri = Uri.tryParse(formattedFilePath);

          if (fileUri != null && await canLaunchUrl(fileUri)) {
            await launchUrl(fileUri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cannot open the file')),
            );
          }
        },
      ),
    );
  }
}

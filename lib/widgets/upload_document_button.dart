import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadDocumentButton extends StatefulWidget {
  final Function(String?) onFilePicked;

  const UploadDocumentButton({Key? key, required this.onFilePicked})
      : super(key: key);

  @override
  _UploadDocumentButtonState createState() => _UploadDocumentButtonState();
}

class _UploadDocumentButtonState extends State<UploadDocumentButton> {
  String? filePath;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(Icons.upload_file),
      label: Text('העלאת מסמך'),
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles();
        if (result != null && result.files.single.path != null) {
          setState(() {
            filePath = result.files.single.path;
          });
          widget.onFilePicked(filePath);
        }
      },
    );
  }
}

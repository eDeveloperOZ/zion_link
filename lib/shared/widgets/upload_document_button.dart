import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:tachles/core/services/file_upload_service.dart';

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
          final File file = File(result.files.single.path!);
          final fileName = result.files.single.name;
          // Save the file using FileUploadService
          final savedFile = await FileUploadService.saveFile(fileName, file);
          setState(() {
            filePath = savedFile.path;
          });
          widget.onFilePicked(filePath);
        }
      },
    );
  }
}

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUploadService {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // Use a different folder for uploaded documents
    final uploadDirectory = Directory('${directory.path}/uploaded_documents');
    if (!await uploadDirectory.exists()) {
      await uploadDirectory.create(recursive: true);
    }
    return uploadDirectory.path;
  }

  static Future<File> saveFile(String fileName, File file) async {
    final path = await _localPath;
    final File newFile = File('$path/$fileName');
    return file.copy(newFile.path);
  }
}

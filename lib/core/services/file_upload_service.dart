import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

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

  /// Saves the given [content] to a file named [fileName] in the Downloads directory.
  ///
  /// This method creates a file with the specified [fileName] and writes the [content]
  /// to it. The file is saved in the Downloads directory of the machine.
  ///
  /// Returns a [Future<File>] that completes with the file containing the content.
  static Future<File> saveContentToFile(String fileName, String content) async {
    final directory =
        await getDownloadsDirectory(); // Get the Downloads directory
    if (directory == null) {
      throw FileSystemException("Downloads directory not found.");
    }
    final File file = File(
        '${directory.path}/$fileName'); // Create a file in the Downloads directory
    return file
        .writeAsString(content); // Write the content to the file and return it
  }
}

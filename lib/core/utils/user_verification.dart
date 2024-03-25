import 'dart:io';
import 'package:universal_io/io.dart';
import 'package:path/path.dart' as path;

class UserVerification {
  static final String _filePath =
      path.join(Directory.systemTemp.path, 'machine_id.txt');

  static Future<String?> _getMachineMACAddress() async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run('getmac', []);
        return result.stdout
            .toString()
            .split('\n')
            .firstWhere((line) => line.isNotEmpty, orElse: () => "")
            .split(' ')
            .first;
      } else if (Platform.isLinux || Platform.isMacOS) {
        final result = await Process.run('ifconfig', []);
        final regex = RegExp(r'ether ([0-9a-f:]+)');
        final match = regex.firstMatch(result.stdout.toString());
        return match?.group(1);
      }
    } catch (e) {
      print("Error obtaining MAC address: $e");
    }
    return null; // Ensure method always returns a value or null
  }

  static Future<bool> verifyMachine() async {
    final file = File(_filePath);
    print("The MAC address file is stored at: ${file.path}");
    final macAddress = await _getMachineMACAddress();
    if (macAddress == null) {
      print("Unable to obtain MAC address.");
      return false;
    }

    if (await file.exists()) {
      final storedMacAddress = await file.readAsString();
      if (storedMacAddress == macAddress) {
        print("Machine verified successfully.");
        return true;
      } else {
        print("Machine verification failed. MAC address does not match.");
        return false;
      }
    } else {
      await file.writeAsString(macAddress);
      print("Machine registered successfully.");
      return true;
    }
  }
}

import 'dart:developer' as developer;

class Logger {
  static void info(String message) {
    developer.log(message, name: 'INFO');
  }

  static void warning(String message) {
    developer.log(message, name: 'WARNING');
  }

  static void error(String message) {
    developer.log(message, name: 'ERROR');
  }
}

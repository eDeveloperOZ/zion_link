import 'dart:developer' as developer;
import 'package:sentry_flutter/sentry_flutter.dart' as Sentry;

class Logger {
  // ANSI color codes
  static const String _infoColor = '\x1B[34m'; // Blue
  static const String _warningColor = '\x1B[33m'; // Yellow
  static const String _errorColor = '\x1B[31m'; // Red
  static const String _criticalColor = '\x1B[35m'; // Magenta
  static const String _resetColor = '\x1B[0m'; // Reset

// Includes messages that provide a record of the normal operation of the system.
// For exmaple, logins, configuration changes, etc.
  static void info(String message) {
    _logWithColor(message, _infoColor, 'INFO');
  }

// Signifies potential issues that may lead to errors or unexpected behavior in the future if not addressed.
// For example, deprecated APIs, poor use of an API, 'guessed' data, etc.
  static void warning(String message) {
    _logWithColor(message, _warningColor, 'WARNING');
  }

// Indicates error conditions that impair some operation but are less severe than critical situations
// For example, messages that are execptions, caught and handled
  static void error(String message) {
    _logWithColor(message, _errorColor, 'ERROR');
  }

// Signifies critical conditions in the program that demand intervention to prevent system failure.
// For example, an unexpected exception, a severe error, etc.
  static void critical(String message) {
    _logWithColor(message, _criticalColor, 'CRITICAL');
    // TODO: Uncomment the following line to log to Sentry
    // log to Sentry
    // Sentry.captureException(e);
  }

// Used to notify the developer of a specific event that happened in the system and require imidiate attention.
// For example, a user has reached a certain threshold, a new user has registered, etc.
  static void notifyDev(String message) {
    // TODO: Uncomment the following line to log to Sentry
    // log to Sentry
    // Sentry.captureException(e);
    _logWithColor(message, _infoColor, 'NOTIFY');
  }

  static void _logWithColor(String message, String color, String name) {
    // Check if running in a web environment
    if (identical(0, 0.0)) {
      // For web, just use the regular log method as ANSI codes do not work
      developer.log(message, name: name);
    } else {
      // For terminal/console environments, prepend the color code and append the reset code
      print('$color$name: $message$_resetColor');
      if (name == 'CRITICAL' || name == 'ERROR') {
        // Print the stack trace
        print(StackTrace.current);
      }
    }
  }
}

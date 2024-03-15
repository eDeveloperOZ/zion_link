import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart'; // Import the Logger class

class SigninService {
  /// Attempts to sign in a user with the given [emailOrUsername] and [password].
  ///
  /// This method checks the Supabase database for a user with the matching
  /// credentials. If a user is found, it returns the user's details; otherwise,
  /// it returns null.
  ///
  /// Parameters:
  /// - [emailOrUsername]: The email or username of the user attempting to sign in.
  /// - [password]: The password of the user.
  ///
  /// Returns:
  /// - A [Future] that completes with a [User] if the credentials match an existing user,
  ///   or `null` if no matching user is found.
  static Future<List?> signIn(String emailOrUsername, int password) async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .or('email.eq.$emailOrUsername,username.eq.$emailOrUsername')
          .eq('password', password);

      return response as List?;
    } catch (error) {
      Logger.error('Error signing in: $error'); // Use Logger for error logging
      return null;
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tachles/core/utils/logger.dart';

class SignInService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<bool> signIn(String email, String password) async {
    var response;
    try {
      final response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);
      return response.user != null;
    } catch (e) {
      Logger.error("response: ${response}");
      Logger.error(e.toString());
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      final response = await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response.user != null;
    } catch (e) {
      Logger.error(e.toString());
      return false;
    }
  }
}

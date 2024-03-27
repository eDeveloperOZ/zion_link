import 'package:supabase_flutter/supabase_flutter.dart';

class SignInService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);
      return response.user != null;
    } catch (e) {
      print(e); // Consider using a logging package for better error handling
      return false;
    }
  }
}

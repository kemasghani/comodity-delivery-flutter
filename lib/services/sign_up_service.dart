import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Sign up a new user
  Future<UserModel?> signUpUser(String name, String address, String email, String password) async {
    try {
      // Sign up using Supabase Auth (email is stored in Auth)
      final response = await supabase.auth.signUp(email: email, password: password);

      if (response.user == null) return null;

      // Insert user data into 'users' table (without email)
      final userData = UserModel(
        id: response.user!.id,
        name: name,
        address: address,
      );

      await supabase.from('users').insert(userData.toJson());

      return userData;
    } catch (e) {
      print("Error signing up: $e");
      return null;
    }
  }
}

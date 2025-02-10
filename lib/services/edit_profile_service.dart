import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class EditProfileService {
  final supabase = Supabase.instance.client;

  Future<UserModel?> getUserProfile(String userId) async {
    final response = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single(); // Fetch only one user

    if (response == null) return null;

    return UserModel.fromJson(response);
  }

  Future<bool> updateUserProfile(
      String userId, Map<String, dynamic> updatedData) async {
    final response =
        await supabase.from('users').update(updatedData).eq('id', userId);

    return response.error == null; // Returns `true` if update is successful
  }
}

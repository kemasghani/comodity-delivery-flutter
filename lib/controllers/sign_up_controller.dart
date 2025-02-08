import '../services/sign_up_service.dart';
import '../models/user_model.dart';

class UserController {
  final SupabaseService _supabaseService = SupabaseService();

  Future<UserModel?> signUp(
      String name, String address, String email, String password) async {
    return await _supabaseService.signUpUser(name, address, email, password);
  }
}

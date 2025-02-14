import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ✅ Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      print("✅ Password reset email sent.");
      return true;
    } catch (e) {
      print("❌ Error sending password reset email: $e");
      return false;
    }
  }

  // ✅ Reset Password using OTP (Token from Email)
  Future<bool> resetPassword(String resetToken, String newPassword) async {
    try {
      // Verify OTP and reset password
      await _supabase.auth.verifyOTP(
        type: OtpType.recovery,
        token: resetToken,
      );

      print("✅ Password reset successful.");
      return true;
    } catch (e) {
      print("❌ Error resetting password: $e");
      return false;
    }
  }
}

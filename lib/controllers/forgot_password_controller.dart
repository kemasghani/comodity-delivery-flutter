import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../view/otp/otp_screen.dart';

class ForgotPasswordController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final box = GetStorage();
  var isLoading = false.obs;

  Future<void> sendOtp(String email) async {
    try {
      isLoading.value = true;

      // Request OTP from Supabase
      await supabase.auth.resetPasswordForEmail(email);

      // Since OTP is not returned, ask the user to check their email
      Get.snackbar(
        "Success",
        "OTP has been sent to your email",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // ✅ Store email for later verification
      box.write('otp_email', email);

      // Navigate to OTP screen
      Get.to(() => OtpScreen(email: email));
    } catch (error) {
      // ❌ Show error Snackbar
      Get.snackbar(
        "Error",
        "Failed to send OTP: $error",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}

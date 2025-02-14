import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../view/reset_password/reset_password_screen.dart'; // ✅ Import ResetPasswordScreen

class OtpController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final box = GetStorage();
  var isLoading = false.obs;
  final otpController = TextEditingController();

  Future<void> verifyOtp() async {
    try {
      isLoading.value = true;

      // Get stored email
      String? email = box.read('otp_email');
      if (email == null) {
        Get.snackbar(
          "Error",
          "Email not found, please request OTP again",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Get OTP from user input
      String otp = otpController.text.trim();

      // Verify OTP with Supabase
      await supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery, // For password reset
      );

      // ✅ Show success message
      Get.snackbar(
        "Success",
        "OTP verified successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // ✅ Navigate to Reset Password Screen
      Get.offNamed(ResetPasswordScreen.routeName, arguments: {'email': email});

    } catch (error) {
      // ❌ Show error message
      Get.snackbar(
        "Error",
        "Invalid OTP, please try again",
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

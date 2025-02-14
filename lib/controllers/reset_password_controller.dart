import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  var isLoading = false.obs;
  var isObscure = true.obs; // For password visibility toggle

  Future<void> resetPassword(String email) async {
    if (newPasswordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      Get.snackbar("Error", "All fields are required",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar("Error", "Passwords do not match",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // Call Supabase API to update password
      await supabase.auth
          .updateUser(UserAttributes(password: newPasswordController.text));

      Get.snackbar("Success", "Password updated successfully!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      // Navigate to login screen after reset
      Get.offAllNamed("/sign_in");
    } catch (error) {
      Get.snackbar("Error", "Failed to reset password",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/reset_password_controller.dart';

class ResetPasswordScreen extends StatelessWidget {
  static String routeName = "/reset_password"; // Define the route name

  ResetPasswordScreen({Key? key}) : super(key: key);

  final ResetPasswordController controller = Get.put(ResetPasswordController());

  @override
  Widget build(BuildContext context) {
    final String email = Get.arguments?['email'] ?? ''; // Extract email

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reset password for: $email",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Obx(() => TextField(
                  controller: controller.newPasswordController,
                  obscureText: controller.isObscure.value,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(controller.isObscure.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        controller.isObscure.toggle();
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 20),
            Obx(() => TextField(
                  controller: controller.confirmPasswordController,
                  obscureText: controller.isObscure.value,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(controller.isObscure.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        controller.isObscure.toggle();
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 30),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.resetPassword(email),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit"),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

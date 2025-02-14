import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/forgot_password_controller.dart';

class ForgotPassForm extends StatelessWidget {
  ForgotPassForm({super.key});

  final ForgotPasswordController forgotPasswordController =
      Get.put(ForgotPasswordController());
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter your email";
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                String email = emailController.text.trim();
                await forgotPasswordController.sendOtp(email);
              }
            },
            child: Obx(() => forgotPasswordController.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Send Reset Email")),
          ),
        ],
      ),
    );
  }
}

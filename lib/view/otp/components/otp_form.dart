import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/otp_controller.dart'; // Import OtpController
import '../../../constants.dart';

class OtpForm extends StatefulWidget {
  final String email; // Email parameter for OTP verification

  const OtpForm({super.key, required this.email});

  @override
  _OtpFormState createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());

  final OtpController otpController =
      Get.put(OtpController()); // Initialize OtpController

  @override
  void dispose() {
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void nextField(String value, int index) {
    if (value.length == 1 && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              6,
              (index) => SizedBox(
                width: 50,
                child: TextFormField(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  autofocus: index == 0,
                  obscureText: true,
                  style: const TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) => nextField(value, index),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              String otpCode = controllers.map((c) => c.text).join();

              if (otpCode.length == 6) {
                // Store OTP in Controller
                otpController.otpController.text = otpCode;

                // Call verifyOtp function
                otpController.verifyOtp();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter all 6 digits")),
                );
              }
            },
            child: const Text("Verify OTP"),
          ),
        ],
      ),
    );
  }
}

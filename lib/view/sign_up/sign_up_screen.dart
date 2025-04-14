import 'package:flutter/material.dart';
import '../../components/socal_card.dart';
import '../../constants.dart';
import 'components/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  static String routeName = "/sign_up";

  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text("Register Account", style: headingStyle),
                  const Text(
                    "Complete your details",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SignUpForm(), // SignUpForm now includes Name & Address
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

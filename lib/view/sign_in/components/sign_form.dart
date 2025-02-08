import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';
import '../../../helper/keyboard.dart';
import '../../../services/user_session.dart';
import '../../forgot_password/forgot_password_screen.dart';
import '../../login_success/login_success_screen.dart';

class SignForm extends StatefulWidget {
  const SignForm({super.key});

  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool remember = false;
  final List<String?> errors = [];
  final supabase = Supabase.instance.client;

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  Future<void> signIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        print("🔵 Attempting to sign in with email: $email");

        final response = await supabase.auth.signInWithPassword(
          email: email!,
          password: password!,
        );

        if (response.user != null) {
          print(
              "✅ Login successful! User ID: ${response.user!.id}, Email: ${response.user!.email}");

          // Save user session data
          await UserSession()
              .saveUserData(response.user!.id, response.user!.email ?? '');
          print("✅ User data saved to session.");

          // Fetch saved data to verify
          final savedUserId = await UserSession().getUserId();
          final savedUserEmail = await UserSession().getUserEmail();
          print(
              "🔍 Retrieved from session -> User ID: $savedUserId, Email: $savedUserEmail");

          KeyboardUtil.hideKeyboard(context);
          Navigator.pushReplacementNamed(context, LoginSuccessScreen.routeName);
        } else {
          print("❌ Login failed: User is null.");
          addError(error: "Login failed. Please check your credentials.");
        }
      } catch (e) {
        print("🔥 Login error: $e");
        addError(error: "Login failed. Please check your credentials.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) removeError(error: kEmailNullError);
              if (emailValidatorRegExp.hasMatch(value))
                removeError(error: kInvalidEmailError);
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kEmailNullError);
                return "";
              } else if (!emailValidatorRegExp.hasMatch(value)) {
                addError(error: kInvalidEmailError);
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            obscureText: true,
            onSaved: (newValue) => password = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) removeError(error: kPassNullError);
              if (value.length >= 8) removeError(error: kShortPassError);
            },
            validator: (value) {
              if (value!.isEmpty) {
                addError(error: kPassNullError);
                return "";
              } else if (value.length < 8) {
                addError(error: kShortPassError);
                return "";
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: "Password",
              hintText: "Enter your password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: remember,
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    remember = value ?? false;
                  });
                },
              ),
              const Text("Remember me"),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, ForgotPasswordScreen.routeName),
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          FormError(errors: errors), // Display authentication errors
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: signIn,
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }
}

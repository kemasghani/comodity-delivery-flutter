import 'package:flutter/material.dart';
import '../../../controllers/sign_up_controller.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final UserController _userController = UserController();

  String name = "";
  String email = "";
  String address = "";
  String password = "";
  String confirmPassword = "";

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = await _userController.signUp(name, address, email, password);

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign up successful! Welcome, \${user.name}")),
        );
        // Navigate to home or login screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign up failed. Try again.")),
        );
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
            decoration: InputDecoration(labelText: "Full Name"),
            onSaved: (value) => name = value!,
            validator: (value) =>
                value!.isEmpty ? "Please enter your name" : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(labelText: "Email"),
            onSaved: (value) => email = value!,
            validator: (value) =>
                value!.isEmpty ? "Please enter your email" : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(labelText: "Address"),
            onSaved: (value) => address = value!,
            validator: (value) =>
                value!.isEmpty ? "Please enter your address" : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(labelText: "Password"),
            obscureText: true,
            onSaved: (value) => password = value!,
            validator: (value) {
              if (value!.isEmpty) return "Please enter your password";
              if (value.length < 8)
                return "Password must be at least 8 characters";
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(labelText: "Confirm Password"),
            obscureText: true,
            onSaved: (value) => confirmPassword = value!,
            validator: (value) {
              if (value!.isEmpty) return "Please confirm your password";
              if (value != password) return "Passwords do not match";
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _signUp,
            child: Text("Sign Up"),
          ),
        ],
      ),
    );
  }
}

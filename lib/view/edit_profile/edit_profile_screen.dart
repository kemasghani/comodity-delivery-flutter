import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/edit_profile_form.dart';
import '../../controllers/edit_profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  static String routeName = "/edit_profile";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditProfileController(),
      child: Scaffold(
        appBar: AppBar(title: Text("Edit Profile")),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: EditProfileForm(),
        ),
      ),
    );
  }
}

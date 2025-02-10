import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/edit_profile_controller.dart';

class EditProfileForm extends StatefulWidget {
  @override
  _EditProfileFormState createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  String? name, address;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<EditProfileController>(context, listen: false)
            .loadUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<EditProfileController>(context);

    if (controller.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: controller.user?.name ?? '',
            decoration: InputDecoration(labelText: "Full Name"),
            onSaved: (newValue) => name = newValue,
          ),
          SizedBox(height: 16),
          TextFormField(
            initialValue: controller.user?.address ?? '',
            decoration: InputDecoration(labelText: "Address"),
            onSaved: (newValue) => address = newValue,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                controller.updateUserProfile(name ?? '', address ?? '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Profile Updated")),
                );
              }
            },
            child: Text("Save Changes"),
          ),
        ],
      ),
    );
  }
}

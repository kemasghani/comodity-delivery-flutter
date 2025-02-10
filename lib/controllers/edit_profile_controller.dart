import 'package:flutter/material.dart';
import '../services/edit_profile_service.dart';
import '../services/user_session.dart';
import '../models/user_model.dart';

class EditProfileController extends ChangeNotifier {
  final EditProfileService _service = EditProfileService();
  UserModel? user;
  bool isLoading = false;

  Future<void> loadUserProfile() async {
    isLoading = true;
    notifyListeners();

    String? userId = await UserSession().getUserId();
    if (userId != null) {
      user = await _service.getUserProfile(userId);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserProfile(String name, String address) async {
    if (user == null) return;

    bool success = await _service.updateUserProfile(user!.id, {
      'name': name,
      'address': address,
    });

    if (success) {
      user = UserModel(id: user!.id, name: name, address: address);
      notifyListeners();
    }
  }
}

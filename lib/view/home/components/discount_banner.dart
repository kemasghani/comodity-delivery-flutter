import 'package:flutter/material.dart';
import '../../../services/user_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class DiscountBanner extends StatelessWidget {
  const DiscountBanner({Key? key}) : super(key: key); // Keep const constructor

  Future<String?> _getUserName() async {
    final supabase = Supabase.instance.client; // Get Supabase instance

    String? userId = await UserSession().getUserId(); // Get stored userId
    debugPrint("User ID from session: $userId"); // Debug log

    if (userId == null) {
      debugPrint("No user ID found, returning Guest.");
      return "Guest"; // Default to "Guest" if no userId
    }

    try {
      final response = await supabase
          .from('users')
          .select('name')
          .eq('id', userId)
          .single(); // Query user's name by UUID

      debugPrint("Supabase response: $response"); // Debug log for API response

      return response?['name'] ??
          "Guest"; // Return name or "Guest" if not found
    } catch (e) {
      debugPrint("Error fetching user name: $e"); // Log any errors
      return "Guest";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Show loading
        }

        if (snapshot.hasError) {
          debugPrint("FutureBuilder Error: ${snapshot.error}");
          return const Center(child: Text("Error loading user name"));
        }

        String userName = snapshot.data ?? "Guest"; // Default to "Guest"
        debugPrint("Final displayed userName: $userName");

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF4A3298),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text.rich(
            TextSpan(
              style: const TextStyle(color: Colors.white),
              children: [
                const TextSpan(text: "A Summer Surprise\n"),
                const TextSpan(
                  text: "Cashback 20%\n",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "Welcome, $userName", // Show user name
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

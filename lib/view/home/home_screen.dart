import 'package:flutter/material.dart';
import 'package:shop_app/view/add_order/add_order_screen.dart';
import 'components/discount_banner.dart';
import 'components/home_header.dart';

class HomeScreen extends StatelessWidget {
  static String routeName = "/home";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              const HomeHeader(),
              const DiscountBanner(),

              const SizedBox(height: 20),

              // ✅ Button to Navigate to Map Screen
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AddOrderScreen.routeName);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.blue, // Button color
                ),
                child: const Text("Add Order"),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

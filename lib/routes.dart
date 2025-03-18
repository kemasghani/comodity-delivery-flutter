import 'package:flutter/widgets.dart';
import 'package:shop_app/view/products/products_screen.dart';
import 'view/cart/cart_screen.dart';
import 'view/complete_profile/complete_profile_screen.dart';
import 'view/details/details_screen.dart';
import 'view/edit_profile/edit_profile_screen.dart';
import 'view/forgot_password/forgot_password_screen.dart';
import 'view/home/home_screen.dart';
import 'view/init_screen.dart';
import 'view/login_success/login_success_screen.dart';
import 'view/otp/otp_screen.dart';
import 'view/profile/profile_screen.dart';
import 'view/sign_in/sign_in_screen.dart';
import 'view/sign_up/sign_up_screen.dart';
import 'view/splash/splash_screen.dart';
import 'view/reset_password/reset_password_screen.dart';
import 'view/map/map_screen.dart';
import 'view/history/order_history_screen.dart';
import 'view/add_order/add_order_screen.dart';

final Map<String, WidgetBuilder> routes = {
  InitScreen.routeName: (context) => const InitScreen(),
  SplashScreen.routeName: (context) => const SplashScreen(),
  SignInScreen.routeName: (context) => const SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  LoginSuccessScreen.routeName: (context) => const LoginSuccessScreen(),
  SignUpScreen.routeName: (context) => const SignUpScreen(),
  CompleteProfileScreen.routeName: (context) => const CompleteProfileScreen(),
  OtpScreen.routeName: (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = args?['email'] ?? ''; // ✅ Extract email safely
    return OtpScreen(email: email);
  },
  HomeScreen.routeName: (context) => const HomeScreen(),
  ProductsScreen.routeName: (context) => const ProductsScreen(),
  DetailsScreen.routeName: (context) => const DetailsScreen(),
  CartScreen.routeName: (context) => const CartScreen(),
  ProfileScreen.routeName: (context) => const ProfileScreen(),
  EditProfileScreen.routeName: (context) => EditProfileScreen(),
  ResetPasswordScreen.routeName: (context) => ResetPasswordScreen(),
  MapScreen.routeName: (context) => const MapScreen(),
  AddOrderScreen.routeName: (context) => AddOrderScreen(),
  OrderHistoryScreen.routeName: (context) =>  OrderHistoryScreen(),
};

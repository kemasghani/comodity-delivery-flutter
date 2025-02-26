import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_app/view/splash/splash_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bjxfdzanibahlxsvkrzs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJqeGZkemFuaWJhaGx4c3ZrcnpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE5ODg3NjEsImV4cCI6MjA0NzU2NDc2MX0.UlcvJuqmh7NHyPwMeZGUxWDUyeGd3rQBYj-mAZuMK6c', // Replace with your Supabase anon key
    authOptions: FlutterAuthClientOptions(
      autoRefreshToken: true,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shop App',
      theme: AppTheme.lightTheme(context),
      initialRoute: SplashScreen.routeName,
      routes: routes, // Defined in routes.dart
    );
  }
}

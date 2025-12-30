// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'SplashScreen.dart';
import 'homepage.dart';
import 'admin_homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp();

  // Check if admin is logged in
  final prefs = await SharedPreferences.getInstance();
  final isAdminLoggedIn = prefs.getBool('isAdminLoggedIn') ?? false;

  runApp(MyApp(isAdminLoggedIn: isAdminLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isAdminLoggedIn;

  const MyApp({super.key, required this.isAdminLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AUST Robotics Club',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A),
        ),
        fontFamily: 'Poppins', // Optional: Add your preferred font
      ),
      home: SplashScreen(isAdminLoggedIn: isAdminLoggedIn),
    );
  }
}
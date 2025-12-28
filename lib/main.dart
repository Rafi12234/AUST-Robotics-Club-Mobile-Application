// main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'admin_homepage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

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
            seedColor: const Color(0xFF16A34A)), // green theme
      ),
      home: isAdminLoggedIn ? const AdminDashboardPage() : const HomePage(),
    );
  }
}

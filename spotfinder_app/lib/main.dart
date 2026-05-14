import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'core/theme/app_colors.dart';

void main() {
  runApp(const SpotFinderApp());
}

class SpotFinderApp extends StatelessWidget {
  const SpotFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpotFinder',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
      ),
      // Aquí decides qué pantalla ver primero para probar
      home: const LoginScreen(), 
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

/// Splash screen.
///
/// During development we always start the app at the Login screen so the
/// driver can re-authenticate every run. This also clears any stale JWT
/// that may have been persisted in a previous session — which is what
/// caused the "Inicia sesión para ver tu configuración" dead-end (the app
/// landed inside MainNavigationScreen with `AuthController.user == null`).
///
/// To re-enable the production "auto-skip if a session is cached" behavior:
///   1. Replace `_bootstrap` with the original logic that calls
///      `auth.hasSession()` and routes to MainNavigationScreen when true.
///   2. Also rehydrate `AuthController.user` from the backend (call
///      `GET /api/v1/users/{userId}`) so other screens don't see a null user.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Force a clean slate every run — wipe any cached JWT + user info.
    // This guarantees the app starts at LoginScreen and never lands inside
    // the main navigation with a null user.
    final auth = context.read<AuthController>();
    await auth.logout();

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_tethering, color: AppColors.primaryNeon, size: 80),
            SizedBox(height: 20),
            Text(
              'SPOTFINDER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.primaryNeon),
          ],
        ),
      ),
    );
  }
}

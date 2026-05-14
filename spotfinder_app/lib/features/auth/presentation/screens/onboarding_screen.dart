import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _navigateToLogin(context),
                child: const Text("SKIP", style: TextStyle(color: AppColors.textGray)),
              ),
            ),
            const Spacer(),
            // Simulación de la imagen central de la pantalla 3 (ALPR Scanning)
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/images/smart_access.png'), // Asegúrate de tener esta imagen
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Smart Access",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              "Experience seamless entry and exit with our AI-powered Automatic License Plate Recognition.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGray, fontSize: 16),
            ),
            const Spacer(),
            NeonButton(
              text: "Next",
              onPressed: () => _navigateToLogin(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
  Navigator.push(
    context, 
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
}
}
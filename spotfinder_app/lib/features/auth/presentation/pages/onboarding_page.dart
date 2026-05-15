import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neon_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('SKIP', style: TextStyle(color: AppColors.textGray)),
              ),
            ),
            const Spacer(),
            Container(
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.surfaceDark,
                border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3)),
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_car_filled,
                  size: 120,
                  color: AppColors.primaryNeon,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Smart Access',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Experience seamless entry and exit with our AI-powered Automatic License Plate Recognition.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGray, fontSize: 16),
            ),
            const Spacer(),
            NeonButton(
              text: 'Next',
              onPressed: () => context.go('/login'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

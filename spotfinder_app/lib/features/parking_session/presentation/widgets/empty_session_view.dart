import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class EmptySessionView extends StatelessWidget {
  const EmptySessionView({
    super.key,
    this.title = 'No active session',
    this.subtitle = "Drive into a SpotFinder lot and we'll register your session automatically.",
    this.icon = Icons.directions_car_filled_outlined,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryNeon, size: 72),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textGray, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

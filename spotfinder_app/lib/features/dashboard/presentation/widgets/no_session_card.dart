import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Shown on the Dashboard when the driver has no active vehicle session.
/// Guides them on how to start one (drive in — ALPR creates the session).
class NoSessionCard extends StatelessWidget {
  const NoSessionCard({super.key, required this.onFindParking});
  final VoidCallback onFindParking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primaryNeon.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNeon.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.car_rental, color: AppColors.primaryNeon, size: 26),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No active session',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Drive into any SpotFinder lot. Our ALPR cameras will recognize your '
              'plate and start your session automatically.',
              style: TextStyle(color: AppColors.textGray, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.map_outlined, color: AppColors.primaryNeon),
                label: const Text(
                  'Find nearby parking',
                  style: TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryNeon),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onFindParking,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

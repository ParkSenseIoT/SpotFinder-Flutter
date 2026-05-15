import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Four-up grid of quick-action buttons that jump to other tabs.
class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({
    super.key,
    required this.onMap,
    required this.onPayments,
    required this.onAlerts,
    required this.onSettings,
  });

  final VoidCallback onMap;
  final VoidCallback onPayments;
  final VoidCallback onAlerts;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
        children: [
          _ActionTile(icon: Icons.map_outlined, label: 'Map', onTap: onMap),
          _ActionTile(icon: Icons.payment_outlined, label: 'Pay', onTap: onPayments),
          _ActionTile(icon: Icons.notifications_outlined, label: 'Alerts', onTap: onAlerts),
          _ActionTile(icon: Icons.settings_outlined, label: 'Settings', onTap: onSettings),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryNeon.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryNeon, size: 22),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

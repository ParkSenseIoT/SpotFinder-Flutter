import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Single row inside a [SettingsSection]. Icon + label + optional trailing
/// value/widget + chevron when there's an onTap.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.trailingText,
    this.trailing,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final foreground =
        destructive ? const Color(0xFFEF4444) : Colors.white;
    final tint = iconColor ??
        (destructive ? const Color(0xFFEF4444) : AppColors.primaryNeon);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tint.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: tint, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (trailingText != null) ...[
              Text(
                trailingText!,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
            ],
            if (onTap != null && trailing == null)
              const Icon(Icons.chevron_right,
                  color: AppColors.textGray, size: 22),
          ],
        ),
      ),
    );
  }
}

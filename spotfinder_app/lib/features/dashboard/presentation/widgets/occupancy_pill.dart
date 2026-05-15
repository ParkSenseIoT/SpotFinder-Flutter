import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../parking/domain/entities/occupancy_summary_entity.dart';

/// Compact card showing total/available counts of the parking lot.
/// Tapping it switches to the Map tab.
class OccupancyPill extends StatelessWidget {
  const OccupancyPill({super.key, required this.summary, required this.onTap});

  final OccupancySummaryEntity summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final available = summary.available;
    final total = summary.total;
    final usage = summary.percentage;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryNeon.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryNeon.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_parking,
                    color: AppColors.primaryNeon, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find parking',
                      style: TextStyle(color: AppColors.textGray, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$available ',
                            style: const TextStyle(
                              color: Color(0xFF22C55E),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'of $total available',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('$usage% used',
                            style: const TextStyle(
                                color: AppColors.textGray, fontSize: 11)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: summary.occupancyRate.clamp(0.0, 1.0).toDouble(),
                              minHeight: 5,
                              backgroundColor: AppColors.background,
                              valueColor: AlwaysStoppedAnimation(_progressColor(summary.occupancyRate)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textGray),
            ],
          ),
        ),
      ),
    );
  }

  Color _progressColor(double rate) {
    if (rate >= 0.9) return const Color(0xFFEF4444);
    if (rate >= 0.7) return Colors.orange;
    return const Color(0xFF22C55E);
  }
}

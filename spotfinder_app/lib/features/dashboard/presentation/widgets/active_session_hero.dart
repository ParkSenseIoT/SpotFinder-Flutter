import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../payments/domain/entities/active_session_entity.dart';
import '../../../payments/domain/entities/parking_fee_entity.dart';

/// The main card on the Dashboard when the driver has an active session.
/// Shows plate + slot + duration + live fee + a contextual CTA.
class ActiveSessionHero extends StatelessWidget {
  const ActiveSessionHero({
    super.key,
    required this.session,
    required this.fee,
    required this.isPaying,
    required this.onPay,
    required this.onFindMyCar,
  });

  final ActiveSessionEntity session;
  final ParkingFeeEntity? fee;
  final bool isPaying;
  final VoidCallback onPay;
  final VoidCallback onFindMyCar;

  @override
  Widget build(BuildContext context) {
    final isPaid = session.isPaid;
    final accent = isPaid ? const Color(0xFF22C55E) : AppColors.primaryNeon;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accent.withOpacity(0.18),
              AppColors.surfaceDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: accent, size: 26),
                const SizedBox(width: 10),
                const Text(
                  'Current session',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _statusBadge(isPaid),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              session.licensePlate,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _miniStat(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: fee?.duration ?? session.currentDuration,
                  color: Colors.white,
                ),
                const SizedBox(width: 18),
                _miniStat(
                  icon: Icons.payments_outlined,
                  label: 'Fee',
                  value: fee?.formattedAmount ?? '—',
                  color: accent,
                ),
                const SizedBox(width: 18),
                _miniStat(
                  icon: Icons.pin_drop_outlined,
                  label: 'Slot',
                  value: session.slotId == null ? '—' : 'S-${session.slotId}',
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (!isPaid) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: isPaying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.bolt, size: 20),
                  label: Text(isPaying ? 'Processing...' : 'Pay now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: isPaying ? null : onPay,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pay before reaching the exit barrier — it verifies payment via ALPR.',
                style: TextStyle(color: AppColors.textGray, fontSize: 11),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.pin_drop, color: Color(0xFF22C55E)),
                  label: const Text(
                    'Find my car',
                    style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF22C55E)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onFindMyCar,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Payment confirmed. You can now exit any time.',
                style: TextStyle(color: AppColors.textGray, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(bool isPaid) {
    final color = isPaid ? const Color(0xFF22C55E) : Colors.orange;
    final label = isPaid ? 'PAID' : 'PENDING';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textGray, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

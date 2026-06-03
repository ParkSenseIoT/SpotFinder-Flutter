import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reservation_entity.dart';

/// Card-style tile for a single reservation. Shows slot, status, grace-period
/// countdown for PENDING entries, and optional [onCancel] CTA.
class ReservationTile extends StatelessWidget {
  const ReservationTile({super.key, required this.reservation, this.onCancel});

  final ReservationEntity reservation;
  final VoidCallback? onCancel;

  Color get _statusColor {
    switch (reservation.status) {
      case ReservationStatus.pending:
        return const Color(0xFFFF9100);
      case ReservationStatus.confirmed:
        return AppColors.primaryNeon;
      case ReservationStatus.expired:
        return AppColors.textGray;
      case ReservationStatus.cancelled:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bookmark, color: _statusColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Slot #${r.slotId}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  r.status.label,
                  style: TextStyle(
                      color: _statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.textGray, size: 16),
              const SizedBox(width: 6),
              Text(
                'Reserva desde ${_fmt(r.reservedFrom)}',
                style: const TextStyle(color: AppColors.textGray, fontSize: 12),
              ),
            ],
          ),
          if (r.isPending) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.hourglass_bottom,
                    color: Color(0xFFFF9100), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Tienes ${r.minutesLeft} min antes de que expire',
                  style: const TextStyle(
                      color: Color(0xFFFF9100),
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
          if (r.cancellationReason != null && r.cancellationReason!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Razón: ${r.cancellationReason}',
              style: const TextStyle(color: AppColors.textGray, fontSize: 12),
            ),
          ],
          if (r.canBeCancelled && onCancel != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                label: const Text('Cancelar reserva',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm $hh:$mi';
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/parking_session.dart';
import '../../domain/value_objects/payment_status.dart';
import '../../domain/value_objects/session_status.dart';

class SessionHistoryTile extends StatelessWidget {
  const SessionHistoryTile({super.key, required this.session});

  final ParkingSession session;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm');
    return Material(
      color: AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push('/sessions/${session.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryNeon.withValues(alpha: 0.15),
                child: const Icon(Icons.directions_car_filled, color: AppColors.primaryNeon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.licensePlate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(session.entryTimestamp),
                      style: const TextStyle(color: AppColors.textGray, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statusChip(session.sessionStatus),
                  const SizedBox(height: 6),
                  _paymentChip(session.paymentStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(SessionStatus status) {
    final color = status == SessionStatus.active ? AppColors.primaryNeon : AppColors.textGray;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _paymentChip(PaymentStatus status) {
    final color = switch (status) {
      PaymentStatus.paid => Colors.greenAccent,
      PaymentStatus.pending => Colors.amberAccent,
      PaymentStatus.unpaid => Colors.redAccent,
      PaymentStatus.unknown => AppColors.textGray,
    };
    return Text(
      status.label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    );
  }
}

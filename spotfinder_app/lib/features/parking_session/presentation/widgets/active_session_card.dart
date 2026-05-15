import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/parking_fee.dart';
import '../../domain/entities/parking_session.dart';
import '../../domain/value_objects/payment_status.dart';
import '../blocs/active_session/active_session_bloc.dart';
import '../blocs/active_session/active_session_state.dart';
import 'fee_display.dart';
import 'session_timer.dart';

class ActiveSessionCard extends StatelessWidget {
  const ActiveSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveSessionBloc, ActiveSessionState>(
      builder: (context, state) {
        final session = state.session;
        if (state.status == ActiveSessionStatus.loading && session == null) {
          return _CardSkeleton();
        }
        if (state.status == ActiveSessionStatus.failure && session == null) {
          return _ErrorCard(message: state.errorMessage ?? 'Unable to load session');
        }
        if (session == null) return const SizedBox.shrink();
        return _SessionContent(session: session, fee: state.fee);
      },
    );
  }
}

class _SessionContent extends StatelessWidget {
  const _SessionContent({required this.session, required this.fee});

  final ParkingSession session;
  final ParkingFee? fee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceDark, Color(0xFF0F1822)],
        ),
        border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_parking, color: AppColors.primaryNeon, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Active session',
                style: TextStyle(color: AppColors.primaryNeon, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
              ),
              const Spacer(),
              _PaymentBadge(status: session.paymentStatus),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            session.licensePlate,
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          Text(
            session.slotId != null ? 'Slot #${session.slotId}' : 'Slot pending',
            style: const TextStyle(color: AppColors.textGray, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Elapsed', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                    const SizedBox(height: 4),
                    SessionTimer(entryTimestamp: session.entryTimestamp),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimated', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                    const SizedBox(height: 4),
                    FeeDisplay(fee: fee),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/find-my-car'),
                  icon: const Icon(Icons.pin_drop_outlined, color: AppColors.primaryNeon),
                  label: const Text('Find my car', style: TextStyle(color: AppColors.primaryNeon)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryNeon),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/sessions/${session.id}'),
                  icon: const Icon(Icons.receipt_long, color: Colors.black),
                  label: const Text('Details', style: TextStyle(color: Colors.black)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryNeon,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      PaymentStatus.paid => Colors.greenAccent,
      PaymentStatus.pending => Colors.amberAccent,
      PaymentStatus.unpaid => Colors.redAccent,
      PaymentStatus.unknown => AppColors.textGray,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/active_session_entity.dart';
import '../../domain/entities/parking_fee_entity.dart';

/// Card that mirrors the "My Stay" panel: license plate, slot code, live
/// duration, accumulated fee, and a primary CTA to pay.
class ActiveSessionCard extends StatelessWidget {
  const ActiveSessionCard({
    super.key,
    required this.session,
    required this.fee,
    required this.isPaying,
    required this.onPay,
  });

  final ActiveSessionEntity session;
  final ParkingFeeEntity? fee;
  final bool isPaying;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final paid = session.isPaid;
    final amountLabel = fee?.formattedAmount ?? '—';
    final durationLabel = fee?.duration ?? session.currentDuration;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: paid
              ? const Color(0xFF22C55E).withOpacity(0.5)
              : AppColors.primaryNeon.withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car,
                  color: AppColors.primaryNeon, size: 26),
              const SizedBox(width: 10),
              const Text(
                'My Stay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _StatusBadge(paid: paid),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _kv('Placa', session.licensePlate, mono: true),
              ),
              Expanded(
                child: _kv(
                  'Espacio',
                  session.slotId != null ? '#${session.slotId}' : '—',
                  mono: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _kv('Ingreso', _formatEntry(session.entryTimestamp)),
              ),
              Expanded(
                child: _kv('Duración', durationLabel),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryNeon.withOpacity(0.18),
                  AppColors.primaryNeon.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryNeon.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Text(
                  'Monto acumulado',
                  style: TextStyle(color: AppColors.textGray, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  amountLabel,
                  style: const TextStyle(
                    color: AppColors.primaryNeon,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: paid || isPaying ? null : onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: paid
                    ? const Color(0xFF22C55E)
                    : AppColors.primaryNeon,
                foregroundColor: Colors.black,
                disabledBackgroundColor:
                    AppColors.primaryNeon.withOpacity(0.25),
                disabledForegroundColor: Colors.black54,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isPaying
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      paid ? 'Pago realizado' : 'Pagar $amountLabel',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String label, String value, {bool mono = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: mono ? 'monospace' : null,
            letterSpacing: mono ? 1.2 : 0,
          ),
        ),
      ],
    );
  }

  String _formatEntry(DateTime ts) {
    final local = ts.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.paid});
  final bool paid;

  @override
  Widget build(BuildContext context) {
    final color = paid ? const Color(0xFF22C55E) : const Color(0xFFFF9100);
    final label = paid ? 'PAGADO' : 'PENDIENTE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

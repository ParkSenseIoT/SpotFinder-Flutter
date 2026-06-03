import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_status.dart';

/// US15 — detailed view of a single payment from the driver's history.
///
/// Pushed from [PaymentHistoryTile.onTap]. Displays full transaction id,
/// receipt link, fee breakdown (duration / rate / hours) and payment method.
class PaymentDetailScreen extends StatelessWidget {
  const PaymentDetailScreen({super.key, required this.payment});

  final PaymentEntity payment;

  Color get _statusColor {
    switch (payment.status) {
      case PaymentStatus.completed:
        return AppColors.primaryNeon;
      case PaymentStatus.pending:
        return const Color(0xFFFF9100);
      case PaymentStatus.failed:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Detalle de pago',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SummaryCard(payment: payment, statusColor: _statusColor),
          const SizedBox(height: 18),
          _Section(title: 'Detalles de la transacción', tiles: [
            _Tile(label: 'Pago ID', value: '#${payment.id}'),
            _Tile(
                label: 'Transacción',
                value: payment.transactionId ?? '—',
                copyable: payment.transactionId != null),
            _Tile(label: 'Sesión asociada', value: '#${payment.sessionId}'),
            _Tile(label: 'Método', value: payment.paymentMethod.label),
            _Tile(
              label: 'Estado',
              value: payment.status.label,
              valueColor: _statusColor,
            ),
          ]),
          const SizedBox(height: 14),
          _Section(title: 'Tarificación', tiles: [
            _Tile(
                label: 'Tiempo estacionado',
                value: payment.duration ?? '—'),
            _Tile(
                label: 'Horas cobradas',
                value: payment.hoursCharged.toString()),
            _Tile(
                label: 'Total cobrado',
                value: payment.formattedAmount,
                valueColor: Colors.white,
                bold: true),
          ]),
          if (payment.receiptUrl != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long,
                      color: AppColors.primaryNeon, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Tienes un recibo descargable de Culqi.',
                        style: TextStyle(color: Colors.white, height: 1.3)),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: payment.receiptUrl!));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: AppColors.surfaceDark,
                            content: Text('Enlace al recibo copiado.')),
                      );
                    },
                    child: const Text('Copiar',
                        style: TextStyle(color: AppColors.primaryNeon)),
                  ),
                ],
              ),
            ),
          ],
          if (payment.status == PaymentStatus.failed)
            Container(
              margin: const EdgeInsets.only(top: 18),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.redAccent, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Este pago falló. Vuelve al detalle de la sesión para reintentar con otro método.',
                      style: TextStyle(color: Colors.white, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.payment, required this.statusColor});
  final PaymentEntity payment;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            payment.formattedAmount,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              payment.status.label,
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.6),
            ),
          ),
          const SizedBox(height: 10),
          if (payment.paidAt != null)
            Text(
              _fmtFull(payment.paidAt!),
              style:
                  const TextStyle(color: AppColors.textGray, fontSize: 12),
            ),
        ],
      ),
    );
  }

  String _fmtFull(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year} $hh:$mi';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.tiles});
  final String title;
  final List<_Tile> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.3),
            ),
          ),
          const Divider(color: Colors.white12, height: 14),
          ...tiles,
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
    this.copyable = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textGray, fontSize: 13)),
          ),
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: valueColor ?? Colors.white,
                        fontSize: 13.5,
                        fontWeight: bold ? FontWeight.bold : FontWeight.w500),
                  ),
                ),
                if (copyable && value != '—')
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: value));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            backgroundColor: AppColors.surfaceDark,
                            content: Text('$label copiado.')),
                      );
                    },
                    icon: const Icon(Icons.copy,
                        size: 16, color: AppColors.textGray),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

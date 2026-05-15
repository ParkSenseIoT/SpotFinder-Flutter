import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payment_method.dart';

/// Bottom sheet that lets the driver pick a payment method.
/// Resolves with the chosen [PaymentMethod], or null if dismissed.
Future<PaymentMethod?> showPaymentMethodSheet(BuildContext context, {required String amountLabel}) {
  return showModalBottomSheet<PaymentMethod>(
    context: context,
    backgroundColor: AppColors.surfaceDark,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _PaymentMethodSheet(amountLabel: amountLabel),
  );
}

class _PaymentMethodSheet extends StatelessWidget {
  const _PaymentMethodSheet({required this.amountLabel});
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textGray,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose payment method',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Total to pay: $amountLabel',
              style: const TextStyle(color: AppColors.primaryNeon, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            _MethodTile(
              icon: Icons.smartphone,
              iconColor: const Color(0xFF7B1FA2),
              title: 'Yape',
              subtitle: 'Pay instantly with your Yape app',
              onTap: () => Navigator.pop(context, PaymentMethod.yape),
            ),
            const SizedBox(height: 12),
            _MethodTile(
              icon: Icons.credit_card,
              iconColor: AppColors.primaryNeon,
              title: 'Credit Card',
              subtitle: 'Visa, Mastercard, AmEx',
              onTap: () => Navigator.pop(context, PaymentMethod.creditCard),
            ),
            const SizedBox(height: 12),
            _MethodTile(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: const Color(0xFF22C55E),
              title: 'Debit Card',
              subtitle: 'Direct debit from your bank',
              onTap: () => Navigator.pop(context, PaymentMethod.debitCard),
            ),
            const SizedBox(height: 16),
            const Text(
              'Powered by Culqi · Test mode',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGray, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: iconColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textGray),
          ],
        ),
      ),
    );
  }
}

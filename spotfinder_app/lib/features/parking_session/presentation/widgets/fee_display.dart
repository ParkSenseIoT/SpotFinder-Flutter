import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/parking_fee.dart';

class FeeDisplay extends StatelessWidget {
  const FeeDisplay({super.key, this.fee});

  final ParkingFee? fee;

  @override
  Widget build(BuildContext context) {
    if (fee == null) {
      return const Text(
        'Calculating fee…',
        style: TextStyle(color: AppColors.textGray, fontSize: 14),
      );
    }
    final formatter = NumberFormat.simpleCurrency(name: fee!.currency);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatter.format(fee!.amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${fee!.hoursCharged} h • ${formatter.format(fee!.ratePerHour)} / h',
          style: const TextStyle(color: AppColors.textGray, fontSize: 13),
        ),
      ],
    );
  }
}

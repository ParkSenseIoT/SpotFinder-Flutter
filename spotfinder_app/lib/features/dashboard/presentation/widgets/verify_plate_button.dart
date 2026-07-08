import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../access/presentation/verify_plate_sheet.dart';

/// Prominent CTA on the dashboard that launches the on-demand "Verificar placa"
/// flow. On a recognized plate it calls [onVerified] so the dashboard can
/// refresh the active session.
class VerifyPlateButton extends StatelessWidget {
  const VerifyPlateButton({super.key, required this.onVerified});

  final Future<void> Function(String plate) onVerified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final plate = await showVerifyPlateSheet(context);
            if (plate != null && plate.isNotEmpty) {
              await onVerified(plate);
            }
          },
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('Verificar placa',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryNeon,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}

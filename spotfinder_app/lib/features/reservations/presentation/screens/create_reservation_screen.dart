import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/reservations_controller.dart';

/// Form to create a new reservation. Only requires the slot id; the backend
/// applies a 15-minute grace period by default (overridable here).
class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _slotController = TextEditingController();
  final _graceController = TextEditingController(text: '15');

  @override
  void dispose() {
    _slotController.dispose();
    _graceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReservationsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Nueva reserva',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Reserva un espacio del estacionamiento por hasta 15 minutos. Si '
                  'no ingresas antes de que termine ese tiempo, la reserva expira '
                  'automáticamente.',
                  style: TextStyle(color: AppColors.textGray, height: 1.4),
                ),
                const SizedBox(height: 24),
                _NumberField(
                  controller: _slotController,
                  label: 'ID del espacio',
                  hint: 'p. ej. 42',
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Ingresa un ID válido (>0)';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _NumberField(
                  controller: _graceController,
                  label: 'Ventana de gracia (minutos)',
                  hint: '15',
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final n = int.tryParse(v);
                    if (n == null || n <= 0) return 'Debe ser un número > 0';
                    if (n > 120) return 'Máximo 120 minutos';
                    return null;
                  },
                ),
                const Spacer(),
                if (controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      controller.errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNeon,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: controller.isLoading
                        ? null
                        : () => _submit(context, controller),
                    child: controller.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.6, color: Colors.black),
                          )
                        : const Text('Confirmar reserva',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, ReservationsController c) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final slot = int.parse(_slotController.text.trim());
    final grace = int.tryParse(_graceController.text.trim());
    final ok = await c.create(slotId: slot, gracePeriodMinutes: grace);
    if (!ok) return;
    if (!context.mounted) return;
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.surfaceDark,
        content: Text('Reserva confirmada. Tienes 15 minutos para llegar.'),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textGray, fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textGray),
            filled: true,
            fillColor: AppColors.surfaceDark,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryNeon),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}

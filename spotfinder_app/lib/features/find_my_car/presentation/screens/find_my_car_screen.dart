import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../payments/presentation/controllers/payments_controller.dart';

/// US07 — Find My Car.
///
/// Reuses [PaymentsController] (which already exposes the driver's active
/// parking session including the slot code) to show a "where did I park"
/// summary with the floor, slot id and step-by-step breadcrumbs.
class FindMyCarScreen extends StatelessWidget {
  const FindMyCarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthController>().user;
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: Text('Sesión expirada. Vuelve a iniciar sesión.',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => PaymentsController(userId: user.id)..load(),
      child: const _FindMyCarView(),
    );
  }
}

class _FindMyCarView extends StatelessWidget {
  const _FindMyCarView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentsController>();
    final session = controller.activeSession;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Find My Car',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryNeon,
        onRefresh: controller.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            if (controller.isLoading && session == null)
              const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryNeon))
            else if (session == null)
              _NoActiveSession()
            else
              _Located(
                slotCode: session.slotId == null ? null : 'A-${session.slotId}',
                plate: session.licensePlate,
              ),
          ],
        ),
      ),
    );
  }
}

class _NoActiveSession extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_car_filled_outlined,
              color: AppColors.textGray.withOpacity(0.7), size: 64),
          const SizedBox(height: 14),
          const Text(
            'No hay vehículo estacionado',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando tu vehículo ingrese al estacionamiento, aquí verás el piso '
            'y el código del espacio para encontrarlo fácilmente al regresar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGray, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _Located extends StatelessWidget {
  const _Located({required this.slotCode, required this.plate});

  final String? slotCode;
  final String? plate;

  String get _level {
    final code = slotCode ?? '';
    if (code.isEmpty) return '—';
    final upper = code.toUpperCase();
    final hint = upper.split('-').first;
    return 'Piso $hint';
  }

  @override
  Widget build(BuildContext context) {
    final code = slotCode ?? '—';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryNeon.withOpacity(0.18),
                AppColors.surfaceDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryNeon.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              const Icon(Icons.local_parking,
                  color: AppColors.primaryNeon, size: 60),
              const SizedBox(height: 12),
              const Text(
                'Tu vehículo está en',
                style: TextStyle(color: AppColors.textGray, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                code,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 6),
              Text(_level,
                  style: const TextStyle(
                      color: AppColors.primaryNeon,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              if (plate != null && plate!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(plate!,
                      style: const TextStyle(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Cómo llegar',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _Step(
            n: 1,
            text:
                'Ubica el ascensor o escaleras más cercanas y baja al $_level.'),
        _Step(
            n: 2,
            text:
                'Sigue las flechas hacia los espacios marcados con el prefijo del código.'),
        _Step(n: 3, text: 'Tu vehículo está bajo el LED encendido en el espacio $code.'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Icon(Icons.tips_and_updates_outlined,
                  color: Color(0xFFFF9100), size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Si no encuentras el espacio, pide ayuda al operador mostrando este código.',
                  style: TextStyle(color: AppColors.textGray, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.text});
  final int n;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryNeon,
              shape: BoxShape.circle,
            ),
            child: Text('$n',
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

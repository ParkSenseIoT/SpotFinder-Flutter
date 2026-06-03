import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/premium_service_entity.dart';
import '../controllers/premium_services_controller.dart';

/// US17 — catálogo de servicios Premium (lavado, detailing, combustible).
/// Reachable desde Settings → "Servicios Premium".
class PremiumServicesScreen extends StatelessWidget {
  const PremiumServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthController>().user;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Sesión expirada. Vuelve a iniciar sesión.',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => PremiumServicesController(userId: user.id),
      child: const _PremiumServicesView(),
    );
  }
}

class _PremiumServicesView extends StatelessWidget {
  const _PremiumServicesView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PremiumServicesController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Servicios Premium',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          const _Header(),
          const SizedBox(height: 18),
          ...controller.catalog.map((s) => _ServiceCard(
                service: s,
                requested: controller.requested.any((r) => r.service.id == s.id),
                onRequest: () => _confirmRequest(context, controller, s),
              )),
        ],
      ),
    );
  }

  Future<void> _confirmRequest(BuildContext context,
      PremiumServicesController c, PremiumServiceEntity service) async {
    final note = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Solicitar servicio', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(service.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(service.description,
                style: const TextStyle(color: Colors.white70, height: 1.3)),
            const SizedBox(height: 12),
            TextField(
              controller: note,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Indicaciones extra (opcional)',
                hintStyle: TextStyle(color: AppColors.textGray),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white12)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryNeon)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textGray))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Solicitar',
                  style: TextStyle(color: AppColors.primaryNeon))),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await c.request(
        service: service,
        note: note.text.trim().isEmpty ? null : note.text.trim());
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? AppColors.surfaceDark : Colors.redAccent,
        content: Text(ok
            ? 'Servicio solicitado. Te avisaremos cuando inicie.'
            : (c.errorMessage ?? 'No se pudo solicitar el servicio.')),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9100), Color(0xFFFF6B00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.workspace_premium, color: Colors.white, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mientras tu auto está estacionado',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Solicita lavado, detailing o combustible directo desde la app. Disponible para Plan Premium.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.requested,
    required this.onRequest,
  });

  final PremiumServiceEntity service;
  final bool requested;
  final VoidCallback onRequest;

  IconData get _icon {
    switch (service.iconAsset) {
      case 'wash':
        return Icons.local_car_wash_outlined;
      case 'detail':
        return Icons.auto_fix_high_outlined;
      case 'fuel':
        return Icons.local_gas_station_outlined;
      default:
        return Icons.miscellaneous_services_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9100).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: const Color(0xFFFF9100), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(service.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(service.priceLabel,
                        style: const TextStyle(
                            color: AppColors.primaryNeon,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(service.description,
                    style: const TextStyle(
                        color: AppColors.textGray, fontSize: 12, height: 1.4)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: AppColors.textGray),
                    const SizedBox(width: 4),
                    Text(service.estimatedTime,
                        style: const TextStyle(
                            color: AppColors.textGray, fontSize: 12)),
                    const Spacer(),
                    if (requested)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNeon.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Solicitado',
                            style: TextStyle(
                                color: AppColors.primaryNeon,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      )
                    else
                      TextButton(
                        onPressed: onRequest,
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            backgroundColor: AppColors.primaryNeon,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: const Text('Solicitar',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

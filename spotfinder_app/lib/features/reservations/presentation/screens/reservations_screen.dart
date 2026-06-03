import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/reservations_controller.dart';
import '../widgets/reservation_tile.dart';
import 'create_reservation_screen.dart';

/// Driver-facing list of reservations. Shows Active first, then History.
/// Reached from Settings → "Mis reservas".
class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthController>().user;
    if (user == null) return _missingSession();

    return ChangeNotifierProvider(
      create: (_) => ReservationsController(userId: user.id)..load(),
      child: const _ReservationsView(),
    );
  }

  Widget _missingSession() => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: Text(
            'Sesión expirada. Vuelve a iniciar sesión.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
}

class _ReservationsView extends StatelessWidget {
  const _ReservationsView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReservationsController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Mis reservas',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryNeon,
        onRefresh: controller.load,
        child: _buildBody(context, controller),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryNeon,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nueva reserva',
            style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: controller,
                child: const CreateReservationScreen(),
              ),
            ),
          );
          if (created == true) await controller.load();
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReservationsController c) {
    if (c.isLoading && c.active.isEmpty && c.history.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryNeon));
    }
    if (c.errorMessage != null && c.active.isEmpty && c.history.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
        children: [
          const Icon(Icons.cloud_off, color: AppColors.textGray, size: 60),
          const SizedBox(height: 12),
          Text(c.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          const Text('Desliza hacia abajo para reintentar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGray)),
        ],
      );
    }
    if (c.active.isEmpty && c.history.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
        children: const [
          Icon(Icons.bookmark_border, color: AppColors.textGray, size: 60),
          SizedBox(height: 12),
          Text(
            'Aún no tienes reservas',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Toca "Nueva reserva" para reservar un espacio con anticipación.\n'
            'Disponible para planes Pro y Premium.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGray, height: 1.4),
          ),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 96),
      children: [
        if (c.active.isNotEmpty)
          ..._section(
            title: 'Activas',
            tiles: c.active
                .map((r) => ReservationTile(
                      reservation: r,
                      onCancel: r.canBeCancelled
                          ? () => _confirmCancel(context, c, r.id)
                          : null,
                    ))
                .toList(),
          ),
        if (c.history.isNotEmpty)
          ..._section(
            title: 'Historial',
            tiles: c.history
                .where((r) => !c.active.any((a) => a.id == r.id))
                .map((r) => ReservationTile(reservation: r))
                .toList(),
          ),
      ],
    );
  }

  Iterable<Widget> _section({required String title, required List<Widget> tiles}) sync* {
    yield Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4),
      ),
    );
    yield* tiles;
  }

  Future<void> _confirmCancel(
      BuildContext context, ReservationsController c, int reservationId) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar reserva',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Estás seguro de cancelar esta reserva? Liberarás el espacio para otros conductores.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Razón (opcional)',
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
            child: const Text('Volver',
                style: TextStyle(color: AppColors.textGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancelar reserva',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await c.cancel(
        reservationId: reservationId,
        reason: reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim());
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? AppColors.surfaceDark : Colors.redAccent,
        content:
            Text(ok ? 'Reserva cancelada.' : (c.errorMessage ?? 'No se pudo cancelar.')),
      ),
    );
  }
}

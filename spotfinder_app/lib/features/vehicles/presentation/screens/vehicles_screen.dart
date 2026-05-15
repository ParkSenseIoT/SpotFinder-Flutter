import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/vehicles_controller.dart';
import 'add_vehicle_screen.dart';

/// Lists the driver's vehicles. Pull-to-refresh, tap delete icon to remove.
/// Pushed from Settings → "Mis vehículos".
class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthController>().user;
    if (user == null) return _missingSession();

    return ChangeNotifierProvider(
      create: (_) => VehiclesController(userId: user.id)..load(),
      child: const _VehiclesView(),
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

class _VehiclesView extends StatelessWidget {
  const _VehiclesView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VehiclesController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mis vehículos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
        label: const Text('Agregar vehículo',
            style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: controller,
                child: const AddVehicleScreen(),
              ),
            ),
          );
          if (added == true) await controller.load();
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, VehiclesController c) {
    if (c.isLoading && c.vehicles.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon));
    }
    if (c.errorMessage != null && c.vehicles.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
        children: [
          const Icon(Icons.cloud_off, color: AppColors.textGray, size: 60),
          const SizedBox(height: 12),
          Text(
            c.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Desliza hacia abajo para reintentar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGray),
          ),
        ],
      );
    }
    if (c.vehicles.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
        children: const [
          Icon(Icons.directions_car_outlined, color: AppColors.textGray, size: 60),
          SizedBox(height: 12),
          Text(
            'Aún no has registrado vehículos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Toca el botón "+" para agregar tu placa.\nSin esto, el ALPR del estacionamiento '
            'no puede asociarte a la sesión.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGray, height: 1.4),
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: c.vehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final v = c.vehicles[i];
        return _VehicleCard(
          plate: v.plate,
          description: v.descriptiveLabel,
          onDelete: () => _confirmDelete(context, c, v.id, v.plate),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    VehiclesController c,
    int vehicleId,
    String plate,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar vehículo', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar el vehículo con placa $plate? Esta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await c.delete(vehicleId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? AppColors.surfaceDark : Colors.redAccent,
        content: Text(ok ? 'Vehículo eliminado.' : (c.errorMessage ?? 'No se pudo eliminar.')),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.plate,
    required this.description,
    required this.onDelete,
  });

  final String plate;
  final String description;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryNeon.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryNeon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.directions_car, color: AppColors.primaryNeon, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textGray, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: onDelete,
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
  }
}

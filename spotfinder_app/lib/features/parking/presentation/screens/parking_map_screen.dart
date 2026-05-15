import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/parking_slot_entity.dart';
import '../controllers/parking_controller.dart';

/// Driver-facing map of slots.
/// Pulls the initial list over REST, then keeps it in sync over STOMP.
class ParkingMapScreen extends StatelessWidget {
  const ParkingMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParkingController()..start(),
      child: const _ParkingMapView(),
    );
  }
}

class _ParkingMapView extends StatelessWidget {
  const _ParkingMapView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ParkingController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryNeon,
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _SummaryHeader(controller: controller)),
              SliverToBoxAdapter(child: _Legend()),
              if (controller.isLoading && controller.slots.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
                )
              else if (controller.errorMessage != null && controller.slots.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorState(message: controller.errorMessage!),
                )
              else if (controller.slots.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: controller.slots.length,
                    itemBuilder: (_, i) => _SlotTile(slot: controller.slots[i]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.controller});
  final ParkingController controller;

  @override
  Widget build(BuildContext context) {
    final s = controller.summary;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryNeon.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_parking, color: AppColors.primaryNeon, size: 28),
              const SizedBox(width: 10),
              const Text(
                'Live availability',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _LiveBadge(isLive: controller.isLive),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _stat('Total', s.total.toString(), Colors.white),
              _divider(),
              _stat('Available', s.available.toString(), const Color(0xFF22C55E)),
              _divider(),
              _stat('Occupied', s.occupied.toString(), const Color(0xFFEF4444)),
              _divider(),
              _stat('Usage', '${s.percentage}%', AppColors.primaryNeon),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: s.occupancyRate.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation(_progressColor(s.occupancyRate)),
            ),
          ),
        ],
      ),
    );
  }

  Color _progressColor(double rate) {
    if (rate >= 0.9) return const Color(0xFFEF4444);
    if (rate >= 0.7) return Colors.orange;
    return const Color(0xFF22C55E);
  }

  Widget _stat(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 30, color: Colors.white12);
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.isLive});
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final color = isLive ? const Color(0xFF22C55E) : AppColors.textGray;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(isLive ? 'LIVE' : 'OFFLINE',
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 14,
        runSpacing: 6,
        children: const [
          _LegendDot(color: Color(0xFF22C55E), label: 'Available'),
          _LegendDot(color: Color(0xFFEF4444), label: 'Occupied'),
          _LegendDot(color: AppColors.textGray, label: 'Out of service'),
          _LegendDot(color: Colors.orange, label: 'Evacuation'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({required this.slot});
  final ParkingSlotEntity slot;

  @override
  Widget build(BuildContext context) {
    final color = slot.status.color;
    return Tooltip(
      message: '${slot.slotCode} · ${slot.status.label}',
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_iconFor(slot.status), color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              slot.slotCode,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(SlotStatus status) {
    switch (status) {
      case SlotStatus.available:
        return Icons.check_circle_outline;
      case SlotStatus.occupied:
        return Icons.directions_car;
      case SlotStatus.outOfService:
        return Icons.do_not_disturb_alt;
      case SlotStatus.evacuation:
        return Icons.warning_amber;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_parking_outlined, color: AppColors.textGray, size: 60),
          SizedBox(height: 12),
          Text(
            'No hay espacios registrados todavía.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 6),
          Text(
            'Un administrador debe registrar los espacios desde el dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: AppColors.textGray, size: 60),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Desliza hacia abajo para reintentar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}

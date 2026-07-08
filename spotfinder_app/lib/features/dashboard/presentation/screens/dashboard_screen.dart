import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../payments/domain/entities/payment_method.dart';
import '../../../payments/presentation/widgets/payment_method_sheet.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/active_session_hero.dart';
import '../widgets/emergency_banner.dart';
import '../widgets/greeting_header.dart';
import '../widgets/no_session_card.dart';
import '../widgets/occupancy_pill.dart';
import '../widgets/quick_action_grid.dart';
import '../widgets/recent_notifications_card.dart';
import '../widgets/verify_plate_button.dart';

/// Driver-facing home screen. Aggregates the active session, occupancy summary,
/// emergency banner, recent notifications and quick navigation actions.
///
/// Tab-switching callbacks are passed by [MainNavigationScreen] so this screen
/// can keep the bottom-nav as the single source of truth for the selected tab.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onSwitchToTab,
  });

  /// Callback used to jump to another bottom-nav tab.
  /// 0=Dashboard, 1=Map, 2=Payments, 3=Alerts, 4=Settings.
  final void Function(int index) onSwitchToTab;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    if (user == null) return _emptyAuth();

    return ChangeNotifierProvider(
      create: (_) => DashboardController(userId: user.id)..load(),
      child: _DashboardView(onSwitchToTab: onSwitchToTab),
    );
  }

  Widget _emptyAuth() => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Inicia sesión para ver tu dashboard.',
              style: TextStyle(color: AppColors.textGray)),
        ),
      );
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({required this.onSwitchToTab});
  final void Function(int) onSwitchToTab;

  Future<void> _payTapped(BuildContext context) async {
    final controller = context.read<DashboardController>();
    final fee = controller.currentFee;
    final amountLabel = fee?.formattedAmount ?? '—';
    final method = await showPaymentMethodSheet(context, amountLabel: amountLabel);
    if (method == null || !context.mounted) return;

    final ok = await controller.pay(method);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? const Color(0xFF22C55E) : Colors.redAccent,
        content: Text(ok
            ? 'Payment confirmed. You may exit now.'
            : (controller.errorMessage ?? 'Payment failed.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user!;
    final controller = context.watch<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryNeon,
          onRefresh: controller.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              GreetingHeader(user: user),
              EmergencyBanner(status: controller.emergencyStatus),
              if (controller.isLoading && controller.activeSession == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
                )
              else if (controller.activeSession != null)
                ActiveSessionHero(
                  session: controller.activeSession!,
                  fee: controller.currentFee,
                  isPaying: controller.isPaying,
                  onPay: () => _payTapped(context),
                  onFindMyCar: () => _showFindMyCar(context, controller),
                )
              else
                NoSessionCard(onFindParking: () => onSwitchToTab(1)),
              OccupancyPill(
                summary: controller.occupancy,
                onTap: () => onSwitchToTab(1),
              ),
              VerifyPlateButton(
                onVerified: (plate) async {
                  await controller.refresh();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF22C55E),
                      content: Text('Placa reconocida: $plate'),
                    ),
                  );
                },
              ),
              QuickActionGrid(
                onMap: () => onSwitchToTab(1),
                onPayments: () => onSwitchToTab(2),
                onAlerts: () => onSwitchToTab(3),
                onSettings: () => onSwitchToTab(4),
              ),
              RecentNotificationsCard(
                notifications: controller.recentNotifications,
                onSeeAll: () => onSwitchToTab(3),
              ),
              if (controller.errorMessage != null && controller.activeSession == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textGray, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFindMyCar(BuildContext context, DashboardController controller) {
    final s = controller.activeSession;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.pin_drop, color: Color(0xFF22C55E)),
            SizedBox(width: 8),
            Text('Find my car', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s?.slotId == null
                  ? 'We have not detected your parking slot yet. Try again after walking back to your car.'
                  : 'Your vehicle ${s!.licensePlate} is parked at slot S-${s.slotId}.',
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primaryNeon)),
          ),
        ],
      ),
    );
  }
}

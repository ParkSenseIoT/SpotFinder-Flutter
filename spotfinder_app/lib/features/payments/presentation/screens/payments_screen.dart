import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/payments_controller.dart';
import '../widgets/active_session_card.dart';
import '../widgets/payment_history_tile.dart';
import '../widgets/payment_method_sheet.dart';
import '../widgets/payment_receipt_dialog.dart';

/// Driver-facing "Pay" tab. Shows the active session (if any), live fee,
/// payment CTA, and a scrollable payment history below.
///
/// Mirrors the structure of `NotificationCenterScreen`: it can render either
/// inside the bottom navigation (no AppBar) or as a stand-alone route.
class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key, this.showAppBar = true});

  /// When false, hide the AppBar so the screen blends with the bottom-nav
  /// host. The header is rendered inline instead.
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Inicia sesión para ver tus pagos.',
            style: TextStyle(color: AppColors.textGray),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => PaymentsController(userId: user.id)..load(),
      child: _PaymentsView(showAppBar: showAppBar),
    );
  }
}

class _PaymentsView extends StatefulWidget {
  const _PaymentsView({required this.showAppBar});
  final bool showAppBar;

  @override
  State<_PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<_PaymentsView> {
  bool _receiptInFlight = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentsController>();

    // Surface a completed payment via the receipt dialog. We guard with a
    // local flag so the dialog only opens once per success event.
    final completed = controller.lastCompletedPayment;
    if (completed != null && !_receiptInFlight) {
      _receiptInFlight = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showPaymentReceiptDialog(context, completed);
        if (!mounted) return;
        controller.clearLastPayment();
        _receiptInFlight = false;
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: AppColors.background,
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Payments',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: SafeArea(
        top: !widget.showAppBar,
        child: RefreshIndicator(
          color: AppColors.primaryNeon,
          onRefresh: controller.refresh,
          child: _buildBody(context, controller),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PaymentsController c) {
    if (c.isLoading && c.activeSession == null && c.history.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
        ],
      );
    }

    if (c.errorMessage != null &&
        c.activeSession == null &&
        c.history.isEmpty) {
      return _ErrorState(message: c.errorMessage!);
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (!widget.showAppBar)
          const SliverToBoxAdapter(child: _InlineHeader()),
        SliverToBoxAdapter(
          child: c.activeSession == null
              ? const _NoActiveSession()
              : ActiveSessionCard(
                  session: c.activeSession!,
                  fee: c.currentFee,
                  isPaying: c.isPaying,
                  onPay: () => _onPay(context, c),
                ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    color: AppColors.primaryNeon, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Historial',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (c.history.isNotEmpty)
                  Text(
                    '${c.history.length} registros',
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (c.history.isEmpty)
          const SliverToBoxAdapter(child: _EmptyHistory())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => PaymentHistoryTile(payment: c.history[i]),
              childCount: c.history.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Future<void> _onPay(BuildContext context, PaymentsController c) async {
    final session = c.activeSession;
    if (session == null) return;
    final amountLabel = c.currentFee?.formattedAmount ?? '—';

    final method = await showPaymentMethodSheet(context, amountLabel: amountLabel);
    if (method == null || !context.mounted) return;

    final ok = await c.pay(method);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          content: Text(c.errorMessage ?? 'No se pudo procesar el pago.'),
        ),
      );
    }
  }
}

class _InlineHeader extends StatelessWidget {
  const _InlineHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: Row(
        children: [
          Icon(Icons.payments_outlined,
              color: AppColors.primaryNeon, size: 26),
          SizedBox(width: 10),
          Text(
            'Payments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoActiveSession extends StatelessWidget {
  const _NoActiveSession();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(Icons.local_parking_outlined,
              color: AppColors.textGray.withOpacity(0.7), size: 50),
          const SizedBox(height: 12),
          const Text(
            'Sin sesión activa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cuando tu vehículo ingrese al estacionamiento, aquí verás el '
            'tiempo, el monto y podrás pagar antes de salir.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGray, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: const Center(
        child: Text(
          'Aún no tienes pagos registrados.',
          style: TextStyle(color: AppColors.textGray, fontSize: 13),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const Icon(Icons.cloud_off,
                  color: AppColors.textGray, size: 60),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Desliza hacia abajo para reintentar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGray, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

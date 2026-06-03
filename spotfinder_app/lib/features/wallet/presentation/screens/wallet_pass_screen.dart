import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../payments/presentation/controllers/payments_controller.dart';
import '../../domain/entities/wallet_pass_entity.dart';
import '../controllers/wallet_controller.dart';

/// US16 — pase digital de estancia (Google Wallet).
///
/// Combina el PaymentsController (para tener la activeSession) con el
/// WalletController (que arma el pase). Si el backend expone más tarde
/// `/api/v1/wallet/passes` reemplaza el `loadFromSession` por una llamada real.
class WalletPassScreen extends StatelessWidget {
  const WalletPassScreen({super.key});

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => PaymentsController(userId: user.id)..load()),
        ChangeNotifierProvider(create: (_) => WalletController(userId: user.id)),
      ],
      child: const _WalletPassView(),
    );
  }
}

class _WalletPassView extends StatefulWidget {
  const _WalletPassView();
  @override
  State<_WalletPassView> createState() => _WalletPassViewState();
}

class _WalletPassViewState extends State<_WalletPassView> {
  bool _initialised = false;

  @override
  Widget build(BuildContext context) {
    final paymentsCtrl = context.watch<PaymentsController>();
    final walletCtrl = context.watch<WalletController>();

    if (!_initialised && !paymentsCtrl.isLoading) {
      _initialised = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        walletCtrl.loadFromSession(paymentsCtrl.activeSession);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pase digital',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryNeon,
        onRefresh: () async {
          await paymentsCtrl.refresh();
          await walletCtrl.loadFromSession(paymentsCtrl.activeSession);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            if (paymentsCtrl.isLoading || walletCtrl.isLoading)
              const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryNeon))
            else if (walletCtrl.pass == null)
              const _EmptyPass()
            else
              _PassCard(pass: walletCtrl.pass!),
            const SizedBox(height: 24),
            const _PremiumNote(),
          ],
        ),
      ),
    );
  }
}

class _EmptyPass extends StatelessWidget {
  const _EmptyPass();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        children: [
          Icon(Icons.qr_code_2_outlined,
              color: AppColors.textGray, size: 64),
          SizedBox(height: 12),
          Text(
            'Sin pase activo',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'El pase se genera automáticamente cuando ingresas al estacionamiento. '
            'Te llegará una notificación con el botón "Añadir a Google Wallet".',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGray, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _PassCard extends StatelessWidget {
  const _PassCard({required this.pass});
  final WalletPassEntity pass;

  Color get _accent => pass.state == WalletPassState.active
      ? AppColors.primaryNeon
      : const Color(0xFFFF9100);

  String get _stateLabel {
    switch (pass.state) {
      case WalletPassState.pending:
        return 'Pendiente de pago';
      case WalletPassState.active:
        return 'Listo para salir';
      case WalletPassState.expired:
        return 'Expirado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
              color: _accent.withOpacity(0.18),
              blurRadius: 18,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SpotFinder Pass',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _stateLabel,
                  style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                // We render the QR payload as a clipped monospace string. Adding a
                // proper QR widget requires another dependency; the text is enough
                // for UX validation and copy-paste by the operator if needed.
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.qr_code,
                      color: Colors.black87, size: 110),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  pass.qrCode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 11,
                      letterSpacing: 0.8,
                      fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _Tile(
                      label: 'Placa', value: pass.licensePlate.toUpperCase())),
              const SizedBox(width: 10),
              Expanded(
                  child:
                      _Tile(label: 'Ingreso', value: _fmt(pass.entryTime))),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _accent.withOpacity(0.6))),
              ),
              icon: const Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.white),
              label: const Text('Añadir a Google Wallet',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: pass.qrCode));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.surfaceDark,
                    content: Text(
                        'Pase copiado. En producción se invocará la API de Google Wallet.'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm $hh:$mi';
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 11,
                  letterSpacing: 0.4)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PremiumNote extends StatelessWidget {
  const _PremiumNote();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: const [
          Icon(Icons.workspace_premium_outlined,
              color: Color(0xFFFF9100), size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Disponible para conductores Premium. El pase se actualiza solo cuando completas el pago.',
              style: TextStyle(color: AppColors.textGray, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

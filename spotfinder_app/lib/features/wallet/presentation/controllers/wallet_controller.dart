import 'package:flutter/foundation.dart';

import '../../../payments/domain/entities/active_session_entity.dart';
import '../../domain/entities/wallet_pass_entity.dart';

/// US16 — controller for the Google Wallet pass.
///
/// Today the SpotFinder backend does not expose Google Wallet endpoints yet
/// (it is the SS04 spike). The controller derives the pass from the driver's
/// active session so the UX/UI flow can be validated without the integration
/// being live. When the wallet endpoint exists, the {@link _buildPass} fall-back
/// should be replaced by a network call inside a {@code wallet_repository_impl}.
class WalletController extends ChangeNotifier {
  WalletController({required this.userId});

  final int userId;

  WalletPassEntity? _pass;
  WalletPassEntity? get pass => _pass;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Build a pass from the driver's current session. Pass null when there is
  /// no active session so the screen renders an empty-state.
  Future<void> loadFromSession(ActiveSessionEntity? session) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _pass = session == null ? null : _buildPass(session);
    } catch (_) {
      _errorMessage = 'No se pudo generar el pase digital.';
      _pass = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static WalletPassEntity _buildPass(ActiveSessionEntity s) {
    final state = s.isPaid ? WalletPassState.active : WalletPassState.pending;
    return WalletPassEntity(
      passId: 'pass-${s.id}',
      licensePlate: s.licensePlate,
      entryTime: s.entryTimestamp,
      currentAmount: 'PEN —',
      qrCode: 'SPOTFINDER:SESSION:${s.id}',
      state: state,
      saveUrl: null,
    );
  }
}

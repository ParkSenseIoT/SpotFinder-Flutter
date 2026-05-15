import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/entities/active_session_entity.dart';
import '../../domain/entities/parking_fee_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/usecases/payment_usecases.dart';

/// State holder for the Payments tab. One controller per logged-in driver.
///
/// Responsibilities:
///   - Fetch the active vehicle session (if any).
///   - Keep the displayed fee "alive" by re-querying the backend every 20s
///     while there is an unpaid active session.
///   - Send a payment to Culqi-via-backend and refresh the session afterwards.
///   - List past payments.
class PaymentsController extends ChangeNotifier {
  PaymentsController({required this.userId, PaymentRepository? repository})
      : _repository = repository ?? PaymentRepositoryImpl() {
    _getActiveSession = GetActiveSessionUseCase(_repository);
    _calculateFee = CalculateFeeUseCase(_repository);
    _initiatePayment = InitiatePaymentUseCase(_repository);
    _getHistory = GetPaymentHistoryUseCase(_repository);
  }

  final int userId;
  final PaymentRepository _repository;
  late final GetActiveSessionUseCase _getActiveSession;
  late final CalculateFeeUseCase _calculateFee;
  late final InitiatePaymentUseCase _initiatePayment;
  late final GetPaymentHistoryUseCase _getHistory;

  ActiveSessionEntity? _activeSession;
  ActiveSessionEntity? get activeSession => _activeSession;

  ParkingFeeEntity? _currentFee;
  ParkingFeeEntity? get currentFee => _currentFee;

  List<PaymentEntity> _history = const [];
  List<PaymentEntity> get history => _history;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaying = false;
  bool get isPaying => _isPaying;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PaymentEntity? _lastCompletedPayment;
  PaymentEntity? get lastCompletedPayment => _lastCompletedPayment;

  Timer? _feeRefreshTimer;
  static const _feeRefreshInterval = Duration(seconds: 20);

  Future<void> load() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final results = await Future.wait([
        _getActiveSession.execute(userId),
        _getHistory.execute(userId),
      ]);
      _activeSession = results[0] as ActiveSessionEntity?;
      _history = results[1] as List<PaymentEntity>;
      _maybeFetchFee();
      _scheduleFeeRefresh();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'No se pudo cargar la información de pagos.';
    } finally {
      _setLoading(false);
    }
  }

  /// Pull-to-refresh — same as [load] but skips the loading spinner overlay.
  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        _getActiveSession.execute(userId),
        _getHistory.execute(userId),
      ]);
      _activeSession = results[0] as ActiveSessionEntity?;
      _history = results[1] as List<PaymentEntity>;
      await _refreshFeeNow();
      _scheduleFeeRefresh();
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  /// Send the payment to the backend. Returns true if it completed successfully.
  Future<bool> pay(PaymentMethod method) async {
    final session = _activeSession;
    if (session == null) return false;
    if (session.isPaid) return true;

    _isPaying = true;
    _errorMessage = null;
    _lastCompletedPayment = null;
    notifyListeners();

    try {
      // The backend's Culqi gateway is stubbed; any non-empty token works.
      // In production this token comes from Culqi Checkout (web view) or
      // their Flutter SDK.
      final fakeToken = 'tkn_test_${session.id}_${DateTime.now().millisecondsSinceEpoch}';

      final payment = await _initiatePayment.execute(
        sessionId: session.id,
        method: method,
        token: fakeToken,
      );

      _lastCompletedPayment = payment;

      // Refresh session + history so the UI flips paymentStatus to PAID.
      await refresh();
      _isPaying = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isPaying = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Error inesperado al procesar el pago.';
      _isPaying = false;
      notifyListeners();
      return false;
    }
  }

  void clearLastPayment() {
    _lastCompletedPayment = null;
    notifyListeners();
  }

  // -------- internals --------

  void _maybeFetchFee() {
    final s = _activeSession;
    if (s == null || s.isPaid) {
      _currentFee = null;
      return;
    }
    // Fire-and-forget — the next refresh will catch any error.
    _refreshFeeNow();
  }

  Future<void> _refreshFeeNow() async {
    final s = _activeSession;
    if (s == null || s.isPaid) {
      _currentFee = null;
      return;
    }
    try {
      _currentFee = await _calculateFee.execute(s.id);
      notifyListeners();
    } catch (_) {
      // swallow; keep previous fee
    }
  }

  void _scheduleFeeRefresh() {
    _feeRefreshTimer?.cancel();
    final s = _activeSession;
    if (s == null || s.isPaid) return;
    _feeRefreshTimer = Timer.periodic(_feeRefreshInterval, (_) => _refreshFeeNow());
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _feeRefreshTimer?.cancel();
    super.dispose();
  }
}

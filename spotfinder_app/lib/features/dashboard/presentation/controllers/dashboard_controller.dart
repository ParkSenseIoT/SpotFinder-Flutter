import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../notifications/data/repositories/notification_repository_impl.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../parking/data/repositories/parking_repository_impl.dart';
import '../../../parking/domain/entities/occupancy_summary_entity.dart';
import '../../../payments/data/repositories/payment_repository_impl.dart';
import '../../../payments/domain/entities/active_session_entity.dart';
import '../../../payments/domain/entities/parking_fee_entity.dart';
import '../../../payments/domain/entities/payment_method.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/emergency_status_entity.dart';

/// State holder for the Dashboard tab.
///
/// Pulls data from four different feature repositories and merges them into
/// a single observable state:
///   - Active vehicle session (Payments BC).
///   - Live parking fee (Payments BC, auto-refreshes every 20s).
///   - Occupancy summary of the lot (Parking BC).
///   - Latest notifications (Notifications BC).
///   - Emergency banner status (Dashboard BC, polled every 30s).
class DashboardController extends ChangeNotifier {
  DashboardController({
    required this.userId,
    PaymentRepository? paymentRepository,
    ParkingRepository? parkingRepository,
    NotificationsRepository? notificationsRepository,
    DashboardRepository? dashboardRepository,
  })  : _payments = paymentRepository ?? PaymentRepositoryImpl(),
        _parking = parkingRepository ?? ParkingRepositoryImpl(),
        _notifications = notificationsRepository ?? NotificationsRepositoryImpl(),
        _dashboard = dashboardRepository ?? DashboardRepositoryImpl();

  final int userId;
  final PaymentRepository _payments;
  final ParkingRepository _parking;
  final NotificationsRepository _notifications;
  final DashboardRepository _dashboard;

  // ───── State ─────
  ActiveSessionEntity? _activeSession;
  ActiveSessionEntity? get activeSession => _activeSession;

  ParkingFeeEntity? _currentFee;
  ParkingFeeEntity? get currentFee => _currentFee;

  OccupancySummaryEntity _occupancy = OccupancySummaryEntity.empty();
  OccupancySummaryEntity get occupancy => _occupancy;

  List<NotificationEntity> _recentNotifications = const [];
  List<NotificationEntity> get recentNotifications => _recentNotifications;

  EmergencyStatusEntity _emergencyStatus = EmergencyStatusEntity.normal();
  EmergencyStatusEntity get emergencyStatus => _emergencyStatus;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaying = false;
  bool get isPaying => _isPaying;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _refreshTimer;
  static const _refreshInterval = Duration(seconds: 30);

  // ───── Lifecycle ─────

  Future<void> load() async {
    _setLoading(true);
    _errorMessage = null;
    await _fetchAll();
    _setLoading(false);
    _schedulePeriodicRefresh();
  }

  /// Pull-to-refresh handler. Does not show the loading spinner.
  Future<void> refresh() async {
    await _fetchAll();
    notifyListeners();
  }

  Future<void> _fetchAll() async {
    try {
      final results = await Future.wait([
        _payments.getActiveSession(userId),
        _parking.occupancySummary(),
        _notifications.listAll(userId),
        _dashboard.getEmergencyStatus(),
      ]);
      _activeSession = results[0] as ActiveSessionEntity?;
      _occupancy = results[1] as OccupancySummaryEntity;
      _recentNotifications =
          (results[2] as List<NotificationEntity>).take(3).toList(growable: false);
      _emergencyStatus = results[3] as EmergencyStatusEntity;

      // Live fee only for active, unpaid sessions.
      final s = _activeSession;
      if (s != null && !s.isPaid) {
        try {
          _currentFee = await _payments.calculateFee(s.id);
        } catch (_) {/* keep previous */}
      } else {
        _currentFee = null;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'No se pudo cargar el dashboard.';
    }
  }

  void _schedulePeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => refresh());
  }

  // ───── Actions ─────

  /// Pay the active session. Used by the "Pay now" CTA in the hero card.
  Future<bool> pay(PaymentMethod method) async {
    final s = _activeSession;
    if (s == null || s.isPaid) return false;
    _isPaying = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Same dummy-token strategy as the Payments feature — the backend's
      // Culqi adapter is stubbed.
      final fakeToken = 'tkn_test_${s.id}_${DateTime.now().millisecondsSinceEpoch}';
      await _payments.initiatePayment(sessionId: s.id, method: method, token: fakeToken);
      await refresh(); // session flips to PAID
      _isPaying = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isPaying = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'No se pudo procesar el pago.';
      _isPaying = false;
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

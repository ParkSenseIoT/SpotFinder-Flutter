import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/reservation_repository_impl.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/usecases/reservation_usecases.dart';

/// State holder for the Reservations screens. One controller per logged-in user.
class ReservationsController extends ChangeNotifier {
  ReservationsController({required this.userId, ReservationRepository? repository})
      : _repository = repository ?? ReservationRepositoryImpl() {
    _listActiveUseCase = ListActiveReservationsUseCase(_repository);
    _listHistoryUseCase = ListReservationHistoryUseCase(_repository);
    _createUseCase = CreateReservationUseCase(_repository);
    _cancelUseCase = CancelReservationUseCase(_repository);
  }

  final int userId;
  final ReservationRepository _repository;
  late final ListActiveReservationsUseCase _listActiveUseCase;
  late final ListReservationHistoryUseCase _listHistoryUseCase;
  late final CreateReservationUseCase _createUseCase;
  late final CancelReservationUseCase _cancelUseCase;

  List<ReservationEntity> _active = const [];
  List<ReservationEntity> get active => _active;

  List<ReservationEntity> _history = const [];
  List<ReservationEntity> get history => _history;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Loads active + history in parallel.
  Future<void> load() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final results = await Future.wait([
        _listActiveUseCase.execute(userId),
        _listHistoryUseCase.execute(userId),
      ]);
      _active = results[0];
      _history = results[1];
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar las reservas.';
    } finally {
      _setLoading(false);
    }
  }

  /// Returns true on success.
  Future<bool> create({required int slotId, int? gracePeriodMinutes}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final created = await _createUseCase.execute(
        userId: userId,
        slotId: slotId,
        gracePeriodMinutes: gracePeriodMinutes,
      );
      _active = [..._active, created];
      _history = [created, ..._history];
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = 'Error inesperado al crear la reserva.';
      _setLoading(false);
      return false;
    }
  }

  /// Returns true on success.
  Future<bool> cancel({required int reservationId, String? reason}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final updated = await _cancelUseCase.execute(
        reservationId: reservationId,
        reason: reason,
      );
      _active = _active.where((r) => r.id != reservationId).toList(growable: false);
      _history = _history
          .map((r) => r.id == reservationId ? updated : r)
          .toList(growable: false);
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (_) {
      _errorMessage = 'Error inesperado al cancelar la reserva.';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

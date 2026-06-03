import '../../../../core/network/api_client.dart';
import '../../domain/entities/reservation_entity.dart';
import '../models/reservation_model.dart';

/// Contract for the Reservations feature against the SpotFinder backend.
abstract class ReservationRepository {
  /// `GET /api/v1/reservations/active?userId={userId}`
  Future<List<ReservationEntity>> listActive(int userId);

  /// `GET /api/v1/reservations/history?userId={userId}`
  Future<List<ReservationEntity>> listHistory(int userId);

  /// `POST /api/v1/reservations`
  Future<ReservationEntity> create({
    required int userId,
    required int slotId,
    DateTime? reservedFrom,
    int? gracePeriodMinutes,
  });

  /// `PATCH /api/v1/reservations/{id}/cancel`
  Future<ReservationEntity> cancel({required int reservationId, String? reason});
}

class ReservationRepositoryImpl implements ReservationRepository {
  ReservationRepositoryImpl({ApiClient? api}) : _api = api ?? ApiClient();
  final ApiClient _api;

  @override
  Future<List<ReservationEntity>> listActive(int userId) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/reservations/active',
      query: {'userId': userId},
    );
    final raw = response.data ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ReservationModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<ReservationEntity>> listHistory(int userId) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/reservations/history',
      query: {'userId': userId},
    );
    final raw = response.data ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ReservationModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<ReservationEntity> create({
    required int userId,
    required int slotId,
    DateTime? reservedFrom,
    int? gracePeriodMinutes,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/reservations',
      body: {
        'userId': userId,
        'slotId': slotId,
        if (reservedFrom != null) 'reservedFrom': reservedFrom.toIso8601String(),
        if (gracePeriodMinutes != null) 'gracePeriodMinutes': gracePeriodMinutes,
      },
    );
    final data = response.data;
    if (data == null) {
      throw ApiException(statusCode: 500, message: 'Respuesta vacía del servidor');
    }
    return ReservationModel.fromJson(data);
  }

  @override
  Future<ReservationEntity> cancel({required int reservationId, String? reason}) async {
    final response = await _api.patch<Map<String, dynamic>>(
      '/api/v1/reservations/$reservationId/cancel',
      body: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    final data = response.data;
    if (data == null) {
      throw ApiException(statusCode: 500, message: 'Respuesta vacía del servidor');
    }
    return ReservationModel.fromJson(data);
  }
}

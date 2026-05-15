import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/active_session_entity.dart';
import '../../domain/entities/parking_fee_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_method.dart';
import '../models/active_session_model.dart';
import '../models/parking_fee_model.dart';
import '../models/payment_model.dart';

/// Contract for everything the Payments feature reads/writes against the backend.
abstract class PaymentRepository {
  /// `GET /api/v1/parking-sessions/active?userId={userId}`.
  /// Returns null if the driver has no active session (HTTP 404).
  Future<ActiveSessionEntity?> getActiveSession(int userId);

  /// `GET /api/v1/payments/calculate-fee/{sessionId}` — live fee for a session.
  Future<ParkingFeeEntity> calculateFee(int sessionId);

  /// `POST /api/v1/payments` — sends to Culqi (stubbed on the server).
  Future<PaymentEntity> initiatePayment({
    required int sessionId,
    required PaymentMethod method,
    required String token,
  });

  /// `GET /api/v1/payments/history?userId={userId}`.
  Future<List<PaymentEntity>> getHistory(int userId);
}

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({ApiClient? api}) : _api = api ?? ApiClient();
  final ApiClient _api;

  @override
  Future<ActiveSessionEntity?> getActiveSession(int userId) async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        '/api/v1/parking-sessions/active',
        query: {'userId': userId},
      );
      final data = response.data;
      if (data == null) return null;
      return ActiveSessionModel.fromJson(data);
    } on ApiException catch (e) {
      // 404 == driver has no active session right now. Treat as "no data" silently.
      if (e.statusCode == 404) return null;
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<ParkingFeeEntity> calculateFee(int sessionId) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/payments/calculate-fee/$sessionId',
    );
    final data = response.data;
    if (data == null) return ParkingFeeEntity.empty();
    return ParkingFeeModel.fromJson(data);
  }

  @override
  Future<PaymentEntity> initiatePayment({
    required int sessionId,
    required PaymentMethod method,
    required String token,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/payments',
      body: {
        'sessionId': sessionId,
        'paymentMethod': method.apiValue,
        'token': token,
      },
    );
    final data = response.data;
    if (data == null) {
      throw ApiException(statusCode: 500, message: 'Respuesta vacía del servidor');
    }
    return PaymentModel.fromJson(data);
  }

  @override
  Future<List<PaymentEntity>> getHistory(int userId) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/payments/history',
      query: {'userId': userId},
    );
    final raw = response.data ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(PaymentModel.fromJson)
        .toList(growable: false);
  }
}

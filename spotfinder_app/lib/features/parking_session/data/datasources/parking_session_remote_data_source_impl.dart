import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../dtos/parking_fee_dto.dart';
import '../dtos/parking_session_dto.dart';
import 'parking_session_remote_data_source.dart';

class ParkingSessionRemoteDataSourceImpl implements ParkingSessionRemoteDataSource {
  ParkingSessionRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<ParkingSessionDto?> getActive(int userId) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/parking-sessions/active',
        queryParameters: {'userId': userId},
      );
      return ParkingSessionDto.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<ParkingSessionDto> getById(int sessionId) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/parking-sessions/$sessionId',
    );
    return ParkingSessionDto.fromJson(response.data!);
  }

  @override
  Future<List<ParkingSessionDto>> getHistory(int userId) async {
    final response = await _client.dio.get<List<dynamic>>(
      '/parking-sessions/history',
      queryParameters: {'userId': userId},
    );
    return (response.data ?? const [])
        .map((e) => ParkingSessionDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> end(int sessionId) async {
    await _client.dio.patch<dynamic>('/parking-sessions/$sessionId/end');
  }

  @override
  Future<ParkingFeeDto> calculateFee(int sessionId) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/payments/calculate-fee/$sessionId',
    );
    return ParkingFeeDto.fromJson(response.data!);
  }
}

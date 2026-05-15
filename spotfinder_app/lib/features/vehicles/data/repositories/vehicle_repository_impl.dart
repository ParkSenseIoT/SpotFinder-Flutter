import '../../../../core/network/api_client.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../models/vehicle_model.dart';

/// Contract for the Vehicles feature against the SpotFinder backend.
abstract class VehicleRepository {
  /// `GET /api/v1/users/{userId}/vehicles`
  Future<List<VehicleEntity>> listForUser(int userId);

  /// `POST /api/v1/users/{userId}/vehicles`
  Future<VehicleEntity> register({
    required int userId,
    required String plate,
    String? brand,
    String? model,
    String? color,
  });

  /// `DELETE /api/v1/users/{userId}/vehicles/{vehicleId}`
  Future<void> delete({required int userId, required int vehicleId});
}

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl({ApiClient? api}) : _api = api ?? ApiClient();
  final ApiClient _api;

  @override
  Future<List<VehicleEntity>> listForUser(int userId) async {
    final response = await _api.get<List<dynamic>>('/api/v1/users/$userId/vehicles');
    final raw = response.data ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(VehicleModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<VehicleEntity> register({
    required int userId,
    required String plate,
    String? brand,
    String? model,
    String? color,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/users/$userId/vehicles',
      body: {
        'plate': plate.trim(),
        if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
        if (model != null && model.trim().isNotEmpty) 'model': model.trim(),
        if (color != null && color.trim().isNotEmpty) 'color': color.trim(),
      },
    );
    final data = response.data;
    if (data == null) {
      throw ApiException(statusCode: 500, message: 'Respuesta vacía del servidor');
    }
    return VehicleModel.fromJson(data);
  }

  @override
  Future<void> delete({required int userId, required int vehicleId}) async {
    await _api.delete<dynamic>('/api/v1/users/$userId/vehicles/$vehicleId');
  }
}

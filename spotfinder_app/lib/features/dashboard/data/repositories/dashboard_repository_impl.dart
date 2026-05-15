import '../../../../core/network/api_client.dart';
import '../../domain/entities/emergency_status_entity.dart';
import '../models/emergency_status_model.dart';

/// Repository for dashboard-specific reads.
///
/// Most of the dashboard data is pulled from existing feature repositories
/// (PaymentRepository for active session, ParkingRepository for occupancy,
/// NotificationsRepository for the inbox). The only piece that's specific
/// to this feature is the emergency status banner.
abstract class DashboardRepository {
  /// `GET /api/v1/emergency/status`.
  Future<EmergencyStatusEntity> getEmergencyStatus();
}

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({ApiClient? api}) : _api = api ?? ApiClient();
  final ApiClient _api;

  @override
  Future<EmergencyStatusEntity> getEmergencyStatus() async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        '/api/v1/emergency/status',
      );
      final data = response.data;
      if (data == null) return EmergencyStatusEntity.normal();
      return EmergencyStatusModel.fromJson(data);
    } on ApiException {
      // Backend may not be reachable or the user lacks permissions —
      // gracefully degrade to "no emergency".
      return EmergencyStatusEntity.normal();
    }
  }
}

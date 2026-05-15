import '../../../../core/network/api_client.dart';
import '../../domain/entities/occupancy_summary_entity.dart';
import '../../domain/entities/parking_slot_entity.dart';
import '../models/occupancy_summary_model.dart';
import '../models/parking_slot_model.dart';

/// Read-only operations against the parking-slots API.
abstract class ParkingRepository {
  /// `GET /api/v1/parking-slots` (optionally filtered by facility).
  Future<List<ParkingSlotEntity>> listSlots({int? facilityId});

  /// `GET /api/v1/parking-slots/occupancy` summary.
  Future<OccupancySummaryEntity> occupancySummary({int? facilityId});
}

class ParkingRepositoryImpl implements ParkingRepository {
  ParkingRepositoryImpl({ApiClient? api}) : _api = api ?? ApiClient();
  final ApiClient _api;

  @override
  Future<List<ParkingSlotEntity>> listSlots({int? facilityId}) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/parking-slots',
      query: facilityId == null ? null : {'facilityId': facilityId},
    );
    final raw = response.data ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ParkingSlotModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<OccupancySummaryEntity> occupancySummary({int? facilityId}) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/api/v1/parking-slots/occupancy',
      query: facilityId == null ? null : {'facilityId': facilityId},
    );
    final data = response.data;
    if (data == null) return OccupancySummaryEntity.empty();
    return OccupancySummaryModel.fromJson(data);
  }
}

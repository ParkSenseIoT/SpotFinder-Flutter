import '../../domain/entities/occupancy_summary_entity.dart';

/// JSON mapper for `OccupancySummaryResource` (REST) and `/topic/occupancy` payload (STOMP).
class OccupancySummaryModel extends OccupancySummaryEntity {
  const OccupancySummaryModel({
    required super.total,
    required super.available,
    required super.occupied,
    required super.occupancyRate,
  });

  factory OccupancySummaryModel.fromJson(Map<String, dynamic> json) {
    return OccupancySummaryModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      available: (json['available'] as num?)?.toInt() ?? 0,
      occupied: (json['occupied'] as num?)?.toInt() ?? 0,
      occupancyRate: (json['occupancyRate'] as num?)?.toDouble() ?? 0,
    );
  }
}

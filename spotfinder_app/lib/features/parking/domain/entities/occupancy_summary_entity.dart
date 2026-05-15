/// Aggregated counts of slot statuses.
/// Returned by `GET /api/v1/parking-slots/occupancy` and also pushed via
/// the `/topic/occupancy` STOMP destination.
class OccupancySummaryEntity {
  final int total;
  final int available;
  final int occupied;
  final double occupancyRate; // 0..1

  const OccupancySummaryEntity({
    required this.total,
    required this.available,
    required this.occupied,
    required this.occupancyRate,
  });

  factory OccupancySummaryEntity.empty() => const OccupancySummaryEntity(
        total: 0,
        available: 0,
        occupied: 0,
        occupancyRate: 0,
      );

  /// Whole-number percentage, e.g. 73.
  int get percentage => (occupancyRate * 100).round();
}

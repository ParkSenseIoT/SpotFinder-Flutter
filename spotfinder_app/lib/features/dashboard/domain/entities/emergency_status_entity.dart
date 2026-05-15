/// Current emergency status of the parking facility.
/// Matches the backend's `EmergencyStatusResource`.
class EmergencyStatusEntity {
  final bool isActive;
  final int? emergencyId;
  final String? type; // GAS | SMOKE
  final int gasLevel;
  final String? sensorLocation;
  final DateTime? triggeredAt;
  final String overallStatus; // NORMAL | EMERGENCY

  const EmergencyStatusEntity({
    required this.isActive,
    required this.gasLevel,
    required this.overallStatus,
    this.emergencyId,
    this.type,
    this.sensorLocation,
    this.triggeredAt,
  });

  factory EmergencyStatusEntity.normal() => const EmergencyStatusEntity(
        isActive: false,
        gasLevel: 0,
        overallStatus: 'NORMAL',
      );
}

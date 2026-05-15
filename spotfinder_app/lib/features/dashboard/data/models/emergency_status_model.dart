import '../../domain/entities/emergency_status_entity.dart';

class EmergencyStatusModel extends EmergencyStatusEntity {
  const EmergencyStatusModel({
    required super.isActive,
    required super.gasLevel,
    required super.overallStatus,
    super.emergencyId,
    super.type,
    super.sensorLocation,
    super.triggeredAt,
  });

  factory EmergencyStatusModel.fromJson(Map<String, dynamic> json) {
    return EmergencyStatusModel(
      isActive: json['emergencyActive'] == true || json['isEmergencyActive'] == true,
      emergencyId: json['emergencyId'] is num ? (json['emergencyId'] as num).toInt() : null,
      type: json['type'] as String?,
      gasLevel: (json['gasLevel'] as num?)?.toInt() ?? 0,
      sensorLocation: json['sensorLocation'] as String?,
      triggeredAt: DateTime.tryParse((json['triggeredAt'] ?? '').toString()),
      overallStatus: (json['overallStatus'] ?? 'NORMAL').toString(),
    );
  }
}

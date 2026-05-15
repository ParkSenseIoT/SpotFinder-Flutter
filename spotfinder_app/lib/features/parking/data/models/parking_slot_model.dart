import '../../domain/entities/parking_slot_entity.dart';

/// JSON mapper for the backend's `ParkingSlotResource`.
class ParkingSlotModel extends ParkingSlotEntity {
  const ParkingSlotModel({
    required super.id,
    required super.slotCode,
    required super.status,
    super.sensorId,
    super.facilityId,
    super.lastUpdated,
  });

  factory ParkingSlotModel.fromJson(Map<String, dynamic> json) {
    DateTime? updated;
    final raw = json['lastUpdated'];
    if (raw is String && raw.isNotEmpty) {
      updated = DateTime.tryParse(raw);
    }
    return ParkingSlotModel(
      id: (json['id'] as num).toInt(),
      slotCode: (json['slotCode'] ?? '').toString(),
      status: SlotStatus.fromString(json['status'] as String?),
      sensorId: json['sensorId'] as String?,
      facilityId: json['facilityId'] is num
          ? (json['facilityId'] as num).toInt()
          : null,
      lastUpdated: updated,
    );
  }
}

import '../../domain/entities/active_session_entity.dart';

class ActiveSessionModel extends ActiveSessionEntity {
  const ActiveSessionModel({
    required super.id,
    required super.licensePlate,
    required super.entryTimestamp,
    required super.paymentStatus,
    required super.sessionStatus,
    required super.currentDuration,
    super.exitTimestamp,
    super.slotId,
  });

  factory ActiveSessionModel.fromJson(Map<String, dynamic> json) {
    return ActiveSessionModel(
      id: (json['id'] as num).toInt(),
      licensePlate: (json['licensePlate'] ?? '').toString(),
      entryTimestamp: DateTime.tryParse((json['entryTimestamp'] ?? '').toString()) ?? DateTime.now(),
      exitTimestamp: DateTime.tryParse((json['exitTimestamp'] ?? '').toString()),
      slotId: json['slotId'] is num ? (json['slotId'] as num).toInt() : null,
      paymentStatus: (json['paymentStatus'] ?? 'PENDING').toString(),
      sessionStatus: (json['sessionStatus'] ?? 'ACTIVE').toString(),
      currentDuration: (json['currentDuration'] ?? '0h 0min').toString(),
    );
  }
}

class ParkingSessionDto {
  const ParkingSessionDto({
    required this.id,
    required this.licensePlate,
    required this.entryTimestamp,
    required this.exitTimestamp,
    required this.slotId,
    required this.paymentStatus,
    required this.sessionStatus,
    required this.currentDuration,
    required this.userId,
  });

  final int id;
  final String licensePlate;
  final String entryTimestamp;
  final String? exitTimestamp;
  final int? slotId;
  final String? paymentStatus;
  final String? sessionStatus;
  final String? currentDuration;
  final int userId;

  factory ParkingSessionDto.fromJson(Map<String, dynamic> json) {
    return ParkingSessionDto(
      id: (json['id'] as num).toInt(),
      licensePlate: json['licensePlate'] as String? ?? '',
      entryTimestamp: json['entryTimestamp'] as String,
      exitTimestamp: json['exitTimestamp'] as String?,
      slotId: (json['slotId'] as num?)?.toInt(),
      paymentStatus: json['paymentStatus'] as String?,
      sessionStatus: json['sessionStatus'] as String?,
      currentDuration: json['currentDuration'] as String?,
      userId: (json['userId'] as num).toInt(),
    );
  }
}

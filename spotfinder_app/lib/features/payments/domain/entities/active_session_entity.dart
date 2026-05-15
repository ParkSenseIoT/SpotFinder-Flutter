/// Snapshot of the driver's active vehicle session. Matches `VehicleSessionResource`.
class ActiveSessionEntity {
  final int id;
  final String licensePlate;
  final DateTime entryTimestamp;
  final DateTime? exitTimestamp;
  final int? slotId;
  final String paymentStatus; // PENDING / PAID
  final String sessionStatus; // ACTIVE / COMPLETED
  final String currentDuration; // pre-formatted from backend, e.g. "1h 23min"

  const ActiveSessionEntity({
    required this.id,
    required this.licensePlate,
    required this.entryTimestamp,
    required this.paymentStatus,
    required this.sessionStatus,
    required this.currentDuration,
    this.exitTimestamp,
    this.slotId,
  });

  bool get isPaid => paymentStatus.toUpperCase() == 'PAID';
  bool get isActive => sessionStatus.toUpperCase() == 'ACTIVE';
}

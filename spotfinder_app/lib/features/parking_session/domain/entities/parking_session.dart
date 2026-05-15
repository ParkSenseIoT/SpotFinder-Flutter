import 'package:equatable/equatable.dart';

import '../value_objects/payment_status.dart';
import '../value_objects/session_status.dart';

class ParkingSession extends Equatable {
  const ParkingSession({
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
  final DateTime entryTimestamp;
  final DateTime? exitTimestamp;
  final int? slotId;
  final PaymentStatus paymentStatus;
  final SessionStatus sessionStatus;
  final Duration currentDuration;
  final int userId;

  bool get isActive => sessionStatus == SessionStatus.active && exitTimestamp == null;

  Duration durationSinceEntry(DateTime now) {
    final reference = exitTimestamp ?? now;
    return reference.difference(entryTimestamp);
  }

  @override
  List<Object?> get props => [
        id,
        licensePlate,
        entryTimestamp,
        exitTimestamp,
        slotId,
        paymentStatus,
        sessionStatus,
        currentDuration,
        userId,
      ];
}

import '../../domain/entities/parking_session.dart';
import '../../domain/value_objects/payment_status.dart';
import '../../domain/value_objects/session_status.dart';
import '../dtos/parking_session_dto.dart';

class ParkingSessionMapper {
  const ParkingSessionMapper._();

  static ParkingSession toEntity(ParkingSessionDto dto) {
    return ParkingSession(
      id: dto.id,
      licensePlate: dto.licensePlate,
      entryTimestamp: _parseDate(dto.entryTimestamp)!,
      exitTimestamp: _parseDate(dto.exitTimestamp),
      slotId: dto.slotId,
      paymentStatus: PaymentStatus.fromString(dto.paymentStatus),
      sessionStatus: SessionStatus.fromString(dto.sessionStatus),
      currentDuration: _parseDuration(dto.currentDuration),
      userId: dto.userId,
    );
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static Duration _parseDuration(String? raw) {
    if (raw == null || raw.isEmpty) return Duration.zero;
    final parts = raw.split(':');
    if (parts.length != 3) return Duration.zero;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final seconds = int.tryParse(parts[2]) ?? 0;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
}

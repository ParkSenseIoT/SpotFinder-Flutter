import '../../domain/entities/reservation_entity.dart';

/// Marshalling between the JSON shape of `/api/v1/reservations/...` and
/// the domain `ReservationEntity`.
class ReservationModel {
  static ReservationEntity fromJson(Map<String, dynamic> json) {
    return ReservationEntity(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      slotId: (json['slotId'] as num).toInt(),
      status: ReservationStatus.fromApi(json['status'] as String?),
      reservedFrom: DateTime.parse(json['reservedFrom'] as String),
      reservedUntil: DateTime.parse(json['reservedUntil'] as String),
      gracePeriodMinutes: (json['gracePeriodMinutes'] as num).toInt(),
      confirmedAt: _parseNullableDate(json['confirmedAt']),
      cancelledAt: _parseNullableDate(json['cancelledAt']),
      expiredAt: _parseNullableDate(json['expiredAt']),
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: _parseNullableDate(json['createdAt']),
    );
  }

  static DateTime? _parseNullableDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is! String) return null;
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

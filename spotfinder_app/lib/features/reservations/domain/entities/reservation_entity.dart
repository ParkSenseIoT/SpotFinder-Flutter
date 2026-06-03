/// Lifecycle of a reservation, mirrors the backend enum.
enum ReservationStatus {
  pending('PENDING', 'Pendiente'),
  confirmed('CONFIRMED', 'Confirmada'),
  expired('EXPIRED', 'Expirada'),
  cancelled('CANCELLED', 'Cancelada');

  const ReservationStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ReservationStatus fromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'PENDING':
        return ReservationStatus.pending;
      case 'CONFIRMED':
        return ReservationStatus.confirmed;
      case 'EXPIRED':
        return ReservationStatus.expired;
      case 'CANCELLED':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.pending;
    }
  }
}

/// Plain data carrier for the UI. Mirrors backend `ReservationResource`.
class ReservationEntity {
  final int id;
  final int userId;
  final int slotId;
  final ReservationStatus status;
  final DateTime reservedFrom;
  final DateTime reservedUntil;
  final int gracePeriodMinutes;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final DateTime? expiredAt;
  final String? cancellationReason;
  final DateTime? createdAt;

  const ReservationEntity({
    required this.id,
    required this.userId,
    required this.slotId,
    required this.status,
    required this.reservedFrom,
    required this.reservedUntil,
    required this.gracePeriodMinutes,
    this.confirmedAt,
    this.cancelledAt,
    this.expiredAt,
    this.cancellationReason,
    this.createdAt,
  });

  bool get isPending => status == ReservationStatus.pending;
  bool get isConfirmed => status == ReservationStatus.confirmed;
  bool get isActive => isPending || isConfirmed;
  bool get canBeCancelled => isPending;

  /// Minutes left before the grace period elapses. Returns 0 when negative or terminal.
  int get minutesLeft {
    if (!isPending) return 0;
    final diff = reservedUntil.difference(DateTime.now()).inMinutes;
    return diff < 0 ? 0 : diff;
  }
}

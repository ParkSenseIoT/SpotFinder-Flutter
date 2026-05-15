/// Mirrors `NotificationStatus` from the backend.
enum NotificationStatus {
  pending,
  sent,
  delivered,
  read,
  failed,
  unknown;

  String get apiValue {
    switch (this) {
      case NotificationStatus.pending:
        return 'PENDING';
      case NotificationStatus.sent:
        return 'SENT';
      case NotificationStatus.delivered:
        return 'DELIVERED';
      case NotificationStatus.read:
        return 'READ';
      case NotificationStatus.failed:
        return 'FAILED';
      case NotificationStatus.unknown:
        return 'UNKNOWN';
    }
  }

  static NotificationStatus fromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'PENDING':
        return NotificationStatus.pending;
      case 'SENT':
        return NotificationStatus.sent;
      case 'DELIVERED':
        return NotificationStatus.delivered;
      case 'READ':
        return NotificationStatus.read;
      case 'FAILED':
        return NotificationStatus.failed;
      default:
        return NotificationStatus.unknown;
    }
  }

  bool get isRead => this == NotificationStatus.read;
}

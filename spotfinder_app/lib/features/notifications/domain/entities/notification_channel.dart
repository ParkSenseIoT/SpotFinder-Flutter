/// Mirrors `NotificationChannel` from the backend.
enum NotificationChannel {
  push,
  inApp,
  unknown;

  String get apiValue {
    switch (this) {
      case NotificationChannel.push:
        return 'PUSH';
      case NotificationChannel.inApp:
        return 'IN_APP';
      case NotificationChannel.unknown:
        return 'UNKNOWN';
    }
  }

  static NotificationChannel fromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'PUSH':
        return NotificationChannel.push;
      case 'IN_APP':
        return NotificationChannel.inApp;
      default:
        return NotificationChannel.unknown;
    }
  }
}

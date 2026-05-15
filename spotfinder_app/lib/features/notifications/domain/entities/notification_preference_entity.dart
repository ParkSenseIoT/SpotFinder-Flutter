import 'notification_type.dart';

/// Per-user toggle for a notification [NotificationType].
/// Matches `NotificationPreferenceResource` on the backend.
class NotificationPreferenceEntity {
  final NotificationType type;
  final bool enabled;

  const NotificationPreferenceEntity({
    required this.type,
    required this.enabled,
  });

  NotificationPreferenceEntity copyWith({bool? enabled}) {
    return NotificationPreferenceEntity(
      type: type,
      enabled: enabled ?? this.enabled,
    );
  }
}

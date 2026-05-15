import 'notification_channel.dart';
import 'notification_status.dart';
import 'notification_type.dart';

/// A persisted notification record. Matches `NotificationResource`.
class NotificationEntity {
  final int id;
  final int userId;
  final NotificationType type;
  final String title;
  final String body;
  final NotificationStatus status;
  final NotificationChannel channel;
  final DateTime? createdAt;
  final DateTime? readAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.status,
    required this.channel,
    this.createdAt,
    this.readAt,
  });

  bool get isRead => status.isRead || readAt != null;

  NotificationEntity copyWith({
    NotificationStatus? status,
    DateTime? readAt,
  }) {
    return NotificationEntity(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      status: status ?? this.status,
      channel: channel,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

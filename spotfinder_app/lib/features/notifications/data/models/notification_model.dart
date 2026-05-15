import '../../domain/entities/notification_channel.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_status.dart';
import '../../domain/entities/notification_type.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.body,
    required super.status,
    required super.channel,
    super.createdAt,
    super.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      type: NotificationType.fromApi(json['type'] as String?),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      status: NotificationStatus.fromApi(json['status'] as String?),
      channel: NotificationChannel.fromApi(json['channel'] as String?),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      readAt: DateTime.tryParse((json['readAt'] ?? '').toString()),
    );
  }
}

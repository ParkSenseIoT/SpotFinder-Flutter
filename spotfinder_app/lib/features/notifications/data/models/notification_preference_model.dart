import '../../domain/entities/notification_preference_entity.dart';
import '../../domain/entities/notification_type.dart';

class NotificationPreferenceModel extends NotificationPreferenceEntity {
  const NotificationPreferenceModel({
    required super.type,
    required super.enabled,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      type: NotificationType.fromApi(json['notificationType'] as String?),
      enabled: (json['enabled'] as bool?) ?? false,
    );
  }

  /// Shape expected by `UpdatePreferencesResource.preferences[*]` on the
  /// backend: `{ "notificationType": "...", "enabled": bool }`.
  Map<String, dynamic> toJson() => {
        'notificationType': type.apiValue,
        'enabled': enabled,
      };

  static Map<String, dynamic> entityToJson(NotificationPreferenceEntity entity) {
    return {
      'notificationType': entity.type.apiValue,
      'enabled': entity.enabled,
    };
  }
}

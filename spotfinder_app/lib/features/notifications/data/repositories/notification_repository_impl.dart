import '../../../../core/network/api_client.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_preference_entity.dart';
import '../models/notification_model.dart';
import '../models/notification_preference_model.dart';

/// Contract for everything the Notifications feature reads/writes against the backend.
abstract class NotificationsRepository {
  /// `GET /api/v1/notifications/user/{userId}` — every notification for the user.
  Future<List<NotificationEntity>> listAll(int userId);

  /// `GET /api/v1/notifications/user/{userId}/unread` — only unread.
  Future<List<NotificationEntity>> listUnread(int userId);

  /// `PATCH /api/v1/notifications/{id}/read`.
  Future<void> markAsRead(int notificationId);

  /// `GET /api/v1/users/{userId}/notification-preferences`.
  ///
  /// Backend seeds defaults if the user has none, so this should always
  /// return one entry per configurable type.
  Future<List<NotificationPreferenceEntity>> getPreferences(int userId);

  /// `PUT /api/v1/users/{userId}/notification-preferences`.
  Future<void> updatePreferences(
    int userId,
    List<NotificationPreferenceEntity> preferences,
  );
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({ApiClient? api}) : _api = api ?? ApiClient();
  final ApiClient _api;

  @override
  Future<List<NotificationEntity>> listAll(int userId) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/notifications/user/$userId',
    );
    return _parseList(response.data);
  }

  @override
  Future<List<NotificationEntity>> listUnread(int userId) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/notifications/user/$userId/unread',
    );
    return _parseList(response.data);
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await _api.patch<void>('/api/v1/notifications/$notificationId/read');
  }

  @override
  Future<List<NotificationPreferenceEntity>> getPreferences(int userId) async {
    final response = await _api.get<List<dynamic>>(
      '/api/v1/users/$userId/notification-preferences',
    );
    final raw = response.data ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(NotificationPreferenceModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<void> updatePreferences(
    int userId,
    List<NotificationPreferenceEntity> preferences,
  ) async {
    await _api.put<void>(
      '/api/v1/users/$userId/notification-preferences',
      body: {
        'preferences': preferences
            .map(NotificationPreferenceModel.entityToJson)
            .toList(growable: false),
      },
    );
  }

  List<NotificationEntity> _parseList(List<dynamic>? raw) {
    if (raw == null) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(NotificationModel.fromJson)
        .toList(growable: false);
  }
}

import '../../data/repositories/notification_repository_impl.dart';
import '../entities/notification_entity.dart';
import '../entities/notification_preference_entity.dart';

class GetNotificationsUseCase {
  GetNotificationsUseCase(this.repository);
  final NotificationsRepository repository;

  Future<List<NotificationEntity>> execute(int userId) =>
      repository.listAll(userId);
}

class GetUnreadNotificationsUseCase {
  GetUnreadNotificationsUseCase(this.repository);
  final NotificationsRepository repository;

  Future<List<NotificationEntity>> execute(int userId) =>
      repository.listUnread(userId);
}

class MarkNotificationAsReadUseCase {
  MarkNotificationAsReadUseCase(this.repository);
  final NotificationsRepository repository;

  Future<void> execute(int notificationId) =>
      repository.markAsRead(notificationId);
}

class GetNotificationPreferencesUseCase {
  GetNotificationPreferencesUseCase(this.repository);
  final NotificationsRepository repository;

  Future<List<NotificationPreferenceEntity>> execute(int userId) =>
      repository.getPreferences(userId);
}

class UpdateNotificationPreferencesUseCase {
  UpdateNotificationPreferencesUseCase(this.repository);
  final NotificationsRepository repository;

  Future<void> execute(int userId, List<NotificationPreferenceEntity> prefs) =>
      repository.updatePreferences(userId, prefs);
}

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/notification_usecases.dart';

/// State holder for the notification center (inbox).
///
/// Responsibilities:
///   - Fetch every notification for the current user.
///   - Track which ones are unread (drives the bell badge).
///   - Optimistically mark a notification as read when the user opens it,
///     persisting the change with `PATCH /api/v1/notifications/{id}/read`.
class NotificationsController extends ChangeNotifier {
  NotificationsController({
    required this.userId,
    NotificationsRepository? repository,
  }) : _repository = repository ?? NotificationsRepositoryImpl() {
    _getAll = GetNotificationsUseCase(_repository);
    _markRead = MarkNotificationAsReadUseCase(_repository);
  }

  final int userId;
  final NotificationsRepository _repository;
  late final GetNotificationsUseCase _getAll;
  late final MarkNotificationAsReadUseCase _markRead;

  List<NotificationEntity> _notifications = const [];
  List<NotificationEntity> get notifications => _notifications;

  List<NotificationEntity> get unread =>
      _notifications.where((n) => !n.isRead).toList(growable: false);

  int get unreadCount => unread.length;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _disposed = false;

  Future<void> load() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _notifications = await _getAll.execute(userId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar las notificaciones.';
    } finally {
      _setLoading(false);
    }
  }

  /// Pull-to-refresh — same as [load] but without the loading overlay.
  Future<void> refresh() async {
    try {
      _notifications = await _getAll.execute(userId);
      _errorMessage = null;
      _safeNotify();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _safeNotify();
    }
  }

  /// Optimistically marks the notification as read and persists.
  /// Reverts the local change if the backend rejects it.
  Future<void> markAsRead(NotificationEntity notification) async {
    if (notification.isRead) return;

    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index == -1) return;

    final original = _notifications[index];
    _notifications = List.of(_notifications)
      ..[index] = original.copyWith(readAt: DateTime.now());
    _safeNotify();

    try {
      await _markRead.execute(notification.id);
    } catch (_) {
      // Revert on failure so the badge stays consistent with the backend.
      final i = _notifications.indexWhere((n) => n.id == notification.id);
      if (i != -1) {
        _notifications = List.of(_notifications)..[i] = original;
        _safeNotify();
      }
    }
  }

  /// Convenience: marks every still-unread notification as read.
  Future<void> markAllAsRead() async {
    final pending = unread;
    if (pending.isEmpty) return;
    for (final n in pending) {
      await markAsRead(n);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _safeNotify();
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

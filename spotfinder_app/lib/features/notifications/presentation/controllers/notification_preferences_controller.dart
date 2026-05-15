import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification_preference_entity.dart';
import '../../domain/entities/notification_type.dart';
import '../../domain/usecases/notification_usecases.dart';

/// State holder for the notification preferences screen.
///
/// Responsibilities:
///   - Fetch the current preferences (the backend seeds defaults if missing).
///   - Apply local toggles and persist them with PUT.
///   - Refuse to toggle `EMERGENCY_ALERT` off — that one is locked on per spec.
class NotificationPreferencesController extends ChangeNotifier {
  NotificationPreferencesController({
    required this.userId,
    NotificationsRepository? repository,
  }) : _repository = repository ?? NotificationsRepositoryImpl() {
    _getPrefs = GetNotificationPreferencesUseCase(_repository);
    _updatePrefs = UpdateNotificationPreferencesUseCase(_repository);
  }

  final int userId;
  final NotificationsRepository _repository;
  late final GetNotificationPreferencesUseCase _getPrefs;
  late final UpdateNotificationPreferencesUseCase _updatePrefs;

  Map<NotificationType, bool> _preferences = const {};
  Map<NotificationType, bool> get preferences => _preferences;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _disposed = false;

  Future<void> load() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await _getPrefs.execute(userId);
      _preferences = _mergeWithDefaults(result);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _preferences = _defaults();
    } catch (_) {
      _errorMessage = 'No se pudieron cargar las preferencias.';
      _preferences = _defaults();
    } finally {
      _setLoading(false);
    }
  }

  /// Toggles a preference locally and persists it.
  /// Reverts the change if the server rejects it.
  Future<bool> setEnabled(NotificationType type, bool enabled) async {
    if (type.isMandatory) return false; // EMERGENCY_ALERT can't be turned off
    final previous = _preferences[type] ?? true;
    if (previous == enabled) return true;

    _preferences = Map.of(_preferences)..[type] = enabled;
    _isSaving = true;
    _errorMessage = null;
    _safeNotify();

    try {
      final payload = _preferences.entries
          .map((e) => NotificationPreferenceEntity(type: e.key, enabled: e.value))
          .toList(growable: false);
      await _updatePrefs.execute(userId, payload);
      _isSaving = false;
      _safeNotify();
      return true;
    } on ApiException catch (e) {
      // Revert.
      _preferences = Map.of(_preferences)..[type] = previous;
      _errorMessage = e.message;
      _isSaving = false;
      _safeNotify();
      return false;
    } catch (_) {
      _preferences = Map.of(_preferences)..[type] = previous;
      _errorMessage = 'No se pudieron guardar los cambios.';
      _isSaving = false;
      _safeNotify();
      return false;
    }
  }

  Map<NotificationType, bool> _mergeWithDefaults(
    List<NotificationPreferenceEntity> server,
  ) {
    final map = _defaults();
    for (final pref in server) {
      if (pref.type == NotificationType.unknown) continue;
      map[pref.type] = pref.enabled;
    }
    // Emergency must always be on regardless of what the server returns.
    map[NotificationType.emergencyAlert] = true;
    return map;
  }

  Map<NotificationType, bool> _defaults() {
    return {
      for (final t in NotificationType.configurable) t: true,
    };
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

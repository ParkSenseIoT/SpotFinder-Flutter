import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/password_change_request.dart';
import '../../domain/usecases/settings_usecases.dart';

/// State holder for the Change Password form.
class ChangePasswordController extends ChangeNotifier {
  ChangePasswordController({
    required this.userId,
    SettingsRepository? repository,
  }) : _repository = repository ?? SettingsRepositoryImpl() {
    _changePassword = ChangePasswordUseCase(_repository);
  }

  final int userId;
  final SettingsRepository _repository;
  late final ChangePasswordUseCase _changePassword;

  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  String get currentPassword => _currentPassword;
  String get newPassword => _newPassword;
  String get confirmPassword => _confirmPassword;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _success = false;
  bool get success => _success;

  void setCurrentPassword(String value) {
    _currentPassword = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setNewPassword(String value) {
    _newPassword = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    _errorMessage = null;
    notifyListeners();
  }

  /// Returns null if every field is valid, or a localized error message.
  String? validate() {
    if (_currentPassword.isEmpty) return 'Ingresa tu contraseña actual.';
    if (_newPassword.length < 8) {
      return 'La nueva contraseña debe tener al menos 8 caracteres.';
    }
    if (_newPassword == _currentPassword) {
      return 'La nueva contraseña debe ser distinta a la actual.';
    }
    if (_newPassword != _confirmPassword) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  Future<bool> save() async {
    final clientError = validate();
    if (clientError != null) {
      _errorMessage = clientError;
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _success = false;
    notifyListeners();

    try {
      await _changePassword.execute(
        userId,
        PasswordChangeRequest(
          currentPassword: _currentPassword,
          newPassword: _newPassword,
        ),
      );
      _success = true;
      _isSaving = false;
      // Wipe the password fields so they don't linger in memory.
      _currentPassword = '';
      _newPassword = '';
      _confirmPassword = '';
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.statusCode == 401
          ? 'La contraseña actual es incorrecta.'
          : e.message;
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'No se pudo cambiar la contraseña.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}

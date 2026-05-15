import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/profile_update_request.dart';
import '../../domain/usecases/settings_usecases.dart';

/// State holder for the Edit Profile form.
class EditProfileController extends ChangeNotifier {
  EditProfileController({
    required this.userId,
    required this.initialFirstName,
    required this.initialLastName,
    SettingsRepository? repository,
  })  : _repository = repository ?? SettingsRepositoryImpl(),
        _firstName = initialFirstName,
        _lastName = initialLastName {
    _updateProfile = UpdateProfileUseCase(_repository);
  }

  final int userId;
  final String initialFirstName;
  final String initialLastName;
  final SettingsRepository _repository;
  late final UpdateProfileUseCase _updateProfile;

  String _firstName;
  String _lastName;
  String get firstName => _firstName;
  String get lastName => _lastName;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserEntity? _updatedUser;
  UserEntity? get updatedUser => _updatedUser;

  bool get isDirty =>
      _firstName.trim() != initialFirstName ||
      _lastName.trim() != initialLastName;

  bool get isValid =>
      _firstName.trim().isNotEmpty && _lastName.trim().isNotEmpty;

  void setFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  /// Returns true if the profile was saved successfully.
  /// On success, [updatedUser] holds the fresh [UserEntity] returned by the
  /// backend so the caller can sync it with [AuthController].
  Future<bool> save() async {
    if (!isValid || !isDirty) return false;

    _isSaving = true;
    _errorMessage = null;
    _updatedUser = null;
    notifyListeners();

    try {
      _updatedUser = await _updateProfile.execute(
        userId,
        ProfileUpdateRequest(
          firstName: _firstName.trim(),
          lastName: _lastName.trim(),
        ),
      );
      _isSaving = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'No se pudo guardar el perfil.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}

import '../../../auth/domain/entities/user_entity.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../entities/password_change_request.dart';
import '../entities/profile_update_request.dart';

class UpdateProfileUseCase {
  UpdateProfileUseCase(this.repository);
  final SettingsRepository repository;

  Future<UserEntity> execute(int userId, ProfileUpdateRequest request) =>
      repository.updateProfile(userId, request);
}

class ChangePasswordUseCase {
  ChangePasswordUseCase(this.repository);
  final SettingsRepository repository;

  Future<void> execute(int userId, PasswordChangeRequest request) =>
      repository.changePassword(userId, request);
}

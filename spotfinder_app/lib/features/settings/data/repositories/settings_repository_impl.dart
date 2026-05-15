import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/password_change_request.dart';
import '../../domain/entities/profile_update_request.dart';

/// Anything the Settings feature reads/writes against the backend.
abstract class SettingsRepository {
  /// `PUT /api/v1/users/{userId}` — update first/last name. Returns the
  /// refreshed [UserEntity] so the controller can update the AuthController.
  Future<UserEntity> updateProfile(int userId, ProfileUpdateRequest request);

  /// `POST /api/v1/users/{userId}/change-password`. Returns nothing on 204.
  /// Throws [ApiException] with code 401 if the current password is wrong.
  Future<void> changePassword(int userId, PasswordChangeRequest request);
}

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({ApiClient? api}) : _api = api ?? ApiClient();
  final ApiClient _api;

  @override
  Future<UserEntity> updateProfile(int userId, ProfileUpdateRequest request) async {
    final response = await _api.put<Map<String, dynamic>>(
      '/api/v1/users/$userId',
      body: {
        'firstName': request.firstName,
        'lastName': request.lastName,
      },
    );
    final data = response.data;
    if (data == null) {
      throw ApiException(statusCode: 500, message: 'Respuesta vacía del servidor');
    }
    return UserModel.fromJson(data);
  }

  @override
  Future<void> changePassword(int userId, PasswordChangeRequest request) async {
    await _api.post<void>(
      '/api/v1/users/$userId/change-password',
      body: {
        'currentPassword': request.currentPassword,
        'newPassword': request.newPassword,
      },
    );
  }
}

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Domain-facing contract. Hides HTTP details from the UI.
abstract class AuthRepository {
  /// POST /api/v1/users/signin → returns the authenticated user.
  /// Side effect: stores JWT + minimal user fields in secure storage.
  Future<UserEntity> login(String email, String password);

  /// POST /api/v1/users/signup → returns nothing on success (201).
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String requestedRole, // ADMIN or CAR_OWNER
  });

  /// Clear the persisted session.
  Future<void> logout();

  /// True if a JWT is already persisted.
  Future<bool> hasSession();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({ApiClient? api, TokenStorage? storage})
      : _api = api ?? ApiClient(),
        _storage = storage ?? TokenStorage();

  final ApiClient _api;
  final TokenStorage _storage;

  @override
  Future<UserEntity> login(String email, String password) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/api/v1/users/signin',
      body: {'email': email.trim(), 'password': password},
    );
    final data = response.data;
    if (data == null) {
      throw ApiException(statusCode: 500, message: 'Respuesta vacía del servidor');
    }

    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException(statusCode: 500, message: 'Token no recibido');
    }

    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw ApiException(statusCode: 500, message: 'Usuario no recibido');
    }

    final user = UserModel.fromJson(userJson);
    await _storage.saveSession(
      token: token,
      userId: user.id,
      email: user.email,
      roles: user.roles,
    );
    return user;
  }

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String requestedRole,
  }) async {
    await _api.post<dynamic>(
      '/api/v1/users/signup',
      body: {
        'email': email.trim(),
        'password': password,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'requestedRole': requestedRole,
      },
    );
  }

  @override
  Future<void> logout() => _storage.clear();

  @override
  Future<bool> hasSession() => _storage.hasSession();
}

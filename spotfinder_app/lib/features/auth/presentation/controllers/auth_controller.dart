import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

/// Holds the authentication state shared across screens.
/// Notifies listeners on every change so widgets rebuild via `Provider`.
class AuthController extends ChangeNotifier {
  AuthController({AuthRepository? repository})
      : _repository = repository ?? AuthRepositoryImpl() {
    _loginUseCase = LoginUseCase(_repository);
    _registerUseCase = RegisterUseCase(_repository);
  }

  final AuthRepository _repository;
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserEntity? _user;
  UserEntity? get user => _user;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _user = await _loginUseCase.execute(email, password);
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado. Intenta de nuevo.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String requestedRole,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _registerUseCase.execute(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        requestedRole: requestedRole,
      );
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado. Intenta de nuevo.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }

  /// Replace the cached user (e.g. after an Edit-Profile success) so every
  /// screen that watches AuthController reflects the new name immediately.
  void updateCachedUser(UserEntity user) {
    _user = user;
    notifyListeners();
  }

  Future<bool> hasSession() => _repository.hasSession();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

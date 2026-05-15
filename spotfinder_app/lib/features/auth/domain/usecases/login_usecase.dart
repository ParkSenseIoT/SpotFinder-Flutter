import '../entities/user_entity.dart';
import '../../data/repositories/auth_repository_impl.dart';

class LoginUseCase {
  LoginUseCase(this.repository);
  final AuthRepository repository;

  Future<UserEntity> execute(String email, String password) {
    return repository.login(email, password);
  }
}

class RegisterUseCase {
  RegisterUseCase(this.repository);
  final AuthRepository repository;

  Future<void> execute({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String requestedRole,
  }) {
    return repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      requestedRole: requestedRole,
    );
  }
}

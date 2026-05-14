import '../entities/user_entity.dart';
import '../../data/repositories/auth_repository_impl.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> execute(String email, String password) async {
    // Aquí se pueden agregar validaciones de formato antes de llamar al repo
    return await repository.login(email, password);
  }
}
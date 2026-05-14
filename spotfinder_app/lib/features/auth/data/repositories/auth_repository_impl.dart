import '../../domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> register(String name, String email, String phone);
}

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserEntity> login(String email, String password) async {
    // Lógica de conexión con API SpotFinder
    throw UnimplementedError();
  }

  @override
  Future<void> register(String name, String email, String phone) async {
    // Lógica de registro
  }
}
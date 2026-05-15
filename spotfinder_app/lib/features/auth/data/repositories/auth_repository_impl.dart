import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/dio_exception_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../dtos/sign_in_request_dto.dart';
import '../dtos/sign_up_request_dto.dart';
import '../mappers/user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SessionStorage sessionStorage,
  })  : _remote = remoteDataSource,
        _storage = sessionStorage;

  final AuthRemoteDataSource _remote;
  final SessionStorage _storage;

  @override
  Future<Either<Failure, AuthenticatedUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remote.signIn(SignInRequestDto(email: email, password: password));
      final user = UserMapper.fromSignInResponse(dto);
      await _storage.saveToken(user.token);
      await _storage.saveUserId(user.id);
      await _storage.saveUserEmail(user.email);
      return Right(user);
    } on DioException catch (e) {
      return Left(DioExceptionMapper.map(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String requestedRole,
  }) async {
    try {
      await _remote.signUp(SignUpRequestDto(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        requestedRole: requestedRole,
      ));
      return const Right(unit);
    } on DioException catch (e) {
      return Left(DioExceptionMapper.map(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _storage.clear();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthenticatedUser?>> restoreSession() async {
    try {
      final token = await _storage.readToken();
      final userId = await _storage.readUserId();
      final email = await _storage.readUserEmail();
      if (token == null || userId == null || email == null) {
        return const Right(null);
      }
      return Right(AuthenticatedUser(
        id: userId,
        email: email,
        firstName: '',
        lastName: '',
        roles: const [],
        token: token,
      ));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

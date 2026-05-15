import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/authenticated_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthenticatedUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String requestedRole,
  });

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, AuthenticatedUser?>> restoreSession();
}

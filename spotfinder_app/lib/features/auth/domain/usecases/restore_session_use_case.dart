import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/authenticated_user.dart';
import '../repositories/auth_repository.dart';

class RestoreSessionUseCase implements UseCase<AuthenticatedUser?, NoParams> {
  RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthenticatedUser?>> call(NoParams params) =>
      _repository.restoreSession();
}

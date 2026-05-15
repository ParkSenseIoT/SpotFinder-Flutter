import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/authenticated_user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase implements UseCase<AuthenticatedUser, SignInParams> {
  SignInUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthenticatedUser>> call(SignInParams params) {
    return _repository.signIn(email: params.email, password: params.password);
  }
}

class SignInParams extends Equatable {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

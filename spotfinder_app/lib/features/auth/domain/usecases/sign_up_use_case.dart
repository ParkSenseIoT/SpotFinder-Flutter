import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<Unit, SignUpParams> {
  SignUpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SignUpParams params) {
    return _repository.signUp(
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
      requestedRole: params.requestedRole,
    );
  }
}

class SignUpParams extends Equatable {
  const SignUpParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.requestedRole = 'CAR_OWNER',
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String requestedRole;

  @override
  List<Object?> get props => [email, password, firstName, lastName, requestedRole];
}

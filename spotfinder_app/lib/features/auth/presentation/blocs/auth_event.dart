import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSessionRestoreRequested extends AuthEvent {
  const AuthSessionRestoreRequested();
}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
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

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

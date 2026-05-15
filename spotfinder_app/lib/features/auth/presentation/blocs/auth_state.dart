import 'package:equatable/equatable.dart';

import '../../domain/entities/authenticated_user.dart';

enum AuthStatus { unknown, unauthenticated, authenticating, authenticated, registering, registered, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthenticatedUser? user;
  final String? errorMessage;

  const AuthState.unknown() : this();

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  const AuthState.authenticating() : this(status: AuthStatus.authenticating);

  const AuthState.authenticated(AuthenticatedUser user)
      : this(status: AuthStatus.authenticated, user: user);

  const AuthState.registering() : this(status: AuthStatus.registering);

  const AuthState.registered() : this(status: AuthStatus.registered);

  const AuthState.failure(String message)
      : this(status: AuthStatus.failure, errorMessage: message);

  AuthState copyWith({
    AuthStatus? status,
    AuthenticatedUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

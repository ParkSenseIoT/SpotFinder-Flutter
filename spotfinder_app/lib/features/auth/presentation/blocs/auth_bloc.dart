import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/use_case.dart';
import '../../domain/usecases/restore_session_use_case.dart';
import '../../domain/usecases/sign_in_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignInUseCase signIn,
    required SignUpUseCase signUp,
    required SignOutUseCase signOut,
    required RestoreSessionUseCase restoreSession,
  })  : _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _restoreSession = restoreSession,
        super(const AuthState.unknown()) {
    on<AuthSessionRestoreRequested>(_onRestore);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
  }

  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignOutUseCase _signOut;
  final RestoreSessionUseCase _restoreSession;

  Future<void> _onRestore(AuthSessionRestoreRequested event, Emitter<AuthState> emit) async {
    final result = await _restoreSession(const NoParams());
    result.fold(
      (_) => emit(const AuthState.unauthenticated()),
      (user) => user == null
          ? emit(const AuthState.unauthenticated())
          : emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignIn(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());
    final result = await _signIn(SignInParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthState.failure(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignUp(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.registering());
    final result = await _signUp(SignUpParams(
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
      requestedRole: event.requestedRole,
    ));
    result.fold(
      (failure) => emit(AuthState.failure(failure.message)),
      (_) => emit(const AuthState.registered()),
    );
  }

  Future<void> _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _signOut(const NoParams());
    emit(const AuthState.unauthenticated());
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/calculate_fee_use_case.dart';
import '../../../domain/usecases/end_session_use_case.dart';
import '../../../domain/usecases/get_active_session_use_case.dart';
import 'active_session_event.dart';
import 'active_session_state.dart';

class ActiveSessionBloc extends Bloc<ActiveSessionEvent, ActiveSessionState> {
  ActiveSessionBloc({
    required GetActiveSessionUseCase getActiveSession,
    required CalculateFeeUseCase calculateFee,
    required EndSessionUseCase endSession,
  })  : _getActiveSession = getActiveSession,
        _calculateFee = calculateFee,
        _endSession = endSession,
        super(const ActiveSessionState()) {
    on<ActiveSessionRequested>(_onRequested);
    on<ActiveSessionRefreshRequested>(_onRefreshRequested);
    on<ActiveSessionFeeRefreshRequested>(_onFeeRefreshRequested);
    on<ActiveSessionEndRequested>(_onEndRequested);
    on<ActiveSessionCleared>(_onCleared);
  }

  final GetActiveSessionUseCase _getActiveSession;
  final CalculateFeeUseCase _calculateFee;
  final EndSessionUseCase _endSession;

  Future<void> _onRequested(ActiveSessionRequested event, Emitter<ActiveSessionState> emit) async {
    emit(state.copyWith(status: ActiveSessionStatus.loading, clearError: true));
    await _loadSession(event.userId, emit);
  }

  Future<void> _onRefreshRequested(
    ActiveSessionRefreshRequested event,
    Emitter<ActiveSessionState> emit,
  ) async {
    await _loadSession(event.userId, emit);
  }

  Future<void> _loadSession(int userId, Emitter<ActiveSessionState> emit) async {
    final result = await _getActiveSession(userId);
    await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: ActiveSessionStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (session) async {
        if (session == null) {
          emit(const ActiveSessionState(status: ActiveSessionStatus.empty));
          return;
        }
        emit(state.copyWith(
          status: ActiveSessionStatus.success,
          session: session,
          clearError: true,
        ));
        await _refreshFee(session.id, emit);
      },
    );
  }

  Future<void> _onFeeRefreshRequested(
    ActiveSessionFeeRefreshRequested event,
    Emitter<ActiveSessionState> emit,
  ) async {
    final session = state.session;
    if (session == null) return;
    await _refreshFee(session.id, emit);
  }

  Future<void> _refreshFee(int sessionId, Emitter<ActiveSessionState> emit) async {
    final result = await _calculateFee(sessionId);
    result.fold(
      (_) => null,
      (fee) => emit(state.copyWith(fee: fee)),
    );
  }

  Future<void> _onEndRequested(
    ActiveSessionEndRequested event,
    Emitter<ActiveSessionState> emit,
  ) async {
    final session = state.session;
    if (session == null) return;
    emit(state.copyWith(status: ActiveSessionStatus.ending));
    final result = await _endSession(session.id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ActiveSessionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(const ActiveSessionState(status: ActiveSessionStatus.ended)),
    );
  }

  void _onCleared(ActiveSessionCleared event, Emitter<ActiveSessionState> emit) {
    emit(const ActiveSessionState());
  }
}

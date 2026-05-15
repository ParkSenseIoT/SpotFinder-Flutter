import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/calculate_fee_use_case.dart';
import '../../../domain/usecases/end_session_use_case.dart';
import '../../../domain/usecases/get_session_by_id_use_case.dart';
import '../../../domain/value_objects/session_status.dart';
import 'session_detail_event.dart';
import 'session_detail_state.dart';

class SessionDetailBloc extends Bloc<SessionDetailEvent, SessionDetailState> {
  SessionDetailBloc({
    required GetSessionByIdUseCase getSessionById,
    required CalculateFeeUseCase calculateFee,
    required EndSessionUseCase endSession,
  })  : _getSessionById = getSessionById,
        _calculateFee = calculateFee,
        _endSession = endSession,
        super(const SessionDetailState()) {
    on<SessionDetailRequested>(_onRequested);
    on<SessionDetailEndRequested>(_onEndRequested);
  }

  final GetSessionByIdUseCase _getSessionById;
  final CalculateFeeUseCase _calculateFee;
  final EndSessionUseCase _endSession;

  Future<void> _onRequested(
    SessionDetailRequested event,
    Emitter<SessionDetailState> emit,
  ) async {
    emit(const SessionDetailState(status: SessionDetailStatus.loading));
    final result = await _getSessionById(event.sessionId);
    await result.fold(
      (failure) async => emit(SessionDetailState(
        status: SessionDetailStatus.failure,
        errorMessage: failure.message,
      )),
      (session) async {
        emit(SessionDetailState(
          status: SessionDetailStatus.success,
          session: session,
        ));
        if (session.sessionStatus == SessionStatus.active) {
          final feeResult = await _calculateFee(session.id);
          feeResult.fold(
            (_) => null,
            (fee) => emit(state.copyWith(fee: fee)),
          );
        }
      },
    );
  }

  Future<void> _onEndRequested(
    SessionDetailEndRequested event,
    Emitter<SessionDetailState> emit,
  ) async {
    final session = state.session;
    if (session == null) return;
    emit(state.copyWith(status: SessionDetailStatus.ending));
    final result = await _endSession(session.id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SessionDetailStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: SessionDetailStatus.ended)),
    );
  }
}

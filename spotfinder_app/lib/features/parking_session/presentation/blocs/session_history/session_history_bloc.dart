import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_session_history_use_case.dart';
import 'session_history_event.dart';
import 'session_history_state.dart';

class SessionHistoryBloc extends Bloc<SessionHistoryEvent, SessionHistoryState> {
  SessionHistoryBloc({required GetSessionHistoryUseCase getSessionHistory})
      : _getSessionHistory = getSessionHistory,
        super(const SessionHistoryState()) {
    on<SessionHistoryRequested>(_onRequested);
  }

  final GetSessionHistoryUseCase _getSessionHistory;

  Future<void> _onRequested(
    SessionHistoryRequested event,
    Emitter<SessionHistoryState> emit,
  ) async {
    emit(state.copyWith(status: SessionHistoryStatus.loading));
    final result = await _getSessionHistory(event.userId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SessionHistoryStatus.failure,
        errorMessage: failure.message,
      )),
      (sessions) => emit(SessionHistoryState(
        status: SessionHistoryStatus.success,
        sessions: sessions,
      )),
    );
  }
}

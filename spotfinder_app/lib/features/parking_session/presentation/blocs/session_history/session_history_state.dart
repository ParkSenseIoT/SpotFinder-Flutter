import 'package:equatable/equatable.dart';

import '../../../domain/entities/parking_session.dart';

enum SessionHistoryStatus { initial, loading, success, failure }

class SessionHistoryState extends Equatable {
  const SessionHistoryState({
    this.status = SessionHistoryStatus.initial,
    this.sessions = const [],
    this.errorMessage,
  });

  final SessionHistoryStatus status;
  final List<ParkingSession> sessions;
  final String? errorMessage;

  SessionHistoryState copyWith({
    SessionHistoryStatus? status,
    List<ParkingSession>? sessions,
    String? errorMessage,
  }) {
    return SessionHistoryState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, sessions, errorMessage];
}

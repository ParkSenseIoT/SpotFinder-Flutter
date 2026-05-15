import 'package:equatable/equatable.dart';

abstract class SessionDetailEvent extends Equatable {
  const SessionDetailEvent();

  @override
  List<Object?> get props => [];
}

class SessionDetailRequested extends SessionDetailEvent {
  const SessionDetailRequested(this.sessionId);

  final int sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class SessionDetailEndRequested extends SessionDetailEvent {
  const SessionDetailEndRequested();
}

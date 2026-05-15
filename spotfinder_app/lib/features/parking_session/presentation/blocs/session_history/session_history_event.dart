import 'package:equatable/equatable.dart';

abstract class SessionHistoryEvent extends Equatable {
  const SessionHistoryEvent();

  @override
  List<Object?> get props => [];
}

class SessionHistoryRequested extends SessionHistoryEvent {
  const SessionHistoryRequested(this.userId);

  final int userId;

  @override
  List<Object?> get props => [userId];
}

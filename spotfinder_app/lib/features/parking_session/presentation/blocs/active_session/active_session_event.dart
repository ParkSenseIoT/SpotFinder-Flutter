import 'package:equatable/equatable.dart';

abstract class ActiveSessionEvent extends Equatable {
  const ActiveSessionEvent();

  @override
  List<Object?> get props => [];
}

class ActiveSessionRequested extends ActiveSessionEvent {
  const ActiveSessionRequested(this.userId);

  final int userId;

  @override
  List<Object?> get props => [userId];
}

class ActiveSessionRefreshRequested extends ActiveSessionEvent {
  const ActiveSessionRefreshRequested(this.userId);

  final int userId;

  @override
  List<Object?> get props => [userId];
}

class ActiveSessionFeeRefreshRequested extends ActiveSessionEvent {
  const ActiveSessionFeeRefreshRequested();
}

class ActiveSessionEndRequested extends ActiveSessionEvent {
  const ActiveSessionEndRequested();
}

class ActiveSessionCleared extends ActiveSessionEvent {
  const ActiveSessionCleared();
}

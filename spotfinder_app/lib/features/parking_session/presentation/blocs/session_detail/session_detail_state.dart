import 'package:equatable/equatable.dart';

import '../../../domain/entities/parking_fee.dart';
import '../../../domain/entities/parking_session.dart';

enum SessionDetailStatus { initial, loading, success, failure, ending, ended }

class SessionDetailState extends Equatable {
  const SessionDetailState({
    this.status = SessionDetailStatus.initial,
    this.session,
    this.fee,
    this.errorMessage,
  });

  final SessionDetailStatus status;
  final ParkingSession? session;
  final ParkingFee? fee;
  final String? errorMessage;

  SessionDetailState copyWith({
    SessionDetailStatus? status,
    ParkingSession? session,
    ParkingFee? fee,
    String? errorMessage,
  }) {
    return SessionDetailState(
      status: status ?? this.status,
      session: session ?? this.session,
      fee: fee ?? this.fee,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, session, fee, errorMessage];
}
